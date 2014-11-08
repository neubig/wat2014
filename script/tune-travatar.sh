#!/bin/bash
set -e

CORES=`nproc`
WD=`pwd`
TRAVDIR=$WD/tools/travatar
mkdir -p travatar-tune
mkdir -p travatar-test

THRESH=0
L2=1e-6
NBEST=200

# for SRC in en ja; do
# if [[ "x$SRC" == "xja" ]]; then TRG=en; else TRG=ja; fi
for input in fortrue forlow; do
for CAND in nbest; do
for UPDATE in mert; do
for OTHER in en zh; do 
for SRC in $OTHER ja; do
if [[ "x$SRC" == "xja" ]]; then TRG=$OTHER; else TRG=ja; fi
# Find the F-e
if [[ $SRC == "ja" ]]; then
    F=$SRC; E=$TRG
else
    F=$TRG; E=$SRC
fi
TXTDIR=out
MODTYPE=$input
if [[ $input == fortrue* ]]; then MODTYPE=treetrue; fi
if [[ $input == forlow* ]]; then MODTYPE=treelow; fi
FE="$F-$E"
# Iterate over the models
for f in travatar-model/${SRC}${TRG}*lm*st$MODTYPE*; do
for evalt in bleu interp; do
for PL in 2000; do
for CL in 050; do
    ACTEVAL=$evalt
    if [[ "x$evalt" == "xinterp" ]]; then ACTEVAL="interp:0.5|bleu|0.5|ribes"; fi
    if [[ "x$evalt" == "xbleup" ]]; then ACTEVAL="bleu:smooth=1,scope=corpus"; fi
    if [[ $input == fortrue ]] || [[ $input == forlow ]]; then 
        IN_FORMAT=egret
    else
        IN_FORMAT=penn
    fi
    f1=`basename $f`;
    if [[ "x$UPDATE" == "xmert" ]]; then
        UPSTR="-algorithm mert -threshold $THRESH"
        UPID="tmert"
    elif [[ "x$UPDATE" == "xxeval" ]]; then
        UPSTR="-algorithm xeval -l2 $L2"
        UPID="txeval-l2$L2"
    else
        UPSTR="-algorithm onlinepro -update $UPDATE"
        UPID="tpro-u$UPDATE"
    fi
    ID="$f1-$input-$UPID-n$NBEST-e$evalt"
    if [[ $CAND == "forest" ]]; then ID="$ID-forest"; fi
    echo $ID
    if [ -e $f/filtered-dev.ini ] && [ ! -e travatar-tune/$ID ]; then
        echo "doing $f"
        nice $TRAVDIR/script/mert/mert-travatar.pl -no-filter-rt -nbest $NBEST -threads $CORES -cand-type $CAND -eval "$ACTEVAL" -tune-options "$UPSTR -debug 1" -in-format $IN_FORMAT -travatar-config $f/filtered-dev.ini -src $FE/preproc/dev/$input/$SRC -ref $FE/preproc/dev/$TXTDIR/$TRG -travatar-dir $TRAVDIR -working-dir travatar-tune/$ID &> log/tune-$ID.log
    fi

    # Do testing
    # Do testing
    for SEARCH in inc; do
        for PL in 02000; do
            if [[ "x$SEARCH" == "xcp" ]]; then
                TID="$ID-pl$PL"
            elif [[ "x$SEARCH" == "xinc" ]]; then
                TID="$ID-pi$PL"
            else
                echo "BAD SEARCH: $SEARCH"
                exit
            fi
            TUNE="travatar-tune/$ID"
            if [ -e $TUNE/travatar.ini ]; then
                mkdir -p travatar-test/$TID
                for g in dev devtest test; do
                    echo "doing $TID $g"
                    # echo "$TRAVDIR/script/train/filter-model.pl $TUNE/travatar.ini travatar-test/$TID/travatar-$g.ini travatar-test/$TID/filtered-$g \"$TRAVDIR/script/train/filter-rt.pl -src $FE/preproc/$g/$input/$SRC -src-format $IN_FORMAT\""
                    # nice $TRAVDIR/script/train/filter-model.pl $TUNE/travatar.ini travatar-test/$TID/travatar-$g.ini travatar-test/$TID/filtered-$g "$TRAVDIR/script/train/filter-rt.pl -src $FE/preproc/$g/$input/$SRC -src-format $IN_FORMAT"
                    if [[ ! -e travatar-test/$TID/$g.out ]]; then
                        sed "s/dev/$g/g" < travatar-tune/$ID/travatar.ini > travatar-test/$TID/travatar-$g.ini
                        nice $TRAVDIR/src/bin/travatar -search $SEARCH -chart_limit $CL -pop_limit $PL -threads 21 -in_format $IN_FORMAT -config_file travatar-test/$TID/travatar-$g.ini -trace_out travatar-test/$TID/$g.trace < $FE/preproc/$g/$input/$SRC > travatar-test/$TID/$g.out 2> travatar-test/$TID/$g.err
                        $TRAVDIR/src/bin/mt-evaluator -ref $FE/preproc/$g/$TXTDIR/$TRG travatar-test/$TID/$g.out 2> /dev/null | tee travatar-test/$TID/$g.eval
                    fi
                done
            fi
        done
    done

done
done
done
done
done
done
done
done
done
