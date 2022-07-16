#!/bin/bash

./runSSString ss_strings_dssp.fasta
./runSSString ss_strings_dssp_nc.fasta

./runSSString ss_strings_dssp.fasta mat_sub_dssp.out mat_sub_dssp.out
./runSSString ss_strings_dssp.fasta mat_sub_dssp.out mat_1.out
./runSSString ss_strings_dssp.fasta mat_1.out mat_sub_dssp.out

