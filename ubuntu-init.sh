#!/bin/bash

sudo apt-get install xclip wget curl git gcc g++ make
sudo apt-get install ripgrep fzf fd-find 
sudo apt-get install python3 python3-pip python3-venv python3-neovim 

NODE_PATH=$(which node)
if [[ ! -z $NODE_PATH ]]; then
   sudo apt-get install nodejs npm 
fi

npm install -g neovim


