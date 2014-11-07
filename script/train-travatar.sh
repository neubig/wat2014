#!/bin/bash

TRAVDIR=/home/is/neubig/work/travatar
SRC=ja
TRG=en
if [[ $SRC == "ja" ]]; then 
    F=$SRC; E=$TRG
else 
    F=$TRG; E=$SRC
fi
FE="$F-$E"
WD=`pwd`
NT=2
TERM=10
SRCTRG=${SRC}${TRG}
ALIGNTYPE=nile
LMORDER=5
COMPOSE=5
SMOOTH=kn
ATTACH=top
BINARIZE=rightrp
FEAT=dic

SRC_TREE=treein
SRC_WORD=in
TRG_TREE=out
TRG_WORD=out

TRG_FORMAT=word

if [[ "x$FEAT" == "xisx" ]]; then 
    TRG_FORMAT=penn
    TRG_TREE=treeout
    SCORE_OPTIONS=-trg_syntax
elif [[ "x$FEAT" == "xsyn" ]]; then 
    TRG_FORMAT=penn
    TRG_TREE=treeout
    SCORE_OPTIONS="-trg-syntax -src-label -trg-label -src-trg-label"
fi

ID=$SRCTRG-$ALIGNTYPE-lm$LMORDER-nt$NT-t$TERM-c$COMPOSE-s$SMOOTH-f$FEAT-st$SRC_TREE
echo $ID
[[ -e travatar-model ]] || mkdir travatar-model
if [[ ! -e $WD/travatar-model/$ID ]]; then
    nohup $TRAVDIR/script/train/train-travatar.pl -score_options "$SCORE_OPTIONS" -trg_format $TRG_FORMAT -attach $ATTACH -binarize $BINARIZE -smooth $SMOOTH -compose $COMPOSE -nonterm_len $NT -term_len $TERM -work_dir $WD/travatar-model/$ID -lm_file $WD/lm/interp/$LMORDER/$SRC-$TRG.blm -src_file $WD/$FE/preproc/train/$SRC_TREE/$SRC -src_words $WD/$FE/preproc/train/$SRC_WORD/$SRC -trg_file $WD/$FE/preproc/train/$TRG_TREE/$TRG -trg_words $WD/$FE/preproc/train/$TRG_WORD/$TRG -align_file $WD/$FE/preproc/train/$ALIGNTYPE/$SRCTRG -travatar_dir $TRAVDIR -threads 2 &> log/train-$ID.log
fi

if [[ -e $WD/travatar-model/$ID/model/travatar.ini ]]; then
    for g in dev devtest test; do
        if [[ ! -e $WD/travatar-model/$ID/filtered-$g ]]; then
            echo "nice $TRAVDIR/script/train/filter-model.pl $WD/travatar-model/$ID/model/travatar.ini $WD/travatar-model/$ID/filtered-$g.ini $WD/travatar-model/filtered-$g "$TRAVDIR/script/train/filter-rt.pl -src $FE/preproc/$g/$SRC_TREE/$SRC -src-format penn" &> log/filter-$ID-$g.log &"
            nice $TRAVDIR/script/train/filter-model.pl $WD/travatar-model/$ID/model/travatar.ini $WD/travatar-model/$ID/filtered-$g.ini $WD/travatar-model/$ID/filtered-$g "$TRAVDIR/script/train/filter-rt.pl -src $FE/preproc/$g/$SRC_TREE/$SRC -src-format penn" &> log/filter-$ID-$g.log &
        fi
    done
fi
