# Ekran Görüntüleri

Bu klasör teslimat kanıtları için kullanılır.

Mevcut akış:

- Cypress smoke testi çalıştırıldığında `cypress/endToEnd.spec.js/app-home.png` ve `cypress/endToEnd.spec.js/record-list.png` burada üretilir

Cloud deploy tamamlandiktan sonra eklenen EKS kanitlari:

- `eks/frontend-lb-home.png`
- `eks/backend-readyz.png`
- `eks/etl-job-success.png`
- `eks/github-actions-green.png`

Önerilen son kontrol:

1. `make up`
2. `cd apps/frontend && npm ci && npx cypress run`
3. EKS deploy sonrasi `docs/screenshots/eks/` altindaki canli kanitlari kontrol et
4. Final teslimde README ve checklist ile ekran goruntusu dosya adlarini eslestir
