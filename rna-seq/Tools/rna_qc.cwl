#!/usr/bin/env cwl-runner

class: CommandLineTool
id: rnaseq_rna_qc
label: rna_qc
cwlVersion: v1.2

requirements:
  ResourceRequirement:
    # ramMin: $(inputs.ramGB)
    # coresMin: $(inputs.ncpus)
    ramMin: 64
    coresMin: 16
  DockerRequirement:
    dockerPull: docker://encodedcc/rna-seq-pipeline:1.2.4

baseCommand: [python3, /software/rna-seq-pipeline/src/rna_qc.py]

inputs:
  input_bam:
    type: File
    inputBinding:
      position: 1
      prefix: "--input_bam"
  tr_id_to_gene_type_tsv:
    type: File
    inputBinding:
      position: 1
      prefix: "--tr_id_to_gene_type_tsv"
  output_filename:
    type: string
    inputBinding:
      position: 1
      prefix: "--output_filename"
  disks:  
    type: string?

outputs:
  rnaQC:
    type: File
    outputBinding:
      glob: "$(inputs.output_filename)"
  python_log:
    type: File
    outputBinding:
      glob: "rna_qc.log"