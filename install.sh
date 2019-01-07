#!/usr/bin/env bash

set -o nounset
set -o errexit

echo 
echo "************************ SETUP *************************** "
echo 
echo "   This will install initial packages on this host "
echo "   and update repositories."
echo 
echo "********************************************************** "
echo 
read -p "Continue? (y/N) ==> " YES

if [[ "${YES}" != "Y" && "${YES}" != "y" ]];
then
    echo "Aborting."
    exit 0
fi

SOFTWARE=~/software
WORKSPACE=~/workspace

if [ ! -d $WORKSPACE ]; then
    mkdir $WORKSPACE
fi

if [ ! -d $SOFTWARE ]; then
    mkdir $SOFTWARE
fi

apt-get update

apt-get -y install terminator git zsh wget rake curl

# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# Cloning dotfiles
if [ ! -d  $WORKSPACE/dotfiles ]; then
    git clone https://github.com/aboivin/dotfiles $WORKSPACE/dotfiles
    cd $WORKSPACE/dotfiles
    git remote remove origin
    git remote add origin git@github.com:aboivin/dotfiles.git
    rake "install[yes']"
fi

# Install z jumper
if [ ! -d  $SOFTWARE/z ]; then
    mkdir $SOFTWARE/z
    wget https://raw.githubusercontent.com/rupa/z/master/z.sh $SOFTWARE/z
fi

# Install intellij
wget "https://download.jetbrains.com/product?code=IIU&latest&distribution=linux" $SOFTWARE/idea.tar.gz
tar -xzvf $SOFTWARE/idea.tar.gz $SOFTWARE


# Installing docker
apt-get -y install apt-transport-https ca-certificates curl software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

apt-key fingerprint 0EBFCD88

add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

apt-get update

apt-get -y install docker-ce

groupadd docker

usermod -aG docker $USER