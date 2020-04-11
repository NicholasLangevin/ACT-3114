
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
        plot(table_roc(y, probPred), type="l", # main="ROC", 
            xlab="Taux faux positifs", ylab="Taux vrai positifs", ...)
        abline(a=0, b=1)
    }
}

Rmd_table <- function(dat, caption="", label="", 
                         align=rep("c", ncol(dat)+1), digits=3, ...){
 
    require(xtable)
    print(xtable(dat, digits = digits,
                 caption=caption,
                 label=label,
                 align=align),
                 include.rownames = FALSE, 
                 sanitize.text.function=function(x){x},
                 caption.placement = "top", comment=FALSE, ...)
}



# grid <- expand.grid(cp=0.0, minbucket=1)
# args <- list(formula=lapse~., method = "class", cp=0.0, minbucket=1)
# FUN <- "rpart"
# data <- testData
# nfold <- 2

vc <- function(nfold, data, FUN, args){
    if (nfold <= 1) stop("Argument 'nfold' need to be as possite integer")
    require(pROC)
    n <- nrow(data)
    taille <- n %/% nfold
    set.seed(1001)
    alea <- runif(n)
    rang <- rank(alea)
    summary(rang)
    block <- (rang-1) %/% taille + 1
    block_tmp <- as.factor(block)
    block <- ifelse(block > as.numeric(levels(block_tmp)[nfold]), nfold, block)
    block <- as.factor(block)
    
    auc <- numeric(nfold)
    for (fold in seq(nfold)){

        data.args <- list(data=data[block != fold,])
        mod <- do.call(eval(parse(text=FUN)), c(data.args, args))

        if (FUN == "knn") 
            pred <- mod$pred
        else
            pred <- predict(mod, data[block == fold,], type="prob")

        auc[fold] <- as.numeric(suppressMessages(roc(dataToNumeric(data[block == fold,], "y"), pred[, 2]))$auc)

    }
    return(auc)
}

gridSearch <- function(grid, nfold, data, FUN, args){

    grid.n <- nrow(grid)
    grid.colnames <- colnames(grid)
    fold.mean <- numeric(grid.n)
    fold.sd <- numeric(grid.n)
    percByFold <- 1/grid.n
    perc <- 0
    for (row in seq(grid.n)){

        message(scales::percent(perc, suffix =" %", accuracy = 0.01))

        grid.row <- grid[row,]
        params <- lapply(grid.row, function(row) row)
        mod.args <- c(args, params)
        call.args <- list(nfold=nfold,
                         FUN = FUN,
                         data = data,
                         args=mod.args)


        val <- do.call(vc, call.args)
        fold.mean[row] <- mean(val)
        fold.sd[row] <- sd(val)

        perc <- perc + percByFold

    }

    grid$AUCmean <- fold.mean
    grid$AUCsd <- fold.sd
    return(grid)
}

        






