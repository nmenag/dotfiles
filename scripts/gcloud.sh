#!/bin/bash

echo "Install gcloud "

asdf plugin add gcloud
asdf install gcloud latest
asdf global gcloud latest

echo "configuring"

# gcloud auth login

# gcloud config set project <<Cluster name>>

# gcloud container clusters get-credentials zubale-staging --region us-central1 --<<cluster name>>

