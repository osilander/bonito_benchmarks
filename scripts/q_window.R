# this script desperately needs some cleaning
# Rscript --slave --no-restore q_window.R none

library(beeswarm)
library(tidyr)
library(here)

args = commandArgs(trailingOnly=TRUE)
plot.pattern <- paste(args[1],".snps",sep="") 

setwd(here())
steps <- c(1e5, 2.5e5, 4e5)
steps.lit <- c("100Kbp", "250Kbp", "400Kbp")


files <- dir("./results", pattern=plot.pattern)
medaka.files <- 
names <- gsub(".snps","",files)
names <- gsub("-","\n",names)
names <- gsub("K12_","",names)
names <- gsub("guppy_4.0","g4.0",names)
names <- gsub("bonito_0.3","b0.3",names)
cat(files, "\n")
cat(names,"\n")
for (s in 1:length(steps)) {
	wins <- seq(1,4.8e6,by=steps[s])
	quals <- matrix(nrow=5e6/steps[s]-2,ncol=length(files))
	colnames(quals) <- names
	med.quals <- vector()
	for(f in 1:length(files)) {
		input <- files[f]
		cat(input,"\n")
		
		d <- read.table(file=paste("results/",input,sep=""))	
		q.win <- vector()
		
		for (i in 1:(length(wins)-2)) {
			snps <- subset(d, d[,1] >= wins[i] & d[,1] < wins[i+1])
			#q <- max(dim(snps)[1],0, na.rm=TRUE)
			q <- max(1,dim(snps)[1])
			#cat(q,"\n")
			quals[i,f] <- -log10(q/steps[s])*10
		}
		med.quals[f] <- median(quals[,f])
	}
	o.quals <- order(med.quals)
	quals.df <- as.data.frame(quals)
	quals.long <- gather(quals.df, key="Assembler",value="qscore")

	ifelse(!dir.exists(file.path("./", "figures")), dir.create(file.path("./", "figures")), FALSE)
	png.name <- paste("figures/quals_beeswarm_",args[1],"_",steps.lit[s],".png",sep="")
	png(file=png.name, width=100*length(files),height=480)
	par(las=1)
	par(mar=c(8,5,2,1))
	beeswarm(qscore ~ Assembler, data = quals.long, 
	  log = FALSE, pch = 16, col = rainbow(8),
	  main = (paste("qscore -",steps.lit[s], "window", sep=" ")), cex.main=1.2, xlab="basecaller-assembler-polisher")
	abline(h=seq(30,55,by=5),lty=2,lwd=0.5,col="grey",font.main=1)
	dev.off()
}
