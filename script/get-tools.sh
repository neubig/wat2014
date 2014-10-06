#!/bin/bash
set -e

CORES=`nproc`
WD=`pwd`


# Install desired packages
PACKAGES="git python libtool libboost-all-dev cython python-gflags libboost-mpi-python-dev openmpi-bin"
echo "Currently installing packages '$PACKAGES' if they don't already exist"
sudo apt-get install $PACKAGES

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

################### English Processing Tools ###############################

if [[ ! -e $TD/stanford-parser-full-2014-08-27 ]]; then

    wget -P $TD/download http://nlp.stanford.edu/software/stanford-parser-full-2014-08-27.zip
    cd $TD
    unzip download/stanford-parser-full-2014-08-27.zip

fi

################### Japanese Processing Tools ##############################

# Install KyTea
if [[ ! -e $TD/bin/kytea ]]; then
    git clone https://github.com/neubig/kytea.git $TD/kytea
    
    cd $TD/kytea
    autoreconf -i
    ./configure --prefix=$TD
    make -j $CORES 
    make install
fi

# Install Eda
if [[ ! -e $TD/eda-0.3.1/eda ]]; then
    mkdir -p $TD/download
    wget -P $TD/download http://plata.ar.media.kyoto-u.ac.jp/tool/EDA/downloads/eda-0.3.1.tar.gz
    cd $TD
    tar -xzf download/eda-0.3.1.tar.gz
    cd eda-0.3.1
    make -j $CORES
fi

################### Chinese Processing Tools ###############################

if [[ ! -e $TD/stanford-segmenter-2014-08-27 ]]; then
    wget -P $TD/download http://nlp.stanford.edu/software/stanford-segmenter-2014-08-27.zip
    sc $TD
    unzip download/stanford-segmenter-2014-08-27.zip
fi

################### Finish #################################################

echo "Finished getting tools!"
