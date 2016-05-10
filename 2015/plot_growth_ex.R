
library(lavaan)


model <- ' i =~ 1*t1 + 1*t2 + 1*t3 + 1*t4
           s =~ 0*t1 + 1*t2 + 2*t3 + 3*t4 '
fit <- growth(model, data=Demo.growth)
summary(fit)


parameterestimates(fit)

pred = predict(fit)
meani = 0.615
means = 1.006

slope.mat = c(0,1,2,3)
expected.growth <- matrix(rep(t(meani), each=4) +
                            rep(t(means), each=4)*slope.mat, 
                          nrow=1, byrow=TRUE)


plot(c(0,3), c(-8,15), xlab="time", ylab="score", type="n")
lines(0:3, expected.growth, col="red", type="b", lw=3)
for(i in 1:30){
 
 expected.growth <- matrix(rep(t(pred[i,1]), each=4) +
                            rep(t(pred[i,2]), each=4)*slope.mat, 
                           nrow=1, byrow=TRUE)
 lines(0:3,expected.growth)
}

