
#!/bin/bash

echo "Configuration Git"

ssh-keygen -t ed25519 -C $(echo "$EMAIL")

eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
sudo apt-get install xclip
xclip -selection clipboard < ~/.ssh/id_ed25519.pub

$(git config --global user.name "$USERNAME")
$(git config --global user.email "$EMAIL")

cat <<EOT >> ~/.gitconfig

[color]
        status = auto
        branch = auto
        diff = auto
        interactive = auto
        ui = auto

[core]
        editor = nano -w

[color "branch"]
        current = yellow reverse
        local = yellow
        remote = green

[color "diff"]
        meta = yellow bold
        frag = magenta bold
        old = red bold
        new = green bold

[color "status"]
	added = yellow
	changed = green
	untracked = cyan

[alias]
        lg = log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit
EOT

echo "finished Git config"


## ADD SSH KEY 
# https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account?tool=webui

## NOTE:

# Create Personal Access Token on GitHub
# From your GitHub account, go to Settings => Developer Settings => Personal Access Token => Generate New Token (Give your password) => Fillup the form => click Generate token => Copy the generated Token, it will be something like ghp_sFhFsSHhTzMDreGRLjmks4Tzuzgthdvfsrta
# git config --global credential.helper cache
# restart the terminal

# clone the projects  via SSH instead HTTPS
# example git@github.com:nmenag/dotfiles.git
#

