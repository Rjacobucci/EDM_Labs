

dat.syn <- read.csv("C:/Users/RJacobucci/Google Drive/ATI_2016/EDM/dat_syn.csv")

dat.syn$GENDER <- as.numeric(dat.syn$GENDER)


# scaling all variables to make everything more interpretable
dat.syn <- data.frame(scale(dat.syn))


# mvtboost package -- multivariate boosting
library(devtools)
# use this to get most recent version of package
devtools::install_github("patr1ckm/mvtboost")
library(mvtboost)

set.seed(5192016)
X = data.matrix(dat.syn[,1:30])
Y = data.matrix(dat.syn[,31:54])

out <- mvtb(Y=Y,X=X,           
            n.trees=1000,     
            shrinkage=.01, 
            interaction.depth=3) 
ri = mvtb.ri(out) 


ri[rowSums(ri > 15) > 0,]

# takes forever
mvtb.nonlin(out,X=X,Y=Y)


# not interpretable
covx <- mvtb.covex(out,X=X,Y=Y)

mvtb.heat(covx)               # heat map of the clustered covariance explained matrix
clus <- mvtb.cluster(covx) 
str(clus)

summary(out)




# run a subset to get covariance explained to be interpretable


Y2 = data.matrix(dat.syn[,31:36])

out2 <- mvtb(Y=Y2,X=X,           
            n.trees=1000,     
            shrinkage=.01, 
            interaction.depth=3) 

summary(out2)
 
covx2 <- mvtb.covex(out2,X=X,Y=Y2)

mvtb.heat(covx2) 


# SEM Trees #

# need to first install OpenMx and lavaan
source('http://www.brandmaier.de/semtree/getsemtree.R')
library(semtree)

# can't estimate the factor mean due to standard error issues

lav.mod <- "
f =~ 1*SuperiorFrontal + l1*MiddleFrontal + l2*InferiorFrontal + l3*Precentral + l4*MiddleOrbitofrontal +
l5*LateralOrbitofrontal + l6*GyrusRectus + l7*Postcentral + l8*SuperiorParietal + l9*Supramarginal +
l10*Angular + l11*Precuneus + l12*SuperiorOccipital + l13*MiddleOccipital + l14*InferiorOccipital + l15*Cuneus +
l16*SuperiorTemporal + l17*MiddleTemporal + l18*InferiorTemporal + l19*ParaHippocampal + l20*Lingual +
l21*Fusiform + l22*Insular + l23*Cingulate 
"


lav.rasch <- "
f =~ 1*SuperiorFrontal + 1*MiddleFrontal + 1*InferiorFrontal + 1*Precentral + 1*MiddleOrbitofrontal +
1*LateralOrbitofrontal + 1*GyrusRectus + 1*Postcentral + 1*SuperiorParietal + 1*Supramarginal +
1*Angular + 1*Precuneus + 1*SuperiorOccipital + 1*MiddleOccipital + 1*InferiorOccipital + 1*Cuneus +
1*SuperiorTemporal + 1*MiddleTemporal + 1*InferiorTemporal + 1*ParaHippocampal + 1*Lingual +
1*Fusiform + 1*Insular + 1*Cingulate 
"

oneFac.out <- lavaan::cfa(lav.mod,dat.syn,meanstructure = TRUE)


set.seed(5192016)
rasch.out <- lavaan::cfa(lav.rasch,dat.syn,meanstructure = TRUE)


tree = semtree(rasch.out,dat.syn)

# too big
plot(tree)


parameters(tree)

# invariance 


# error as of 5/19/16
tree.inv = semtree(oneFac.out,dat.syn,invariance=c("l1","l2","l3","l4","l5","l6","l7",
                                              "l8","l9","l10","l11","l12","l13",
                                              "l14","l15","l16","l17","l18","l19",
                                              "l20","l21","l22","l23"))


