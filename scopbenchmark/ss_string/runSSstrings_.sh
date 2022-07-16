#!/bin/bash

./runSSString.sh ss_strings_dssp.fasta
./runSSString.sh ss_strings_dssp_nc.fasta

./runSSString.sh ss_strings_dssp.fasta mat_sub_dssp.out mat_sub_dssp.out
./runSSString.sh ss_strings_dssp.fasta mat_sub_dssp.out mat_1.out
./runSSString.sh ss_strings_dssp.fasta mat_1.out mat_sub_dssp.out

