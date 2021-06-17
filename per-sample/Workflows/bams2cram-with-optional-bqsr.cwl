#!/usr/bin/env cwl-runner

class: Workflow
id: bams2cram-with-optional-bqsr
label: bams2cram-with-optional-bqsr
cwlVersion: v1.1

$namespaces:
  edam: http://edamontology.org/

requirements:
  - class: StepInputExpressionRequirement

inputs:
  reference:
    type: File
    format: edam:format_1929
    doc: FastA file for reference genome
    secondaryFiles:
      - .fai
      - ^.dict

  bams:
    type:
      type: array
      items: File
    doc: BAM files to be merged

  use_bqsr:
    type: boolean

  use_original_qualities:
    type: string
    doc: true or false
    default: "false"

  dbsnp:
    type: File
    format: edam:format_3016
    secondaryFiles:
      - .idx
    doc: Homo_sapiens_assembly38.dbsnp138.vcf

  mills:
    type: File
    format: edam:format_3016
    secondaryFiles:
      - .tbi
    doc: Mills_and_1000G_gold_standard.indels.hg38.vcf.gz

  known_indels:
    type: File
    format: edam:format_3016
    secondaryFiles:
      - .tbi
    doc: Homo_sapiens_assembly38.known_indels.vcf.gz

  outprefix:
    type: string

  gatk4_MarkDuplicates_java_options:
    type: string?

  gatk4_BaseRecalibrator_java_options:
    type: string?

  gatk4_ApplyBQSR_java_options:
    type: string?

  static_quantized_quals:
    type:
      type: array
      items: int
    default: [10, 20, 30]
    doc: Use static quantized quality scores to a given number of levels (with -bqsr)

  samtools_num_threads:
    type: int
    default: 1

steps:
  gatk4-MarkDuplicates:
    label: gatk4-MarkDuplicates
    doc: Merges multiple BAMs and mark duplicates
    run: ../Tools/gatk4-MarkDuplicates.cwl
    in:
      in_bams: bams
      outprefix:
        source: outprefix
        valueFrom: $(inputs.outprefix).gatk4-MarkDuplicates
      java_options: gatk4_MarkDuplicates_java_options
    out:
      [markdup_bam, metrics, log]

  gatk4-optional-bqsr:
    label: gatk4-optional-bqsr
    doc: Generates BQSR table and applies BQSR to BAM if required
    run: ../Tools/gatk4-optional-bqsr.cwl
    in:
      use_bqsr: use_bqsr
      reference: reference
      bam: gatk4-MarkDuplicates/markdup_bam
      use_original_qualities: use_original_qualities
      dbsnp: dbsnp
      mills: mills
      known_indels: known_indels
      outprefix: outprefix
      gatk4_BaseRecalibrator_java_options: gatk4_BaseRecalibrator_java_options
      gatk4_ApplyBQSR_java_options: gatk4_ApplyBQSR_java_options
      static_quantized_quals: static_quantized_quals
    out:
      [out_bam, log]

  samtools-bam2cram:
    label: samtools-bam2cram
    doc: Coverts BAM to CRAM
    run: ../Tools/samtools-bam2cram.cwl
    in:
      bam: gatk4-optional-bqsr/out_bam
      reference: reference
      num_threads: samtools_num_threads
    out:
      [cram, log]

  samtools-index:
    label: samtools-index
    doc: Indexes CRAM
    run: ../Tools/samtools-index.cwl
    in:
      cram: samtools-bam2cram/cram
      num_threads: samtools_num_threads
    out:
      [crai, log]

outputs:
  markdup_metrics:
    type: File
    outputSource: gatk4-MarkDuplicates/metrics
  markdup_log:
    type: File
    outputSource: gatk4-MarkDuplicates/log
  cram:
    type: File
    format: edam:format_3462
    outputSource: samtools-bam2cram/cram
  cram_log:
    type: File
    outputSource: samtools-bam2cram/log
  crai:
    type: File
    outputSource: samtools-index/crai
  crai_log:
    type: File
    outputSource: samtools-index/log
  bqsr_log:
    type: File
    outputSource: gatk4-optional-bqsr/log