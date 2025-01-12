#!/usr/bin/env python3
"""
Learn submat from alignments:

    ./create_submat.py pairfile.out seqfile.csv --mat submat.out

    where:
        pairfile.out - sid1, sid2, CIGAR_string
        seqfile.csv - sid, sequence
"""

import sys
import re
import numpy as np
import pandas as pd
import argparse

arg = argparse.ArgumentParser(description=__doc__,
    formatter_class=argparse.RawDescriptionHelpFormatter)
arg.add_argument('pairfile', type=str, help='path to struct. alignment file')
arg.add_argument('seqfile', type=str, help='path to csv file with sid - seq')
arg.add_argument('--mat', type=str, help='save sub. score mat', default=None)
arg.add_argument('--cle', help='use CLE letters', action='store_true')

args = arg.parse_args()
seqfile_path = args.seqfile
pairfile_path = args.pairfile
sub_scores_path = args.mat

_err_cnt = 0

def parse_cigar(cigar_string):
    ref, query = 0, 0
    matches = []

    for cnt, action in re.findall('([0-9]*)([IDMP])', cigar_string):
        cnt = int(cnt)

        if action == 'D':
            ref += cnt
        elif action == 'I':
            query += cnt
        elif action == 'M':  # use only Perfect matches
            ref += cnt
            query += cnt
        elif action == 'P':
            matches += [(ref + i, query + i) for i in range(cnt)]
            ref += cnt
            query += cnt
        else:
            raise ValueError(f'Action {action}')

    return np.array(matches)


def mutual_information(p_ab):
    p_a = p_ab.sum(axis=1)
    p_b = p_ab.sum(axis=0)
    with np.errstate(invalid='ignore', divide='ignore'):
        log_scores = np.log2(p_ab / (p_a[:, np.newaxis] * p_b))
        return np.sum(p_ab * log_scores, where=np.isfinite(log_scores))


def calc_alphabet_mi(counts, counts_prev):
    MI = mutual_information(p_ab = counts / counts.sum())
    MI_prev = mutual_information(p_ab = counts_prev / counts_prev.sum())
    MI_tot = MI - (1 - 0.057) * MI_prev  # magic number: fraction of residues following on a gap
    return MI, MI_tot


def write_mat(file_obj, names, mat):
    csize = 4
    header = (' ' * (csize - 1)).join([' '] + names)

    file_obj.write(header + '\n')
    for name, line in zip(names, mat):
        file_obj.write(
                ''.join([name] + [str(i).rjust(csize, ' ') for i in line]) + '\n')


# Load sequences
sid2seq = {}
with open(seqfile_path, 'r') as file:
    for line in file:
        sid, seq = line.rstrip('\n').split()
        sid2seq[sid] = seq


# Find alphabet
letters = set()
for seq in sid2seq.values():
    letters.update(set(seq))
letters = sorted(letters)

letter2idx = {letter: k for k, letter in enumerate(letters)}


# Parse struct. alignment
pair_file = open(pairfile_path, 'r')

counts = np.zeros((len(letters), len(letters)), dtype='int')  # counts x_i, y_i
counts_prev = np.zeros((len(letters), len(letters)), dtype='int')  # counts x_i, y_(i-1)
for line in pair_file:
    sid1, sid2, cigar_string = line.rstrip('\n').split()
    seq1 = sid2seq.get(sid1, None)
    seq2 = sid2seq.get(sid2, None)
    if (not seq1) or (not seq2):
        if not seq1 and _err_cnt < 100:
            print(f'Not found: {sid1}', file=sys.stderr)
            _err_cnt += 1
        if not seq2 and _err_cnt < 100:
            print(f'Not found: {sid2}', file=sys.stderr)
            _err_cnt += 1
        if _err_cnt == 100:
            print(f'errors truncated...', file=sys.stderr)
            _err_cnt += 1
        continue

    idx_1, idx_2 = parse_cigar(cigar_string).T
    for k in range(idx_1.shape[0]):
        i, j = idx_1[k], idx_2[k]
        row = letter2idx[seq1[i]]
        col = letter2idx[seq2[j]]
        counts[row, col] += 1
        counts[col, row] += 1

        if j > 0 and idx_2[k - 1] == j - 1:  # check if y_{i-1} is aligned
            row = letter2idx[seq1[i]]
            col = letter2idx[seq2[j - 1]]
            counts_prev[row, col] += 1
        if i > 0 and idx_1[k - 1] == i - 1:
            row = letter2idx[seq2[j]]
            col = letter2idx[seq1[i - 1]]
            counts_prev[row, col] += 1

pair_file.close()

p_ab = counts / counts.sum()
p_a = p_ab.sum(axis=1)   # base rates

with np.errstate(invalid='ignore', divide='ignore'):
    scores = 2 * np.log2(p_ab / (p_a * p_a[:, np.newaxis]))  # scores in half bits
scores[~np.isfinite(scores)] = 0  # replace NaNs, Infs
scores = np.rint(scores).astype(int)  # rounding

if sub_scores_path:
    with open(sub_scores_path, 'w') as file:
        if args.cle:
            letters = list('ACDEFGHIKLMNPQRSTVWYX')[:len(letters)]
        write_mat(file, letters, scores)

# Output results
df = pd.DataFrame(scores, index=letters, columns=letters)
print(df)

MI, MI_tot = calc_alphabet_mi(counts, counts_prev)
print(f'MI = {MI:.4f}')
print(f'MI_tot = {MI_tot:.4f}')
print(f'counts = {counts.sum()}')

