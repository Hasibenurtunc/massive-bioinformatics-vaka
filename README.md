# Unknown Bacterial Isolate — Species ID & AMR Analysis

Massive Bioinformatics 15. Nesil Staj Programı — Biyoinformatik Departmanı Vaka Analizi.

## İçerik

- **`findings.md`** — Ana rapor: organizma teşhisi, direnç genleri, plazmid/kromozom analizi. Hem klinisyen (Prof. Kılıç) hem de teknik okuyucu için ayrı bölümler içerir.
- **`code/commands.sh`** — Analiz sürecinde çalıştırılan tüm komutlar, sırasıyla ve açıklamalı.

## Özet Sonuç

- **Organizma:** *Klebsiella pneumoniae*
- **En kritik bulgu:** `blaKPC-3` (karbapenem direnç geni), bir plazmid üzerinde (contig_18, dairesel, 79,489 bp)
- **Toplam 24 direnç geni** tespit edildi (detaylar `findings.md` içinde)

## Kullanılan Araçlar

| Araç | Versiyon | Amaç |
|---|---|---|
| NanoPlot | 1.47.1 | Ham okuma kalite kontrolü |
| Kraken2 | 2.17.1 | Taksonomik sınıflandırma (tür teşhisi) |
| Flye | 2.9.6-b1802 | De novo genom assembly |
| ABRicate | 1.4.0 | Antimikrobiyal direnç geni taraması |

## Nasıl Çalıştırılır

1. Ortamı kur (Miniforge/conda gereklidir):
   ```bash
   CONDA_SUBDIR=osx-64 conda create -n Bioinformatic_vaka python=3.10
   conda activate Bioinformatic_vaka
   conda config --env --set subdir osx-64
   conda install -c bioconda -c conda-forge kraken2 abricate nanoplot flye
   ```
   > Not: Apple Silicon (M-serisi) Mac'lerde bazı bioconda paketleri henüz `osx-arm64` için mevcut olmadığından, ortam Rosetta üzerinden Intel (`osx-64`) modunda kuruldu.

2. `code/commands.sh` dosyasındaki komutları sırasıyla çalıştırın. Kraken2 için önce bir referans veritabanı indirilmelidir (script içinde link mevcuttur, ~5.5GB).

3. Girdi verisi: `unknown_isolate.fastq.gz` (Oxford Nanopore ham okumaları). Boyutu nedeniyle bu repoya dahil edilmemiştir; görev sağlayıcısının verdiği örnek veri kullanılmalıdır.

## Notlar

- Direnç veritabanları (ABRicate/NCBI) düzenli güncellendiğinden, kullanılan sürüm `findings.md` içinde belirtilmiştir; farklı bir tarihte aynı veriyle farklı sonuçlar elde edilebilir.
- Bulgular genomik/moleküler düzeydedir; klinik karar için standart antibiyotik duyarlılık testleriyle (fenotipik) doğrulanması önerilir.
