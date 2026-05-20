# Variáveis do projeto

## GitHub Actions (fonte oficial no CI)

Configure em **Settings → Secrets and variables → Actions → Variables**:

| Variável | Exemplo |
|----------|---------|
| `GCP_PROJECT_ID` | `project-b2a6f725-ff7b-4b80-b72` |
| `GCP_PROJECT_NUMBER` | `163992060318` |
| `GKE_CLUSTER_LOCATION` | `us-central1-a` |
| `GKE_CLUSTER_NAME` | `cluster-satc-devops` |
| `K8S_NAMESPACE` | `satc-devops` |

Os workflows usam `${{ vars.NOME_DA_VARIAVEL }}` — não leem `config/variables.env`.

**Secrets** obrigatórios:

- `GCP_SA_KEY` — JSON da service account GCP
- `DOCKER_USERNAME` / `DOCKER_PASSWORD` — Docker Hub

## Uso local

O arquivo [`variables.env`](variables.env) é só para desenvolvimento local (manter igual ao GitHub):

```bash
source config/variables.env
export DOCKER_IMAGE=seu-usuario/thiago-almeida-devops:0.0.2
./k8s/render.sh
./k8s/gke-connect.sh
kubectl apply -f k8s/rendered/
```
