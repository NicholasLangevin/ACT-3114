

load("../data/trainData.RData")
load("../data/testData.RData")

library(pROC)


mod_glm_base <- glm(lapse ~ ., family=binomial, data=trainData)

## Premiere reduction
drop1(mod_glm_base, test = "Chisq")
mod_glm_reduit <- update(mod_glm_base, .~. -policy_caruse -policy_nbcontract -vehicl_agepurchase -prem_index -vehicl_powerkw)
anova(mod_glm_reduit, mod_glm_base, test = "Chisq") # car on fait une reduction multiple


## Deuxieme reduction
drop1(mod_glm_reduit, test = "Chisq")
mod_glm_reduit2 <- update(mod_glm_reduit, .~. -prem_pure)


## Troisieme reduction ? -> oui 
drop1(mod_glm_reduit2, test = "Chisq")
mod_glm_reduit3 <- update(mod_glm_reduit2, .~. -vehicl_garage)


## Quatrieme reduction ? 
drop1(mod_glm_reduit3, test = "Chisq") # non au seuil 1%


mod_glm_final <- mod_glm_reduit3
summary(mod_glm_final)

pred.glm <- predict(mod_glm_final, newdata = testData, type = "response")

roc_auc <- roc(ifelse(testData$lapse == "resignation", 1, 0), as.numeric(pred.glm), auc=TRUE, plot=FALSE, quiet = TRUE, col="red")

