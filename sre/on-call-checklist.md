# On-Call Checklist — Nöbet Devir Teslim Listesi

---

## Nöbet Başlangıcı ✅

Nöbet başladığında aşağıdakileri kontrol et:

- [ ] Laptop şarjlı ve yanında
- [ ] VPN çalışıyor
- [ ] kubectl erişimi var (`kubectl get nodes` → Ready)
- [ ] Grafana dashboard'ları açık ve çalışıyor
- [ ] AlertManager'a erişim var
- [ ] Slack/Teams/bildirim kanalı açık
- [ ] Telefon sessiz modda değil (gece alertları için)
- [ ] Incident runbook sayfası bookmarked
- [ ] Önceki nöbetçiden devir teslim notu alındı

---

## Nöbet Sırasında Yapılacaklar

### Her Gün (Sabah)
- [ ] Grafana dashboard'larına göz at — anormallik var mı?
- [ ] Son 24 saatte tetiklenen alertları gözden geçir
- [ ] Kubernetes cluster durumu: `kubectl get nodes && kubectl get pods -A | grep -v Running`
- [ ] Error budget durumunu kontrol et

### Alert Geldiğinde
1. **Acknowledge et** — "Bakıyorum" mesajı at
2. **Severity belirle** — P1/P2/P3/P4
3. **Runbook'u aç** — `sre/incident-runbook.md`
4. **Adımları takip et** — Kendi başına çözme süresi: max 30 dk
5. **Çözemediysen escalate et** — hero olmaya gerek yok
6. **Çözüldüyse:** kısa özet yaz, gerekiyorsa post-mortem aç

---

## Nöbet Devri — Giden Nöbetçi Notu

Nöbet bittiğinde bir sonraki nöbetçiye bu formatla not bırak:

```markdown
### Nöbet Devir Notu — [Tarih]

**Genel Durum:** [Sakin/Aktif/Sorunlu]

**Açık Olaylar:**
- [Olay varsa özetle, yoksa "Yok"]

**Dikkat Edilecekler:**
- [Bu hafta deployment planı var mı?]
- [Bilinen geçici sorunlar var mı?]
- [Monitoring'te takip edilen trend var mı?]

**Son 24 Saatte Olan Önemli Şeyler:**
- [Alert geldi mi? Ne yapıldı?]
- [Deployment oldu mu? Sorunsuz mu geçti?]
```

---

## Faydalı Komutlar (Quick Reference)

```bash
# Tüm pod'ların durumu
kubectl get pods -n baykar-app -o wide

# Sorunlu pod'ları bul
kubectl get pods -A | grep -v Running | grep -v Completed

# Pod logları
kubectl logs -n baykar-app <pod-name> --tail=100 -f

# Node kaynakları
kubectl top nodes
kubectl top pods -n baykar-app

# HPA durumu
kubectl get hpa -n baykar-app

# Son events
kubectl get events -n baykar-app --sort-by=.lastTimestamp | tail -20

# Quick readiness check
curl -s http://<frontend-url>/api/readyz/ | jq .
```

---

## İletişim

| Rol | Kişi | İletişim |
|-----|------|----------|
| On-Call Mühendis (bu hafta) | [İsim] | [Telefon / Slack] |
| Backup On-Call | [İsim] | [Telefon / Slack] |
| Ekip Lideri | [İsim] | [Telefon / Slack] |
| Altyapı Yöneticisi | [İsim] | [Telefon / Slack] |
