# find all fasta files that match fasta from a specific date
STRAINS, = glob_wildcards("data/{sample}_20210324.fasta")
# assemble using a couple methods; first flye and raven
ASSEMBLY = ["flye", "raven"]
POLISH = ['medaka', 'none']

rule all:
    input:
        expand("results/{sample}/{assembly}-{polish}.snps", sample=STRAINS, assembly=ASSEMBLY, polish=POLISH)

rule assemble:
    input:
        "data/{sample}_20210324.fasta"
    output:
        "results/{sample}/{assembly}/assembly.fasta"
    params:
        dir="results/{sample}/{assembly}",
        size="4.5m"
    run:
        if wildcards.assembly == 'flye':
            shell("flye --nano-raw {input} --out-dir {params.dir} --genome-size {params.size} --threads 24")
        if wildcards.assembly == 'raven':
            shell("raven {input} -t 12 > {output}")

rule polish:
    input:
        nanopore="data/{sample}_20210324.fasta",
        assembly="results/{sample}/{assembly}/assembly.fasta"
    output:
        "results/{sample}/{assembly}-{polish}/consensus.fasta"
    params:
        model="r941_min_high_g360",
        outdir="results/{sample}/{assembly}-{polish}"
    run:
        if wildcards.polish == 'medaka':
            shell("medaka_consensus -m {params.model} -d {input.assembly} -i {input.nanopore} -o {params.outdir}")
        if wildcards.polish == 'none':
            # just rename
            shell("cp {input.assembly} {output}")

rule dnadiff:
    input:
        assembly="results/{sample}/{assembly}-{polish}/consensus.fasta"
    output:
        "results/{sample}/{assembly}-{polish}.snps"
    params:
        prefix="results/{sample}/{assembly}-{polish}",
        reference="data/fixed_lab_MG1655_final2.fasta"
    shell:
        """
        dnadiff {params.reference} {input} -p {params.prefix}
        """

rule plot_quals:
    input:
        "results/{sample}"
    output:
        "results/{strain}/beeswarm_quals.pdf"
    shell:
        "R --slave --no-restore --file=scripts/beeswarm_qual.R --args {input} {output}"
