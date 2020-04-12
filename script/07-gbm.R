### BOOSTING DE GRADIENT STOCHASTIQUE ###

## Téléchargement des packages
library("gbm") #surement à supprimer car on utilise carret pour pouvoir communiquer le modèle
library("caret")
library("ROCR")
library("iml")
source("../script/_utilityFunction.R")

## Importation des données
load("../data/trainData.RData")
load("../data/testData.RData")

## hyperparamètres optimaux (validation croisée)
controles <- trainControl(method="LGOCV", number = 1) #Choix des paramètres de contrôle pour l'entrainement du modèle
gbmGrille <- expand.grid(interaction.depth = 1:8,
                         n.trees = (1:40) * 50, 
                         shrinkage = 0.01, 
                         n.minobsinnode = 20) #Choix de la grille pour le réglage des hyperparamètres (combinaisons possibles)

gbmfit1 <- train(lapse ~ ., 
                  data = dataToNumeric(trainData),
                  method = "gbm",
                  trControl = controles,
                  tuneGrid = gbmGrille,
                  verbose = FALSE) #pour gbm 

names(gbmfit1$bestTune)
gbmfit1$bestTune["n.trees"]
plot(gbmfit1)
gbmfit1$results

## Pour que la variable réponse prenne les valeurs 0, 1.
trainData$lapse <- trainData$lapse == "renouvellement"
testData$lapse <- testData$lapse == "renouvellement"

## Modèle construit à partir d'un boosting de gradient stochastique
mod.gbm <- gbm(lapse ~ ., 
               distribution = "bernoulli",
               data = trainData,
               n.trees = 1600,
               interaction.depth = 2,
               shrinkage = 0.01, 
               bag.fraction = 0.75)

## Prévisions obtenus à partir du modèle gbm
previsions <- predict(mod.gbm, 
                      n.trees = 1600, 
                      newdata = testData,
                      type = "response")

## AUC et courbe ROC
roc(testData$lapse, previsions, plot = TRUE)
auc <- as.numeric(roc(testData$lapse, previsions)$auc)

## Importance des variables
summary(mod.gbm)

## IML 
mod.iml <- Predictor$new(gbmfit1)
imp <- FeatureImp$new(mod.iml, loss = "ce", compare = "difference", n.repetitions = 5)
