#!/bin/bash

./runSSstrings.sh ss_strings_dssp.fasta
./runSSstrings.sh ss_strings_dssp_nc.fasta

./runSSstrings.sh ss_strings_dssp.fasta mat_sub_dssp.out mat_sub_dssp.out
./runSSstrings.sh ss_strings_dssp.fasta mat_sub_dssp.out mat_1.out
./runSSstrings.sh ss_strings_dssp.fasta mat_1.out mat_sub_dssp.out

