### k Plus Proche voisin

## Package
library(tidyverse)
library(FNN)
library(caret)

## Datasets
load(file="../data/trainData.RData")
load(file="../data/validData.RData")

## La fonction knn utilise la distance euclidienne, ce qui veut dire
##  que nous devons avoir des valeurs numeriques.
## La fonction 'dataToNumeric' du fichier _utilityFunction.R fait le travail
## Deplus, elle transforme aussi la variable 'lapse' en binaire, permettant
##  l'utilisation de la courbe ROC.
source("./_utilityFunction.R")


## Recherche du meilleur k
trControl.knn <- trainControl(method  = "cv", # validation croisée
                              summaryFunction = twoClassSummary,
                              classProbs = TRUE,
                              # nombre de plis de la validation croisee
                              number  = 4, 
                              # Methode de gestion du debalancement des donnees
                              sampling = "smote") 

fit.knn <- train(lapse ~ .,
                 method     = "knn",
                 preProcess = "scale", # standardisation
                 tuneGrid   = expand.grid(k = 1:10), # test des k 1:10
                 trControl  = trControl.knn,
                 metric     = "ROC",
                 data       = dataToNumeric(trainData))
fit.knn
## Creation du modele

## Comprehention: 
# 'knn' -> classification
# 'knn.reg' -> regression
# Ici, on fait de la classification car notre y est un facteur. Par contre, 
# si on utilise 'knn' la prediction va etre directement 'renouvellement' ou
# 'resignation'. On ne pourra donc pas utilise une courbe ROC pour evaluer
# le modele. On transfome en 0 (renouvellement) et 0 (resignation) pour 
# faire un knn de regression.
## Fonctionnement de la fonction:
# Ce modele n'a pas besoins d'estimer quelques chose. Il fait directement
# les predictions. Il cherche a predire le y de la base de donnees test(valid).
# Il prend un observation de test, calcul la distance euclidienne avec les 
# observation de train et fait la moyenne des y de train.
(k <- as.numeric(fit.knn$bestTune))
modele.knn <- knn(dataToNumeric(trainData, "x", TRUE), 
                      dataToNumeric(validData, "x", TRUE), 
                      trainData$lapse, k=8)

source("./_utilityFunction.R")
table(trainData$lapse)/nrow(trainData) * 100 # Debalancement des donnes ??
pred_binaire <- ifelse(modele.knn == "renouvellement", 0, 1)
ROC(dataToNumeric(validData, "y"), pred_binaire)

## Matrice de confusion
sum(pred_binaire)
table(dataToNumeric(validData, "y"), pred_binaire)
