# Incident Runbook — Olay Müdahale Kılavuzu

Bu doküman, sık karşılaşılan arıza senaryolarında izlenecek adım adım prosedürleri içerir.

---

## Genel Prensipler

1. **Sakin ol.** Hızlı ama control altında hareket et.
2. **Önce hasarı durdur** (mitigate), sonra kök nedeni bul.
3. **Kommunikasyon:** Ekibi bilgilendir, ilerlemeyi paylaş.
4. **Değişiklik yaptığında not al** — post-mortem için gerekecek.
5. **Bilmediğin bir şey varsa, escalate et.** Hero olmaya gerek yok.

---

## Senaryo 1: Backend Pod'ları CrashLoopBackOff

**Severity:** P1 (Kritik) — API tamamen erişilemez

**Belirtiler:**
- Frontend "API Status" gösteremez
- `/api/healthcheck` 502 döner
- Grafana'da backend uptime = 0

**Adımlar:**

```bash
# 1. Pod durumunu kontrol et
kubectl get pods -n baykar-app -l app=backend

# 2. Hata loglarını oku
kubectl logs -n baykar-app -l app=backend --tail=50

# 3. Son events'leri kontrol et
kubectl describe pod -n baykar-app -l app=backend | grep -A 10 "Events"

# 4. Yaygın nedenler:
#    a) MongoDB bağlantı hatası → MongoDB pod'unu kontrol et
#    b) Env variable eksik → ConfigMap/Secret kontrol et
#    c) OOMKilled → Resource limits artır

# 5. Hızlı çözüm: son çalışan sürüme rollback
kubectl rollout undo deployment/backend -n baykar-app

# 6. Rollback sonrası kontrol
kubectl rollout status deployment/backend -n baykar-app
```

---

## Senaryo 2: MongoDB Bağlantı Hatası

**Severity:** P1 (Kritik) — Tüm CRUD operasyonları durur

**Belirtiler:**
- Backend loglarında "MongoServerError: connection refused"
- `/api/record` endpoint'i 500 döner
- Frontend CRUD sayfaları boş gelir

**Adımlar:**

```bash
# 1. MongoDB pod durumu
kubectl get pods -n baykar-app -l app=mongodb

# 2. MongoDB pod logları
kubectl logs -n baykar-app -l app=mongodb --tail=30

# 3. PVC durumu — disk dolu olabilir
kubectl get pvc -n baykar-app

# 4. MongoDB'ye doğrudan bağlanmayı dene
kubectl exec -it mongodb-0 -n baykar-app -- mongosh --eval "db.adminCommand('ping')"

# 5. Eğer StatefulSet restart gerekiyorsa (dikkatli!)
kubectl rollout restart statefulset/mongodb -n baykar-app

# 6. Eğer data corruption varsa → backup'tan restore
# Bu ciddi bir durum — ekip lideri bilgilendirilmeli
```

---

## Senaryo 3: Yüksek Latency (p99 > 500ms)

**Severity:** P2 (Önemli) — Sistem çalışıyor ama yavaş

**Belirtiler:**
- Grafana dashboard'da latency spike
- Kullanıcılardan "sayfa yavaş" şikayetleri
- AlertManager'dan uyarı

**Adımlar:**

```bash
# 1. Hangi pod'larda CPU/memory spike var?
kubectl top pods -n baykar-app

# 2. HPA çalışıyor mu? Scale up gerçekleşmiş mi?
kubectl get hpa -n baykar-app

# 3. MongoDB sorgu performansı
kubectl exec -it mongodb-0 -n baykar-app -- mongosh --eval "db.currentOp({'active': true})"

# 4. Node kaynak durumu
kubectl top nodes

# 5. Geçici çözüm: manuel scale up
kubectl scale deployment/backend -n baykar-app --replicas=5

# 6. Uzun vadeli çözüm: indeksleme, query optimizasyonu, cache ekleme
```

---

## Senaryo 4: ETL CronJob Başarısız

**Severity:** P3 (Düşük) — Veri pipeline'ı etkilenir, kullanıcı deneyimi etkilenmez

**Belirtiler:**
- CronJob pod'u Failed durumda
- ETL verileri eski kalmış

**Adımlar:**

```bash
# 1. Son job'ların durumunu kontrol et
kubectl get jobs -n baykar-app --sort-by=.metadata.creationTimestamp | tail -5

# 2. Failed pod'un loglarını oku
kubectl logs -n baykar-app -l job-name=<failed-job-name>

# 3. Yaygın nedenler:
#    a) GitHub API rate limit → Token ekle veya bekle
#    b) Network hatası → DNS resolver kontrol et
#    c) Python dependency sorunu → Image rebuild

# 4. Manuel çalıştır
kubectl create job --from=cronjob/etl test-etl -n baykar-app

# 5. Sonraki schedule'da otomatik denenecek (cronjob doğası gereği)
```

---

## Senaryo 5: Load Balancer Sorunu

**Severity:** P1 (Kritik) — Dışarıdan hiçbir erişim yok

**Belirtiler:**
- Tüm URL'ler timeout veya 503 döner
- Internal servisler (ClusterIP) çalışıyor

**Adımlar:**

```bash
# 1. Frontend service durumu
kubectl get svc frontend -n baykar-app
kubectl describe svc frontend -n baykar-app

# 2. Frontend endpoint ve pod durumu
kubectl get endpoints frontend -n baykar-app
kubectl get pods -n baykar-app -l app=frontend -o wide

# 3. AWS load balancer target health
aws elbv2 describe-target-health --target-group-arn <arn>

# 4. DNS çözümleme kontrolü
nslookup <domain>
dig <domain>

# 5. Geçici çözüm: NodePort ile doğrudan erişim
kubectl patch svc frontend -n baykar-app -p '{"spec":{"type":"NodePort"}}'
```

---

## Escalation Matrisi

| Severity | Yanıt Süresi | Kim Müdahale Eder | Bilgilendirme |
|----------|-------------|-------------------|---------------|
| **P1** | < 15 dakika | On-call mühendis | Ekip lideri + tüm takım |
| **P2** | < 1 saat | On-call mühendis | Ekip lideri |
| **P3** | < 4 saat | Mesai saatlerinde bakılır | Ilgili mühendis |
| **P4** | Sonraki sprint | Backlog'a eklenir | - |
