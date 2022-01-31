# Cloud-TP3

![](./schéma.png)

L'objectif de ce TP est de déployer une infrastructure nextcloud supervisé avec grafana et prometheus.

Installation et execution des scripts:

```bash
git clone https://github.com/HDCarBoNe/Cloud-TP3.git
cd Cloud-TP3
terraform apply --auto-approve
```

Le script terraform permet le déployement sur le provider scaleway:
- [x] 2 adresses IP publique
- [x] Un réseau privée
- [x] Un volume pour les données de Nextcloud
- [x] Une instance Grafana
- [x] Une instance Nextcloud
- [ ] Une base de données
- [ ] Un load balancer

Des scripts Ansible accompagne le script terraform:

1. grafana.yml:
    
    - [x] Permet l'installation et la préconfiguration de grafana
    - [x] L'installation de prometheus
    - [x] Création de l'utilisateur grafana sur l'instance déployer
    - [x] Création de l'utilisateur prometheus sur l'instance déployer
    - [x] Changement du mot de passe de l'utilisateur admin de grafana
    - [x] Ajout de node_exporter pour la supervision des données de grafana
    - [ ] Ajout du dashbord pour nextlcoud
    - [ ] Supervision de Nextcloud
2. nextcloud.yml:
    
    - [x] Création de l'utilisateur nextcloud sur l'instance déployer
    - [x] Installation d'Apache2
    - [x] Installation de nextlcoud  
    - [ ] Configuration de la base de données 
    - [ ] Installation de node_exporter

---

## Variables

### grafana.yml

Mot de passe du compte admin de grafana:
```yml
grafana_admin_pwd: "Epsi2022!123"
```

Version de node_exporter:
```yml
node_exporter_version: "1.3.1"
```

Durée de rétention des données de prometheus:
```yml
prometheus_retention_time: "365d"
```

Interval de récupération des données:
```yml
prometheus_scrape_interval: "30s"
```

### nextcloud.yml

Version de Nextlcoud:
```yml
nextcloud_verison: "21.0.1"
```