# Application du jour 3

Point de départ des TP1 et TP2. Le module `modules/microservices` est fourni : lisez-le avant de l'appeler.

| Fichier du module | Contenu |
|---|---|
| `frontend.tf` | Deployment du frontend (page web, port 8080) |
| `service-a.tf` | Deployment du service A (renvoie le nom du pod) |
| `service-b.tf` | Deployment du service B (compteur sur volume) et son PVC |
| `services.tf` | Services internes `service-a` et `service-b` |
| `variables.tf` | `namespace`, `prenom`, `registry`, `tag`, `replicas`, `dns_label_enabled`, `node_selector` |

Il manque le Service `LoadBalancer` du frontend et l'output `url` : vous les ajoutez au TP2.

Registre : `acrformationtf.azurecr.io`. Tags : `v1` et `v2` (en `v2`, le frontend change de couleur).
