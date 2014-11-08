These scripts will reproduce the NAIST system for WAT 2014.
They have been tested on Ubuntu/Debian linux, and may not work elsewhere.
You should ideally have a machine with 32GB of memory or more, and it would help if you have about 20+ cores.

They expect that the ASPEC corpus is placed in

* $HOME/corpus/ASPEC

Before running anything, you will want to install the necessary packages:

* sudo apt-get install git python libtool libboost-all-dev cython python-gflags libboost-mpi-python-dev openmpi-bin

Then, you can run the entire process of downloading all the tools necessary, preprocessing the data, and training the system using the following command:

* nohup ./process.sh &> process.log

Note two things:
1) This has a 99% chance of breaking in your environment. When it does, contact neubig at is.naist.jp for help. Do not hesitate, do not worry. I would like to help you get it working.
2) By default, the script just trains a system with 5000 sentences of training data. This will not make a good system, but it will help you test to make sure things are working. If you want to build a real system, delete or move all the files created by the original process.sh, open process.sh, and modify a couple lines as mentioned in the comments. Note that training the full system will take a loooong time, maybe more than week on a single machine with 20 cores. If you want to make it work faster, note that many of the individual scripts can be run in parallel on multiple machines.

It should also be noted that there are a couple things in the WAT paper that are not implemented here because they alone require other scripts:
* RNNLM reranking: I hope to add this in the near future.
* Interpolation of zh-ja and en-ja language models: I don't think this is so important, but if you want to do this, you will have to install Moses and SRILM. Check run-preproc.sh for the command to be run. The current script just concatenates the data.
* Unknown word splitting: I will add this later if there is demand for it.
