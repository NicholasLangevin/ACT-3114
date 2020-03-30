
## Data
load("../data/trainData.RData")
load("../data/testData.RData")

## Packages
require(randomForest)
require(rpart)
require(rpart.plot)
require(caret)
require(pROC)

set.seed(783590)

mod_bag <- randomForest(lapse~., data = trainData, ntree = 300, nodesize = 2, cp = 0, importance = TRUE, keep.forest = TRUE)

plot(1:dim(mod_bag$err.rate)[1], mod_bag$err.rate[,1],
     type="l", xlab="B", ylab="Taux d'erreur OOB", main="Bagging") ## combien d'arbres ? -> 100 will be ok !

varImpPlot(mod_bag) ## visualiser l'importance des variables 


## Performance du bagging
preds.bag <- predict(mod_bag, newdata = testData, type="prob")
roc(testData$lapse, preds.bag[,2], auc=TRUE, plot=TRUE)


### Optimisation des hyperparamètres nodesize et cp  (#### cette méthode fonctionnerait mais il faudrait une échantillon de validation...)
res_opt <- matrix(nrow = 29 *10, ncol = 3)
cp_test <- seq(0.0001, 0.001, length.out = 10)
j <- 1
for(node in 2:30){
    for(cp in cp_test){
        mod_bag_opt <- randomForest(lapse~., data = trainData, ntree = 100,
                                    nodesize = node, cp = cp, importance = TRUE, keep.forest = TRUE)
        preds.bag <- predict(mod_bag, newdata = testData, type="prob")
        auc <- as.numeric(roc(testData$lapse, preds.bag[,2], auc=TRUE, plot=TRUE, quiet = TRUE)$auc)
        res_opt[j, ] <- c(node, cp, auc)
        j <- j + 1
    }
}



