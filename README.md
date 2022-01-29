# Cloud-TP3

L'objectif de ce TP est de déployer une infrastructure nextcloud supervisé avec grafana et prometheus.

Installation et execution des scripts:

```bahs
git clone https://github.com/HDCarBoNe/Cloud-TP3.git
cd Cloud-TP3
terraform apply --auto-approve
```

Le script terraform permet le déployement sur le provider scaleway:
- 2 adresses IP publique
- Un réseau privée
- Un volume pour les données de Nextcloud
- Une instance Grafana
- Une instance Nextcloud
- Une base de données

Des scripts Ansible accompagne le script terraform:
grafana.yml:
- Permet l'installation et la préconfiguration de grafana
- L'installation de prometheus
- Création de l'utilisateur grafana sur l'instance déployer
- Création de l'utilisateur prometheus sur l'instance déployer
- Changement du mot de passe de l'utilisateur admin de grafana
- Ajout de node_exporter pour la supervision des données de grafana

nextcloud.yml:
- Création de l'utilisateur nextcloud sur l'instance déployer
- Installation d'Apache2
- Installation de nextlcoud  
