
dataToNumeric <- function(data, return = "both", scale = FALSE){

    ## Transformation des variables categorielle ordonne en
    ##  variable numeric (1,2,3,..)
    data$vehicl_powerkw <- as.numeric(data$vehicl_powerkw)
    data$prem_freqperyear <- as.numeric(data$prem_freqperyear)

    ## Transformation des facteur en (c-1) variables binaire
    designMatrix <- model.matrix(lapse~., data)[, -1]

    if(scale & return %in% c("y", "both.num"))
        warning("'scale' argument ignored")
    else if (scale){
        designMatrix <- as.data.frame(scale(designMatrix))
    }

    newData <- data.frame(lapse=data$lapse)
    newData <- cbind(newData, as.data.frame(designMatrix))

    if (return == "x")
        return(as.data.frame(designMatrix)[, -1])
    if (return == "y")
        return(ifelse(data$lapse == levels(data$lapse)[1], 1, 0))
    if (return == "both.num")
        return(as.data.frame(model.matrix(~., data)[, -1]))
    if (return == "both")
        return(newData)

    stop("argument 'return' out of bound")
}

ROC <- function(y, probPred, add = FALSE, ...){

    table_roc <- function(etiq, pred) {
      etiq <- etiq[order(pred, decreasing = TRUE)]
      data.frame(TFP = cumsum(!etiq)/sum(!etiq), # Taux faux positifs
                 TVP = cumsum(etiq)/sum(etiq)) # Taux vrais positifs
    }

    if(add)
        points(table_roc(y, probPred, type="l", add=TRUE, ...))
    else{
        plot(table_roc(y, probPred), type="l", main="ROC", 
            xlab="Taux faux positifs", ylab="Taux vrai positifs", ...)
        abline(a=0, b=1)
    }
}
