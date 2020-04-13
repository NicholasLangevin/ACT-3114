

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

## Mod final
mod_glm_final <- mod_glm_reduit3
summary(mod_glm_final)


## Seuil optimal et tableau de confusion
roc.mod <- roc(ifelse(testData$lapse == "resignation", 1, 0), as.numerci(fitted(mod_glm_final)))

res_optimal <- pROC::coords(roc.mod, "best", best.method = "closest.topleft",
                        ret = c("thr", "spec", "sens", "accuracy", "tn", "tp", "fn", "fp", "precision"),
                        transpose = TRUE)

# seuil_optimal_glm <- res_optimal[1]
# specifite_glm <- res_optimal[2]
# sensitivite_glm <- res_optimal[3]
# precision_glm <- res_optimal[9]
# a_glm <- res_optimal[5]
# d_glm <- res_optimal[6]
# b_glm <- res_optimal[8]
# c_glm <- res_optimal[7]

## Mod final performance 

pred.glm <- predict(mod_glm_final, newdata = testData, type = "response")
roc_auc <- roc(ifelse(testData$lapse == "resignation", 1, 0), as.numeric(pred.glm), auc=TRUE, plot=FALSE, quiet = TRUE, col="red")




























