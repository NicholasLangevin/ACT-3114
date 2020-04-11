#!/usr/bin/env Rscript

library(CASdatasets)

data(eudirectlapse)
data.init <- eudirectlapse

## Changement dans les donnees
data <- data.init

# Changement des 0 et 1 de lapse en renouvellement et resignation
data$lapse <- as.factor(data$lapse)
levels(data$lapse) <- c("renouvellement", "resignation")

# Changment des valeurs unknown en NA des variables:
# polholder_diffdriver, vehicl_garage et policy_caruse
data[data$polholder_diffdriver == "unknown", ]$polholder_diffdriver <- NA
data[data$vehicl_garage == "unknown", ]$vehicl_garage <- NA
data[data$policy_caruse == "unknown", ]$policy_caruse <- NA

# Reordonnement de la variable prem_freqperyear en facteur ordonnée (ordinal)
data$prem_freqperyear <- factor(data$prem_freqperyear, order = TRUE, levels = c("1 per year", "2 per year", "4 per year", "12 per year"))

# Regions
data$vehicl_region <- factor(data$vehicl_region, order = FALSE, levels = c("Reg1", "Reg2", "Reg3", "Reg4", "Reg5", "Reg6", "Reg7", "Reg8", "Reg9", "Reg10", "Reg11", "Reg12", "Reg13", "Reg14"))

# Creation d un nouvelle variable prem_index=prem_final/prem_last
data$prem_index <- data$prem_final / data$prem_last - 1

# Traitement de la variable vehicl_powerkw: regroupement en 4 groupe
#data$vehicl_powerkw_na <- data$vehicl_powerkw
#data[data$vehicl_powerkw_na == "125-300 kW", ]$vehicl_powerkw_na <- NA
data[data$vehicl_powerkw %in% c("150 kW","175 kW","200 kW","225 kW","250 kW","275 kW","300 kW"), ]$vehicl_powerkw <- "125-300 kW"
data <- droplevels(data)
data$vehicl_powerkw <- factor(data$vehicl_powerkw, order = TRUE, levels = c("25-50 kW", "75 kW", "100 kW", "125-300 kW"))
table(data$vehicl_powerkw)

save(data, file="../data/DataPreTraitement.RData")
