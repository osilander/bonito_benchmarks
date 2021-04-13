# find all fasta files that match "bonito"
STRAINS, = glob_wildcards("data/{sample}_bonito.fasta")
# assemble using a couple methods; first flye and raven
ASSEMBLY = ["flye", "raven"]
POLISH = ['medaka', 'none']

rule all:
    input:
        expand("results/{sample}-{assembly}-{polish}.snps", sample=STRAINS, assembly=ASSEMBLY, polish=POLISH)

rule assemble:
    input:
        "data/{sample}_bonito.fasta"
    output:
        "results/{sample}/{assembly}/assembly.fasta"
    params:
        dir="results/{sample}/{assembly}",
        size="4.5m"
    run:
        if wildcards.assembly == 'flye':
            """
            flye --nano-raw {input} --out-dir {params.dir} \
            --genome-size {params.size} --threads 16
            """
        if wildcards.assembly == 'raven':
            """
            raven {input} -t 16 > {output}
            """

rule polish:
    input:
        nanopore="data/2021-03-24_bonito.fasta",
        assembly="results/{sample}/{assembly}/assembly.fasta"
    output:
        "results/{sample}/{assembly}-{polish}/consensus.fasta"
    params:
        model="r941_min_high_g360",
        outdir="results/{sample}/{assembly}-{polish}"
    run:
        if wildcards.polish == 'medaka':
            """
            medaka_consensus -m {params.model} -d {input.assembly} -i {input.nanopore} \
            -o {params.outdir}
            """
        if wildcards.polish == 'none':
            """
            # just rename
            mv {input.assembly} {output}
            """

rule dnadiff:
    input:
        assembly="results/{sample}/{assembly}-{polish}/consensus.fasta"
    output:
        "results/{sample}-{assembly}-{polish}.snps"
    params:
        prefix="results/{sample}/{assembly}-{polish}",
        reference="data/fixed_lab_MG1655_final2.fasta"
    shell:
        """
        dnadiff {params.reference} {input} -p {params.prefix}
        """
