### TREE MODEL ###

## Load Package
library(rpart)
library(rpart.plot)
library(pROC)
library(caret)

## Import data
load("../data/trainData.RData")
load("../data/testData.RData")

## Optimisation des Hyperparametres
trControl.tree <- trainControl(method="cv", # Cross-Validation
                               number=4, # Nombre de plis
                               summaryFunction = twoClassSummary,
                               classProbs=TRUE,
                               #Methode de gestion du debalancement des donnees
                               sampling = "smote"
                               ) 
gridSearch.rpart <- function(maxdepth){
    nResult <- length(maxdepth)
    gridSearchResults <- data.frame(maxdepth = maxdepth,
                                    cp=maxdepth,
                                    ROC=maxdepth)
    iter <- 1
    # sapply(maxdepth, function(depth){
    for(depth in maxdepth){
        fit.tree <- train(lapse ~ .,
                          method     = "rpart",
                          preProcess = "scale",
                          control=rpart.control(maxdepth = depth,
                                                minbucket=1),
                          tuneLength = 20,
                          trControl  = trControl.tree,
                          metric     = "ROC",
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

## Les resultat changent quelques fois mais maxdepth=6 gagne souvent
(gridResult <- gridSearch.rpart(5:12))
gridResult

bestModel <- which.max(gridResult$ROC)
(cp <- gridResult$cp[bestModel])
(maxdepth <- gridResult$maxdepth[bestModel])

## Entrainement du meilleur model
tree.control <- rpart.control(cp=0.0, 
                              minbucket=1,
                              maxdepth=maxdepth
                              )
tree <- rpart(lapse~., 
              data=trainData,
              method="class",
              control=tree.control
              )


plotcp(tree)
# Selon cette métrique, l’arbre racine est le meilleur.

source("_utilityFunction.R")
treeCutted <- prune(tree, cp=cp)
rpart.plot(treeCutted, type=0, fallen.leaves = FALSE, tweak=2.2)
rpart.plot(tree, type=0, fallen.leaves = FALSE, tweak=2.2)

## Test sur les donnees test
pred <- predict(treeCutted, newdata = testData)
roc <- roc(dataToNumeric(testData, "y"), pred[,2], plot=TRUE)
as.numeric(roc$auc)


(grid <- expand.grid(cp=seq(0.0001, 0.0005, length.out=20), maxdepth=5:7))
(res <- gridSearch.rpart2(grid))

gridSearch.rpart2 <- function(grid){
    gridSearchResults <- data.frame(maxdepth = numeric(nrow(grid)),
                                    cp=numeric(nrow(grid)),
                                    ROC=numeric(nrow(grid)))
    for(i in 1:nrow(grid)){
        tree <- rpart(lapse~., 
                      data=trainData,
                      method="class",
                      cp=grid$cp[i],
                      maxdepth=grid$maxdepth[i]
                      )
        pred <- predict(tree, newdata=testData)
        gridSearchResults$maxdepth[i] = grid$maxdepth[i]
        gridSearchResults$cp[i] = grid$cp[i]
        gridSearchResults$ROC[i] = as.numeric(roc(dataToNumeric(testData, "y"), pred[,2])$auc)
        print(as.numeric(roc(dataToNumeric(testData, "y"), pred[,2])$auc))
    }
    return(gridSearchResults)
}
