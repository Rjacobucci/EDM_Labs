library(party)
library(rpart)
library(ipred)
library(rpart.plot)

par(mar=c(rep(1,4)))

# example data taken from party vignette
# http://cran.r-project.org/web/packages/party/vignettes/party.pdf


# from: http://www.ats.ucla.edu/stat/examples/alda/
# http://www.ats.ucla.edu/stat/r/examples/alda/ch14.htm
rearrest = read.csv("/Users/RJacobucci/Documents/Github/ATI_Labs/rearrest.csv")
rearrest = rearrest[,-1]


#data("GBSG2", package = "TH.data")
stree <- ctree(Surv(months, censor) ~ ., data = rearrest)
plot(stree)


# rpart

?rpart
# create survival object
library(survival)
#y = Surv(time=GBSG2$time,event=GBSG2$cens)
Srpart <- rpart(Surv(months,censor) ~ ., data=rearrest)
plot(Srpart);text(Srpart)
prp(Srpart)
# not sure how to get survival plot
library(survMisc)
autoplot(Srpart,leaf="en")



#cforest

sforest <- cforest(Surv(months, censor) ~ ., data = rearrest,
                   controls=cforest_unbiased(mtry=2))
varimp(sforest)
treeresponse(sforest)
prox <- cmdscale(1 - proximity(sforest), eig = TRUE)
prox


library(randomForestSRC)
Srf <- rfsrc(Surv(months,censor) ~ ., data=rearrest,ntree=50)
plot(Srf)
print(Srf)


matplot(Srf$time.interest, 100 * t(Srf$survival[1:10, ]),
        xlab = "Time", ylab = "Survival", type = "l", lty = 1)

plot.survival(Srf, subset = 1:10, haz.model = "ggamma")
