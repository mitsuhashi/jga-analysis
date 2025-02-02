#!/usr/bin/env cwl-runner

class: Workflow
id: rna-seq_wf_scatter_PE
label: rna-seq_wf_scatter
cwlVersion: v1.2

requirements:
  InlineJavascriptRequirement: {}
  SubworkflowFeatureRequirement: {}
  ScatterFeatureRequirement: {}
  StepInputExpressionRequirement: {}

inputs:
  prefix_rsem:
    type: string  
  endedness:
    type: string
  index:
    type: File
  ncpus:
    type: int
  ramGB:
    type: int
  chrom_sizes:
    type: File
  strandedness: 
    type: string 
  rsem_index:
    type: File
  read_strand:
    type: string
  rnd_seed:
    type: int
  tr_id_to_gene_type_tsv:
    type: File
  sample_list:
    type:
      type: array
      items:
        - type: record
          fields:
            bamroot:
              type: string
            fastqs_R1:
              type: File[]
            fastqs_R2:
              type: File[]

steps:
  per-sample:
    label: rna-seq-pipeline-per-sample_PE
    run: rna-seq-pipeline-per-sample_PE.cwl
    in:
      endedness: endedness
      index: index
      ncpus: ncpus
      ramGB: ramGB
      chrom_sizes: chrom_sizes
      strandedness: strandedness
      rsem_index: rsem_index
      read_strand: read_strand
      rnd_seed: rnd_seed
      tr_id_to_gene_type_tsv: tr_id_to_gene_type_tsv
      sample_list: sample_list
      bamroot: 
        valueFrom: $(inputs.sample_list.bamroot)
      fastqs_R1: 
        valueFrom: $(inputs.sample_list.fastqs_R1)
      fastqs_R2: 
        valueFrom: $(inputs.sample_list.fastqs_R2)
    scatter:
      - sample_list
    scatterMethod: dotproduct
    out:
      - genomebam
      - annobam
      - genome_flagstat
      - anno_flagstat
      - log
      - genome_flagstat_json
      - anno_flagstat_json
      - log_json
      - python_log
      - unique_unstranded
      - all_unstranded
      - unique_plus
      - unique_minus
      - all_plus
      - all_minus
      - python_log_bts
      - genes_results
      - isoforms_results
      - number_of_genes
      - python_log_rsem
      - rnaQC
      - python_log_rna_qc
  rsem_aggr:
    label: rsem_aggregate_scatter
    run: ../Tools/rsem_aggr.cwl
    in:
      rsem_isoforms: per-sample/isoforms_results
      rsem_genes: per-sample/genes_results
      prefix_rsem: prefix_rsem
    out:
      - transcripts_tpm
      - transcripts_isopct
      - transcripts_expected_count
      - genes_tpm
      - genes_expected_count

outputs:
  transcripts_tpm:
    type: File
    outputSource: rsem_aggr/transcripts_tpm
  transcripts_isopct:
    type: File
    outputSource: rsem_aggr/transcripts_isopct
  transcripts_expected_count:
    type: File
    outputSource: rsem_aggr/transcripts_expected_count
  genes_tpm:
    type: File
    outputSource: rsem_aggr/genes_tpm
  genes_expected_count:
    type: File
    outputSource: rsem_aggr/genes_expected_count
  genomebam:
    type: File[]
    outputSource: per-sample/genomebam
  annobam:
    type: File[]
    outputSource: per-sample/annobam
  genome_flagstat:
    type: File[]
    outputSource: per-sample/genome_flagstat
  anno_flagstat:
    type: File[]
    outputSource: per-sample/anno_flagstat
  log:
    type: File[]
    outputSource: per-sample/log
  genome_flagstat_json:
    type: File[]
    outputSource: per-sample/genome_flagstat_json
  anno_flagstat_json:
    type: File[]
    outputSource: per-sample/anno_flagstat_json
  log_json:
    type: File[]
    outputSource: per-sample/log_json
  python_log:
    type: File[]
    outputSource: per-sample/python_log
  unique_unstranded:
    type: File[]?
  all_unstranded:
    type: File[]?
  unique_plus:
    type: File[]?
  unique_minus:
    type: File[]?
  all_plus:
    type: File[]?
  all_minus:
    type: File[]?
  python_log_bts:
    type: File[]
    outputSource: per-sample/python_log
  genes_results:
    type: File[]
    outputSource: per-sample/genes_results
  isoforms_results:
    type: File[]
    outputSource: per-sample/isoforms_results
  number_of_genes:
    type: File[]
    outputSource: per-sample/number_of_genes
  python_log_rsem:
    type: File[]
    outputSource: per-sample/python_log
  rnaQC:
    type: File[]
    outputSource: per-sample/rnaQC
  python_log_rna_qc:
    type: File[]
    outputSource: per-sample/python_log