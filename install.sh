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

echo 'Updating repositories...'
apt-get update > /dev/null

if ! hash curl 2>/dev/null; then
    echo 'Installing zsh wget git rake curl terminator acpi...'
    apt-get -y install apt-utils zsh wget git rake curl terminator acpi > /dev/null
    echo 'Installing default-jdk...'
    apt-get -y install default-jdk  > /dev/null
fi

# Install oh-my-zsh
if [ ! -d ~/.oh-my-zsh ]; then
    echo 'Installing oh-my-zsh...'
    wget -q https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh  -O ~/omzsh.sh
    ZSH=~/.oh-my-zsh
    chmod a+x ~/omzsh.sh
    (sh -c ~/omzsh.sh && rm ~/omzsh.sh) &
    sleep 5
fi

# Cloning dotfiles
if [ ! -d  $WORKSPACE/dotfiles ]; then
    echo 'Cloning and installing dotfiles from github...'
    git clone --quiet https://github.com/aboivin/dotfiles $WORKSPACE/dotfiles > /dev/null
    cd $WORKSPACE/dotfiles > /dev/null
    git remote remove origin > /dev/null
    git remote add origin git@github.com:aboivin/dotfiles.git > /dev/null
    rake "install[yes']" > /dev/null
    ln -s $WORKSPACE/dotfiles/zsh/plugins/oh-my-git ~/.oh-my-zsh/plugins/oh-my-git > /dev/null
    ln -s $WORKSPACE/dotfiles/zsh/themes/hckr.zsh-theme ~/.oh-my-zsh/themes/hckr.zsh-theme > /dev/null
fi

# Install z jumper
if [ ! -d  $SOFTWARE/z ]; then
    echo 'Installing z jumper...'
    mkdir $SOFTWARE/z > /dev/null
    wget -q https://raw.githubusercontent.com/rupa/z/master/z.sh -O $SOFTWARE/z/z.sh
    echo ". ~/software/z/z.sh" >> ~/.zshrc.custom > /dev/null
fi

# Install intellij
cd $SOFTWARE
    echo 'Installing Intellij Idea Ultimate...'
if ! ls -l | grep --quiet "idea"; then
    wget -q "https://download.jetbrains.com/product?code=IIU&latest&distribution=linux" -O $SOFTWARE/idea.tar.gz > /dev/null
    tar -xzvf $SOFTWARE/idea.tar.gz > /dev/null
    rm $SOFTWARE/idea.tar.gz > /dev/null
fi

# Install visual studio code
cd $SOFTWARE
if ! ls -l | grep --quiet "VSCode"; then
    echo 'Installing Visual studio code...'
    wget -q "https://go.microsoft.com/fwlink/?LinkID=620884" -O $SOFTWARE/VSCode.tar.gz
    tar -xzvf $SOFTWARE/VSCode.tar.gz > /dev/null
    rm $SOFTWARE/VSCode.tar.gz > /dev/null
fi

# Install maven
cd $SOFTWARE
if ! ls -l | grep --quiet "maven"; then
    echo 'Installing Maven...'
    wget -q "http://mirrors.standaloneinstaller.com/apache/maven/maven-3/3.6.0/source/apache-maven-3.6.0-src.tar.gz" -O $SOFTWARE/maven.tar.gz
    tar -xzvf $SOFTWARE/maven.tar.gz > /dev/null
    rm $SOFTWARE/maven.tar.gz
fi

# Installing docker
if ! hash docker 2>/dev/null; then
    echo 'Installing Docker...'
    apt-get -y install apt-transport-https ca-certificates curl software-properties-common > /dev/null
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
    apt-key fingerprint 0EBFCD88 > /dev/null
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /dev/null
    apt-get update > /dev/null
    apt-get -y install docker-ce > /dev/null
    groupadd docker > /dev/null
    usermod -aG docker $USER > /dev/null
fi

echo 'Done.'