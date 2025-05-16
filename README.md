# Citronics Lemon kernel images

This repository builds the .deb packages for relevant kernel versions to be used on the Lemon board by Citronics.

## Prerequisites

```
sudo apt-get update
sudo apt-get install -y build-essential libncurses-dev bison flex libssl-dev bc fakeroot git libelf-dev

# If you plan on cross compiling from x86 or amd64, then also install a gcc compiler for arm 
sudo apt install gcc-arm-linux-gnueabihf
```

## Building kernels

`sudo ./build-all-kernels.sh`