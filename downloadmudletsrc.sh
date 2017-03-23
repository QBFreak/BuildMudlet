#!/bin/sh
cd ~/src

### Download Mudlet Sources

# Getting Mudlet
git clone https://github.com/Mudlet/Mudlet.git
cd Mudlet/src
git checkout release_30 
