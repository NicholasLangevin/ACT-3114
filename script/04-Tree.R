### TREE MODEL ###

## Load Package
library(rpart)
library(rpart.plot)
library(pROC)
library(caret)
source("../script/_utilityFunction.R")

## Import data
load("../data/trainData.RData")
load("../data/testData.RData")



## Arbre complet T0
tree.T0 <- rpart(lapse~., 
              data      = trainData,
              method    = "class",
              control   = tree.control,
              minbucket = 1,
              cp        = 0.0)
plotcp(tree.T0, lty=2, col=2)
summary(tree.T0)
save(tree.T0, file="../src/04-tree/tree.T0.rds")


## Optimisation des Hyperparametres
gridSearch.rpart <- function(minbucket, split="gini"){

    nResult <- length(minbucket)
    gridSearchResults <- data.frame(minbucket = minbucket,
                                    cp=minbucket,
                                    ROC=minbucket)
    iter <- 1
    # sapply(maxdepth, function(depth){
    for(bucket in minbucket){
        fit.tree <- train(lapse ~ .,
                          method     = "rpart",
                          preProcess = "scale",
                          control=rpart.control(minbucket = bucket),
                          tuneLength = 20,
                          trControl  = trControl.tree,
                          metric     = "ROC",
                          parms=list(split=split),
                          data       = trainData
                          )
        gridSearchResults$cp[iter] <- as.numeric(fit.tree$bestTune)
        gridSearchResults$ROC[iter] <- 
            fit.tree$results[fit.tree$results$cp == 
                             as.numeric(fit.tree$bestTune), 2]
        iter <- iter + 1
     }
    return(gridSearchResults)
}

trControl.tree <- trainControl(method="cv", # Cross-Validation
                               number=4, # Nombre de plis
                               summaryFunction = twoClassSummary,
                               classProbs=TRUE)

(tree.gridResult.gini <- gridSearch.rpart(10:20, "gini"))
(tree.gridResult.info <- gridSearch.rpart(10:20, "information"))

save(tree.gridResult.gini, file="../src/04-tree/tree.gridResult.gini.rds")
save(tree.gridResult.info, file="../src/04-tree/tree.gridResult.info.rds")



load(file="../src/04-tree/tree.gridResult.gini.rds")
gridResult <- tree.gridResult.gini
bestModel <- which.max(gridResult$ROC)
(cp <- gridResult$cp[bestModel])
(minbucket <- gridResult$minbucket[bestModel])

## Entrainement du meilleur model
tree <- rpart(lapse~., 
              data=trainData,
              method="class",
              cp=0.0,
              minbucket=minbucket)

tree.final <- prune(tree, cp=cp)
save(tree.final, file="../src/04-tree/tree.final.rds")
rpart.plot(tree.final, type=1, fallen.leaves = FALSE, tweak=1.4)

## Test sur les donnees test
pred <- predict(tree.final, newdata = testData)
roc <- roc(dataToNumeric(testData, "y"), pred[,2], plot=TRUE)
# ROC(dataToNumeric(testData, "y"), pred[,2])
as.numeric(roc$auc)
