---
layout: page
title: Data Overview
id: data_overview
description: A high level overview of the traits and taxa in the OTN registry
---

<link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.12.1/css/jquery.dataTables.css">
<script src="https://code.jquery.com/jquery-3.6.0.min.js" integrity="sha256-/xUj+3OJU5yExlq6GSYGSHk7tPXikynS7ogEvDej/m4=" crossorigin="anonymous"></script>
<script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/1.12.1/js/jquery.dataTables.js"></script>
<script type="text/javascript">
$(document).ready( function () {
	$('div.table1-start').nextUntil('div.table1-end', 'table').DataTable({order: [[1, 'desc']],});
} );
</script>

[Trait Overview](#trait-overview) <!-- - [Trait Overview by Dataset](#trait-overview-by-dataset) - [Taxonomic Overview](#taxonomic-overview) - [Taxonomic Trait Overview](#taxonomic-trait-overview) -->

> Warning this is just a prototype of possible tables, data is incomplete

## Summary

{%- for entry in site.data.overall_totals %}
Currently, this overview contains {{ entry.tot_record }} records of {{ entry.tot_trait }} traits from {{ entry.tot_species }} species in {{ entry.tot_dataset }} datasets.
Note, that the same record might occur in multiple datasets.
{%- endfor %}

Summary from 2022-08-30

## Trait Overview

<div class="table1-start"></div>

|Trait Category| Number of Species |Number of Datasets|Datasets|
|---|--:|--:|---|
{%- for entry in site.data.trait_sum_summary %}
| {{ entry.Trait_category }} | {{ entry.Number_of_species }} | {{ entry.Number_of_datasets }} | {% assign datasets = entry.Datasets | strip_newlines | split: "|" %}{% for ds in datasets %}[{{ ds | split: "/" | last }}]({{ds}}){% unless forloop.last %} &#124; {% endunless %}{% endfor %} |
{%- endfor %}

<div class="table1-end"></div>

<!--
## Trait Overview by Dataset

<div class="table1-end"></div>

|Trait Bucket|Traits|Number of taxa|Number of records|Dataset|
|---|---|---|---|---|
|[Size](#) |Height \| Dry Mass \| Crown Radius| 3007 | 10254 | [TRY](datasets/try) |
|[Morphology](#) |Growth Habit | 223 | 254 | [AmphiBIO](datasets/amphi-bio) |
|[Morphology](#) |Growth Habit | 21 | 1024 | [AmP](datasets/amp) |
|... || 0 | 0 | ... |
|[Size](#) |Body Mass | 123 | 254 | [TRY](datasets/try) |
|[Size](#) |Body Mass | 302 | 12254 | [AmphiBIO](datasets/amphi-bio) |
|... || 0 | 0 | ... |

<div class="table2-end"></div>

<button>Download as csv</button>

## Taxonomic Overview

|Kingdom|Number of traits|Number of records|Dataset|
|---|---|---|---|
|Plantae | 2091 | 500723 | [TRY](datasets/try) |
|... | ... | ... | ... |
|Animalia | 53 | 30123 | [AmphiBIO](datasets/amphi-bio) |
|Animalia | 5 | 10231 | [AmP](datasets/amp) |
|... | ... | ... | ... |

<button>Download as csv</button>

## Taxonomic Trait Overview

|Kingdom|Trait Bucket|Number of records|Traits|Dataset|
|---|---|---|---|---|
|Plantae | Morphology | Growth Habit \| Leaf size \| Wood density |76342| [TRY](datasets/try) |
|... | ... | ... | ... | ... |
|Animalia | Size | Body length \| Dry mass | 2312 | [AmphiBIO](datasets/amphi-bio) |
|Animalia | Size | Body length | 843 | [AmP](datasets/amp) |
|... | ... | ... | ... | ... |

<button>Download as csv</button>
 -->