# Solution Architecture Document

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**

- [Introduction](#introduction)
  - [Goals](#goals)
  - [Definitions, acronyms, abbreviations](#definitions-acronyms-abbreviations)
- [High-level requirements](#high-level-requirements)
  - [Information Architecture Overview](#information-architecture-overview)
- [Technology choices](#technology-choices)
  - [OpenResty](#openresty)
  - [PostgreSQL and Postgrest](#postgresql-and-postgrest)
  - [Keycloak](#keycloak)
- [Solution architecture overview](#solution-architecture-overview)
  - [System context](#system-context)
    - [Keycloak](#keycloak-1)
    - [File system](#file-system)
    - [exiftool](#exiftool)
  - [System components](#system-components)
    - [Web Application](#web-application)
    - [Media API](#media-api)
    - [Media Resource Server](#media-resource-server)
    - [Gateway](#gateway)
    - [Single-Page Application](#single-page-application)
  - [Data model](#data-model)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Introduction

This project came from the frustration that none of the existing solutions was completely suitable for sharing personal media files (photos and videos) within the family. Either the UX or privacy concerns, or simply too slow when self-hosted on a Raspberry Pi.

### Goals

Provide means to upload, organize, and share personal photos and videos between family members.

The solution should work with acceptable performance on a Raspberry Pi.

### Definitions, acronyms, abbreviations

Abbreviation/acronym | Description
-------------------- |------------
OIDC                 | OpenID Connect (see [specifications](https://openid.net/connect/) )
UMA                  | User-Managed Access (see [UMA FAQ](https://kantarainitiative.org/confluence/display/uma/UMA+FAQ))
2FA                  | Two-factor authentication
Exif                 | Exchangeable image file format
SPA                  | Single-Page Application

## High-level requirements

Users with viewing privileges only must be able to:

* View contents of the albums shared with them

Users who are authorized to do uploads have the same privileges as viewers plus they must be able to:

* Upload photos and videos
* View uploaded media files ordered by either date taken or date uploaded
* View uploaded media files without grouping or grouped by date ("Daily", "Monthly" view) or grouped by location
* Remove media from Photostream (/w trashbin functionality)
* Create albums and add media from their Photostream
* Remove media files from albums
* Contribute to albums shared with them if album editing was permitted
* Change the order media is shown in an album
* Select cover photo for the album
* Edit album title

### Information Architecture Overview

![Information Architecture Diagram](images/ia.png)

The users land on their *Photostream* page. On this page by default, they see all their photos ordered by *Date Taken* and in a *Daily* grouping. They can change the sorting to sort by *Date uploaded* and the grouping to *Monthly* or *Location*-based grouping or turn off grouping completely to simply show a continuous stream.

They can initiate file upload where they can select multiple media files present on the device and send them to the Web Application for processing.

For the MVP the sharing part is managed partially with Keycloak: we rely on Keycloak's UMA interface for sharing albums with other users. Creating, listing, and editing albums will be part of the Single-Page Application functionality.

## Technology choices

### OpenResty

As performance is a key factor the motivation was to pick a middleware with the least possible overhead. OpenResty is based on the highly performant Nginx server so it seems to be a reasonable choice. This was the first technical choice made, rest is built around.

### PostgreSQL and Postgrest

PostgreSQL is a leading DB on its own, but with Postgrest it really shines in this context. This setup makes it possible to not just easily store data, but Postgrest provides the means to easily run relatively complex queries using a REST API. These endpoints can be exposed (in a restricted way) to the client, so the Single-Page Application can retrieve data filtered, grouped, and paginated without the need to introduce any code to do so.

### Keycloak

Keycloak is a pretty standard solution to manage user authentication and authorization. For the authentication part, it supports OIDC, and this way it can be used easily with OpenResty (thanks to the `lua-resty-openidc` package), and Postgrest supports JWTs out of the box.

For the authorization User-Managed Access (UMA for short) is a standard gaining more and more popularity as it provides full privacy visibility and control for the users over their resources. As Keycloak implements UMA it can cover the authorization part completely.

## Solution architecture overview

### System context

![System Context Diagram](images/system_context.png)

#### Keycloak

Keycloak's responsibilities are:

* Authenticating users
* Validating tokens on requests from OpenResty and Postgrest
* Validate requests for media files if the current user can access them
* Provides information about owned and shared albums to OpenResty
* Providing means for users to share albums (MVP is just using the built-in UI, later either the UI can be themed or we can go with a fully customized UI and use only the API provided by Keycloak)

#### File system

This is where media files are stored. Theoretically, they could be stored directly in the database, but that would increase the DB dump size greatly, which would be using too much space in this case unnecessarily - there are better solutions to backup files without this kind of disk space consumption like for example syncing folder contents to a versioned S3 bucket on AWS.

#### exiftool

A command-line tool that is used to extract metadata from media files. This data (after some normalization) will be stored in the database.

### System components

![Container Diagram](images/container.png)

#### Web Application

Serves all the static assets related to the Single-Page Application.

![Component Diagram for the Web Application](images/web_application_component.png)

Manages media uploads: handles the physical file upload, extracts metadata using the `exiftool`, moves the uploaded file to the user's folder on the File System, stores metadata in the DB using the Media API.

![Dynamic Diagram for media upload](images/upload.png)

Provides restricted access to the Media API so the Single-Page Application can run queries for media items.

If the UMA interfaces provided by Keycloak turns out to be not usable enough, the Web Application's responsibility will be to provide an appropriate API to the Single-Page Application for users to manage their own albums sharing.

#### Media API

Provides REST API over the DB for the Web Application. No direct access is possible from the Single-Page Application, these all must go through the Web Application, so the bearer token can be added to the Authentication header. The Media API, in turn, uses that token, checks the validity of the signature, and extracts user information from it so that it can be used in the database (e.g. determine if the owner of a given media is issuing a query or not, setting the owner field on new media entry creation, etc.).

#### Media Resource Server

Serves uploaded media files to the Single-Page Application after checking the downloading user's permissions first with Keycloak.

#### Gateway

All requests to the internal services are going through the Gateway. It also proxies application related requests (from the SPA) to the Web Application, and media file requests to the Media Resource Server but before doing so it enforces authentication using Keycloak - for that it directly proxies all auth requests to the Keycloak instance. For all proxied requests it attaches an `Authentication` header with the access token as bearer token so the internal services can identify the users and access their roles.

#### Single-Page Application

Provides UI to the end-user to see their own photos sorted and grouped as they choose, and to see albums shared with them.

### Data model

![Logical Data Structure](images/logical_data_structure.png)

After uploading a media file the metadata will be extracted using the `exiftool`. This metadata goes through a normalization process where unusable information (e.g. filename, which is a temp name in this case) gets removed. The rest of the metadata will be saved with the media entry as `JSONB`. To make certain queries easier however, we store some important data as fields too - this makes it possible to easily sort and group the queried entries.
