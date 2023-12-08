#!/usr/bin/env bash

sudo apt-get update && sudo apt install -y apache2
sudo chmod 666 /var/www/html/index.html
sudo echo '<!DOCTYPE html><html><head><meta charset="UTF-8"><title>Apache service</title><link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css"><link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/10.7.2/styles/atom-one-dark.min.css"><script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/10.7.2/highlight.min.js"></script></head><body><header><nav class="navbar navbar-expand-lg navbar-light bg-light"><a class="navbar-brand" href="">Welcome to my APACHE service!</a></nav></header></body></html>' > /var/www/html/index.html
