# Error Budget Policy

Bu doküman, error budget tükendiğinde veya hızla azaldığında izlenecek aksiyonları tanımlar.

---

## Error Budget Nedir?

Error budget, SLO'muzdan çıkan "kabul edilebilir kesinti süresi"dir.

```
SLO = %99.9
Error Budget = %0.1 = ayda ~43 dakika
```

Bu süreyi feature deployment'lar, planlanmış bakım ve beklenmeyen kesintiler paylaşır.

---

## Budget Durumuna Göre Aksiyonlar

### 🟢 Budget > %50 (Sağlıklı)
- Normal geliştirme hızı devam eder
- Riskli deployment'lar (büyük migration, major version upgrade) bu dönemde yapılır
- Canary deployment ile yeni özelliklerin gradual rollout'u

### 🟡 Budget %20-%50 arası (Dikkatli)
- Riskli deployment'lar ertelenir
- Mevcut deployment'lara ekstra izleme eklenir
- Rollback prosedürleri gözden geçirilir
- Takım toplantısında durum paylaşılır

### 🔴 Budget < %20 (Kritik)
- **Feature freeze:** Sadece güvenilirlik iyileştirmeleri deploy edilir
- Her deployment için 2 kişi onay gerekir
- On-call mühendis deployment'lar sırasında aktif izleme yapar
- Günlük standup'ta error budget durumu paylaşılır

### ⚫ Budget Tükendi (%0)
- **Tam freeze:** Sadece güvenilirlik ve güvenlik yamaları
- Post-mortem process zorunlu
- Yönetim bilgilendirilir
- Sonraki sprint tamamen güvenilirlik çalışmalarına ayrılır

---

## Karar Matrisi

| Olay | Budget Etkisi | Aksiyon |
|------|--------------|---------|
| 5 dakikalık plansız kesinti | ~%12 budget kullanır | Post-mortem, RCA |
| 15 dakikalık kesinti | ~%35 budget kullanır | Feature freeze değerlendirilir |
| 30 dakikalık kesinti | ~%70 budget kullanır | Otomatik feature freeze |
| Tekrarlayan kısa kesintiler | Kümülatif etki | Pattern analizi, kök neden çözümü |

---

## Gözden Geçirme Takvimi

- **Haftalık:** Error budget mevcut durumu kontrol
- **Aylık:** SLO hedeflerinin geçerliliği değerlendirme
- **Çeyreklik:** SLO'ların güncellenmesi (gerekirse)

> **Kural:** SLO'lar ayarlanırken hem mühendislik hem de iş tarafının mutabık olması gerekir. SLO'yu gereksiz yüksek tutmak (%99.999 gibi) inovasyon hızını öldürür. SLO'yu düşük tutmak ise kullanıcı güvenini sarsar.
