#!/bin/bash

echo "INSTALL JAVA"

asdf plugin-add java
asdf install java openjdk-22 # or latest version
asdf global java openjdk-22 

. ~/.asdf/plugins/java/set-java-home.zsh # set JAVA_HOME

echo "INSTALL ANDROID STUDIO"

sudo snap install android-studio --classic

