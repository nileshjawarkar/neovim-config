#!/bin/bash

sudo dnf install xclip wget curl git gcc g++ make
sudo dnf install ripgrep fzf fd-find
sudo dnf install python3 python3-pip python3-virtualenv python3-neovim

NODE_PATH=$(which node)
if [[ -n $NODE_PATH ]]; then
    sudo dnf install nodejs nodejs-npm
fi

npm install -g neovim
