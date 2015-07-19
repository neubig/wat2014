#!/bin/bash
set -e

CORES=`nproc`
WD=`pwd`

# Install desired packages

TD=$WD/tools

mkdir -p $TD/download

################### Language Independent Tools ############################

# Install GIZA++

if [[ ! -e $TD/giza-pp ]]; then
    wget -P $TD https://giza-pp.googlecode.com/files/giza-pp-v1.0.7.tar.gz
    cd $TD
    tar -xzf $TD/giza-pp-v1.0.7.tar.gz
    cd $TD/giza-pp
    make -j $CORES
    cp GIZA++-v2/GIZA++ GIZA++-v2/*.out mkcls-v2/mkcls .
fi

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
if [[ ! -e $TD/travatar ]]; then
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
    
    # Get chinese models (temporary)
    mkdir -p $TD/Ckylark/model
    cd $TD/Ckylark/model
    wget http://www.phontron.com/download/ckylark-ctb.tar.gz
    tar -xzf ckylark-ctb.tar.gz
    rm ckylark-ctb.tar.gz

    # Unzip models
    gunzip $TD/Ckylark/model/*.gz

fi

# Install KyTea
if [[ ! -e $TD/bin/kytea ]]; then
    git clone https://github.com/neubig/kytea.git $TD/kytea
    
    cd $TD/kytea
    gunzip data/model.bin.gz # Needs to unzip the models file before autoreconf
    autoreconf -i
    ./configure --prefix=$TD
    make -j $CORES 
    make install

    # Install the chinese model
    wget -P $TD/kytea/data http://www.phontron.com/kytea/download/model/ctb-0.4.0-5.mod.gz
    gunzip $TD/kytea/data/ctb-0.4.0-5.mod.gz

fi

# Install util-scirpts in ~/work/
if [[ ! -e $WD/work ]]; then
    git clone https://github.com/neubig/util-scripts.git $TD/util-scripts
fi
    

################### Finish #################################################

echo "Finished getting tools!"
