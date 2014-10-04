#!/bin/bash

TRG=en
TRG3LET=eng
SPLIT_TRG='(-|\\\\/)'
if [[ $1 == "zh" ]]; then
    TRG=zh
    TRG3LET=chn
    SPLIT_TRG=
fi


WD=`pwd`
EDIR=/home/is/neubig/usr/local/Egret
TRAVDIR=/home/is/neubig/work/travatar
SRC=ja
ST=$SRC-$TRG
CORES=`nproc`

mkdir -p $ST/preproc log

# # ********* Training preprocessing *********
# echo "Preprocessing training data"
# nohup nice $TRAVDIR/script/preprocess/preprocess.pl -truecase-trg -split-words-trg "$SPLIT_TRG" -egret-src-model $EDIR/jpn_grammar -egret-trg-model $EDIR/${TRG3LET}_grammar -nile-gizatype union -nile-model /home/is/neubig/usr/local/nile/model/nile-$TRG-$SRC.model -nile-order trgsrc -align -threads 32 -clean-len 80 -align -src $SRC -trg $TRG $ST/data/train.$SRC $ST/data/train.$TRG `pwd`/$ST/preproc/train &> log/preproc-$ST-`hostname`.log
# 
# if [[ $2 == "nileonly" ]]; then
#     exit
# fi
# 
# # ********* Testing preprocessing *********
# for f in dev devtest test; do
#     nohup nice $TRAVDIR/script/preprocess/preprocess.pl -truecase-trg -truecase-trg-model ja-en/preproc/train/truecaser/en.truecaser -split-words-trg "$SPLIT_TRG" -egret-forest-opt "-nbest4threshold=500" -align -forest-src -forest-trg -egret-src-model $EDIR/jpn_grammar -egret-trg-model $EDIR/${TRG3LET}_grammar -threads 10 -src $SRC -trg $TRG $ST/data/$f.$SRC $ST/data/$f.$TRG `pwd`/$ST/preproc/$f &> log/preproc-$ST-$f-`hostname`.log &
# done
#  
# # ********* LM preprocessing *********
# mkdir -p lm/data
# for f in lm/raw/*.ja; do
#     if [[ ! -e lm/data/`basename $f` ]]; then
#         cat $f | sed 's/、/，/g;  s/（）//g; s/ //g' | ~/work/util-scripts/han2zen.pl --nospace | kytea -notags -wsconst D > lm/data/`basename $f`
#     fi
# done
# 
# for f in lm/raw/*.en; do
#     if [[ ! -e lm/data/`basename $f` ]]; then
#         echo $f
#         java -cp /home/is/neubig/usr/local/stanford-parser/stanford-parser.jar:/home/is/neubig/usr/local/stanford-parser/stanford-parser-models.jar edu.stanford.nlp.process.PTBTokenizer -preserveLines $f | sed "s/(/-LRB-/g; s/)/-RRB-/g; s/[     ]+/ /g; s/^ +//g; s/ +$//g" | ~/work/travatar/src/bin/tree-converter -input_format word -output_format word -split '(-|\\/)' | $TRAVDIR/script/recaser/truecase.pl --model ja-en/preproc/train/truecaser/en.truecaser > lm/data/`basename $f`
#     fi
# done
# 
# for f in lm/raw/*.zh; do
#     if [[ ! -e lm/data/`basename $f` ]]; then
#         echo $f
#         /home/is/neubig/usr/local/stanford-segmenter/segment.sh ctb $f UTF-8 0 | sed 's/（ *） *//g' | ~/work/util-scripts/han2zen.pl --nospace 2> /dev/null > lm/data/`basename $f`
#     fi
# done

# ********* LM training *********
ORDER=6
INDIR=p$ORDER
mkdir -p lm/model/$INDIR
for f in lm/data/*; do
    if [[ ! -e lm/model/$INDIR/`basename $f` ]]; then
        # echo "ngram-count -kndiscount -interpolate -order $ORDER -unk -text $f -lm lm/model/$ORDER/`basename $f`"
        # ngram-count -kndiscount -interpolate -order $ORDER -unk -text $f -lm lm/model/$ORDER/`basename $f`
        echo "$TRAVDIR/src/kenlm/lm/lmplz -o $ORDER -S 50% -T /tmp < $f > lm/model/$INDIR/`basename $f`"
        $TRAVDIR/src/kenlm/lm/lmplz -o $ORDER -S 50% -T /tmp < $f > lm/model/$INDIR/`basename $f`
    fi
done
 
# # ********* LM interpolation *********
ORDER=6
INDIR=p$ORDER
mkdir -p lm/interp/$INDIR
for OTHER in zh en; do
    mkdir -p lm/interp/$INDIR
    if [[ ! -e lm/interp/$INDIR/$OTHER-ja.arpa ]]; then
        /home/is/neubig/work/mosesdecoder/scripts/ems/support/interpolate-lm.perl --name lm/interp/$INDIR/$OTHER-ja.arpa --tuning ja-$OTHER/preproc/devtest/out/ja --lm `ls -m lm/model/$INDIR/*.ja | sed 's/ //g' | tr -d '\n'` --srilm /home/is/neubig/usr/local/srilm/bin/i686-m64
    fi
    if [[ ! -e lm/interp/$INDIR/ja-$OTHER.arpa ]]; then
        /home/is/neubig/work/mosesdecoder/scripts/ems/support/interpolate-lm.perl --name lm/interp/$INDIR/ja-$OTHER.arpa --tuning ja-$OTHER/preproc/devtest/out/$OTHER --lm `ls -m lm/model/$INDIR/*.$OTHER | sed 's/ //g' | tr -d '\n'` --srilm /home/is/neubig/usr/local/srilm/bin/i686-m64
    fi
done
 
# ********* LM binarization *********
ORDER=6
for f in lm/interp/*/*.arpa; do
    f1=${f/arpa/blm}
    if [[ ! -e $f1 ]]; then
        echo "$TRAVDIR/src/kenlm/lm/build_binary -i $f $f1"
        $TRAVDIR/src/kenlm/lm/build_binary -i $f $f1
    fi
done
