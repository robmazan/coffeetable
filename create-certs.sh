#!/bin/bash

openssl req -newkey rsa:2048 -x509 -nodes -keyout conf/selfsigned.app.key -new -out conf/selfsigned.app.crt -subj /CN=coffeetable.app -reqexts SAN -extensions SAN -config <(cat /etc/ssl/openssl.cnf <(printf '[SAN]\nsubjectAltName=DNS:coffeetable.app,IP:127.0.0.1')) -sha256 -days 3650
openssl req -newkey rsa:2048 -x509 -nodes -keyout conf/selfsigned.auth.key -new -out conf/selfsigned.auth.crt -subj /CN=auth.coffeetable.app -reqexts SAN -extensions SAN -config <(cat /etc/ssl/openssl.cnf <(printf '[SAN]\nsubjectAltName=DNS:auth.coffeetable.app,IP:127.0.0.1')) -sha256 -days 3650
openssl req -newkey rsa:2048 -x509 -nodes -keyout conf/selfsigned.media.key -new -out conf/selfsigned.media.crt -subj /CN=media.coffeetable.app -reqexts SAN -extensions SAN -config <(cat /etc/ssl/openssl.cnf <(printf '[SAN]\nsubjectAltName=DNS:media.coffeetable.app,IP:127.0.0.1')) -sha256 -days 3650

sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain conf/selfsigned.app.crt
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain conf/selfsigned.auth.crt
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain conf/selfsigned.media.crt
