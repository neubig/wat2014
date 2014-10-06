#!/bin/bash
set -e

# The location of the aspec data
ASPEC_DIR=$HOME/corpus/ASPEC
if [[ ! -e $ASPEC_DIR/data ]]; then
    echo "Could not find the ASPEC data in $ASPEC_DIR"
    exit 0
fi 

# Get the TM data
mkdir -p ja-{en,zh}/data
for f in dev devtest test; do 
    echo "Getting ja-en $f"
    cat $ASPEC_DIR/data/ASPEC-JE/$f/*.txt | script/split-aspec.pl ja-en/data/$f.{id,ja,en} en
    echo "Getting ja-zh $f"
    cat $ASPEC_DIR/data/ASPEC-JC/$f/*.txt | script/split-aspec.pl ja-zh/data/$f.{id,ja,zh} zh
done

f=train
echo "Getting ja-en $f"
cat $ASPEC_DIR/data/ASPEC-JE/$f/*.txt | head -n 5000 | script/split-aspec.pl ja-en/data/$f.{id,ja,en} entrain 0.05
echo "Getting ja-zh $f"
cat $ASPEC_DIR/data/ASPEC-JC/$f/*.txt | head -n 5000  | script/split-aspec.pl ja-zh/data/$f.{id,ja,zh} zh

# Get the LM data
mkdir -p lm/raw
f=train
cat $ASPEC_DIR/data/ASPEC-JE/$f/*.txt | head -n 5000  | script/split-aspec.pl lm/raw/aspec-ja-en-$f.{id,ja,en} entrain
cat  $ASPEC_DIR/data/ASPEC-JC/$f/*.txt | head -n 5000  | script/split-aspec.pl lm/raw/aspec-ja-zh-$f.{id,ja,zh} zh
