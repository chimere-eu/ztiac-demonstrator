# Rapport de validation des performances, de la résilience et de la sécurité du démonstrateur ZTIAC

## 1. Introduction
Ce document présente les résultats des tests réalisés sur le démonstrateur ZTIAC, afin de valider ses performances, sa résilience et son niveau de sécurité.  
L’objectif est de vérifier la conformité du démonstrateur aux objectifs techniques fixés dans le projet, en particulier :  
- garantir des performances stables et reproductibles,  
- démontrer la résilience des composants face aux pannes et aux variations de charge,  
- valider l’intégration de mécanismes de sécurité by design (Zero Trust, segmentation, conformité aux bonnes pratiques).  



## 2. Méthodologie de validation
### 2.1 Environnement de démonstration
- Description des ressources utilisées :  
  - Machines virtuelles (VM) : tinav5.c2r4p3,  2 vCPU 4Go RAM
  - Modules pour services applicatifs : Jitsi, Keycloak, Nextcloud, Outline, OpenBao, reverse proxies (privé/public), agent de transfert Chimere
  - OS utilisé : ami-7814b5cd de Outscale Ubuntu-24.04-2025.07.07 
  - Versions logicielles : Définies dans les scripts d’installation et les modules Terraform  
- Localisation :  
  - Déploiement sur cloud privé Outscale Région Gov (SecNumCloud)

### 2.2 Scénarios de démonstration

Scénarios : 
- Déploiement _from scratch_.
- Accès utilisateur externe sur application publique : Jitsi Meet
- Accès utilisateur interne sur applications privées via solution Zero Trust Chimere.
- Simulation arret des machines et redémarrage.
- Simulation desctruction de la machine et recréation via Terraform (redimensionnement par exemple) avec persistence du volume et des données.  

## 3. Validation des performances
### 3.1 Tests réalisés
- Déploiement automatisé d’infrastructures via les modèles IaC.  
- Temps moyen de déploiement complet.  
- Validation du dimensionnement de la brique Zero Trust.  
- Latence réseau mesurée entre l’utilisateur et l’application protégée.  

### 3.2 Résultats
- Déploiement complet sans erreur : ✅
- Accès utilisateur externe sur application publique : ✅
- Accès utilisateur interne sur applications privées via solution Zero Trust Chimere : ✅
- Temps de déploiement moyen : `<10 minutes`
- Brique Chimere Zero Trust : dimensionné correctement pour un usage simultané jusqu'à 100 utilisateurs.


### 3.3 Analyse
Les résultats démontrent que les performances sont conformes aux attentes, avec des temps de déploiement au niveau des standards du marché. Le dimensionnement est correct pour l'usage attendu sur un démonstrateur. La variable et le redimensionnement est aisé à ajuster pour une montée en charge.



## 4. Validation de la résilience
### 4.1 Tests réalisés
- Simulation arret des machines et redémarrage.
- Simulation desctruction de la machine et recréation via Terraform (redimensionnement par exemple) avec persistence du volume et des données.  
- Redémarrage d’un composant critique (serveur agent Zero Trust).  

### 4.2 Résultats
- Temps moyen de reprise après redémarrage : `<60 secondes` pour la VM et depand de l'application ensuite (gloabelement `<60 secondes` également.).  
- Aucun incident de perte de données constaté.  


### 4.3 Analyse
Le démonstrateur confirme sa capacité à absorber des incidents tout en garantissant la continuité de service. Les mécanismes d’orchestration IaC permettent un redéploiement rapide et automatisé.  



## 5. Validation de la sécurité
### 5.1 Tests réalisés
- Audit de configuration des modèles IaC.  
- Vérification de la segmentation réseau et des politiques Zero Trust.  

### 5.2 Résultats
- Aucune faille critique identifiée.  
- Authentification et autorisations conformes aux principes de moindre privilège.  
- Communications chiffrées jusqu'au reverse proxy, HTTP dans des zones réseau closes (locales et restreintes).   

### 5.3 Analyse
La sécurité est intégrée nativement dans le démonstrateur. L’approche “by design” renforce la robustesse face aux menaces et réduit la surface d’attaque.  



## 6. Conclusion
Les tests menés sur le démonstrateur ZTIAC permettent de valider :  
- des **performances conformes** aux objectifs des temps de déploiement attendus et un accès immédiat.
- une **résilience avérée**, grâce à la capacité de reprise rapide après incident et au maintien de la disponibilité,  
- une **sécurité robuste**, reposant sur l’intégration native de principes Zero Trust et de bonnes pratiques IaC.  

Le démonstrateur répond pleinement aux enjeux fixés et constitue une base solide pour une mise en production et une industrialisation à plus grande échelle.


