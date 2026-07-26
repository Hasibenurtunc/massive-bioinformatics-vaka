#!/bin/bash
# =============================================================
# Massive Bioinformatics - 15. Nesil Staj Programı
# Vaka Analizi: Unknown Bacterial Isolate - AMR & Species ID
# =============================================================
# Bu script, analiz sürecinde çalıştırılan tüm komutları
# sırasıyla ve açıklamalarıyla belgelemektedir.
#
# Ortam: macOS (Apple Silicon M5 Pro), Rosetta/osx-64 subdir
# (Not: Bazı bioconda paketleri henüz osx-arm64 için
# derlenmediğinden, conda ortamı Intel/osx-64 modunda kuruldu.)
# =============================================================

# -------------------------------------------------------------
# 0. ORTAM KURULUMU
# -------------------------------------------------------------

# Miniforge kurulumu (Homebrew üzerinden)
brew install miniforge

# Rosetta 2 kurulumu (Apple Silicon'da Intel paketlerini
# çalıştırabilmek için gerekli)
softwareupdate --install-rosetta

# Conda ortamını Intel (osx-64) modunda oluştur
# Gerekçe: abricate'in bazı bağımlılıkları (perl-socket vb.)
# henüz osx-arm64 için mevcut değildi.
CONDA_SUBDIR=osx-64 conda create -n Bioinformatic_vaka python=3.10
conda activate Bioinformatic_vaka
conda config --env --set subdir osx-64

# Gerekli araçların kurulumu
conda install -c bioconda -c conda-forge kraken2 abricate nanoplot flye

# Kurulum doğrulama
kraken2 --version
abricate --version
NanoPlot --version
flye --version

# -------------------------------------------------------------
# 1. PROJE KLASÖRÜ VE VERİ HAZIRLIĞI
# -------------------------------------------------------------

mkdir -p data results
mv unknown_isolate.fastq.gz data/

# -------------------------------------------------------------
# 2. KALİTE KONTROL (QC)
# -------------------------------------------------------------

NanoPlot --fastq data/unknown_isolate.fastq.gz -o results/qc

# Sonuç özeti: 260,294 okuma, 576.6 Mb, ortalama kalite Q20.1,
# N50 15,932 bp, %99.8 okuma >Q10. Veri kalitesi analiz için
# yeterli bulundu.

# -------------------------------------------------------------
# 3. KRAKEN2 VERİTABANI İNDİRME
# -------------------------------------------------------------

# Gerekçe: Standard-8 (8GB'a sıkıştırılmış Standard veritabanı)
# tercih edildi çünkü (a) senaryo tek bir bakteriyel izolatı
# hedefliyor, geniş ökaryotik kapsam gerekmiyor, (b) zaman
# kısıtı nedeniyle tam Standard (~80GB) yerine hız/kapsam
# dengesi sunan bu versiyon seçildi.

mkdir -p ~/kraken2_db
cd ~/kraken2_db
curl -O https://genome-idx.s3.amazonaws.com/kraken/k2_standard_08_GB_20260626.tar.gz
tar -xzvf k2_standard_08_GB_20260626.tar.gz
rm k2_standard_08_GB_20260626.tar.gz  # Disk alanı için arşiv silindi

# -------------------------------------------------------------
# 4. TÜR TEŞHİSİ (KRAKEN2)
# -------------------------------------------------------------

cd ~/Desktop/Bio_vaka
kraken2 --db ~/kraken2_db \
  --output results/kraken_out.txt \
  --report results/kraken_report.txt \
  --use-names \
  data/unknown_isolate.fastq.gz

# Raporu yorumlamak için:
sort -k1 -rn results/kraken_report.txt | head -30

# Sonuç: %93.18 sınıflandırma oranı. Genus seviyesinde Klebsiella
# (%74.26) baskın; species seviyesinde Klebsiella pneumoniae
# (%16.82 doğrudan + %20.00 "complex" seviyesinde).

# -------------------------------------------------------------
# 5. DE NOVO ASSEMBLY (FLYE)
# -------------------------------------------------------------

# Gerekçe: Ham okumalar yerine assembly üzerinde AMR taraması
# yapmak, hem daha güvenilir sonuç verir hem de genlerin hangi
# replikonda (kromozom/plazmid) olduğunu belirlememizi sağlar.
#
# NOT: Dosya yolunda gizli bir boşluk karakteri nedeniyle ilk
# denemede "Path to reads contain spaces" hatası alındı.
# Çözüm: proje klasörü boşluksuz bir isimle (Bio_vaka) yeniden
# adlandırıldı.

flye --nano-raw data/unknown_isolate.fastq.gz \
  --out-dir results/assembly \
  -t 4

# Sonuç: Toplam 5,893,617 bp, 13 fragment, en büyük fragment
# 5,306,074 bp (dairesel = muhtemel kromozom), ortalama
# coverage 96x. Boyut, K. pneumoniae'nin tipik genom boyutuyla
# (~5.5-6 Mb) örtüşerek tür teşhisini bağımsız olarak doğruluyor.

cat results/assembly/assembly_info.txt

# -------------------------------------------------------------
# 6. DİRENÇ GENİ TARAMASI (ABRICATE)
# -------------------------------------------------------------

# Gerekçe: NCBI AMRFinderPlus veritabanı, güncel ve küratörlü
# bir kaynak olarak tercih edildi.

abricate results/assembly/assembly.fasta > results/abricate_out.txt
cat results/abricate_out.txt

# Sonuç: 24 direnç geni tespit edildi. En kritik bulgu:
# blaKPC-3 (karbapenem direnci) - contig_18 üzerinde, ve
# contig_18 dairesel/circular bir plazmid (bkz. assembly_info.txt).
# Bu, direncin yatay gen transferiyle diğer bakterilere
# yayılabileceği anlamına gelir.

# -------------------------------------------------------------
# 7. SONUÇLARIN RAPORLANMASI
# -------------------------------------------------------------

# Tüm bulgular findings.md dosyasında, hem Prof. Kılıç
# (teknik olmayan) hem de bir biyoinformatikçi için ayrı
# bölümler halinde raporlanmıştır. Bkz. ../findings.md
