library(glmnet)

lassoDIF <- function(data){
  if (!is.data.frame(data)) data <- as.data.frame(data)
  y <- factor(data$Y)
  J <- length(unique(data$ITEM))
  x <- model.matrix(data$Y ~ -1 + factor(data$ITEM) + data$SCORE + factor(data$ITEM):factor(data$sex))
  pen <- rep(0, 2*J+1)
  pen[(length(pen)-J+1):length(pen)] <- 1
  prov <- glmnet(x, y, family = "binomial", alpha = 1, penalty.factor = pen, intercept = FALSE)
  res <- glmnet(x, y, family = "binomial", alpha = 1, penalty.factor = pen,
                lambda = c(prov$lambda,0), intercept = FALSE)
  return(res)}

lassoDIF.coef <- function(out, nr.lambda = 1000){
  J <- (nrow(out$beta)-1)/2
  nr1 <- nrow(coef(out, s = 0)) - J + 1
  nr2 <- nrow(coef(out, s = 0))
  s <- seq(from = 0, to = max(out$lambda), length = nr.lambda)
  mat <- coef(out, s = s)[nr1:nr2, ]
  mat.names <- "Item1"
  for (i in 2:J) mat.names <- c(mat.names, paste("Item", i, sep = ""))
  rownames(mat) <- mat.names
  return(list(lambda = s, pars = as.matrix(mat)))}

lassoDIF.ABWIC <- function(out, type="AIC", N=NULL){
  J <- (nrow(out$beta)-1)/2
  if (type == "AIC" | type == "BIC"){
    CRIT <- switch(type, AIC = deviance(out)+2*out$df, BIC = deviance(out)+log(J*N)*out$df)
    l.opt <- out$lambda[CRIT == min(CRIT)]
    nr.opt <- (1:length(out$lambda))[abs(out$lambda-l.opt) == min(abs(out$lambda-l.opt))]
    pr <- out$beta[, nr.opt]
  }
  if (type == "WIC"){
    CRIT <- NULL
    ppAIC <- deviance(out) + 2*out$df
    ppBIC <- deviance(out) + log(J*N)*out$df
    s <- seq(from = 0, to = 1, length = nr.w)
    l.seq <- NULL
    for (i in 1:length(s)){
      f <- s[i]*ppAIC + (1-s[i])*ppBIC
      l.seq[i] <- out$lambda[f == min(f)]
    }
    l.opt <- median(unique(l.seq))
    nr1 <- nrow(coef(out, s = 0)) - J + 1
    nr2 <- nrow(coef(out, s = 0))
    pr <- coef(out, s = l.opt)[nr1:nr2, 1]
  }
  IND <- (length(pr) - J + 1):(length(pr))
  RES <- NULL
  if (max(abs(pr[IND])) > 0) RES <- (1:J)[abs(pr[IND]) > 0]
  mat <- cbind(pr[IND])
  mat.names <- "Item1"
  for (i in 2:J) mat.names <- c(mat.names, paste("Item", i, sep = ""))
  rownames(mat) <- mat.names
  return(list(DIFitems = RES, DIFpars = mat, crit.value = CRIT, crit.type = type, lambda = out$lambda, opt.lambda = l.opt))}


lassoDIF.CV <- function(out, data, nfold = 3){
  if (!is.data.frame(data)) data <- as.data.frame(data)
  y <- factor(data$Y)
  J <- length(unique(data$ITEM))
  x <- model.matrix(data$Y~-1+factor(data$ITEM)+data$SCORE+factor(data$ITEM):factor(data$sex))
  pen<-rep(0, 2*J+1)
  pen[(length(pen)-J+1):length(pen)] <- 1
  prov <- cv.glmnet(x, y, family = "binomial", nfolds = nfold, alpha = 1, type.measure = "deviance", penalty.factor = pen)
  l.opt <- max(prov$lambda[prov$cvm == min(prov$cvm)])
  nr.opt <- (1:length(out$lambda))[abs(out$lambda-l.opt) == min(abs(out$lambda-l.opt))]
  pr <- out$beta[, nr.opt]
  IND <- (length(pr)-J+1):(length(pr))
  RES <- NULL
  if (max(abs(pr[IND])) > 0) RES <- (1:J)[abs(pr[IND]) > 0]
  return(list(DIFitems = RES, DIFpars = pr, opt.lambda = l.opt))}