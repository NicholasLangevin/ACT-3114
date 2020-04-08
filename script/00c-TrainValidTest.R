#!/usr/bin/env Rscript

load(file="../data/DataImputation.RData")

set.seed(111184631)

trainIndex <- createDataPartition(data$lapse, 
                                  p = .8, 
                                  list = FALSE, 
                                  times = 1)

trainData <- data[ trainIndex,]
testData <- data[-trainIndex,]

## Creation du dataset train
## Parameters
# pourcent_train <- 0.8
# pourcent_test <- 0.2

# index_trainData <- sample(1:nrow(data), size = floor(pourcent_train * nrow(data)))
# trainData <- data[index_trainData, ]
# testData <- data[-index_trainData, ]

if (nrow(data) == nrow(trainData) + nrow(testData))
{
    save(trainData, file="../data/trainData.RData")
    save(testData,  file="../data/testData.RData")
    print("Saved")
}
