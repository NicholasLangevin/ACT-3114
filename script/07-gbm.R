### BOOSTING DE GRADIENT STOCHASTIQUE ###

## Téléchargement des packages
library("gbm") #surement à supprimer car on utilise carret pour pouvoir communiquer le modèle
library("caret")
library("ROCR")
source("../script/_utilityFunction.R")

## Importation des données
load("../data/trainData.RData")
load("../data/testData.RData")

## Pour que la variable réponse prenne les valeurs 0, 1.
trainData$lapse <- trainData$lapse == "renouvellement"
testData$lapse <- testData$lapse == "renouvellement"

## hyperparamètres optimaux (validation croisée)
controles <- trainControl(method="LGOCV", number = 1, classProbs = TRUE) #Choix des paramètres de contrôle pour l'entrainement du modèle
gbmGrille <- expand.grid(interaction.depth = c(1, 3, 6, 9),
                         n.trees = c(100, 1000, 5000, 10000),
                         shrinkage = 0.01, 
                         n.minobsinnode = 20) #Choix de la grille pour le réglage des hyperparamètres (combinaisons possibles)

gbmfit1 <- train(lapse ~ ., 
                 data = dataToNumeric(trainData),
                 method = "gbm",
                 metric = "ROC",
                 trControl = controles,
                 tuneGrid = gbmGrille,
                 verbose = FALSE) #pour gbm

gbmfit1$bestTune


## Modèle construit à partir d'un boosting de gradient stochastique
mod.gbm <- gbm(lapse ~ ., 
               distribution = "bernoulli",
               data = trainData,
               n.trees = 50,
               interaction.depth = 2,
               shrinkage = 0.1, 
               bag.fraction = 0.75)

## Prévisions obtenus à partir du modèle gbm
previsions <- predict(mod.gbm, 
                      n.trees = 50, 
                      newdata = testData,
                      type = "response")

## AUC et courbe ROC
roc(testData$lapse, previsions, plot = TRUE)

## Importance des variables
summary(mod.gbm)
