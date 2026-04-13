# Service Level Objectives (SLO) — MERN App

Bu doküman, sistemimizin güvenilirlik hedeflerini tanımlar. SRE prensipleri doğrultusunda, her servis için ölçülebilir SLI (Service Level Indicator) ve SLO (Service Level Objective) tanımlanmıştır.

---

## Kavramlar

| Terim | Tanım | Bizde Karşılığı |
|-------|-------|-----------------|
| **SLI** | Servis kalitesinin somut ölçümü | Uptime %, latency, error rate |
| **SLO** | SLI için hedeflenen eşik | "Aylık %99.9 erişilebilirlik" |
| **SLA** | Müşteriyle anlaşılan garanti | Dışarıya taahhüt (genelde SLO'dan biraz daha düşük) |
| **Error Budget** | SLO'dan arta kalan hata payı | %99.9 SLO = ayda 43 dakika kesinti hakkı |

---

## Backend API — SLO Tanımlamaları

| SLI | Ölçüm Yöntemi | SLO Hedefi | Alarm Eşiği |
|-----|---------------|------------|-------------|
| **Availability** | `up{job="backend"}` (Prometheus) | %99.9 / ay (≤ 43.8 dk kesinti) | `up == 0` for > 1 dk |
| **Latency (p99)** | `histogram_quantile(0.99, http_request_duration_seconds)` | < 500ms | p99 > 500ms for > 5 dk |
| **Error Rate** | `rate(http_5xx_total) / rate(http_total)` | < %1 | > %5 for > 5 dk |
| **Throughput** | `rate(http_requests_total[5m])` | Bilgilendirme amaçlı | Ani düşüş (> %50) |

## Frontend (Nginx) — SLO Tanımlamaları

| SLI | Ölçüm Yöntemi | SLO Hedefi | Alarm Eşiği |
|-----|---------------|------------|-------------|
| **Availability** | Nginx access log (non-5xx / total) | %99.9 / ay | 5xx oranı > %1 |
| **Page Load** | Şu an ölçülmüyor (gelecekte: RUM) | < 3 saniye | - |

## MongoDB — SLO Tanımlamaları

| SLI | Ölçüm Yöntemi | SLO Hedefi | Alarm Eşiği |
|-----|---------------|------------|-------------|
| **Availability** | MongoDB ping komutu | %99.95 / ay | Bağlantı hatası > 30s |
| **Query Latency** | `mongodb_operation_duration` | p99 < 100ms | p99 > 200ms for > 5 dk |

---

## Error Budget Hesabı

**Aylık hesaplama (30 gün baz):**

```
%99.9 SLO = 30 gün × 24 saat × 60 dakika × 0.001 = 43.2 dakika/ay

Bu demek ki:
- Ayda en fazla ~43 dakika plansız kesinti olabilir.
- Bu süre aşılırsa, yeni feature deployment'lar dondurulur.
- Öncelik güvenilirlik iyileştirme çalışmalarına verilir.
```

---

## Ölçüm Araçları

| Araç | Amacı |
|------|-------|
| **Prometheus** | Metrik toplama, SLI hesaplama |
| **Grafana** | Dashboard, SLO görselleştirme |
| **AlertManager** | Eşik aşımlarında bildirim |
| **Loki** | Log analizi, hata korelasyonu |

---

> **Not:** Bu SLO'lar bir case study bağlamında tanımlanmıştır. Gerçek üretim ortamında, SLO'lar tarihsel veri ve iş gereksinimleri analiz edilerek belirlenmelidir. İlk 30 gün "ölçüm modu"nda çalışıp, gerçekçi baseline'lar oluşturmak best practice'tir.
