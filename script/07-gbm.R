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
roc <- roc(testDataBool$lapse, previsions_Bern)
auc <- as.numeric(roc(testDataBool$lapse, previsions_Bern)$auc)
save(roc_gbm,file="../src/07-gbm/roc.rds")
save(auc,file="../src/07-gbm/auc.rds")

## Importance des variables
summary(gbm_opti_Bern, las = 1)

## IML 
## Pour nous permettre de comprendre quelles sont les variables explicatives qui influencent le plus la prévision
#mod.iml <- Predictor$new(gbmfit_Bern) #Créer un modèle utilisable avec iml
#imp <- FeatureImp$new(mod.iml, loss = "ce", compare = "difference", n.repetitions = 5) #Calcul de l'importance des variables
#save(imp, file="../src/07-gbm/imp.rds")
#save(mod.iml, file="../src/07-gbm/mod.iml.rds")
load(file="../src/07-gbm/imp.rds")
load(file="../src/07-gbm/mod.iml.rds")
plot(imp) #Graphique de l'importance des variables

## PDP : Graphiquede dépendance partielle
## Pour nous permettre de mieux comprendre l'effet global d'une variable explicative sur la prévision
pdp.prim_last <- FeatureEffect$new(mod.iml, "prem_index", method="pdp", grid.size=50)
pdp.vehicl_region <- FeatureEffect$new(mod.iml, "vehicl_region", method="pdp", grid.size=50)
pdp.policy_age <- FeatureEffect$new(mod.iml, "policy_age", method="pdp", grid.size=50)
pdp.prem_freqperyear <- FeatureEffect$new(mod.iml, "prem_freqperyear", method="pdp", grid.size=50)

save(pdp.prim_last, file="../src/07-gbm/pdp_prim_last.rds")
save(pdp.prim_last, file="../src/07-gbm/pdp_vehicl_region.rds")
save(pdp.prim_last, file="../src/07-gbm/pdp_policy_age.rds")
save(pdp.prim_last, file="../src/07-gbm/pdp_prem_freqperyear.rds")

## ICE : Graphique d'espérance conditionnelle individuelle
## Pour nous permettent de comprendre l'effet d'une variable explicative sur une prévision en particulier
## et de détecter des interactions
