#!/bin/bash
set -e

WD=`pwd`
EDIR=$WD/tools/egret
KDIR=$WD/tools/kytea
CDIR=$WD/tools/Ckylark
TDIR=$WD/tools/travatar
NDIR=$WD/tools/nile
MDIR=$MD/tools/mosesdecoder
SDIR=$MD/tools/srilm
CORES=`nproc`

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
