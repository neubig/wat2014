#!/bin/bash
set -e

if [[ $# != 1 ]]; then
    echo "Usage: $0 en/zh"
    exit 1;
fi
TRG=$1

WD=`pwd`
EDIR=$WD/tools/egret
KDIR=$WD/tools/kytea
CDIR=$WD/tools/Ckylark
TDIR=$WD/tools/travatar
NDIR=$WD/tools/nile
MDIR=$MD/tools/mosesdecoder
SDIR=$MD/tools/srilm
SRC=ja
CORES=`nproc`

# ********* Preprocess ja-en data *********
if [[ $TRG == "en" ]]; then
    echo "Preprocessing ja-en training data"
    SPLIT_TRG='(-|\\\\/)'
    TRG3LET=eng
    ST=$SRC-$TRG
    mkdir -p $ST/preproc log
    
    echo "$TDIR/script/preprocess/preprocess.pl -program-dir $WD/tools -truecase-trg -split-words-trg "$SPLIT_TRG" -egret-src-model $EDIR/jpn_grammar -egret-trg-model $EDIR/${TRG3LET}_grammar -nile-segments 40 -nile-gizatype union -nile-model $NDIR/model/nile-$TRG-$SRC.model -nile-order trgsrc -align -threads $CORES -clean-len 80 -src $SRC -trg $TRG $ST/data/train.$SRC $ST/data/train.$TRG $WD/$ST/preproc/train &> log/preproc-$ST-`hostname`.log"
    $TDIR/script/preprocess/preprocess.pl -program-dir $WD/tools -truecase-trg -split-words-trg "$SPLIT_TRG" -egret-src-model $EDIR/jpn_grammar -egret-trg-model $EDIR/${TRG3LET}_grammar -nile-segments 40 -nile-gizatype union -nile-model $NDIR/model/nile-$TRG-$SRC.model -nile-order trgsrc -align -threads $CORES -clean-len 80 -src $SRC -trg $TRG $ST/data/train.$SRC $ST/data/train.$TRG $WD/$ST/preproc/train &> log/preproc-$ST-`hostname`.log
    
    for f in dev devtest test; do
        $TDIR/script/preprocess/preprocess.pl -program-dir $WD/tools -truecase-trg -truecase-trg-model $ST/preproc/train/truecaser/en.truecaser -split-words-trg "$SPLIT_TRG" -egret-forest-opt "-nbest4threshold=500" -forest-src -forest-trg -egret-src-model $EDIR/jpn_grammar -egret-trg-model $EDIR/${TRG3LET}_grammar -threads $CORES -src $SRC -trg $TRG $ST/data/$f.$SRC $ST/data/$f.$TRG $WD/$ST/preproc/$f &> log/preproc-$ST-$f-`hostname`.log
    done
fi

# ********* Preprocess ja-zh data *********
if [[ $TRG == "zh" ]]; then
    echo "Preprocessing ja-zh training data"
    TRG3LET=chn
    ST=$SRC-$TRG
    mkdir -p $ST/preproc log
    
    echo "$TDIR/script/preprocess/preprocess.pl -program-dir $WD/tools -egret-src-model $EDIR/jpn_grammar -kytea-trg-model $KDIR/data/ctb-0.4.0-5.mod -ckylark-trg-model $CDIR/model/ctb -egret-trg-model $EDIR/${TRG3LET}_grammar -align -threads $CORES -clean-len 80 -src $SRC -trg $TRG $ST/data/train.$SRC $ST/data/train.$TRG $WD/$ST/preproc/train &> log/preproc-$ST-`hostname`.log"
    $TDIR/script/preprocess/preprocess.pl -program-dir $WD/tools -egret-src-model $EDIR/jpn_grammar -kytea-trg-model $KDIR/data/ctb-0.4.0-5.mod -ckylark-trg-model $CDIR/model/ctb -egret-trg-model $EDIR/${TRG3LET}_grammar -align -threads $CORES -clean-len 80 -src $SRC -trg $TRG $ST/data/train.$SRC $ST/data/train.$TRG $WD/$ST/preproc/train &> log/preproc-$ST-`hostname`.log
    
    for f in dev devtest test; do
        $TDIR/script/preprocess/preprocess.pl -program-dir $WD/tools -egret-forest-opt "-nbest4threshold=500" -forest-src -forest-trg -egret-src-model $EDIR/jpn_grammar -kytea-trg-model $KDIR/data/ctb-0.4.0-5.mod -ckylark-trg-model $CDIR/model/ctb -egret-trg-model $EDIR/${TRG3LET}_grammar -threads $CORES -src $SRC -trg $TRG $ST/data/$f.$SRC $ST/data/$f.$TRG $WD/$ST/preproc/$f &> log/preproc-$ST-$f-`hostname`.log
    done
fi

