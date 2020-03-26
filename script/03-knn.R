### k Plus Proche voisin

## Package
library(tidyverse)
library(FNN)
library(caret)
library(dummies)
library(pROC)

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
                 tuneGrid   = expand.grid(k = 15:20), # test des k 1:10
                 trControl  = trControl.knn,
                 metric     = "ROC",
                 data       = dataToNumeric(trainData))
fit.knn
## Creation du modele

## Comprehention: 
# 'knn' -> classification
# 'KNN:knn.reg' -> regression
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
(k <- fit.knn$bestTune)
modele.knn <- knn.reg(dataToNumeric(trainData, "x", TRUE), 
                      dataToNumeric(validData, "x", TRUE), 
                      dataToNumeric(trainData, "y"), k=k)

names(modele.knn)
source("./_utilityFunction.R")
## TODO: Rajouter cette information au rapport
table(trainData$lapse)/nrow(trainData) * 100 # Debalancement des donnes ??
ROC(x, modele.knn$pred, c(0.87, 0.9))
# Dans tous les cas le modele est mauvais

## Matrice de confusion
pred_binaire <- ifelse(modele.knn$pred > 0., 1, 0)
table(dataToNumeric(validData, "y"), pred_binaire)
