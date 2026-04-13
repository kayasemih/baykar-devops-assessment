# Mimari

## Uygulama Akışı

```text
Internet
  |
AWS LoadBalancer Service
  |
frontend Deployment
  |- React static files
  |- Nginx reverse proxy (/api -> backend:5050)
  |
backend Deployment
  |- /healthcheck/
  |- /readyz/
  |- /record/*
  |- /metrics
  |
mongodb StatefulSet
```

Frontend dış dünyaya açılan tek uygulama bileşenidir. Backend ve MongoDB iç servis olarak kalır.

## Kubernetes Kaynakları

| Bileşen | Kaynak | Not |
|---|---|---|
| Frontend | Deployment + LoadBalancer Service | React SPA ve `/api` proxy |
| Backend | Deployment + ClusterIP Service | Express API ve Prometheus metrikleri |
| MongoDB | StatefulSet + Headless Service | Kalıcı veri ve sabit DNS |
| ETL | CronJob | Saatlik Python işi |
| Güvenlik | NetworkPolicy | MongoDB sadece backend'den erişilebilir |
| Gözlemlenebilirlik | Prometheus, Alertmanager, Grafana, Loki, Promtail | Metrik, alert ve log toplama |

## Dış Erişim Tercihi

İlk yaklaşım ingress tabanlıydı, ancak repo içinde AWS Load Balancer Controller kurulumu eksikti. Bu nedenle teslimatta tutarlı ve gerçekten uygulanabilir bir yol olarak `frontend` servisinin `LoadBalancer` tipi kullanıldı.

Bu modelde:

- AWS dış hostname sağlar
- Nginx `/api/*` isteklerini backend'e proxy eder
- Smoke test doğrudan dış hostname üstünden `readyz` endpoint'ini doğrular

## Operasyonel Endpoint'ler

- `/healthcheck/`: container/process liveness
- `/readyz/`: MongoDB erişimi dahil readiness kontrolü
- `/metrics`: Prometheus scrape endpoint'i

Bu ayrım sayesinde Kubernetes probe'ları ve CD smoke testi daha anlamlı hale gelir.

## Gözlemlenebilirlik Akışı

```text
backend /metrics -> Prometheus -> Alertmanager
pod logs -> Promtail -> Loki -> Grafana
```

Grafana tek arayüzde hem metrik hem log datasource'u ile çalışır.

## Ağ Politikası

- `mongodb`: sadece `app=backend` pod'larından ingress kabul eder
- `backend`: sadece frontend ve monitoring namespace'inden ingress kabul eder
- `frontend`: dış trafikten 8080 portunu kabul eder
- `default-deny-ingress`: namespace içindeki diğer tüm ingress yollarını kapatır

## Bilinçli Olarak Kapsam Dışında Bırakılanlar

- MongoDB replica set
- TLS sonlandırma
- External secrets manager entegrasyonu
- Backup otomasyonu
- Multi-region veya DR otomasyonu
