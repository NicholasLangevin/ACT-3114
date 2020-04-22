# Introduction
Les contracts d'assurance IARD sont pour la plupart d'une *durée de 1 ans*.
Le renouvellement des polices est donc une étape répétitives pour les compagnies
d'assurance.

Comme dans le cas de la tarification, les compagnies d'assurances peuvent être
tenté d'optimiser ce processus pour offrir un prix unique à chaque assuré 
dependament de leurs caractéristiqueis. Cette optimisation peut permettre 
d'augmenter la rentabilité de cette compagnie.

Finalement, un autre raison pourquoi il est important de ne pas n'églifer les 
stratégie de renouvellement est que la plupart des compagnies vont données des
*rabais au nouveau* assuré dans le but d'augmenter leur *part de marché*. Il est 
donc important pour ceux-ci d'*augmenter la prime efficacement* les contracts au 
renouvellement pour premièrement ne pas perde les clients et deuxièmement 
rentabilisé leur investissement.

c'est dans cette objectif que la présentation d'aujourd'hui tente de vous 
informer sur la modélisation de la probabilité de résignation.

# Plan de la présentation 
Dans un prémier temps, je vais vous expliquer en quoi la probabilité de 
résignation peut être util dans une statégie de renouvellement.

Ensuite, je vais vous présenté brièvement les données avec lesquels nous avons
travailler pour notre analyse.

Finalement, mes collèges vont vous parler ...

# Description du problème dans un context actuariel
Premièrement:
- Taux de rétention:
  Savoir combien de personnes vont renouveler permet de faire un estimation
  du taux de rétention. Le taux de rétention est important dans la compagnie 
  pour deux raison. 1. Permet de calculé le taux de croissance. 
  Renouvellement + nouvelles police > 100% indique que la compagnie est
  croissante en terme d'unité. 2. Indicateur de la compétitive dans le marché.
  Si le taux de rétention réelle est plus petit que celui prédit, une raison
  potentielle est que les compétiteurs offrent des meilleurs prix, ou encore
  que le service à la clientèle porte des lacunes.

Deuxièmement:
- Élasticité:
  Une autre raison de calculé la probabilité de renouvellement est pour calculé
  l'élastique. Ceci représente la variation dans la probabilité de
  renouvellement pour un variation de prix donnée. Ceci permet de déterminer de
  combien l'augmentation de la prime sera pour chaque contrat. Plus la
  prédiction de renouvellement pour une police donnée est grande, plus
  l'assureur en profitera pour augmenter la prime.

# Descriptions du jeu de données
Notre jeu de données représente le statut de renouvellement pour 23 060 
polices basées sur un an d'observation. 

Les variables peuvent être classé en 3 catégories
1) Caractéristiques des conducteurs
2) Caractéristiques du véhicule assurés
3) Différentes primes

# Analyse exploratoire
## Augmentation au renouvellement 
Graphique du % d'augmentation de la prime en fonction du status de
renouvellement. On voit bien que l'augmentation de la prime est influencer par
le classement bonus malus de l'assurer. Le système bonus malus est utilisé en
assurance pour déterminer le risque de l'assurer. Si une personnes monte dans
le classement, ceci veut dire que l'assurer à eux une une mauvaise expérience
dans l'année et donc une surcharge dans sa prime. Notre base de données ne
comprend pas l'information sur la fréquence ou la sévérité.

On voit que ceux qui augmente on effectivement un hausse de prime, les stable
status co et une diminution entraine aussi un diminution de la prime. 

De plus, les personnes qui on résigné leur police semblent avoir un peut plus 
de variance.

ATTENTION: Les renouvellements semblent avoir plus de grande augmentation 
de prime, mais il est important de rappeler que la base de données est 
dé balancé et ceci pourrait expliquer pourquoi.

## Augmentation par rapport à la prime pure
Ce graphique représente l'augmentation de la prime final chargée au client et
la prime pure. 

*La prime pure* représente l'espérance des couts. Cette prime devrait
théoriquement être chargée au client. En pratique, la prime final peut chargée
peut être différent pour des raison marketing ou de rentabilité. 


Les *bon dossier* sont chargée plus cher que leur prime theorique. Diminuer 
dans le systeme bonus malus signifie que l experience est bonne depuis
plusieurs années. donc la compagnie dinimu la prime, mes pas autant qu'elle
devrait pour faire du profit. 

Les stable et up sont similaire, mais dans le cas des resignations, le 3e
quartile est plus élever. Cest normal, parce que les concurrant on sensiblement
une tarrification similaire et charge plus proche des cettes prime pure.


## Police commercial
*Age de la voiture et de l'assuré* sont des bon indicateur de resignation
dans le cas de police commercial

Les jeunes qui ont des compagnie vont plus probablement magasiner chaque années
pour trouver le meilleurs prix.

Finalement, les police commercial garde leur auto plus longtemps, mais vers 15
ans les chance qu il change leurs voiture la prochaine années est grande.
Et la compagnie d assurance ne semble pas avoir la part de marche des nouveaux
vehicule

## Âge de l'assuré

## Région géographique
TODO:
