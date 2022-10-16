#!/usr/bin/env bash

cd ~ 

# clone the repository
git clone https://github.com/AleoHQ/snarkOS.git --depth 1 &&
cd snarkOS &&

# build for Ubuntu
bash ./build_ubuntu.sh
wait