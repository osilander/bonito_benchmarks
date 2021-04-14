# bonito_benchmarks
## Benchmarking basecallers and assemblers using *E. coli* K12

This repo compares *E. coli* K12 assemblies (for now, `raven` and `flye`) using data from different basecallers (`guppy` and `bonito`). One set of `guppy` basecalls have been filtered (*hq*) using `filtlong` to retain the highest quality reads (quality weighting of 10 to retain at least 500Mbp)

Each assembly is polished using `medaka` (or not).

The results of each assembly is compared to the K12 reference, and the quality of the assembly is assessed by
error per window across the genome. This is plotted as a phred-based q-score (e.g. q50 means 1 error every 100,000 base pairs).

First, using 250 Kbp windows. Max q-score here is 54. As is apparent for both the 100Kbp and 250Kbp windowed q-score plots, the `raven` and `flye` assemblies basecalled with `bonito` and with `medaka` polishing come out *very very* close, at around q49 (1.2 errors every 100Kbp). Notably, there are three 250Kbp windows in the `raven` assembly that have *no errors at all*. This suggests that with `bonito`, ONT may be closing in on the q60 *E. coli* genome, which is one of the harder microbes. 

Also interesting is that the `guppy` basecalls do not come far behind `bonito`, around 45.5 (2.8 errors every 100Kbp). However, this means that on average, for a 5Mbp genome, there are close to 150 errors (with the vast majority being indels). 

![beeswarm_K12](figures/quals_beeswarm_250.png)

Second, using 400 Kbp windows. Here, max q-score is 56, and there are no windows without errors.

![beeswarm_K12](figures/quals_beeswarm_400.png)
