#!/bin/bash

echo "Installing ASDF"
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.8.1

echo -e "\n. $HOME/.asdf/asdf.sh" >> ~/.zshrc

source ~/.zshrc

echo "ASDF installed!!"
echo $(asdf --version)

echo "Install ruby"

asdf plugin add ruby https://github.com/asdf-vm/asdf-ruby.git
asdf install ruby latest
asdf global ruby latest

echo "Install Erlang"

asdf plugin add erlang https://github.com/asdf-vm/asdf-erlang.git
asdf install erlang latest
asdf global erlang latest

cat <<EOT >> ~/.zshrc
export ERL_AFLAGS="-kernel shell_history enabled"
EOT

echo "Install Elixir"

asdf plugin-add elixir https://github.com/asdf-vm/asdf-elixir.git
asdf install elixir latest
asdf global elixir latest

echo "Install Nodejs"

asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
asdf install nodejs latest
asdf global nodejs latest

echo "Install python"

asdf plugin-add python
asdf install python latest
asdf global python latest

asdf install python 3.8.0
asdf global gcloud 3.8.0

# echo 'Install gcloud'

# asdf plugin add gcloud
# asdf install gcloud latest
# asdf global gcloud latest

# step configuring

# gcloud auth login
# Set the project with: gcloud config set project <<Cluster name>>
# Add the clusters: gcloud container clusters get-credentials  staging --region us-central1 --project <<Cluster name>>
# gcloud container clusters get-credentials  production --region us-central1 --project <<Cluster name>>
# install gke-loud-auth-plugin https://cloud.google.com/sdk/docs/install-sdk

# echo "Install Java"

# asdf plugin-add java
# asdf install java openjdk{version}
# asdf global java openjdk-{version}

# . ~/.asdf/plugins/java/set-java-home.zsh # set JAVA_HOME

# echo "Install kubectl"
# asdf plugin add kubectl
# asdf install kubectl latest
# asdf global kubectl latest

# echo "Install kubectx"
# asdf plugin add kubectx
# asdf install kubectx latest
# asdf global kubectx latest

# echo "Install k9s"
# asdf plugin add k9s
# asdf install k9s latest
# asdf global k9s latest

# echo 'Install helm'
# asdf plugin-add helm
# asdf install helm latest
# asdf global helm latest

# source ~/.zshrc
