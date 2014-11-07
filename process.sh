#!/bin/bash

# Download and install the tools
script/get-tools.sh

# Get the data from the ASPEC directory
script/get-data.sh

# Run the preprocessing
script/run-preproc.sh

# Train the models
script/train-travatar.sh en true ja low nile
script/train-travatar.sh ja low en true nile
script/train-travatar.sh zh low ja low giza
script/train-travatar.sh ja low zh low giza
