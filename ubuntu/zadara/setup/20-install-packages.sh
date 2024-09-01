#!/usr/bin/bash
set -e
sudo apt-get update -y
sudo apt-get install -y $(cat resources/apt-packages.list)
