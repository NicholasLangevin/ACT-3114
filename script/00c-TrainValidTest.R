load(file="../data/DataImputation.RData")

## Parameters
pourcent_train <- 0.6
pourcent_valid <- 0.2
pourcent_test <- 0.2

## Creation du dataset train
index_trainData <- sample(1:nrow(data), size = floor(pourcent_train * nrow(data)))
trainData <- data[index_trainData,]

## data temportaire (contenant valid + test)
tempData <- data[-index_trainData,]

## Separation du data restant en valid et test datasets
index_validData <- sample(1:nrow(tempData), size = floor(pourcent_valid * nrow(tempData)))
validData <- tempData[index_validData,]
testData <- tempData[-index_validData,]

if (nrow(data) == nrow(trainData) + nrow(validData) + nrow(testData))
{
    save(trainData, file="../data/trainData.RData")
    save(validData, file="../data/validData.RData")
    save(testData,  file="../data/testData.RData")
}
