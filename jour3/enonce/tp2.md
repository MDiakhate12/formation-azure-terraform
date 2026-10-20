# TP2 : mon application en ligne

**Objectif** : voir votre application tourner sur Internet, avec une adresse fournie par Azure. **Durée** : 30 minutes.

## Étapes

1. Lisez le registre partagé avec `data "azurerm_container_registry"` (`acrformationtf`, dans `rg-formation-partage`).
2. Appelez le module : `source = "./modules/app"`, `namespace`, `prenom`, `registry` (le `login_server` du data), `tag = "v1"`, `replicas = 2`.
3. Dans le module, ajoutez `frontend-service.tf` : un `kubernetes_service_v1` de type `LoadBalancer`, `selector = { app = "frontend" }`, port `80` vers `target_port = 8080`.
4. Dans `modules/app/outputs.tf`, ajoutez l'output `url` :
   `"http://${kubernetes_service_v1.frontend.status[0].load_balancer[0].ingress[0].ip}"`.
   À la racine, exposez-le en `app_url`.
5. `apply` : l'attente de l'IP publique prend une à deux minutes.
6. Ouvrez l'URL et actualisez : le nom du pod du service A change.
7. Supprimez le pod du service B : `kubectl delete pod -n app -l app=service-b`. Actualisez : le compteur a survécu.

## Questions

- Pourquoi le service B n'a-t-il qu'un réplica ?
- Quel objet Azure a été créé pour votre Service `LoadBalancer` ? Où est-il ?

## Pour aller plus loin

Passez `dns_label_enabled = true` au module et ouvrez `http://tf-<prénom>.swedencentral.cloudapp.azure.com`.
