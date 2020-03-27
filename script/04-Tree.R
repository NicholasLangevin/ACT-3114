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
fit.tree <- train(lapse ~ .,
                  method     = "rpart",
                  preProcess = "scale",
                  tuneLength = 20,
                  trControl  = trControl.tree,
                  metric     = "ROC",
                  data       = trainData
                  )

fit.tree
(cp <- as.numeric(fit.tree$bestTune))


tree.control <- rpart.control(cp=0.0, 
                              minsplit=1, 
                              minbucket=1,
                              # maxdepth=6
                              )
tree <- rpart(lapse~., 
              data=trainData,
              method="class",
              control=tree.control
              )

plotcp(tree)
# Selon cette métrique, l’arbre racine est le meilleur.

source("_utilityFunction.R")
treeCutted <- prune(tree, cp=0, maxdepth=2)
rpart.plot(treeCutted, type=0, fallen.leaves = FALSE, tweak=2.2)
pred <- predict(treeCutted, newdata = testData)
roc <- roc(dataToNumeric(testData, "y"), pred[,2], plot=TRUE)
roc$auc
