# this script desperately needs some cleaning
# Rscript --slave --no-restore q_window.R none

library(beeswarm)
library(tidyr)
library(here)

args = commandArgs(trailingOnly=TRUE)
plot.pattern <- paste(args[1],".+",args[2],".snps",sep="") 

setwd(here())
steps <- c(1e5, 2.5e5, 5e5)
steps.lit <- c("100Kbp", "250Kbp", "500Kbp")

# a buncch of manipulations to simplify the filenames
files <- dir("./results", pattern=plot.pattern)
names <- gsub(".snps","",files)
names <- gsub("-","\n",names)
names <- gsub("K12_","",names)
names <- gsub("_b0.3","\nb0.3.5",names)
names <- gsub("_g4.5","\ng4.5",names)
# print out just to check
#cat(names,"\n")
for (s in 1:length(steps)) {
	wins <- seq(1,4.6e6,by=steps[s])
	
	# we skip the last window as it is not full length
	quals <- matrix(nrow=5e6/steps[s]-1,ncol=length(files))
	colnames(quals) <- names
	med.quals <- vector()

	# loop over all files
	for(f in 1:length(files)) {
		input <- files[f]
		cat(names[f],"\n")
		d <- read.table(file=paste("results/",input,sep=""))	
		q.win <- vector()

		# again we skip the last window b/c not obvious 
		# how to caluclate quality
		for (i in 1:(length(wins)-1)) {
			snps <- subset(d, d[,1] >= wins[i] & d[,1] < wins[i+1])
			cat(wins[i],"\t",dim(snps)[1],"\n")
			# it's not obvious how too caluclate this
			# if there are no errors
			# in the case of no errors, I just add one to the max score
			if(dim(snps)[1] > 0) {
				q <- max(1,dim(snps)[1])
				quals[i,f] <- -log10(q/steps[s])*10
			}
			else { quals[i,f] <- -log10(1/steps[s])*10 + 1 }
		}
		med.quals[f] <- median(quals[,f])
	}

	# we could order by median but perhaps not
	quals.df <- as.data.frame(quals)
	
	# make the matrix long and use factors (for plotting sake)
	quals.long <- gather(quals.df, key="Assembler",value="qscore")

	# make the figures directory if needed
	ifelse(!dir.exists(file.path("./", "figures")), dir.create(file.path("./", "figures")), FALSE)
	
	# open a png
	png.name <- paste("figures/quals_beeswarm_",args[1],"_",args[2],"_",steps.lit[s],".png",sep="")
	png(file=png.name, width=100*length(files),height=480)
	
	# change some defaults
	par(las=1)
	par(mar=c(8,5,2,1))

	# get the beeswarm plot
	beeswarm(qscore ~ Assembler, data = quals.long, 
	  log = FALSE, pch = 16, col = rainbow(8),
	  main = (paste("qscore -",steps.lit[s], "window", sep=" ")), cex.main=1.2, xlab="basecaller-assembler-polisher")
	
	# add a few lines
	abline(h=seq(30,55,by=5),lty=2,lwd=0.5,col="grey",font.main=1)
	dev.off()
}
