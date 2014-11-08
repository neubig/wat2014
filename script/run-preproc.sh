#!/bin/bash
set -e

if [[ $# != 1 ]]; then
    echo "Usage: $0 en/zh"
    exit 1;
fi

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
echo "Preprocessing ja-en training data"
TRG=en
SPLIT_TRG='(-|\\\\/)'
TRG3LET=eng
ST=$SRC-$TRG
mkdir -p $ST/preproc log

echo "$TDIR/script/preprocess/preprocess.pl -program-dir $WD/tools -truecase-trg -split-words-trg "$SPLIT_TRG" -egret-src-model $EDIR/jpn_grammar -egret-trg-model $EDIR/${TRG3LET}_grammar -nile-segments 40 -nile-gizatype union -nile-model $NDIR/model/nile-$TRG-$SRC.model -nile-order trgsrc -align -threads $CORES -clean-len 80 -src $SRC -trg $TRG $ST/data/train.$SRC $ST/data/train.$TRG $WD/$ST/preproc/train &> log/preproc-$ST-`hostname`.log"
$TDIR/script/preprocess/preprocess.pl -program-dir $WD/tools -truecase-trg -split-words-trg "$SPLIT_TRG" -egret-src-model $EDIR/jpn_grammar -egret-trg-model $EDIR/${TRG3LET}_grammar -nile-segments 40 -nile-gizatype union -nile-model $NDIR/model/nile-$TRG-$SRC.model -nile-order trgsrc -align -threads $CORES -clean-len 80 -src $SRC -trg $TRG $ST/data/train.$SRC $ST/data/train.$TRG $WD/$ST/preproc/train &> log/preproc-$ST-`hostname`.log

for f in dev devtest test; do
    $TDIR/script/preprocess/preprocess.pl -program-dir $WD/tools -truecase-trg -truecase-trg-model $ST/preproc/train/truecaser/en.truecaser -split-words-trg "$SPLIT_TRG" -egret-forest-opt "-nbest4threshold=500" -forest-src -forest-trg -egret-src-model $EDIR/jpn_grammar -egret-trg-model $EDIR/${TRG3LET}_grammar -threads $CORES -src $SRC -trg $TRG $ST/data/$f.$SRC $ST/data/$f.$TRG $WD/$ST/preproc/$f &> log/preproc-$ST-$f-`hostname`.log
done

exit

# ********* Preprocess ja-zh data *********
echo "Preprocessing ja-zh training data"
TRG=zh
TRG3LET=chn
ST=$SRC-$TRG
mkdir -p $ST/preproc log

echo "$TDIR/script/preprocess/preprocess.pl -program-dir $WD/tools -egret-src-model $EDIR/jpn_grammar -kytea-trg-model $KDIR/data/ctb-0.4.0-5.mod -ckylark-trg-model $CDIR/model/ctb -egret-trg-model $EDIR/${TRG3LET}_grammar -align -threads $CORES -clean-len 80 -src $SRC -trg $TRG $ST/data/train.$SRC $ST/data/train.$TRG $WD/$ST/preproc/train &> log/preproc-$ST-`hostname`.log"
$TDIR/script/preprocess/preprocess.pl -program-dir $WD/tools -egret-src-model $EDIR/jpn_grammar -kytea-trg-model $KDIR/data/ctb-0.4.0-5.mod -ckylark-trg-model $CDIR/model/ctb -egret-trg-model $EDIR/${TRG3LET}_grammar -align -threads $CORES -clean-len 80 -src $SRC -trg $TRG $ST/data/train.$SRC $ST/data/train.$TRG $WD/$ST/preproc/train &> log/preproc-$ST-`hostname`.log

for f in dev devtest test; do
    $TDIR/script/preprocess/preprocess.pl -program-dir $WD/tools -egret-forest-opt "-nbest4threshold=500" -forest-src -forest-trg -egret-src-model $EDIR/jpn_grammar -kytea-trg-model $KDIR/data/ctb-0.4.0-5.mod -ckylark-trg-model $CDIR/model/ctb -egret-trg-model $EDIR/${TRG3LET}_grammar -threads $CORES -src $SRC -trg $TRG $ST/data/$f.$SRC $ST/data/$f.$TRG $WD/$ST/preproc/$f &> log/preproc-$ST-$f-`hostname`.log
done

 
# ********* LM preprocessing *********
if [[ ! -e lm/data ]]; then
    mkdir -p lm/data
    cat lm/raw/*.ja | sed 's/、/，/g;  s/（）//g; s/ //g' | ~/work/util-scripts/han2zen.pl --nospace | kytea -notags -wsconst D > lm/data/all.ja
    cat lm/raw/*.en | $TDIR/src/bin/tokenizer | sed "s/[     ]+/ /g; s/^ +//g; s/ +$//g" | ~/work/travatar/src/bin/tree-converter -input_format word -output_format word -split '(-|\\/)' | $TDIR/script/recaser/truecase.pl --model ja-en/preproc/train/truecaser/en.truecaser > lm/data/all.en
    cat lm/raw/*.zh | $KDIR/src/bin/kytea -model $KDIR/data/ctb-0.4.0-5.mod | sed 's/（ *） *//g' | ~/work/util-scripts/han2zen.pl --nospace 2> /dev/null > lm/data/all.zh
fi

# ********* LM training *********
ORDER=6
INDIR=$ORDER
mkdir -p lm/model/$INDIR
for f in ja en zh; do
    if [[ ! -e lm/model/$INDIR/$f.arpa ]]; then
        echo "$TDIR/src/kenlm/lm/lmplz -o $ORDER -S 50% -T /tmp < lm/data/all.$f > lm/model/$INDIR/$f.arpa"
        $TDIR/src/kenlm/lm/lmplz -o $ORDER -S 50% -T /tmp < lm/data/all.$f > lm/model/$INDIR/$f.arpa
    fi
done
 
# NOTE: this is disabeled. If you want to perform LM interpolation, download
#       Moses and SRILM
# # ********* LM interpolation *********
# ORDER=6
# INDIR=$ORDER
# mkdir -p lm/interp/$INDIR
# for OTHER in zh en; do
#     mkdir -p lm/interp/$INDIR
#     if [[ ! -e lm/interp/$INDIR/$OTHER-ja.arpa ]]; then
#         $MDIR/scripts/ems/support/interpolate-lm.perl --name lm/interp/$INDIR/$OTHER-ja.arpa --tuning ja-$OTHER/preproc/devtest/out/ja --lm `ls -m lm/model/$INDIR/*.ja | sed 's/ //g' | tr -d '\n'` --srilm $SDIR/bin/i686-m64
#     fi
#     if [[ ! -e lm/interp/$INDIR/ja-$OTHER.arpa ]]; then
#         $MDIR/scripts/ems/support/interpolate-lm.perl --name lm/interp/$INDIR/ja-$OTHER.arpa --tuning ja-$OTHER/preproc/devtest/out/$OTHER --lm `ls -m lm/model/$INDIR/*.$OTHER | sed 's/ //g' | tr -d '\n'` --srilm $SDIR/bin/i686-m64
#     fi
# done
 
# ********* LM binarization *********
ORDER=6
for f in lm/model/$INDIR/*.arpa; do
    f1=${f/arpa/blm}
    if [[ ! -e $f1 ]]; then
        echo "$TDIR/src/kenlm/lm/build_binary -i $f $f1"
        $TDIR/src/kenlm/lm/build_binary -i $f $f1
    fi
done
