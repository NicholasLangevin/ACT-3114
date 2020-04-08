
## Data
load(paste0(getwd(), "/../data/trainData.RData"))
load(paste0(getwd(), "/../data/testData.RData"))

## Packages
require(randomForest)
require(rpart)
require(rpart.plot)
require(caret)
require(pROC)
library(adabag)
library(plyr)

set.seed(783590)

mod_bag <- randomForest(lapse ~ ., data = trainData,
                        ntree = 300,
                        sampsize= nrow(trainData),
                        nodesize = 2,
                        mtry = ncol(trainData[, -1]),
                        cp = 0,
                        importance = TRUE,
                        keep.forest = TRUE)

plot(1:dim(mod_bag$err.rate)[1], mod_bag$err.rate[,1],
     type="l", xlab="B", ylab="Taux d'erreur OOB", main="Bagging") ## combien d'arbres ? -> stabilisation a 150 arbres

varImpPlot(mod_bag) ## visualiser l'importance des variables 


## Performance du bagging de base (nodesize = 2)
preds.bag <- predict(mod_bag, newdata = testData, type="prob")
roc(testData$lapse, preds.bag[,2], auc=TRUE, plot=TRUE)


### Optimisation de l'hyperparamètres nodesize par validation croisée

set.seed(817)
#Randomly shuffle the data
cv_data <- trainData[sample(nrow(trainData)),]

#Create 5 equally size folds
folds <- cut(seq(1,nrow(cv_data)), breaks = 4,labels=FALSE)

valid_index <- vector(mode = "list", length = 4)
valid_cv_data <- vector(mode = "list", length = 4)
train_cv_data <- vector(mode = "list", length = 4)

for(i in 1:4){
    valid_index[[i]] <- which(folds == i, arr.ind=TRUE)
}

for(i in 1:4){
    valid_cv_data[[i]] <- cv_data[valid_index[[i]], ]
    train_cv_data[[i]] <- cv_data[-valid_index[[i]], ]
}

# verification
# sort(c(as.numeric(rownames(train_cv_data[[1]])), as.numeric(rownames(valid_cv_data[[1]]))))


res_opt <- matrix(nrow = 49, ncol = 2)
j <- 1
for(node in 2:50){
    auc_opt <- numeric(4)
    for(k in 1:4){
        mod_bag_opt_k <- randomForest(lapse ~ ., data = train_cv_data[[k]],
                                      ntree = 100,
                                      sampsize= nrow(train_cv_data[[k]]),
                                      nodesize = node,
                                      mtry = ncol(train_cv_data[[1]][, -1]),
                                      cp = 0,
                                      importance = TRUE,
                                      keep.forest = TRUE)
        preds.bag <- predict(mod_bag_opt_k, newdata = valid_cv_data[[k]], type="prob")
        auc_k <- as.numeric(roc(valid_cv_data[[k]]$lapse, preds.bag[,2], auc=TRUE, plot=FALSE, quiet = TRUE)$auc)
        auc_opt[k] <- auc_k
    }
    res_opt[j, ] <- c(node, mean(auc_opt))
    j <- j + 1
}

nodesize_opti <- res_opt[which.max(res_opt[, 2])] # 34


## Performance du bagging choisi (nodesize = 34)
set.seed(23654)
mod_bag_final <- randomForest(lapse ~ ., data = trainData,
                              ntree = 150,
                              sampsize= nrow(trainData),
                              nodesize = nodesize_opti,
                              mtry = ncol(trainData[, -1]),
                              cp = 0,
                              importance = TRUE,
                              keep.forest = TRUE)

preds.bag_final <- predict(mod_bag_final, newdata = testData, type="prob")
roc(testData$lapse, preds.bag_final[,2], auc=TRUE, plot=TRUE)


### Optimisation de l'hyperparamètres nodesize  (#### cette méthode fonctionnerait mais il faudrait une échantillon de validation...)
# res_opt <- matrix(nrow = 29 *10, ncol = 3)
# cp_test <- seq(0.0001, 0.001, length.out = 10)
# j <- 1
# for(node in 2:30){
#     for(cp in cp_test){
#         mod_bag_opt <- randomForest(lapse~., data = trainData, ntree = 100,
#                                     nodesize = node, cp = 0, importance = TRUE, keep.forest = TRUE)
#         preds.bag <- predict(mod_bag, newdata = testData, type="prob")
#         auc <- as.numeric(roc(testData$lapse, preds.bag[,2], auc=TRUE, plot=TRUE, quiet = TRUE)$auc)
#         res_opt[j, ] <- c(node, cp, auc)
#         j <- j + 1
#     }
# }
# 
# 
# fit.control_cv <- trainControl(method="cv",
#                                number=5,
#                                summaryFunction = twoClassSummary,
#                                classProbs=TRUE)
# 
# cv.fitted.bag_cv <- train(lapse ~ .,
#                            data = trainData,
#                            method = "AdaBag",
#                            tuneGrid = expand.grid(maxdepth = c(2:30), mfinal = 200),
#                            metric = "ROC",
#                            trControl = fit.control_cv)



























