---
layout: post
title: "Deploy a static web page using helm and trafik"
date: 2021-09-12 00:00:00 -0000
categories: kubernetes helm terraform IaaC
---
Deploy a static web page using helm and traefik

The purpose of this lab is to provision a static web page using *helm* and *traefik* as ingress entry point.

Main documentation for the lab is included here: [https://www.robertopaz.com.ar/deploy-using-helm/](https://www.robertopaz.com.ar/deploy-using-helm/)

You can clone the repository to get some of the files required for the lab: [https://github.com/rjrpaz/deploy-using-helm](https://github.com/rjrpaz/deploy-using-helm)

## Steps

1. Build your own Docker image that can serve a static “Hello World” HTML page

1. Deploy that image as a container in a Kubernetes cluster running locally on your machine using helm and writing your own chart

1. Deploy a Traefik container in the same local Kubernetes cluster using helm

1. Make Traefik an ingress point to access the “Hello World” page

1. Make the “Hello World” page accessible locally at `http://hello-world.local`

The whole process is automatized using *terraform*
