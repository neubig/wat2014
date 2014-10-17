#!/bin/bash
set -e

CORES=`nproc`
WD=`pwd`

# Install desired packages

TD=$WD/tools

mkdir -p $TD/download

################### Language Independent Tools ############################

# Install Nile and its dependencies
if [[ ! -e $TD/nile ]]; then
 
    git clone https://github.com/neubig/nile.git $TD/nile
    # Install svector
    cd $TD/nile/svector
    python setup.py install --user
    # Install pyglog
    cd $TD/nile/pyglog
    python setup.py install --user

fi

if [[ ! -e $TD/nile/model ]]; then
    mkdir -p $TD/nile/model
    wget -P $TD/nile/model http://www.phontron.com/travatar/download/nile-en-ja.model
fi

# Install travatar
if [[ ! -e $TD/travatar/src/bin/travatar ]]; then
    git clone https://github.com/neubig/travatar.git $TD/travatar
    
    cd $TD/travatar
    autoreconf -i
    ./configure
    make -j $CORES 
fi

# Install Egret
if [[ ! -e $TD/egret ]]; then

    git clone https://github.com/neubig/egret.git $TD/egret 
    cd $TD/egret
    make -j $CORES 

fi

# Install Egret
if [[ ! -e $TD/Ckylark ]]; then

    git clone https://github.com/odashi/Ckylark.git $TD/Ckylark 
    cd $TD/Ckylark
    autoreconf -i
    ./configure
    make -j $CORES 

fi

# Install KyTea
if [[ ! -e $TD/bin/kytea ]]; then
    git clone https://github.com/neubig/kytea.git $TD/kytea
    
    cd $TD/kytea
    autoreconf -i
    ./configure --prefix=$TD
    make -j $CORES 
    make install
fi

################### Finish #################################################

echo "Finished getting tools!"
