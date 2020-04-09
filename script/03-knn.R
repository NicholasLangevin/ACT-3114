### k Plus Proche voisin

## Package
library(tidyverse)
library(FNN)
library(caret)
library(pROC)

## Datasets
load(file="../data/trainData.RData")
load(file="../data/testData.RData")

## La fonction knn utilise la distance euclidienne, ce qui veut dire
##  que nous devons avoir des valeurs numeriques.
## La fonction 'dataToNumeric' du fichier _utilityFunction.R fait le travail
source("./_utilityFunction.R")


## Recherche du meilleur k
trControl.knn <- trainControl(method  = "cv", # validation croisée
                              number  = 4,  # Nombre de plis
                              summaryFunction = twoClassSummary,
                              classProbs = TRUE)
                              # Methode de gestnon du debalancement des donnees
                              # sampling = "smote") 

fit.knn <- train(lapse ~ .,
                 method     = "knn",
                 preProcess = "scale", # standardisation
                 tuneGrid   = expand.grid(k = seq(1, 50, by=5), 
                 trControl  = trControl.knn,
                 metric     = "ROC",
                 data       = dataToNumeric(trainData))
fit.knn
plot(fit.knn)

save(fit.knn, file="../src/03-knn/knnTrain(fit.knn).rds")
## Creation du modele

## Fonctionnement de la fonction 'knn':
# Ce modele n'a pas besoins d'estimer quelques chose. Il fait directement
# les predictions. Il cherche a predire le y de la base de donnees test(valid).
# Il prend un observation de test, calcul la distance euclidienne avec les 
# observation de train et fait la moyenne des y de train.
load(file="../src/03-knn/knnTrain(fit.knn).rds")
(k <- as.numeric(fit.knn$bestTune))
modele.knn <- knn.reg(dataToNumeric(trainData, "x", TRUE), 
                      dataToNumeric(testData, "x", TRUE), 
                      dataToNumeric(trainData, "y"), k=29)

save(modele.knn, file="../src/03-knn/knnModele(modele.knn).rds")
load(file="../src/03-knn/knnModele(modele.knn).rds")

source("./_utilityFunction.R")
table(trainData$lapse)/nrow(trainData) * 100 # Debalancement des donnes ??
table(testData$lapse)/nrow(testData) * 100 # Debalancement des donnes ??
## pred_binaire <- ifelse(modele.knn == "renouvellement", 0, 1)
ROC(dataToNumeric(testData, "y"), modele.knn$pred, col="blue")
roc(dataToNumeric(testData, "y"), modele.knn$pred, plot=TRUE)
as.numeric(roc(dataToNumeric(testData, "y"), modele.knn$pred)$auc)

## Matrice de confusion
pred_binaire <- ifelse(modele.knn$pred > 0.6, 1, 0)
table(dataToNumeric(testData, "y"), pred_binaire)
