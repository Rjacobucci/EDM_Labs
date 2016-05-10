# Ross Jacobucci -- 2016 APA ATI Exploratory Data Mining Workshop - Session J

# this script requires the installation of a lot of packages
# either use the right bottom pane in RStudio to install packages
# or use install.packages("rpart") for example


library(rpart)
library(caret)


# ----------------- continuous outcomes


library(MASS) # for boston data
data(Boston)

#------- linear regression

lm.Boston <- lm(medv ~., data=Boston)
summary(lm.Boston) # pretty good -- Rsquared = 0.74


#------- Decision Trees -- CART like algorithm
rpart.Boston <- rpart(medv ~., data=Boston)
#summary(rpart.Boston)
plot(rpart.Boston);text(rpart.Boston) # ugly
# not the best plot -- here are some other options

library(rattle); library(rpart.plot)
prp(rpart.Boston);text(rpart.Boston) # okay
fancyRpartPlot(rpart.Boston) # pretty

# calculate r-squared
pred1 <- predict(rpart.Boston)
cor(pred1,Boston$medv)**2
# 0.81

#----- Unbiased Trees from party package using ctree()
library(party);library(partykit)
ctree.Boston <- party::ctree(medv ~., data=Boston)
#plot(ctree.Boston) # too big of a tree
pred2 <- predict(ctree.Boston)
cor(pred2,Boston$medv)**2

# better R2 at 0.87, but huge, uninterpretable tree


#---- boosting -- using the gbm package with caret

gbm.Boston <- train(medv~.,data=Boston,method="gbm",
                 tuneLength=1) # use tuneLength=1 for simplicity
summary(gbm.Boston)
print(gbm.Boston)
# using bootstrapping, the Rsquared is 0.80

pred3 <- predict(gbm.Boston)
cor(pred3,Boston$medv)**2
# not using resampling, Rsquared is 0.84

#------ random forests -- using the randomForest package with caret

rf.Boston <- train(medv~.,data=Boston,method="rf",
                    tuneLength=1) # use tuneLength=1 for simplicity
print(rf.Boston)
# using bootstrapping, the Rsquared is 0.87

pred4 <- predict(rf.Boston)
cor(pred4,Boston$medv)**2
# not using resampling, Rsquared is 0.98
# this is the definition of overfitting



# ---------------- categorical outcomes

# get data
library(ISLR)
data(Default)


# logistic regression using 3 variables to predict whether people default on a loan or not
lr.out <- glm(default~student+balance+income,family="binomial",data=Default)
# didn't change default to factors, as it is already set -- see str(Default)

summary(lr.out)
# using deviance or AIC isn't that intuitive

# other metrics

# get the predicted probabilities for each case
glm.probs=predict(lr.out,type="response")
library(pROC)
rocCurve <- roc(Default$default,glm.probs)

pROC::auc(rocCurve) # area under the curve
pROC::ci(rocCurve) # confidence interval

# quartz()
plot(rocCurve, legacy.axes = TRUE,print.thres=T,print.auc=T)


# use rpart

rpart.out <- rpart(default~student+balance+income,data=Default)
plot(rpart.out);text(rpart.out)

rpart.prob <- predict(rpart.out)[,2]

rocCurve2 <- roc(Default$default,rpart.prob)
pROC::auc(rocCurve2) # area under the curve
pROC::ci(rocCurve2) # confidence interval



# use boosting
gbm.out <- train(default~student+balance+income,data=Default,method="gbm",
                 tuneLength=1) # use tuneLength=1 for simplicity

gbm.prob <- predict(gbm.out,type="prob")[,2]
rocCurve3 <- roc(Default$default,gbm.prob)
pROC::auc(rocCurve3) # area under the curve
pROC::ci(rocCurve3) # confidence interval



plot(rocCurve, legacy.axes = TRUE,col="red")
plot(rocCurve2, legacy.axes = TRUE,add=TRUE,col="blue")
plot(rocCurve3, legacy.axes = TRUE,add=TRUE,col="green")

legend("bottomright", legend=c("Logistic Regression", "CART (rpart)","Boosting (gbm)"),
       col=c("red", "blue","green"), lwd=2)



# get at accuracy

train.class <- predict(gbm.out,type="raw")
confusionMatrix(train.class,Default$default)
# much better than just using
table(train.class,Default$default)






# ----------------- Example of how to do cross-validation using two samples
# note that this is different from doing internal CV or bootstrapping
# most packages such as rpart or caret automatically do CV or bootstrapping

train = sample(dim(Boston)[1], dim(Boston)[1]/2) # half of sample
Boston.train = Boston[train, ]
Boston.test = Boston[-train, ]


ctree.train <- party::ctree(medv ~., data=Boston.train)

pred.ctTest <- predict(ctree.train,Boston.test)
cor(pred.ctTest,Boston.test$medv)**2

# R2 drops from 0.87 to 0.70


