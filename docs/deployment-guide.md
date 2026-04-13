# Kurulum Rehberi

## 1. Lokal Doğrulama

Gereksinimler:

- Docker
- Docker Compose
- Make

Çalıştırma:

```bash
make up
make status
```

Smoke akışı:

```bash
make seed
cd apps/frontend && npm ci && npx cypress run
```

Bu akış sonunda Cypress ekran görüntüleri `docs/screenshots/cypress/endToEnd.spec.js/` altına yazılır.

## 2. AWS Altyapısı

Gereksinimler:

- AWS CLI
- Terraform >= 1.5
- kubectl
- Helm 3
- Docker
- HPA davranışını doğrulamak için cluster'da `metrics-server`

Kurulum:

```bash
cd terraform
cp backend.hcl.example backend.hcl
terraform init -backend-config=backend.hcl
terraform plan -var="github_repository=<owner>/<repo>"
terraform apply -var="github_repository=<owner>/<repo>"
```

Alternatif olarak `terraform.tfvars` içine şu değeri koyabilirsiniz:

```hcl
github_repository = "<owner>/<repo>"
```

Bu değişken verildiğinde Terraform, GitHub Actions için repo-scoped OIDC provider/role ve EKS access entry üretir.

Çıktılar:

- EKS cluster adı
- ECR repository URL'leri
- `github_actions_role_arn`

`AWS_ROLE_ARN` GitHub secret'ını Terraform output'undan doldurun:

```bash
terraform output -raw github_actions_role_arn
```

`kubectl` erişimi:

```bash
aws eks update-kubeconfig --region eu-west-1 --name baykar-devops-eks
kubectl get nodes
```

## 3. GitHub Actions Hazırlığı

Repository secret'ları:

- `AWS_ROLE_ARN`
- `ALERT_WEBHOOK_URL`
- `MONGO_ROOT_USER`
- `MONGO_ROOT_PASS`

CI `main` branch'e push edildiğinde image'ları SHA tag ile ECR'a yollar. `deploy.yml` workflow'u başarılı CI koşusundan sonra deploy yapar.

OIDC trust policy varsayılan olarak yalnızca `main` branch için izin verir. Başka bir branch kullanılacaksa `github_oidc_branch` değişkenini Terraform'da güncelleyin.

## 4. Manuel Kubernetes Deploy

Workflow dışında elle deploy etmek gerekirse:

```bash
kubectl apply -f k8s/namespace.yaml

kubectl create secret generic mongodb-secret \
  --namespace baykar-app \
  --from-literal=mongo-root-username='<user>' \
  --from-literal=mongo-root-password='<password>'

kubectl apply -f k8s/mongodb/statefulset.yaml
kubectl apply -f k8s/mongodb/service.yaml
kubectl apply -f k8s/backend/
kubectl apply -f k8s/frontend/
kubectl apply -f k8s/etl-cronjob.yaml
kubectl apply -f k8s/network-policy.yaml

kubectl apply -f k8s/monitoring/namespace.yaml

cat > /tmp/alertmanager.yml <<'EOF'
global:
  resolve_timeout: 5m
route:
  receiver: critical-webhook
  group_by: ['alertname']
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 2h
receivers:
  - name: critical-webhook
    webhook_configs:
      - url: https://example.invalid/alertmanager-webhook
        send_resolved: true
EOF

kubectl create secret generic alertmanager-config \
  --namespace monitoring \
  --from-file=alertmanager.yml=/tmp/alertmanager.yml

kubectl apply -f k8s/monitoring/prometheus/alertmanager.yaml
kubectl apply -f k8s/monitoring/loki/
kubectl create configmap grafana-dashboards \
  --from-file=k8s/monitoring/grafana/dashboards/ \
  -n monitoring --dry-run=client -o yaml | kubectl apply -f -

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

helm upgrade --install monitoring-prometheus prometheus-community/prometheus \
  --namespace monitoring \
  --values helm/monitoring/prometheus-values.yaml

helm upgrade --install monitoring-grafana grafana/grafana \
  --namespace monitoring \
  --values helm/monitoring/grafana-values.yaml
```

Sonrasında uygun image'ları set edin:

```bash
kubectl set image statefulset/mongodb mongodb=<ecr>/mongodb:<sha> -n baykar-app
kubectl set image deployment/frontend frontend=<ecr>/frontend:<sha> -n baykar-app
kubectl set image deployment/backend backend=<ecr>/backend:<sha> -n baykar-app
kubectl set image cronjob/etl etl=<ecr>/etl:<sha> -n baykar-app

kubectl create job --from=cronjob/etl etl-smoke-manual -n baykar-app
kubectl wait --for=condition=complete job/etl-smoke-manual -n baykar-app --timeout=180s
kubectl logs job/etl-smoke-manual -n baykar-app
```

## 5. Doğrulama

Rollout:

```bash
kubectl rollout status statefulset/mongodb -n baykar-app
kubectl rollout status deployment/backend -n baykar-app
kubectl rollout status deployment/frontend -n baykar-app
```

Dış erişim hostname'i:

```bash
kubectl get svc frontend -n baykar-app
curl http://<load-balancer-hostname>/api/readyz/
kubectl get cronjob etl -n baykar-app
kubectl get jobs -n baykar-app --sort-by=.metadata.creationTimestamp
```

Monitoring erişimi:

```bash
kubectl port-forward -n monitoring svc/monitoring-grafana 3000:80
kubectl port-forward -n monitoring svc/monitoring-prometheus-server 9090:80
```

## 6. Sorun Giderme

| Sorun | Kontrol |
|---|---|
| Frontend dışarı açılmıyor | `kubectl get svc frontend -n baykar-app -o wide` |
| Backend readiness başarısız | `kubectl logs deployment/backend -n baykar-app` |
| MongoDB bağlantı sorunu | Secret değerleri ve `readyz` çıktısı |
| Prometheus target down | `kubectl port-forward svc/monitoring-prometheus-server -n monitoring 9090:80` ve Targets ekranı |
| Log görünmüyor | `kubectl get pods -n monitoring -l app=promtail` |

`/tmp/alertmanager.yml` geçici dosyasını iş bittikten sonra silebilirsiniz.
Webhook örneği için `docs/alertmanager-config.example.yml` dosyasına bakabilirsiniz.
