### BOOSTING DE GRADIENT STOCHASTIQUE ###

## Téléchargement des packages
library("gbm") #surement à supprimer car on utilise carret pour pouvoir communiquer le modèle
library("caret")
library("ROCR")
library("iml")
library("pROC")
source("../script/_utilityFunction.R")

## Importation des données
load("../data/trainData.RData")
load("../data/testData.RData")
trainDataBool <- trainData
testDataBool <- testData

## hyperparamètres optimaux (validation croisée)
controles <- trainControl(method="LGOCV", number = 1) #Choix des paramètres de contrôle pour l'entrainement du modèle
gbmGrille <- expand.grid(interaction.depth = c(1, 2, 3, 5, 7, 9, 10, 11),
                         n.trees = (1:40) * 100, 
                         shrinkage = 0.001, 
                         n.minobsinnode = 20) #Choix de la grille pour le réglage des hyperparamètres (combinaisons possibles)

gbmfit1 <- train(lapse ~ ., 
                  data = dataToNumeric(trainData),
                  method = "gbm",
                  trControl = controles,
                  tuneGrid = gbmGrille,
                  verbose = FALSE) #pour gbm 

#gbmfit2 <- train(lapse ~ ., 
#                 data = dataToNumeric(trainData),
#                 method = "gbm",
#                 trControl = controles,
#                 tuneGrid = gbmGrille,
#                 verbose = FALSE) #pour gbm 
#gbmfit3 <- train(lapse ~ ., 
#                 data = dataToNumeric(trainData),
#                 method = "gbm",
#                 trControl = controles,
#                 tuneGrid = gbmGrille,
#                 verbose = FALSE) #pour gbm 

gbmfit1$bestTune
plot(gbmfit1)
save(gbmfit3, file="../src/07-gbm/plotoptimisation.rds")

## Pour que la variable réponse prenne les valeurs 0, 1.
trainDataBool$lapse <- trainData$lapse == "renouvellement"
testDataBool$lapse <- testData$lapse == "renouvellement"

## Modèle construit à partir d'un boosting de gradient stochastique
set.seed(2000)
mod.gbm <- gbm(lapse ~ ., 
               distribution = "bernoulli",
               data = trainDataBool,
               n.trees = gbmfit1$bestTune["n.trees"],
               interaction.depth = gbmfit1$bestTune["interaction.depth"],
               shrinkage = gbmfit1$bestTune["shrinkage"], 
               bag.fraction = 0.75)

## Prévisions obtenus à partir du modèle gbm
previsions <- predict(mod.gbm, 
                      n.trees = gbmfit1$bestTune["n.trees"], 
                      newdata = testDataBool,
                      type = "response")

## AUC et courbe ROC
roc(testDataBool$lapse, previsions)
auc <- as.numeric(roc(testDataBool$lapse, previsions)$auc)
save(roc_gbm,file="../src/07-gbm/roc.rds")
save(auc,file="../src/07-gbm/auc.rds")

## Importance des variables
summary(mod.gbm)

## IML 
## Pour nous permettre de comprendre quelles sont les variables explicatives qui influencent le plus la prévision
mod.iml <- Predictor$new(gbmfit1) #Créer un modèle utilisable avec iml
imp <- FeatureImp$new(mod.iml, loss = "ce", compare = "difference", n.repetitions = 5) #Calcul de l'importance des variables
plot(imp) #Graphique de l'importance des variables

## PDP : Graphiquede dépendance partielle
## Pour nous permettre de mieux comprendre l'effet global d'une variable explicative sur la prévision

## ICE : Graphique d'espérance conditionnelle individuelle
## Pour nous permettent de comprendre l'effet d'une variable explicative sur une prévision en particulier
## et de détecter des interactions