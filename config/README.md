# Variáveis do projeto

Arquivo principal: [`variables.env`](variables.env)

| Variável | Valor |
|----------|-------|
| `GCP_PROJECT_ID` | `project-b2a6f725-ff7b-4b80-b72` |
| `GCP_PROJECT_NUMBER` | `163992060318` |
| `GKE_CLUSTER_LOCATION` | `us-central1-a` |
| `GKE_CLUSTER_NAME` | `cluster-satc-devops` |
| `K8S_NAMESPACE` | `satc-devops` |

## Uso local

```bash
source config/variables.env
export DOCKER_IMAGE=seu-usuario/thiago-almeida-devops:0.0.2
./k8s/render.sh
chmod +x k8s/gke-connect.sh
./k8s/gke-connect.sh
kubectl apply -f k8s/rendered/
```

## GitHub Actions

Os workflows de deploy carregam automaticamente `config/variables.env`.

Configure também no repositório (**Settings → Secrets and variables → Actions**):

**Variables** (opcional, espelham o arquivo):

- `GCP_PROJECT_ID`
- `GCP_PROJECT_NUMBER`
- `GKE_CLUSTER_LOCATION`
- `GKE_CLUSTER_NAME`
- `K8S_NAMESPACE`

**Secrets** (obrigatório para deploy no GKE):

- `GCP_SA_KEY` — JSON da service account com permissão no cluster GKE
- `DOCKER_USERNAME` / `DOCKER_PASSWORD` — Docker Hub
