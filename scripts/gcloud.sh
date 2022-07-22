#!/bin/bash

echo 'Install python'

asdf plugin add python
asdf install python 3.8.0
asdf global gcloud 3.8.0

echo 'Install gcloud'

asdf plugin add gcloud
asdf install gcloud latest
asdf global gcloud latest


# step configuring

# gcloud auth login

# gcloud config set project <<Cluster name>>

# gcloud container clusters get-credentials zubale-staging --region us-central1 --<<cluster name>>

