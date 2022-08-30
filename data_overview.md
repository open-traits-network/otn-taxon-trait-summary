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
	$('div.table2-start').nextUntil('div.table2-end', 'table').DataTable({order: [[2, 'desc']],});
	$('div.table3-start').nextUntil('div.table3-end', 'table').DataTable({order: [[1, 'desc']],});
	$('div.table4-start').nextUntil('div.table4-end', 'table').DataTable({order: [[1, 'asc']],});
} );
</script>

[Trait Overview](#trait-overview) - [Trait Overview by Dataset](#trait-overview-by-dataset) - [Taxonomic Overview](#taxonomic-overview) - [Taxonomic Trait Overview](#taxonomic-trait-overview)

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

## Trait Overview by Dataset

<div class="table2-start"></div>

|Trait Category | Dataset | Number of Traits |Number of Species|Number of Records|
|---|---|--:|--:|--:|
{%- for entry in site.data.trait_summary %}
| {{ entry.Trait_category }} | [{{ entry.Dataset | split: "/" | last }}]({{entry.Dataset}}) | {{ entry.Number_of_traits }} | {{ entry.Number_of_species }} | {{ entry.Number_of_records }} |
{%- endfor %}

<div class="table2-end"></div>

## Taxonomic Overview

<div class="table3-start"></div>

|Phylum| Number of Traits |Number of Species|Number of Records|
|---|--:|--:|--:|
{%- for entry in site.data.taxon_summary %}
| {{ entry.Phylum }} | {{ entry.Number_of_traits }} | {{ entry.Number_of_species }} | {{ entry.Number_of_records }} |
{%- endfor %}

<div class="table3-end"></div>

## Taxonomic Trait Overview

<div class="table4-start"></div>

|Phylum| Trait Category | Number of Records| Traits |
|---|---|--:|---|
{%- for entry in site.data.taxon_trait_summary %}
| {{ entry.Phylum }} | {{entry.Trait_category}} | {{ entry.Number_of_records }} | {{ entry.Trait_names | strip_newlines | replace: "|", "&#124;"}} |
{%- endfor %}

<div class="table4-end"></div>
