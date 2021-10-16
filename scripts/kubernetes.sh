#!/bin/bash

echo "Install kubectl"
asdf plugin add kubectl
asdf install kubectl latest
asdf global kubectl latest

echo "Install kubectx"
asdf plugin add kubectx
asdf install kubectx latest
asdf global kubectx latest

echo "Install k9s"
asdf plugin add k9s
asdf install k9s latest
asdf global k9s latest
