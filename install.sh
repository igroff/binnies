#! /usr/bin/env bash

git clone https://github.com/igroff/binnies.git ~/binnies
if [ -f ~/.bashrc ]; then
  echo "PATH=~/binnies:${PATH}" >> ~/.bashrc
fi
