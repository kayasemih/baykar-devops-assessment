# Baykar DevOps / SRE Technical Assessment

Bu repo, verilen iki projeyi teslim edilebilir bir DevOps cozumune donusturmek icin hazirlanmistir:

- MERN stack web uygulamasi
- Saatlik calisan Python ETL gorevi

## Teslim Bilgisi

- GitHub repository: `https://github.com/kayasemih/baykar-devops-assessment-submission`
- Teslim paketi: `baykar-devops-assessment-submission.zip`

## Son Teslim Yorumu

```text
Merhaba,

DevOps / SRE teknik vaka calismasi teslimim ektedir.

GitHub repository adresi:
https://github.com/kayasemih/baykar-devops-assessment-submission

Bu calisma kapsaminda:
- MERN uygulamasi Docker ile containerize edildi
- Kubernetes ile orkestrasyon yapildi
- Terraform ile AWS altyapisi tanimlandi
- GitHub Actions ile CI/CD pipeline kuruldu
- Logging, monitoring ve alerting yapisi eklendi
- Python ETL gorevi saatlik calisacak sekilde hazirlandi
- Calisan sisteme ait ekran goruntuleri ve teknik dokumantasyon repo icine eklendi

Tesekkur ederim.
```

Amac; uygulamalari containerize etmek, Kubernetes uzerinde calistirmak, CI/CD otomasyonu kurmak, gozlemlenebilirlik eklemek ve tum sureci dokumante etmektir.

## Kullanilan Teknolojiler

- Docker
- Kubernetes
- GitHub Actions
- Terraform
- AWS EKS ve ECR
- MongoDB
- React
- Express.js / Node.js
- Python
- Prometheus, Grafana, Loki, Alertmanager

## Cozum Ozeti

Bu calismada:

- Frontend, backend, MongoDB ve ETL bilesenleri Docker ile containerize edildi
- Kubernetes manifestleri ile uygulama orkestrasyonu kuruldu
- Terraform ile AWS altyapisi tanimlandi
- GitHub Actions ile CI ve CD pipeline'lari olusturuldu
- Monitoring, logging ve alerting katmani eklendi
- Calisan sistem icin ekran goruntuleri ve teslim kanitlari repo icine eklendi

## Mimari

```text
Internet
  |
AWS LoadBalancer Service
  |
Frontend (React + Nginx)
  |
Backend (Express API)
  |
MongoDB StatefulSet

ETL CronJob -> Python ETL
Prometheus -> backend /metrics
Grafana -> Prometheus + Loki
Promtail -> Loki
Alertmanager -> webhook notifications
```

## Karsilanan Gereksinimler

### MERN Uygulamasi

- MongoDB baglantisi mevcut
- Backend endpoint'leri calisir durumda
- Frontend sayfalari calisir durumda
- Docker image'lari hazir
- Kubernetes deployment dosyalari hazir

### Python Projesi

- `ETL.py` Kubernetes CronJob olarak saatlik calisacak sekilde tanimlandi

## Repo Icerigi

- `apps/` uygulama kaynak kodlari ve Dockerfile'lar
- `k8s/` Kubernetes manifestleri
- `terraform/` AWS altyapi tanimlari
- `.github/workflows/` CI/CD pipeline'lari
- `helm/` monitoring values dosyalari
- `docs/` mimari, deployment, guvenlik, zorluklar ve teslim kanitlari

## Degerlendirici Icin Hizli Rehber

Oncelikli bakilabilecek dosyalar:

1. `README.md`
2. `docs/submission-checklist.md`
3. `docs/architecture.md`
4. `docs/deployment-guide.md`
5. `docs/security-considerations.md`
6. `docs/challenges.md`

## Kanit Dosyalari

Canli sistem ve pipeline kanitlari su klasordedir:

- `docs/screenshots/eks/frontend-lb-home.png`
- `docs/screenshots/eks/backend-readyz.png`
- `docs/screenshots/eks/etl-job-success.png`
- `docs/screenshots/eks/github-actions-green.png`

Lokal smoke test ekran goruntuleri:

- `docs/screenshots/cypress/endToEnd.spec.js/app-home.png`
- `docs/screenshots/cypress/endToEnd.spec.js/record-list.png`

## Lokal Calistirma

```bash
make up
make status
```

Beklenen lokal endpoint'ler:

- Frontend: `http://localhost:3000`
- Backend health: `http://localhost:5050/healthcheck/`
- Backend readiness: `http://localhost:5050/readyz/`

Istege bagli komutlar:

```bash
make seed
make etl
```

## CI/CD

- `ci.yml`: build, test, smoke test, image build ve image scan adimlarini calistirir
- `deploy.yml`: EKS deploy, rollout, ETL smoke run ve readiness dogrulamasini yapar

## Guvenlik ve Operasyon Notlari

- AWS erisimi GitHub Actions OIDC ile saglanir
- MongoDB credential'lari repo icine secret olarak commit edilmez
- Backend ve frontend non-root calisacak sekilde tanimlanmistir
- MongoDB erisimi Kubernetes icinde sinirlandirilmistir

## Sinirlamalar

- MongoDB tek replika olarak calisir
- Monitoring bilesenleri persistent storage kullanmaz
- TLS ve production-grade backup bu kapsamda uygulanmamistir

## Sonuc

Bu repo, istenen vaka calismasini kapsayan Docker, Kubernetes, Terraform, CI/CD, monitoring ve teslim kanitlari ile birlikte tamamlanmis bir teslim paketidir.
