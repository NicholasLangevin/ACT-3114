
## Data
load("../data/trainData.RData")
load("../data/testData.RData")

## Packages
require(randomForest)
require(rpart)
require(rpart.plot)
require(caret)
require(pROC)
require(Rborist)

set.seed(3876)
mod_foret_pre <- randomForest(lapse ~ ., data=trainData, ntree = 200, sampsize = floor(0.75*nrow(trainData)),
                          nodesize = 2, cp = cp_optimal, mtry = 2, importance = TRUE, keep.forest = TRUE)


plot(1:dim(mod_foret_pre$err.rate)[1], mod_foret_pre$err.rate[,1],
     type="l", xlab="B", ylab="Taux d'erreur OOB", main="Foret") ## combien d'arbres ? -> 100 suffira largement


## Optimisation par validation croisée
control <- trainControl(method='cv', 
                        number=3,
                        summaryFunction = twoClassSummary,
                        classProbs=TRUE)

## mtry  et nodesize optimal ?  Attention c'est quand meme long
res_opt <- matrix(nrow = 29, ncol = 3)
set.seed(4414)
for(node in 2:30){
    rf_tuning <- train(lapse ~ .,
                       data = trainData,
                       method = 'rf',
                       metric = "ROC",
                       tuneGrid = expand.grid(mtry = 2:15), 
                       trControl = control,
                       sampsize = floor(0.5*nrow(trainData)),
                       ntree = 50,
                       nodesize = node)
    mtry_opti <- rf_tuning$results$mtry[which.max(rf_tuning$results$ROC)]
    AUC_opti <- rf_tuning$results$ROC[which.max(rf_tuning$results$ROC)]
    res_opt[node - 1, ] <- c(node, mtry_opti, AUC_opti)
}

node_opt <- res_opt[which.max(res_opt[, 3]), ][1]
mtry_opt <- res_opt[which.max(res_opt[, 3]), ][2]

mod_foret_fin <- randomForest(lapse ~ ., data=trainData, ntree = 100, sampsize = floor(0.50*nrow(trainData)),
                              nodesize = node_opt, cp = 0, mtry = mtry_opt, importance = TRUE, keep.forest = TRUE)

preds.foret <- predict(mod_foret_fin, newdata = testData, type="prob")
roc(testData$lapse, preds.foret[,2], auc=TRUE, plot=TRUE)
















