# http://journal.r-project.org/archive/2014-1/menardi-lunardon-torelli.pdf
library(ROSE)

library(ISLR)
data(Default)


table(Default$default)
1-333/(9667+333) # what we would get if predicting everyone as not defaulting

# create new dataset with balanced classes
#note: if 1's were the smaller class, use method="over
data.bal.un <- ovun.sample(default ~ ., data = Default, method = "under",
                             p = 0.5, seed = 1)$data
table(data.bal.un$default)
# now could either run model on new dataset with balanced classes, or


ROSE.hold <- ROSE.eval(default ~ ., data = data.bal.un, learner = rpart,acc.measure="auc",
                       method.assess = "holdout", extr.pred = function(obj)obj[,2], seed = 1)
ROSE.hold



# use randomForest to do classification with balanced classes
library(randomForest); library(caret)

# look at "classwt" argument
rf.out <- randomForest(as.factor(default) ~ ., data=Default,classwt=c(0.5,0.5),importance=TRUE)
varImpPlot(rf.out)
# in this, class weights need to add to one
# example weights No's as 0.5, Yes's as 0.5
# by not setting weights, implicity setting to classwt=c(0.96,0.04)

pred1 <- predict(rf.out,newdata=Default)
confusionMatrix(pred1,Default$default)



rf.outUnbalanced <- randomForest(as.factor(default) ~ ., data=Default,importance=TRUE)
varImpPlot(rf.outUnbalanced)

pred2 <- predict(rf.outUnbalanced,newdata=Default)
confusionMatrix(pred2,Default$default)

