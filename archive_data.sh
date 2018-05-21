#!/bin/bash

bak_dir=$(date '+%Y%m%d').bak
mkdir ${bak_dir}
mv *.html *.lst *.csv ${bak_dir}

#since we're not dealing with iso
mv mirror_* ${bak_dir}
