#!/usr/bin/env cwl-runner

class: Workflow
id: gatk4-sub-JointCalling-biggest-practices
label: gatk4-sub-JointCalling-biggest-practices
cwlVersion: v1.1

requirements:
  SubworkflowFeatureRequirement: {}
  StepInputExpressionRequirement: {}

inputs:
  gatk4-GenomicsDBImport_java_options:
    type: string?
  workspace_dir_name:
    type: string
  gatk4-GenomicsDBImport_batch_size:
    type: int?
  interval:
    type: File
  sample_name_map:
    type: File
  gatk4-GenomicsDBImport_num_threads:
    type: int?
  Reblock_gVCFsDir:
    type: Directory
  gatk4-GnarlyGenotyper_java_options:
    type: string?
  reference:
    type: File
    doc: FastA file for reference genome
    secondaryFiles:
      - .fai
      - ^.dict
  dbsnp_vcf:
    type: File
    doc: A dbSNP VCF file.
  idx:
    type: int
  gnarly_idx:
    type: int
  callset_name:
    type: string
  make_annotation_db:
    type: boolean?
  stand-call-conf:
    type: int?
  max-alternate-alleles:
    type: int?
  # gatk4-GenomicsDBImport_xxx:
  #   type: string?

steps:
  gatk4-GenomicsDBImport-biggest-practices:
    label: gatk4-GenomicsDBImport-biggest-practices
    run: ../Tools/gatk4-GenomicsDBImport-biggest-practices.cwl
    in:
      java_options: gatk4-GenomicsDBImport_java_options
      workspace_dir_name: workspace_dir_name
      batch_size: gatk4-GenomicsDBImport_batch_size
      interval: interval
      sample_name_map: sample_name_map
      num_threads: gatk4-GenomicsDBImport_num_threads
      sampleDir: Reblock_gVCFsDir
    out:
      - genomics-db
  gatk4-GnarlyGenotyper-biggest-practices:
    label: gatk4-GnarlyGenotyper-biggest-practices
    run: ../Tools/gatk4-GnarlyGenotyper-biggest-practices.cwl
    in:
      java_options: gatk4-GnarlyGenotyper_java_options
      reference: reference
      idx: idx
      gnarly_idx: gnarly_idx
      callset_name: callset_name
      make_annotation_db: make_annotation_db
      dbsnp_vcf: dbsnp_vcf
      workspace_dir_name: workspace_dir_name
      interval: interval
      stand-call-conf: stand-call-conf
      max-alternate-alleles: max-alternate-alleles
      workspace_dir: gatk4-GenomicsDBImport-biggest-practices/genomics-db
    out:
      - output_vcf
      - output_database
  # xyz:
  #   label: xyz
  #   run: ../Tools/xyz.cwl
  #   in:
  #     xxx: xxx
  #   out:
  #     - yyy
outputs:
  genomics-db:
    type: Directory
    outputSource: gatk4-GenomicsDBImport-biggest-practices/genomics-db
  output_vcf:
    type: File
    outputSource: gatk4-GnarlyGenotyper-biggest-practices/output_vcf
    secondaryFiles:
      - .tbi
  output_database:
    type: File?
    outputSource: gatk4-GnarlyGenotyper-biggest-practices/output_database
    secondaryFiles:
      - .tbi