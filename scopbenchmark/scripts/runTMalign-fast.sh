#!/bin/bash

## store file name to a query array
while read line ; do
	queryArray+=($line)
done < ../data/scop.file.full.name.list

## store file name to a target array
while read line ; do
        targetArray+=($line)
done < ../data/scop.file.full.name.list

## timing starts
date

## run TMalign all-versus-all
for i in  "${!queryArray[@]}"; do
	./TM-align/TMalign ./benchmark/data/scop-pdb/${queryArray[$i]} ./benchmark/data/scop-pdb/${targetArray[$i]} -fast >> ./${queryArray[$i]}.out
done

## timing ends
date

rm *_tmaln.out

## extract TM-score (query length normalized)
for file in ./*.out; do
	grep -a -n "^Name of Chain_1:\|^Name of Chain_2:\|TM-score=" ./$file | sed 's|=|:|g' | awk '{print $2}' | awk '{print $1}' | sed 's|./benchmark/data/scop-pdb/||g' | xargs -n 4 | awk '{print $1, $2, $3, $4}' >> ./tmalignfast.tot.clean.m8
done

## sort by query id, and tm-score
sort -k1b,1 -nrk3,3 ./tmalignfast.tot.clean.m8 > ../alignResults/rawoutput/tmfastaln


## generate ROCX file
./bench.awk ../data/scop_lookup.fix.tsv <(cat ../alignResults/rawoutput/tmfastaln > ../alignResults/rocx/tmfastaln.rocx

## calculate auc
 awk '{ famsum+=$3; supfamsum+=$4; foldsum+=$5}END{print famsum/NR,supfamsum/NR,foldsum/NR}' ../alignResults/rocx/tmfastaln.rocx
