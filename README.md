# Coffeetable

Coffeetable is a high-performance media file sharing platform based on OpenResty.

See more details in the [Solution Architecture Document](docs/architecture.md).

## Deployment

The repository contains a `docker-compose.yaml` which can be used as a blueprint for deploying the application.

## Set up for local development

As SSL is used for local development too, first of all, you need to add all `.crt` files from the `.docker/certs` directory to your trusted root certification authorities.

Next, you need to add the following lines to your `hosts` file so your computer can resolve these hostnames:

```
127.0.0.1 coffeetable.app
127.0.0.1 auth.coffeetable.app
127.0.0.1 media.coffeetable.app
127.0.0.1 media-api
```

Now you can run the stack:

```sh
$ docker-compose up -d
```

Then you can go to https://coffeetable.app, and log in. There are two predefined users:

* uploader (password: uploader)
* viewer (password: viewer)
