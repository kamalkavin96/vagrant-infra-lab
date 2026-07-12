#!/bin/bash

set -e

echo "======================================"
echo " Ubuntu 24.04 VM Setup"
echo "======================================"

echo "Hostname:"
hostname

echo "Updating packages..."

apt-get update

echo "Installing basic tools..."

apt-get install -y \
    curl \
    wget \
    git \
    vim \
    nano \
    net-tools \
    iputils-ping \
    telnet \
    unzip \
    htop \
    mc

echo "======================================"
echo " Setup Completed"
echo "======================================"