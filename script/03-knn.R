### k Plus Proche voisin

## Package
library(tidyverse)
library(FNN)
library(caret)
library(dummies)

## Datasets
load(file="../data/trainData.RData")
load(file="../data/validData.RData")

## La fonction knn utilise la distance euclidienne, ce qui veut dire
## que nous devons avoir des valeurs numeriques.
## Je transforme les variables categoriel en (c-1) variables binaire
## Je transforme les variables binaire ordonnee en variable (1, 2, 3)
## model.matrix
factorVariables <- c("polholder_BMCevol",
                     "polholder_diffdriver",
                     "polholder_gender",
                     "polholder_job",
                     "policy_caruse",
                     "vehicl_garage")
trainDataNumeric <- dummy.data.frame(trainData, names=factorVariables, sep="|")
validDataNumeric <- dummy.data.frame(validData, names=factorVariables, sep="|")


trainDataNumeric <- trainDataNumeric %>% select(-lapse, -vehicl_region, -vehicl_powerkw, -prem_freqperyear)
validDataNumeric <- validDataNumeric %>% select(-lapse, -vehicl_region, -vehicl_powerkw, -prem_freqperyear)

## TODO: Transformation de lapse de facteur en numerique pour pouvoir utilise la courbe ROC
## TODO: Standardisation ?? -> iris <- cbind(sapply(iris[, -5], scale), iris[5])
modele.knn <- knn(trainDataNumeric, validDataNumeric, trainData[, c("lapse")], k=3)


## TODO: debalancement des donnes
table(trainData$lapse)/nrow(trainData) * 100 # Debalancement des donnes ??

trControl <- trainControl(method  = "cv", # validation croisée
                          summaryFunction = twoClassSummary,
                          classProbs = TRUE,
                          number  = 4,
                          sampling = "smote") # debalancement des donnees

fit <- train(Purchase ~ .,
             method     = "knn",
             preProcess = "scale", # standardisation
             tuneGrid   = expand.grid(k = 1:10), # test des k 1:10
             trControl  = trControl,
             metric     = "ROC",
             data       = Caravan)
