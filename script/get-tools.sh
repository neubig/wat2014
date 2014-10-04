#!/bin/bash
set -e

CORES=`nproc`
WD=`pwd`

# Install desired packages
PACKAGES="git libtool libboost-all-dev"
# echo "Currently installing packages '$PACKAGES' if they don't already exist"
# sudo apt-get install $PACKAGES

mkdir -p $WD/tools

# Install travatar
if [[ ! -e $WD/tools/travatar/src/bin/travatar ]]; then
    git clone https://github.com/neubig/travatar.git $WD/tools/travatar
    
    cd $WD/tools/travatar
    autoreconf -i
    ./configure
    make -j $CORES 
fi

################### Egret Parser ###########################################

# Install Egret
if [[ ! -e $WD/tools/egret ]]; then

    git clone https://github.com/neubig/egret.git $WD/tools/egret 
    cd $WD/tools/egret
    make -j $CORES 

fi

################### English Processing Tools ###############################

if [[ ! -e stanford-parser-full-2014-08-27 ]]; then

    wget -P $WD/tools/download http://nlp.stanford.edu/software/stanford-parser-full-2014-08-27.zip
    cd $WD/tools
    unzip download/stanford-parser-full-2014-08-27.zip

fi

################### Japanese Processing Tools ##############################

# Install KyTea
if [[ ! -e $WD/tools/bin/kytea ]]; then
    git clone https://github.com/neubig/kytea.git $WD/tools/kytea
    
    cd $WD/tools/kytea
    autoreconf -i
    ./configure --prefix=$WD/tools
    make -j $CORES 
    make install
fi

# Install Eda

if [[ ! -e $WD/tools/bin/eda ]]; then
    mkdir -p $WD/tools/download
    wget -P $WD/tools/download http://plata.ar.media.kyoto-u.ac.jp/tool/EDA/downloads/eda-0.3.1.tar.gz
    cd $WD/tools
    tar -xzf download/eda-0.3.1.tar.gz
    cd eda-0.3.1
    make -j $CORES
fi

################### Chinese Processing Tools ###############################
