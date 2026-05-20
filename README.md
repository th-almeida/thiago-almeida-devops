# thiago-almeida-devops

Repositório de estudos e práticas em **DevOps** e **SRE** (Site Reliability Engineering).

GitHub: `thiago-almeida-devops`

---

## Índice

- [Sobre](#sobre)
- [DevOps](#devops)
- [SRE](#sre)
- [DevOps x SRE](#devops-x-sre)
- [Projetos no repositório](#projetos-no-repositório)
- [Kubernetes](#kubernetes)
- [Variáveis GCP / GKE](#variáveis-gcp--gke)

---

## Sobre

Este repositório reúne conceitos, materiais e exemplos relacionados à cultura DevOps e à engenharia de confiabilidade de sistemas (SRE).

---

## DevOps

**DevOps** é uma cultura e conjunto de práticas que buscam integrar as áreas de desenvolvimento e operações, com o objetivo de entregar software de forma mais rápida, eficiente e segura.

- **Objetivo:** melhorar a colaboração entre os times e automatizar processos como testes, integração e deploy.
- **Práticas:** CI/CD, infraestrutura como código (IaC), entre outras.
- **Benefícios:** redução de erros, entregas mais rápidas e maior qualidade no produto final.

---

## SRE

**SRE** (Site Reliability Engineering) é uma abordagem criada pelo Google que aplica conceitos de engenharia de software para resolver problemas de infraestrutura e confiabilidade.

- **Foco:** garantir que os sistemas sejam estáveis, escaláveis e confiáveis.
- **Métricas:** SLA, SLO e SLI para medir desempenho e disponibilidade.
- **Atuação:** automação, resposta a incidentes e melhoria contínua da confiabilidade.

---

## DevOps x SRE

| Aspecto    | DevOps              | SRE                    |
| ----------| --------------------| -----------------------|
| Ênfase    | Cultura e integração| Confiabilidade técnica |
| Abordagem | Colaboração entre times | Métricas, automação e operação |

De forma geral, **DevOps** está mais relacionado à cultura e à integração entre equipes, enquanto **SRE** é uma forma mais prática e técnica de garantir a confiabilidade dos sistemas em produção. Ambos são fundamentais para o desenvolvimento moderno de software.

---

## Projetos no repositório

| Projeto       | Descrição                          |
| ------------- | ---------------------------------- |
| **gremio-page** | Página em React (Vite) sobre o Grêmio Foot-Ball Porto Alegrense. |

Para rodar o frontend do Grêmio:

```bash
cd gremio-page
npm install
npm run dev
```

Acesse em [http://localhost:5173](http://localhost:5173).

---

## Kubernetes

Manifests para as aulas de **HPA** (Aula 10) e **Deploys / Probes** (Aula 11): Rolling Update, Blue-Green, Canary e workflows de deploy no GitHub Actions.

### Pré-requisitos

- Cluster Kubernetes com `kubectl` configurado
- [Metrics Server](https://github.com/kubernetes-sigs/metrics-server) (obrigatório para o HPA por CPU)
- [NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/) (apenas para a estratégia Canary)
- Imagem publicada no Docker Hub (`thiago-almeida-devops`, via workflow `docker_check.yml`)

### Estrutura

```
k8s/
  deployment.yaml      # Rolling Update + probes
  service.yaml
  hpa.yaml             # app-satc-hpa (CPU 70%, 1–5 réplicas)
  render.sh
  blue-green/          # Deployments blue/green + service router
  canary/              # Stable + canary + Ingress (10%)
```

### Renderizar e aplicar manifests

Substitua os placeholders `##K8S_NAMESPACE##`, `##DOCKER_IMAGE##` e `##APP_HOST##`:

```bash
source config/variables.env
export DOCKER_IMAGE=seu-usuario/thiago-almeida-devops:0.0.2
export APP_HOST=gremio.local
chmod +x k8s/render.sh k8s/gke-connect.sh
./k8s/render.sh
./k8s/gke-connect.sh
kubectl apply -f k8s/rendered/
```

Validação local (sem cluster):

```bash
kubectl apply --dry-run=client -f k8s/rendered/
```

### Estratégias de deploy

| Estratégia | Manifests | Comando / Workflow |
|------------|-----------|-------------------|
| **Rolling Update** | `k8s/deployment.yaml`, `service.yaml`, `hpa.yaml` | `.github/workflows/deploy-rolling.yml` |
| **Blue-Green** | `k8s/blue-green/` | `.github/workflows/deploy-blue-green.yml` |
| **Canary** | `k8s/canary/` | `.github/workflows/deploy-canary.yml` |

**Blue-Green** — virar tráfego manualmente:

```bash
kubectl patch service app-satc-traffic-router -n satc-devops \
  -p '{"spec":{"selector":{"app":"satc","version":"green"}}}'
```

**Canary** — Ingress com 10% do tráfego (`nginx.ingress.kubernetes.io/canary-weight: "10"`).

### Health probes

O Nginx na imagem Docker expõe:

- `/healthz` — startup e liveness
- `/ready` — readiness

### Aula 10 — HPA e Metrics Server

O manifest do HPA está em [`k8s/hpa.yaml`](k8s/hpa.yaml) (igual ao slide da aula). O HPA **só funciona** se o **Metrics Server** estiver instalado no cluster:

```bash
chmod +x k8s/metrics-server/install.sh
./k8s/metrics-server/install.sh
```

Criar o namespace e aplicar app + HPA:

```bash
./k8s/render.sh
kubectl apply -f k8s/rendered/namespace.yaml
kubectl apply -f k8s/rendered/deployment.yaml
kubectl apply -f k8s/rendered/service.yaml
kubectl apply -f k8s/rendered/hpa.yaml
```

### Testar HPA

```bash
kubectl get hpa -n satc-devops
kubectl describe hpa app-satc-hpa -n satc-devops
kubectl top pods -n satc-devops
```

Gerar carga para forçar scale up (job opcional):

```bash
kubectl apply -f k8s/rendered/load-test/cpu-load-job.yaml
kubectl get hpa -n satc-devops -w
```

---

## Variáveis GCP / GKE

**No GitHub (CI):** Settings → Secrets and variables → Actions → **Variables** (fonte usada pelos workflows via `vars.*`).

**Local:** copie os mesmos valores em [`config/variables.env`](config/variables.env).

| Variável | Valor |
|----------|-------|
| `GCP_PROJECT_ID` | `project-b2a6f725-ff7b-4b80-b72` |
| `GCP_PROJECT_NUMBER` | `163992060318` |
| `GKE_CLUSTER_LOCATION` | `us-central1-a` |
| `GKE_CLUSTER_NAME` | `cluster-satc-devops` |
| `K8S_NAMESPACE` | `satc-devops` |

Detalhes em [`config/README.md`](config/README.md).

### Secrets do GitHub Actions (deploy)

| Secret | Uso |
|--------|-----|
| `GCP_SA_KEY` | JSON da service account GCP (acesso ao GKE) |
| `DOCKER_USERNAME` | Usuário Docker Hub (já usado no CI) |
| `DOCKER_PASSWORD` | Senha/token Docker Hub |

Os workflows de deploy usam `workflow_dispatch`, leem as **Repository Variables** do GitHub (`vars.GCP_PROJECT_ID`, `vars.K8S_NAMESPACE`, etc.) e autenticam no GKE.
