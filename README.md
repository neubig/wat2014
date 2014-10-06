
These scripts will reproduce the NAIST system for WAT 2014.
They have been tested on Debian linux, and probably won't work elsewhere.
You should ideally have a machine with 32GB of memory or more, and it would help if you have about 20+ cores.

They expect that the ASPEC corpus is placed in

* $HOME/corpus/ASPEC

Before running anything, you will want to install the necessary packages:

* sudo apt-get install git python libtool libboost-all-dev cython python-gflags libboost-mpi-python-dev openmpi-bin

Then, you can run the entire process of downloading all the tools necessary, preprocessing the data, and training the system using the following command:

* nohup ./process.sh &> process.log

Note two things:
1) This has a 99% chance of breaking in your environment. When it does, contact neubig at is.naist.jp for help. Do not hesitate, do not worry. I would like to help you get it working.
2) This will take forever! Maybe a week on a single machine with 20 cores. If you want to make it work faster, look at the individual scripts. There are many parts that can be run in parallel on multiple machines.
