# AWS Maliyet Analizi — Cost Analysis

Bu doküman, projenin AWS üzerinde çalışma maliyetinin kabaca tahminini sunar.

---

## Beklenen Aylık Maliyet (eu-west-1, on-demand fiyatlandırma)

| Kaynak | Birim | Fiyat/Saat | Aylık Maliyet |
|--------|-------|-----------|--------------|
| **EKS Control Plane** | 1 cluster | $0.10/saat | **$73** |
| **EC2 Worker Nodes** (t3.medium × 2) | 2 instance | $0.0464/saat × 2 | **$67** |
| **NAT Gateway** | 1 gateway | $0.048/saat + veri | **$35 + veri** |
| **ALB (Load Balancer)** | 1 ALB | $0.0252/saat + LCU | **$18 + LCU** |
| **EBS (MongoDB Storage)** | 10 GB gp3 | $0.088/GB/ay | **$1** |
| **ECR (Container Registry)** | ~500MB × 3 | $0.10/GB/ay | **< $1** |
| **CloudWatch Logs** | EKS audit logs | $0.57/GB | **~$5** |

### **Toplam Tahmini: ~$200-250/ay**

---

## Maliyet Optimizasyonu Önerileri

### Kısa Vadeli (Hemen uygulanabilir)

| Öneri | Tasarruf | Açıklama |
|-------|---------|----------|
| **Spot Instances** kullan | %60-70 | Stateless workload'lar (frontend, backend) için uygun. MongoDB için uygun DEĞİL. |
| **NAT Gateway yerine VPC Endpoints** | ~$35/ay | S3 ve ECR için VPC endpoint kullanarak NAT üzerinden trafiği azalt |
| **EKS node'larını geceleri scale down** | ~%40 | Non-prod ortamlar için (kube-downscaler tool'u ile) |

### Orta Vadeli

| Öneri | Tasarruf | Açıklama |
|-------|---------|----------|
| **Reserved Instances** (1 yıl) | %30-40 | Sabit çalışacak node'lar için |
| **Graviton (ARM) instance'ları** | %20 | `t4g.medium` ~%20 daha ucuz, `t3.medium` ile aynı performans |
| **Fargate** (serverless containers) | Değişken | Düşük trafik saatlerinde çok düşük maliyet, yüksek trafik saatlerinde daha pahalı |

### MonogDB için Alternatifler

| Seçenek | Maliyet | Avantaj | Dezavantaj |
|---------|---------|---------|------------|
| MongoDB container (şu anki) | $0 (node üzerinde) | Basit, kontrol sizde | HA/backup sizin sorumluluğunuz |
| MongoDB Atlas (Free Tier) | $0 | Yönetilen, otomatik backup | 512MB limit, performans sınırlı |
| MongoDB Atlas (M10) | ~$57/ay | Dedicated cluster, HA | Ek maliyet |
| AWS DocumentDB | ~$200/ay | AWS-native, auto-scaling | Pahalı, tam MongoDB uyumlu değil |



## Ortam Başına Bütçe Tahmini

| Ortam | Konfigürasyon | Aylık Maliyet |
|-------|--------------|---------------|
| **Dev** | 1 node (t3.small), Spot, geceleri kapalı | **~$50** |
| **Staging** | 2 node (t3.medium), Spot | **~$120** |
| **Production** | 2-4 node (t3.medium), On-Demand/Reserved, HA | **~$250** |

---

## Maliyet İzleme

- **AWS Cost Explorer** ile aylık takip
- **Budget Alert**: $300/ay eşiğinde alarm
- **Tag-based tracking**: Tüm kaynaklar `Project: baykar-devops-case` ile tag'li (Terraform default_tags ile)

---

> **Not:** Bu fiyatlar Nisan 2025 AWS eu-west-1 on-demand fiyatlarına dayanmaktadır. Gerçek maliyetler trafik hacmi, veri transferi ve kullanım istatistiklerine göre değişebilir.
