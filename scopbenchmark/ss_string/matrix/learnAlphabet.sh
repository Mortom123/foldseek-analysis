#!/bin/bash -x

#./learnAlphabet.sh pdbs_train.txt

PDBS_TRAIN=$1
SEQS=$2
# Filter alignments for training
awk 'FNR==NR {pdbs[$1]=1; next}
     ($1 in pdbs) && ($2 in pdbs) {print $1,$2,$10}' \
         $PDBS_TRAIN tmaln-06.out > pairfile_train.out

# seqs.csv needs to be a file with following format:
# d123123 HSHSLSKJGH
# d123124 HSHGKLLDSKJGH
# d123125 HSHSGDLSLDGHSK

./create_submat.py pairfile_train.out $2 --mat sub_score.mat