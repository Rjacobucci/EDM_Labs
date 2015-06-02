library(semtree)
library(lavaan)
library(semtree)
HS <- HolzingerSwineford1939[,7:15]

Y <- HS[,4:9]
X <- HS[,1:3]

#copied and read in prior from 
# https://github.com/patr1ckm/Multi-Repsonse-Tree-Boosting/blob/master/13/mvtboost_v14.R

# note, need to have gbm and plyr installed first


out = mvtb(Y,X)

out$rel.wri[[1]]



library(OpenMx)
dataRaw <- mxData( observed=HS, type="raw" )
varPaths <- mxPath( from=c("x1","x2","x3"), arrows=2,
                    free=TRUE, values = c(1,1,1))

means <- mxPath( from="one", to=c("x1","x2","x3"), arrows=1,
                 free=TRUE, values=c(1,1,1))

regPaths1 <- mxPath( from="x2", to="x1", arrows=1,
                    free=TRUE, values=1, labels="beta1" )
regPaths2 <- mxPath( from="x3", to="x1", arrows=1,
                    free=TRUE, values=1, labels="beta2" )
regPaths3 <- mxPath( from="x3", to="x2", arrows=1,
                    free=TRUE, values=1, labels="beta3" )
# means and intercepts
#means <- mxPath( from="one", to=c("x","y"), arrows=1,
#                 free=TRUE, values=c(1,1), labels=c("meanx","beta0") )
open.mod <- mxModel(model="simple regression", type="RAM",
                       dataRaw, manifestVars=c("x1","x2","x3"),
                    varPaths, regPaths1,regPaths2,regPaths3,means)
open.run <- mxRun(open.mod)
summary(open.run)

#semtree
tree.out <- semtree(open.run,HS)
plot(tree.out)
tree.out


control <- semforest.control()
control$semtree.control <- semtree.control()

forest.out <- semforest(open.run,HS,control)

vim <- varimp(forest.out)
plot(vim)

