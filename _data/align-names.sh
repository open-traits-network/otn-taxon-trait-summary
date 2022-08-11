#!/bin/bash
#
# track registered OTN datasets and generate dataset summaries
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
 > R/summaries/agg.dkvp.gz

cat R/summaries/agg.dkvp.gz\
 | gunzip\
 | mlr --ocsv unsparsify\
 | mlr --csv reorder -f "$(head -n1 template-summary-table.csv)"\
 | mlr --icsv --otsv cat\
 | gzip\
 > R/summaries/agg.tsv.gz
 
cat R/summaries/agg.tsv.gz\
 | gunzip\
 | tail -n+2\
 | align-names\
 | gzip\
 > R/summaries/agg-aligned.tsv.gz


