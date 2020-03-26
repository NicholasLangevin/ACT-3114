
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

require(RColorBrewer)
ROC <- function(y, probPred, seuil){
    pred_binaire <- lapply(seuil, function(seuil) 
                           ifelse(probPred > seuil, 1, 0))

    table_roc <- function(etiq, pred) {
      etiq <- etiq[order(pred, decreasing = TRUE)]
      data.frame(TVP = cumsum(etiq)/sum(etiq), # Taux vrais positifs
                 TFP = cumsum(!etiq)/sum(!etiq)) # Taux faux positifs
    }

    n <- length(seuil)

    if(n > 8)
        stop("Can't draw more then 8 threshold")
    else if(n > 3)
        cols <- brewer.pal(n, "Dark2")
    else
        cols <- brewer.pal(3, "Dark2")

    plot(table_roc(y, pred_binaire[[1]]), type="l", col=cols[1])
    if(n >= 2){
        for(i in seq(2, n)){
            points(table_roc(y, pred_binaire[[i]]), type="l", col=cols[i])
        }
    }

    label <- scales::percent(seuil, prefix ="Seuil ", accuracy = 1)
    legend(x="bottomright", legend=label, col=cols, lty=1)
}
