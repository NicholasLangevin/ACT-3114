library(glmnet)
library(dplyr)
library(pROC)

# dataset
load(file="../data/trainData.RData")
load(file="../data/testData.RData")
source("./_utilityFunction.R")

set.seed(87699)
X <- as.matrix(dataToNumeric(trainData, "x", TRUE))
Y <- dataToNumeric(trainData, "y")

lasso.valid.auc <- cv.glmnet(X,
                       Y,
                       alpha = 1,  # lasso
                       family = "binomial",
                       type.measure = "auc")

lasso.valid.dev <- cv.glmnet(X,
                       Y,
                       alpha = 1,  # lasso
                       family = "binomial")


plot(lasso.valid.dev)
plot(lasso.valid.auc)

save(lasso.valid.auc, file="../src/02-lasso/lasso.valid.auc.rds")
save(lasso.valid.dev, file="../src/02-lasso/lasso.valid.dev.rds")


(lambda_optimal.dev <- lasso.valid.dev$lambda.min)
lasso.lambdaOpti.dev <- glmnet(X, Y,
                               lambda = lambda_optimal.dev,
                               alpha = 1,  # lasso
                               family = "binomial")

(lambda_optimal.auc <- lasso.valid.auc$lambda.min)
lasso.valid.auc$lambda.min
lasso.lambdaOpti.auc <- glmnet(X, Y,
                               lambda = lambda_optimal.auc,
                               alpha = 1,  # lasso
                               family = "binomial")


lasso.names0.dev <-
    names(coef(lasso.lambdaOpti.dev)[which(coef(lasso.lambdaOpti.dev)==0),])
lasso.names0.auc <-
    names(coef(lasso.lambdaOpti.auc)[which(coef(lasso.lambdaOpti.auc)==0),])


coef(lasso.lambdaOpti.dev)



# =================================================================

lasso.pred.dev <- predict(lasso.lambdaOpti.dev, 
                          newx= as.matrix(dataToNumeric(testData, "x")),
                          type="response")

lasso.pred.auc <- predict(lasso.lambdaOpti.auc, 
                          newx= as.matrix(dataToNumeric(testData, "x")),
                          type="response")

save(lasso.pred.dev, file="../src/02-lasso/lasso.pred.dev.rds")
save(lasso.pred.auc, file="../src/02-lasso/lasso.pred.auc.rds")

# save(lasso.confMatrix.dev, file="../src/02-lasso/lasso.confMatrix.dev.rds")
# save(lasso.confMatrix.auc, file="../src/02-lasso/lasso.confMatrix.auc.rds")

source("./_utilityFunction.R")
roc.dev <- roc(ifelse(testData$lapse == "resignation", 1, 0), as.numeric(lasso.pred.dev), plot=T, col="red")
plot(roc.dev, print.thres="best", print.thres.best.method="closest.topleft")

result.coords.dev <- coords(roc.dev, "best", best.method="closest.topleft", ret=c("threshold", "accuracy", "specificity", "sensitivity"), transpose = TRUE)
format(result.coords.dev, scientific=FALSE, digits=1)


roc.auc <- roc(ifelse(testData$lapse == "resignation", 1, 0), as.numeric(lasso.pred.auc), plot=T, col="red")
# plot(roc.auc, print.thres="best", print.thres.best.method="closest.topleft")

result.coords.auc <- coords(roc.auc, "best", best.method="closest.topleft", ret=c("threshold", "accuracy", "specificity", "sensitivity"), transpose = TRUE)
format(result.coords.auc, scientific=FALSE, digits=1)
