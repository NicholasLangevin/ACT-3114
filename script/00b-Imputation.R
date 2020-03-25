library(dplyr)
library(mice)
load(file="../data/DataPreTraitement.RData") # Import as data

summary(data[,c("vehicl_garage", "policy_caruse", "polholder_diffdriver")])
# Choix des methode
methode <- c("sample","sample","polyreg","sample","sample","sample","logreg","sample","sample","sample","sample","sample","sample","sample","sample","polyreg","sample","sample", "sample")
donnees.imp <- mice(data %>% select(-lapse), m=1, method=methode, print=FALSE, seed=1096)
summary(donnees.imp)
data.compl <- mice::complete(donnees.imp)
data.compl <- cbind(data %>% select(lapse), data.compl)

# Summary apres semble similaire a avant
summary(data.compl[,c("vehicl_garage", "policy_caruse", "polholder_diffdriver")])
# Il ne reste bien plus de donnees.
apply(data.compl, 2, FUN = function(x) sum(is.na(x)))
data <- data.compl

save(data, file="../data/DataImputation.RData")
