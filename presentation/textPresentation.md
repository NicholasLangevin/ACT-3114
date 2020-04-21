# Introduction
TODO:

# Plan de la présentation 

# Description du problème dans un context actuariel
Dans un context d'assurance, il est important de savoir si un assurer à 
beaucoup de chance de renouveler sont contrat pour l'année suivant. Pourquoi?

- Taux de rétention:
  Savoir combien de personnes vont renouveler permet de faire un estimation
  du taux de rétention. Le taux de rétention est important dans la compagnie 
  pour deux raison. 1. Permet de calculé le taux de croissance. 
  Renouvellement + nouvelles police > 100% indique que la compagnie est
  croissante en terme d'unité. 2. Indicateur de la compétitive dans le marché.
  Si le taux de rétention réelle est plus petit que celui prédit, une raison
  potentielle est que les compétiteurs offrent des meilleurs prix, ou encore
  que le service à la clientèle porte des lacunes.
  
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

La prime pure représente l'espérance des couts. Cette prime devrait
théoriquement être chargée au client. En pratique, la prime final peut chargée
peut être différent pour des raison marketing ou de rentabilité. 

Il est surprenant de voir que les assurés avec un bon dossier sont chargée plus
cher en moyenne que lors prime théorique alors que les dossiers stable ou
mauvais sont environ égaux. De plus, les polices chargées plus cher sont ceux
qui ont résigner leur police.

## Police commercial
TODO:

## Âge de l'assuré
TODO:

## Région géographique
TODO:
