# find all samples in the illumina folder that match "bonito"
STRAINS, = glob_wildcards("./data/{sample}_bonito.fasta")

rule all:
    input:
        expand("results/{sample}/flye-raw-medaka/consensus.fasta", sample=STRAINS),
        expand("results/{sample}/raven-medaka/consensus.fasta", sample=STRAINS),
        expand("results/{sample}/flye-corr-medaka/consensus.fasta", sample=STRAINS)

rule flye_raw:
    input:
        nanopore="data/{sample}_bonito.fasta"
    output:
        "results/{sample}/flye-raw/assembly.fasta"
    params:
        dir="results/{sample}/flye-raw",
        size="4.5m"
    shell:
        """
        flye --nano-raw {input.nanopore} --out-dir {params.dir} \
        --genome-size {params.size} --threads 16
        """
rule raven:
    input:
        nanopore="data/{sample}_bonito.fasta"
    output:
        "results/{sample}/raven/assembly.fasta"
    shell:
        """
        raven {input.nanopore} -t 16 > {output}
        """

rule flye_corr:
    input:
        nanopore="data/{sample}_bonito.fasta"
    output:
        "results/{sample}/flye-corr/assembly.fasta"
    params:
        dir="results/{sample}/flye-corr",
        size="4.5m"
    shell:
        """
        flye --nano-corr {input.nanopore} --out-dir {params.dir} \
        --genome-size {params.size} --threads 16
        """

rule medaka_flye_corr:
    input:
        assembly="results/{sample}/flye-corr/assembly.fasta",
        reads="data/{sample}_bonito.fasta"
    output:
        "results/{sample}/flye-corr-medaka/consensus.fasta"
    params:
        outdir="results/{sample}/flye-corr-medaka",
        model="r941_min_high_g360"
    shell:
        """
        medaka_consensus -m {params.model} -d {input.assembly} -i {input.reads} \
        -o {params.outdir}
        """

rule medaka_flye_raw:
    input:
        assembly="results/{sample}/flye-raw/assembly.fasta",
        reads="data/{sample}_bonito.fasta"
    output:
        "results/{sample}/flye-raw-medaka/consensus.fasta"
    params:
        outdir="results/{sample}/flye-raw-medaka",
        model="r941_min_high_g360"
    shell:
        """
        medaka_consensus -m {params.model} -d {input.assembly} -i {input.reads} \
        -o {params.outdir}
        """

rule medaka_raven:
    input:
        assembly="results/{sample}/raven/assembly.fasta",
        reads="data/{sample}_bonito.fasta"
    output:
        "results/{sample}/raven-medaka/consensus.fasta"
    params:
        outdir="results/{sample}/raven-medaka",
        model="r941_min_high_g360"
    shell:
        """
        medaka_consensus -m {params.model} -d {input.assembly} -i {input.reads} \
        -o {params.outdir}
        """
