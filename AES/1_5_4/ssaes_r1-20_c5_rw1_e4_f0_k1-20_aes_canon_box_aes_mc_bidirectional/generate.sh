#!/bin/bash
# Matthew Gwynne, 11.12.2011 (Swansea)
# Copyright 2011 Oliver Kullmann
# This file is part of the OKlibrary. OKlibrary is free software; you can redistribute 
# it and/or modify it under the terms of the GNU General Public License as published by
# the Free Software Foundation and included in this library; either version 3 of the 
# License, or any later version.

# Generating 400 key discovery instances for AES(r,1,5,4) using the canonical
# translation for r in 1 to 20. For each round random keys with seeds
# 1 to 20 are used to instantiation the AES instances.
#
# We have that 20 rounds * 20 keys = the 400 instances r1_k1.cnf to r20_k20.cnf.
#
# All files are in:
#
# ssaes_r1-20_c5_rw1_e4_f0_k1-20_aes_canon_box_aes_mc_bidirectional .
#

set -o errexit
set -o nounset

num_rows=1
num_cols=5
field_size=4
translation_name=canon
translation_param=ts # canonical (this will be fixed)
mixcolumns=bidirectional # Forward and backward translation
rounds=20
keys=20


oklib --maxima --batch-string "'print(\"Loading OKlibrary ...\"); oklib_load_all(); num_rows : ${num_rows}; num_columns : ${num_cols}; exp : ${field_size}; final_round_b : false; box_tran : aes_${translation_param}_box; mc_tran : aes_mc_${mixcolumns}; for num_rounds : 1 thru ${rounds} do ( print(\"Generating round \", num_rounds, \" ...\"), output_ss_fcl_std(num_rounds, num_columns, num_rows, exp, final_round_b, box_tran, mc_tran), for seed : 1 thru ${keys} do ( output_ss_random_pc_pair(seed,num_rounds,num_columns,num_rows,exp,final_round_b) )); exit();'" | grep "round\|Loading OKlib\|Outputting" # Using grep to suppress output, but avoid using $ in batch string.


echo "Generating combined instance+key files ..."
for r in $(seq 1 ${rounds}); do
  for s in $(seq 1 ${keys}); do
    AppendDimacs-O3-DNDEBUG ssaes_r${r}_c${num_cols}_rw${num_rows}_e${field_size}_f0.cnf ssaes_pcpair_r${r}_c${num_cols}_rw${num_rows}_e${field_size}_f0_s${s}.cnf > r${r}_k${s}.cnf;
  done
done


md5sum --quiet -c md5sum
