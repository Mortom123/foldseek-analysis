import sys
import numpy as np
all_letters = "A	B	C	D	E	F	G	H	I	J	K	L	M	N	O	P	Q	R	S	T	U	V	W	X	Y	Z".split("\t")

def write_mat(path, names, mat):
    csize = 4
    header = (' ' * (csize - 1)).join([' '] + names)
    with open(path, "w") as file_obj:
        file_obj.write(header + '\n')
        for name, line in zip(names, mat):
            file_obj.write(
                    ''.join([name] + [str(i).rjust(csize, ' ') for i in line]) + '\n')

def parse_mat(path):
    with open(path) as file_obj:
        letters = None
        weights = []
        for l in file_obj:
            if l.startswith("#"):
                continue

            if letters is None:
                letters = l.strip().split()
                continue

            entries = l.strip().split()
            letter, w = entries[0], entries[1:]
            weights.append(w)
    return letters, weights

mat_path = sys.argv[1]
letters, weights = parse_mat(mat_path)
weights = np.stack(weights)
missing_letters = [l for l in all_letters if l not in letters]

extend_right = np.ones((weights.shape[0], len(missing_letters)), dtype=int)
extend_bottom = np.ones((len(missing_letters),len(all_letters)), dtype=int)

weights = np.hstack([weights, extend_right])
weights = np.vstack([weights, extend_bottom])

new_letters = letters + missing_letters
write_mat("test.out", new_letters, weights)
