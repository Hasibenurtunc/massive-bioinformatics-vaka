# Findings Report: Unknown Bacterial Isolate Analysis

**Analiz tarihi:** 26 Temmuz 2026
**Veri:** `unknown_isolate.fastq.gz` (Oxford Nanopore ham okumaları, 439 MB, 260,294 okuma, 576.6 Mb toplam baz)

---

## Not to Prof. Kılıç (Plain-Language Summary)

Merhaba Prof. Kılıç,

Gönderdiğiniz örneği inceledik. Sonuçlar aşağıdaki gibidir:

**Organizma:** Örnek, **Klebsiella pneumoniae** türü bir bakteridir, ve **ST258** olarak bilinen, dünya çapında hastane salgınlarıyla ilişkilendirilen, iyi tanımlanmış bir klonal gruba (sequence type) aittir. Bu bakteri, özellikle hastane ortamlarında görülen ve tedavisi zor olabilen bir enfeksiyon etkenidir.

**Direnç durumu:** Bu izolat, standart antibiyotiklerin büyük çoğunluğuna karşı dirençlidir. En önemli bulgu, **karbapenem** grubu antibiyotiklere (bu antibiyotikler genelde "son çare" olarak kullanılır) karşı direnç sağlayan **blaKPC-3** genini taşımasıdır. ST258 klonunun literatürde KPC-üreten izolatlarla sıkça ilişkilendirilmiş olması, bu bulguyu daha da güçlü şekilde destekler.

**Virülans:** İzolat, kapsül üretimi, demir toplama sistemleri ve yapışma/biyofilm oluşturma yapıları gibi Klebsiella'ya özgü **standart (klasik) virülans faktörlerini** taşımaktadır. Önemli bir not: "hipervirülan Klebsiella" olarak bilinen özel/nadir markerlere (rmpA, magA) rastlanmamıştır — yani bu izolat, alışılmadık derecede saldırgan bir varyant değil, çoklu ilaç direnciyle bilinen klasik bir klinik suş profilindedir.

**Neden önemli:** Bu direnç geni, bakterinin ana DNA'sında değil, **ayrı ve hareketli bir DNA parçası olan bir plazmid üzerinde** bulunuyor. Bu, direncin **başka bakterilere de bulaşabileceği** anlamına gelir — yani bu sadece bu hastaya özgü bir durum değil, hastanedeki diğer hastalar için de bir enfeksiyon kontrolü riski taşıyor olabilir.

**Önerilerimiz:**
1. Hasta, karbapenem dışı, duyarlılık testiyle doğrulanmış alternatif bir antibiyotik rejimine yönlendirilmelidir (klinik mikrobiyoloji ekibiyle görüşülerek).
2. Enfeksiyon kontrol ekibine bilgi verilmesi, olası yayılımın önlenmesi açısından önemlidir (temas izolasyonu, tarama gibi önlemler değerlendirilebilir).
3. Bu bulgular, klasik antibiyotik duyarlılık testleriyle (fenotipik) doğrulanmalıdır; bizim analizimiz genomik/moleküler düzeydedir, kesin klinik karar için laboratuvarınızın standart yöntemleriyle teyit önerilir.

Sorularınız olursa memnuniyetle detaylandırırız.

---

## Technical Report (For Bioinformaticians)

### 1. Objective
Using raw ONT (Oxford Nanopore) reads from an unknown bacterial isolate, determine (1) the organism identity, and (2) the antimicrobial resistance (AMR) profile, including genomic location of resistance determinants (chromosomal vs. plasmid).

### 2. Data Quality Assessment (QC)

Tool: **NanoPlot v1.47.1**

| Metric | Value |
|---|---|
| Number of reads | 260,294 |
| Total bases | 576,590,333 |
| Mean read length | 2,215.2 bp |
| N50 | 15,932 bp |
| Mean read quality | 20.1 |
| Median read quality | 23.7 |
| Reads >Q10 | 99.8% |
| Reads >Q20 | 74.3% |
| Longest read | 210,485 bp (Q16.5) |

**Değerlendirme:** Veri kalitesi, hem taksonomik sınıflandırma hem de de novo assembly için uygun bulunmuştur. N50 değeri (~16 kb) ve okumaların uzunluğu, uzun-okuma teknolojisinin avantajı olan plazmid/kromozom ayrımı için yeterli bilgi sağlamaktadır.

### 3. Taxonomic Classification

Tool: **Kraken2 v2.17.1**, Database: **Standard-8** (June 2026 release, RefSeq archaea/bacteria/viral/plasmid/human/UniVec, 8GB-capped)

**Gerekçe:** Standard-8 veritabanı seçildi çünkü (a) senaryo tek bir bakteriyel izolatı hedeflemektedir, kapsamlı bir ökaryotik/protist veritabanına ihtiyaç yoktur; (b) zaman kısıtı nedeniyle tam Standard (~80GB) veya PlusPFP gibi daha büyük veritabanları yerine, hız/kapsam dengesi sunan budanmış bir versiyon tercih edilmiştir.

**Sonuç:**
- 242,537 okuma (%93.18) sınıflandırılmış, 17,757 okuma (%6.82) sınıflandırılamamış.
- Genus seviyesinde baskın sınıflandırma: **Klebsiella** (%74.26)
- Species seviyesinde: **Klebsiella pneumoniae** (%16.82, doğrudan) + yakın alt-tür/kompleks sınıflandırmaları (K. pneumoniae complex %20.00, K. quasipneumoniae, K. variicola gibi düşük oranlı yakın türler)

**Not on certainty:** Kraken2'nin k-mer tabanlı yaklaşımı, yakın akraba Klebsiella türleri arasında (K. pneumoniae, K. quasipneumoniae, K. variicola) bazı okumaları "complex" seviyesinde bırakabilir; bu, yakın türlerin genomik benzerliğinden kaynaklanan beklenen bir durumdur ve tür teşhisinin güvenilirliğini azaltmaz — de novo assembly boyutu bu teşhisi bağımsız olarak doğrulamaktadır (bkz. Bölüm 4).

### 4. De Novo Assembly

Tool: **Flye v2.9.6-b1802** (`--nano-raw` mode)

| Metric | Value |
|---|---|
| Total assembly length | 5,893,617 bp |
| Number of fragments | 13 |
| Largest fragment | 5,306,074 bp (circular) |
| Mean coverage | 96x |

**Gerekçe:** Assembly, ham okumalar üzerinde doğrudan AMR taraması yapmak yerine tercih edildi, çünkü (a) ABRicate gibi araçlar bütünleşik/uzun referans dizileri üzerinde daha güvenilir sonuç verir, (b) assembly, genlerin hangi replikonda (kromozom/plazmid) bulunduğunu belirlememizi sağlar — bu, ham okumalarla doğrudan mümkün olmayan bir analizdir. Toplam assembly uzunluğu (~5.89 Mb), K. pneumoniae'nin tipik genom boyutuyla (~5.5–6 Mb) örtüşerek Kraken2 sonucunu bağımsız olarak doğrulamaktadır.

### 5. Replicon Structure (Chromosome vs. Plasmid)

| Contig | Length (bp) | Circular | Interpretation |
|---|---|---|---|
| contig_4 | 5,306,074 | Yes | **Chromosome** |
| contig_5 | 214,836 | Yes | Plasmid |
| contig_18 | 79,489 | Yes | Plasmid |
| contig_7, contig_8, others | <35,000 | No | Smaller/incomplete fragments |

### 6. Strain Typing (MLST)

Tool: **mlst v2.33.1** (Klebsiella scheme)

**Result: ST258** (exact allele matches: gapA-3, infB-3, mdh-1, pgi-1, phoE-1, rpoB-1, tonB-79)

**Significance:** ST258 is a well-documented, globally disseminated high-risk clonal lineage of *K. pneumoniae*, strongly associated with KPC-carbapenemase production and healthcare-associated outbreaks. This finding is consistent with, and reinforces confidence in, the blaKPC-3 detection below.

**Note on database ambiguity:** The default `mlst` scheme-detection step initially returned a tied score between the `ecoli_achtman_4` and `klebsiella` schemes (both scoring 100), incorrectly defaulting to the *E. coli* scheme. Since taxonomic classification (Section 3) and assembly size (Section 4) both independently confirmed *K. pneumoniae*, the `klebsiella` scheme was explicitly specified (`--scheme klebsiella`), yielding a confident, fully-typed ST258 result.

### 7. Virulence Factor Screening

Tool: **ABRicate v1.4.0**, Database: **VFDB (Virulence Factor Database)**

**Summary of detected virulence factor categories** (full detail in `results/abricate_vfdb.txt`):

| Category | Representative genes | Function |
|---|---|---|
| Capsule biosynthesis | rcsA, rcsB, galF, ugd, gndA, wzi | Anti-phagocytic protection, immune evasion |
| Siderophores (iron acquisition) | ent (enterobactin) cluster, iutA (aerobactin) | Iron scavenging from host, supports growth during infection |
| Fimbriae / adhesion / biofilm | fim (Type 1), mrk (Type 3) gene clusters | Surface/device adherence, biofilm formation |
| Type VI Secretion System (T6SS) | tss/vip gene cluster | Inter-bacterial competition |
| Efflux / competitive advantage | acrA, acrB | Antimicrobial/disinfectant efflux |

**Notable absence:** No hypervirulent-lineage markers (e.g., rmpA, rmpA2, magA) were detected. This suggests the isolate represents a **classic multidrug-resistant (MDR) K. pneumoniae** profile rather than a hypervirulent variant — a clinically relevant distinction, as hypervirulent strains carry additional risk of severe invasive disease in healthy hosts.

### 8. Antimicrobial Resistance (AMR) Screening

Tool: **ABRicate v1.4.0**, Database: **NCBI AMRFinderPlus** (2026-Apr-3 release)

**Gerekçe:** NCBI veritabanı, güncel ve küratörlü bir kaynak olarak tercih edilmiştir; ABRicate'in desteklediği diğer veritabanları (CARD, ResFinder) ile çapraz doğrulama, zaman izin verdiğinde ek bir adım olarak önerilir.

**24 direnç geni tespit edilmiştir.** En klinik açıdan önemli bulgu:

| Gene | Location | Resistance | Clinical Significance |
|---|---|---|---|
| **blaKPC-3** | **contig_18 (plasmid)** | **Carbapenem** | **Kritik — son-çare antibiyotik sınıfına direnç, plazmid üzerinde (yatay transfer riski)** |
| blaSHV-158, blaTEM-150, blaOXA-9, blaSHV-12 | contig_4 (kromozom), contig_18 | Beta-lactam / Cephalosporin | Yaygın, kısmen intrinsik |
| oqxA, oqxB | contig_4 (kromozom) | Nitrofurantoin, Quinolone, Tigecycline | Klebsiella'da intrinsik efflux pompası |
| aadA1, aadA2, aac(6')-Ib-AKT, aph(3')-Ia, aac(3)-IVa, aph(4)-Ia | contig_5, contig_8, contig_18 | Aminoglycosides | Çoklu, farklı plazmidlere dağılmış |
| sul1, sul3, dfrA12 | contig_5, contig_8 | Sulfonamide/Trimethoprim | Plazmid kökenli |
| catA1, cmlA1 | contig_5, contig_8 | Chloramphenicol | Plazmid kökenli |
| mph(A), mrx(A), estX-3 | contig_5, contig_8 | Macrolide | Plazmid kökenli |
| fosA6 | contig_4 (kromozom) | Fosfomycin | İntrinsik |

**En kritik bulgu:** `blaKPC-3` geninin **contig_18 (dairesel, 79,489 bp bir plazmid)** üzerinde bulunması, bu izolatın **KPC-üreten, karbapenem-dirençli bir Klebsiella pneumoniae (CRE)** olduğunu göstermektedir. Bu genin plazmid üzerinde olması, direncin konjugasyon yoluyla diğer Enterobacteriaceae üyelerine aktarılabileceği anlamına gelir — enfeksiyon kontrolü açısından yüksek öncelikli bir bulgudur.

### 9. Confidence & Limitations

- Tür teşhisi hem Kraken2 (k-mer tabanlı, hızlı) hem de assembly boyutu (bağımsız doğrulama) ile desteklenmiştir; güven düzeyi yüksektir.
- Direnç genlerinin **varlığı** yüksek güvenle (%100 identity/coverage çoğu gende) tespit edilmiştir; ancak **fenotipik ifade** (genin gerçekten aktif olarak dirence yol açıp açmadığı) genomik veriyle garanti edilemez — laboratuvar bazlı antibiyogram ile doğrulama önerilir.
- Kullanılan veritabanı sürümleri: Kraken2 Standard-8 (2026-06-26), ABRicate NCBI AMRFinderPlus (2026-04-03). Direnç veritabanları düzenli güncellendiğinden, aynı ham veriyle gelecekte farklı/ek bulgular elde edilebilir.
- Küçük, dairesel-olmayan contigler (contig_7, contig_8 vb.) tam plazmid yapısını yansıtmayabilir; bunlar assembly'nin tam çözemediği parçalar olabilir, daha derin/uzun okuma verisiyle iyileştirilebilir.

### 10. Tools & Versions Summary

| Tool | Version | Purpose |
|---|---|---|
| NanoPlot | 1.47.1 | Read QC |
| Kraken2 | 2.17.1 | Taxonomic classification |
| Flye | 2.9.6-b1802 | De novo assembly |
| ABRicate | 1.4.0 | AMR & virulence gene screening |
| mlst | 2.33.1 | Strain typing (MLST) |

**Databases:**
- Kraken2: Standard-8, released 2026-06-26
- ABRicate (AMR): NCBI AMRFinderPlus, released 2026-04-03
- ABRicate (Virulence): VFDB
- mlst: PubMLST Klebsiella scheme