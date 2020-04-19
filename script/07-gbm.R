### BOOSTING DE GRADIENT STOCHASTIQUE ###

## Téléchargement des packages
library("gbm") 
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

## GBM Bernoulli utilisant ROC pour entrainer le modèle
controles_Bern <- trainControl(method="cv", number = 4,
                              summaryFunction = twoClassSummary, classProbs=TRUE) 

gbmGrille_Bern <- expand.grid(interaction.depth = c(3, 5, 7),   # les profondeurs supérieur perforamaient moins et aug. temps calcul
                         n.trees = (1:30) * 100, 
                         shrinkage = 0.005,                     # 0.5% sinon fallait 7000 arbres...
                         n.minobsinnode = 20)

set.seed(420)
#gbmfit_Bern <- train(lapse ~ ., 
#                 data = trainData,
#                 method = "gbm",
#                 distribution = "bernoulli",
#                 trControl = controles_Bern,
#                 tuneGrid = gbmGrille_Bern,
#                 metric = "ROC",
#                 verbose = FALSE) 

#save(gbmfit_Bern, file="../src/07-gbm/gbm_opti_ROC.rds")
load(file="../src/07-gbm/gbm_opti_ROC.rds")

gbmfit_Bern$bestTune   # paramétres optimaux
plot(gbmfit_Bern)      # visualisation de l'optimisation

## Pour que la variable réponse prenne les valeurs 0, 1.
trainDataBool$lapse <- trainData$lapse == "renouvellement"
testDataBool$lapse <- testData$lapse == "renouvellement"

set.seed(2000)
#gbm_opti_Bern <- gbm(lapse ~ ., 
#               distribution = "bernoulli",
#               data = trainDataBool,                                            
#               n.trees = gbmfit_Bern$bestTune["n.trees"],
#               interaction.depth = gbmfit_Bern$bestTune["interaction.depth"],
#               shrinkage = gbmfit_Bern$bestTune["shrinkage"], 
#               bag.fraction = 0.75)


#save(gbm_opti_Bern, file="../src/07-gbm/gbm_Bern_final.rds")
load(file="../src/07-gbm/gbm_Bern_final.rds")

## Prévisions obtenus à partir du modèle
previsions_Bern <- predict(gbm_opti_Bern, 
                      n.trees = gbmfit_Bern$bestTune["n.trees"], 
                      newdata = testDataBool,
                      type = "response")

## AUC et courbe ROC
roc_gbm <- roc(testDataBool$lapse, previsions_Bern)
auc <- as.numeric(roc(testDataBool$lapse, previsions_Bern)$auc)
save(roc_gbm,file="../src/07-gbm/roc.rds")
save(auc,file="../src/07-gbm/auc.rds")


##
## Interprétation
##

## Pour l'interprétation du modèle, on ré-entraine un modèle en prenant les mêmes données de départ
## mais en coupant la grosseur de l'échantillon d'entrainement car le temps de calcul est beaucoup trop long
## On procède comme suit pour trouver l'indice des observations utilisées. 
## Il est à noter qu'on prend bien en compte le débalancement de la variables réponse pour faire le 
## nouvel échantillon. (25% des données initiales)

## Importance des variables
summary(gbm_opti_Bern, las = 1)


## PDP : Graphiquede dépendance partielle
## Pour nous permettre de mieux comprendre l'effet global d'une variable explicative sur la prévision
##
## Peut être interprété comme la moyenne des ICEs (ce n'est pas parfait comme méthoe
## car il y a beaucoup de courbe superposées)
plot(gbm_opti_Bern, 1, gbmfit_Bern$bestTune["n.trees"], type ="response")


##Statistique H de Friedman
## On peut regarder quelles sont les variables qui interragissent avec prim_last et
## vehicl_region, soit les 2 variables les plus importantes pour expliquer lapse
## La statistique de Friedman permet d'estimer la force d'une interaction en mesurant la quantité
## de la variance dans la prévision qui provient de l'interraction
set.seed(12345)
mod.iml <- Predictor$new(gbmfit_Bern) #Créer un modèle utilisable avec iml
int.prim_last <- Interaction$new(mod.iml, "prim_last")
int.vehicl_region <- Interaction$new(mod.iml, "vehicl_region")
plot(int.prim_last)
plot(int.vehicl_region)

