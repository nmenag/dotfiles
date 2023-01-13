#!/bin/bash

echo "Install Java"

asdf plugin-add java
asdf install java openjdk-17
asdf global java openjdk-17

. ~/.asdf/plugins/java/set-java-home.zsh # set JAVA_HOME

source ~/.zshrc