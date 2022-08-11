#!/bin/bash
#
# track registered OTN datasets and generate dataset summaries
#
# uses:
# 	https://github.com/globalbioticinteractions/nomer for name alignment with catalogue of life
#   miller (mlr) for table manipulation
#
# author: https://opentraits.org/members/jorrit-h-poelen 
# date: 2022-08-11
# 

set -xe

function align-names {
  nomer replace globi-correct\
  | nomer append col\
  | grep -v NONE
}


ls -1 R/summaries/*.csv.gz\
 | xargs -L1 -I {} sh -c 'cat {} | gunzip | mlr --icsv cat'\
 | gzip\
 > R/_all.dkvp.gz

cat R/_all.dkvp.gz\
 | gunzip\
 | mlr --ocsv unsparsify\
 | mlr --csv reorder -f "$(head -n1 template-summary-table.csv)"\
 | mlr --icsv --otsv cat\
 | gzip\
 > R/_agg.tsv.gz
 
cat R/_agg.tsv.gz\
 | gunzip\
 | tail -n+2\
 | align-names\
 | gzip\
 > R/_all-aligned.tsv.gz


