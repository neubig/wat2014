#!/bin/bash
set -e

# Download and install the tools
script/get-tools.sh

# Get the data from the ASPEC directory
# The 5000/5000 here is the number of sentences for the TM and LM.
# If you want to build a system similar to NAISTs submission, uncomment the
# second line instead.
script/get-data.sh 5000 5000
# script/get-data.sh 2000000 5000000

# Run the preprocessing
script/run-preproc.sh en
script/run-preproc.sh zh

# Train the language models
script/train-lm.sh

# Train the translation models
script/train-travatar.sh en true ja low nile
script/train-travatar.sh ja low en true nile
script/train-travatar.sh zh low ja low giza
script/train-travatar.sh ja low zh low giza

# Tune/test all the models
script/tune-travatar.sh
