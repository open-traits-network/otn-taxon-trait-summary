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

WORKDIR="tmp"
CONFIGDIR="config"

mkdir -p "$WORKDIR"

function align-names {


  ls -1 R/summaries/*.csv.gz\
   | xargs -L1 -I {} sh -c 'cat {} | gunzip | mlr --icsv cat'\
   | gzip\
   > "$WORKDIR/_all.dkvp.gz"

  cat "$WORKDIR/_all.dkvp.gz"\
   | gunzip\
   | mlr --ocsv unsparsify\
   | mlr --csv reorder -f "$(cat R/summaries/template-summary-table.csv | head -n1)"\
   | mlr --icsv --otsvlite cat\
   | cut -f1-17\
   | gzip\
   > "$WORKDIR/_all.tsv.gz"

  echo 'nomer.append.schema.output=[{"column":0,"type":"externalId"},{"column": 1,"type":"name"},{"column": 2,"type":"rank"},{"column": 3,"type":"commonNames"},{"column": 4,"type":"path"},{"column": 5,"type":"pathIds"},{"column": 6,"type":"pathNames"},{"column": 7,"type":"externalUrl"},{"column": 8,"type":"path.kingdom.name"},{"column": 9,"type":"path.phylum.name"},{"column": 10,"type":"path.family.name"}]' > "$WORKDIR/nomertaxon.properties"

  cat "$WORKDIR/_all.tsv.gz"\
   | gunzip\
   | tail -n+2\
   | nomer replace globi-correct\
   | nomer append col --properties "$WORKDIR/nomertaxon.properties"\
   | gzip\
   > "$WORKDIR/_all_taxon_aligned.tsv.gz"
}

function update-trait-map {
  curl -L "https://docs.google.com/spreadsheets/u/0/d/18VAULEfbpmGd8cW5Uis-CFYmUkrjnAYZ/export?format=tsv" > R/sDevTraits_TraitNameVerbatim_Buckets_Mapping.tsv
}

function build-trait-map {
  cat <(echo -e "datasetId\ttraitNameVerbatim\ttraitCategory") <(cat R/sDevTraits_TraitNameVerbatim_Buckets_Mapping.tsv | tail -n+2)\
  | mlr --itsvlite --ocsv reorder -f traitNameVerbatim,traitCategory,datasetId\
  | mlr --csv cut -f traitNameVerbatim,traitCategory\
  | sort | uniq\
  | sed 's/,$/,UNCATEGORIZED_TRAIT/g'\
  > "$WORKDIR/trait-category-map.csv"
  
  # generate properties
  echo -e "nomer.cache.dir=$PWD/$WORKDIR/.nomertraits\nnomer.taxon.name.correction.url=file:///$PWD/$WORKDIR/trait-category-map.csv\nnomer.preston.dir=\nnomer.preston.remotes=\nnomer.preston.version="\
  > "$WORKDIR/nomertrait.properties"
  
  nomer clean --properties "$WORKDIR/nomertrait.properties"
}

function align-traits { 
  cat "$WORKDIR/_all_taxon_aligned.tsv.gz"\
  | gunzip\
  | cut -f9\
  | sed 's/^/\t/g'\
  | gzip\
  > "$WORKDIR/_all_traits.tsv.gz"

  cat "$WORKDIR/_all_traits.tsv.gz"\
  | gunzip\
  | nomer append --properties "${WORKDIR}/nomertrait.properties" translate-names\
  | cut -f2,5\
  | gzip\
  > "$WORKDIR/_all_traits_aligned.tsv.gz"

  paste <(cat "$WORKDIR/_all_taxon_aligned.tsv.gz" | gunzip) <(cat "$WORKDIR/_all_traits_aligned.tsv.gz" | gunzip)\
  | gzip\
  > "$WORKDIR/_all_taxon_traits_aligned_headerless.tsv.gz"

  cat <(cat "$CONFIGDIR/_all_taxon_traits_aligned_header.tsv" | gzip) "$WORKDIR/_all_taxon_traits_aligned_headerless.tsv.gz"\
  > "$WORKDIR/_all_taxon_traits_aligned.tsv.gz"

  cat "$WORKDIR/_all_taxon_traits_aligned.tsv.gz"\
  | gunzip\
  | mlr --itsvlite --ocsv cat\
  > "$WORKDIR/_all_taxon_traits_aligned.csv.gz"
}


#update-trait-map
build-trait-map

align-names
align-traits
