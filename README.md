# Baykar DevOps / SRE Case Study

Bu repo, MERN uygulamasını ve Python ETL işini Docker, Kubernetes, GitHub Actions ve Terraform ile teslim edilebilir hale getirmek için hazırlanmıştır.

## Kapsam

- Dockerized frontend, backend, MongoDB ve ETL akışı
- Kubernetes manifestleri ile uygulama orkestrasyonu
- GitHub Actions tabanlı CI/CD
- Prometheus, Alertmanager, Grafana, Loki ve Promtail ile gözlemlenebilirlik
- AWS altyapısı için Terraform tanımları
- Mimari, kurulum, güvenlik ve zorluk dokümantasyonu

## Mimari Özeti

```text
Internet
  |
AWS LoadBalancer Service (frontend)
  |
Frontend Nginx (React SPA, /api reverse proxy)
  |
Backend Express API
  |
MongoDB StatefulSet

Prometheus -> backend /metrics
Grafana -> Prometheus + Loki
Promtail -> Loki
ETL CronJob -> Python job
```

EKS tarafında dış erişim `frontend` servisini `LoadBalancer` olarak açarak sağlanır. Bu tercih, ek ingress controller kurulumu gerektirmediği için repo içinde uçtan uca daha tekrarlanabilir bir yol sağlar.

## Lokal Çalıştırma

```bash
make up
make status
```

Beklenen endpoint'ler:

- Frontend: `http://localhost:3000`
- Backend liveness: `http://localhost:5050/healthcheck/`
- Backend readiness: `http://localhost:5050/readyz/`

İsteğe bağlı:

```bash
make seed
make etl
```

## CI Pipeline

`.github/workflows/ci.yml` şu adımları çalıştırır:

1. Dockerfile ve Kubernetes manifest doğrulaması
2. Frontend, backend, MongoDB ve ETL image build'i
3. Backend unit testleri
4. Docker Compose ile entegrasyon doğrulaması
5. Cypress UI smoke testi
6. Trivy image taraması
7. `main` branch'inde immutable SHA tag'i ile ECR push

`:latest` push edilmez. ECR immutable olduğu için dağıtım sadece commit SHA tag'leriyle yapılır.

## CD Pipeline

`.github/workflows/deploy.yml` başarılı CI sonrası:

1. EKS kubeconfig oluşturur
2. `mongodb-secret` değerlerini GitHub secret'lardan üretir
3. Alertmanager webhook secret'ını üretir
4. Uygulama manifestlerini, Loki/Alertmanager bileşenlerini ve Helm tabanli monitoring release'lerini uygular
5. Frontend, backend, MongoDB ve ETL workload'larini SHA tag'li ECR image'lari ile render edip uygular
6. MongoDB icin stale pod kaldiysa yeni StatefulSet revision'iyle yeniden olusmasini zorlar
7. ETL CronJob'u bir kez tetikleyip tamamlandığını doğrular
8. Rollout bekler
9. Dış yük dengeleyici üzerinden `http://<lb>/api/readyz/` smoke testi yapar
10. Başarısızlıkta frontend ve backend deployment rollback uygular

Gerekli GitHub secret'ları:

- `AWS_ROLE_ARN`
- `ALERT_WEBHOOK_URL`
- `MONGO_ROOT_USER`
- `MONGO_ROOT_PASS`

`AWS_ROLE_ARN`, `terraform` apply sırasında `github_repository` değişkeni verilirse `github_actions_role_arn` output'u olarak üretilebilir.

Not: `deploy.yml` eksik cluster veya secret durumunda warning verip deploy adımlarını bilincli olarak skip eder. Bu nedenle tek basina yesil bir deploy run'i, EKS'e gercekten deploy edildigi anlamina gelmez; final teslimat icin cluster, secret'lar ve dis erişim/ETL kanitlari da tamamlanmis olmalidir.

## Gözlemlenebilirlik

- Backend `prom-client` ile gerçek HTTP metrikleri yayınlar
- Prometheus sadece gerçek scrape target'larını toplar
- Alertmanager secret-backed webhook receiver ile kritik alert bildirimleri yollar
- Grafana, Helm values dosyalarindan Prometheus ve Loki datasource'lari ile gelir
- Promtail pod log'larını Loki'ye taşır

Ana alertler:

- `BackendDown`
- `HighErrorRate`
- `HighLatency`

## Güvenlik Notları

- Frontend `nginx-unprivileged` image'ı ile non-root çalışır
- Backend container ve pod security context ile non-root çalışır
- MongoDB credential'ları repoya commit edilmez
- CI/CD AWS erişimi OIDC ile yapılır
- NetworkPolicy ile MongoDB sadece backend tarafından erişilebilir

## Terraform

`terraform/` altında VPC, subnet, EKS, node group, ECR ve GitHub Actions OIDC rol tanımları bulunur. MongoDB image'ı için ayrı ECR repository de eklenmiştir. `github_repository="owner/repo"` verildiğinde Terraform, repo-scoped IAM role ve EKS access entry oluşturarak CI/CD'nin ECR push ve `kubectl` deploy yapabilmesini sağlar. State dosyası ekip çalışmasına uygun şekilde S3 backend ile tutulacak şekilde yapılandırılmıştır; örnek backend ayarları `terraform/backend.hcl.example` içindedir. Bu ortamda `terraform` kurulu olmadığı için burada `terraform validate` koşturulamadı; manifest ve workflow tarafı repo içinde düzeltildi.

## Proje Yapısı

```text
terraform/           Altyapi kodlari
helm/                Helm values dosyalari
k8s/                 Kubernetes manifestleri
  monitoring/        Loki, Alertmanager ve dashboard asset'leri
apps/                MERN, ETL ve Dockerfile'lar
.github/workflows/   CI/CD boru hatlari
docs/                Kurulum ve kanit dokumanlari
```

## Ekran Görüntüleri

`docs/screenshots/` altında ekran görüntüleri tutulur. Cypress smoke testi, lokal doğrulama sırasında görüntüleri `docs/screenshots/cypress/endToEnd.spec.js/` altına yazar.

Beklenen kanıt dosyaları:

- `docs/screenshots/cypress/endToEnd.spec.js/app-home.png`
- `docs/screenshots/cypress/endToEnd.spec.js/record-list.png`

Cloud deploy sonrası eklenen kanıt dosyalari:

- `docs/screenshots/eks/frontend-lb-home.png`
- `docs/screenshots/eks/backend-readyz.png`
- `docs/screenshots/eks/etl-job-success.png`
- `docs/screenshots/eks/github-actions-green.png`

## Final Teslim Kontrolu

Teknik hedefler ve evaluator odakli teslim kanitlari artik repo icinde tamamlanmistir.

Hazir olanlar:

- Dockerfile'lar, Kubernetes manifestleri, Terraform ve GitHub Actions workflow'lari repoda mevcut
- `main` branch deploy akisi calisan SHA image'lariyla stabilize edildi
- Lokal smoke ekran goruntuleri `docs/screenshots/cypress/endToEnd.spec.js/` altinda mevcut

- EKS kanit dosyalari `docs/screenshots/eks/` altinda mevcut

Evaluator odakli son kontrol listesi icin `docs/submission-checklist.md` dosyasina bakabilirsiniz.

## Dokümanlar

- `docs/architecture.md`
- `docs/deployment-guide.md`
- `docs/security-considerations.md`
- `docs/challenges.md`

## Sınırlamalar

- MongoDB tek replika çalışır
- Monitoring bileşenleri kalıcı disk kullanmaz
- HPA manifestleri otomatik ölçekleme için cluster'da `metrics-server` gerektirir
- TLS, external secrets ve production-grade backup bu repoda uygulanmamıştır
