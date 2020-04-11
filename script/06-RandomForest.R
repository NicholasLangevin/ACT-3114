
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
mod_forest_pre <- randomForest(lapse ~ ., data=trainData,
                              ntree = 200, 
                              sampsize = floor(0.5*nrow(trainData)),
                              nodesize = 2,
                              cp = 0,
                              mtry = 4, # sqrt(19), 19 etant le nombre de params max 
                              importance = TRUE,
                              keep.forest = TRUE)


plot(1:dim(mod_forest_pre$err.rate)[1], mod_foret_pre$err.rate[,1],
     type="l", xlab="B", ylab="Taux d'erreur OOB", main="Foret") ## combien d'arbres ? -> stabilisation a 100 arbres

## Performance du modele de base 
preds.forest <- predict(mod_forest_pre, newdata = testData, type="prob")
roc(testData$lapse, preds.forest[,2], auc=TRUE, plot=TRUE)

## Optimisation par validation croisée
control <- trainControl(method = 'cv', 
                        number = 5,
                        summaryFunction = twoClassSummary,
                        classProbs = TRUE)

## mtry  et nodesize optimal ?  Attention c'est quand meme long
res_opt <- matrix(nrow = 8, ncol = 3)
set.seed(4414)
j <- 1
for(node in c(1:8 * 5)){
    rf_tuning <- train(lapse ~ .,
                       data = trainData,
                       method = 'rf',
                       metric = "ROC",
                       tuneGrid = expand.grid(mtry = 2:15), 
                       trControl = control,
                       sampsize = floor(0.5*nrow(trainData)),
                       ntree = 100,
                       nodesize = node)
    mtry_opti <- rf_tuning$results$mtry[which.max(rf_tuning$results$ROC)]
    AUC_opti <- rf_tuning$results$ROC[which.max(rf_tuning$results$ROC)]
    
    res_opt[j, ] <- c(node, mtry_opti, AUC_opti)
    j <- j + 1
}
node_opt <- res_opt[which.max(res_opt[, 3]), ][1]
mtry_opt <- res_opt[which.max(res_opt[, 3]), ][2]
saveRDS(res_opt, file = paste0(getwd(), "/src/06-RandomForest/result_opt_rf_save.rds"))


res_opt_save <- readRDS(paste0(getwd(), "/src/06-RandomForest/result_opt_rf_save.rds"))

## Performance de la forest choisie
set.seed(45)
mod_forest_fin <- randomForest(lapse ~ ., data = trainData,
                              ntree = 100,
                              sampsize = floor(0.5*nrow(trainData)),
                              nodesize = node_opt,
                              cp = 0,
                              mtry = mtry_opt,
                              importance = TRUE,
                              keep.forest = TRUE)

saveRDS(mod_forest_fin, file = paste0(getwd(), "/src/06-RandomForest/mod_forest.rds"))

preds.forest_fin <- predict(mod_forest_fin, newdata = testData, type="prob")
roc(testData$lapse, preds.forest_fin[,2], auc=TRUE, plot=TRUE)


