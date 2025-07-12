Kalp Yetmezliği Tahmin Analitiği Paneli
Bu proje, R ve Shiny kullanılarak geliştirilmiş etkileşimli bir web uygulamasıdır. Uygulama, kalp yetmezliği klinik kayıtları veri setini kullanarak farklı makine öğrenimi modellerini eğitmenize, değerlendirmenize ve karşılaştırmanıza olanak tanır. Ayrıca, yeni hasta verileriyle ölüm riskini tahmin etmek için bir risk prediktörü de içerir.

📋 İçindekiler
Özellikler

Veri Seti

Kurulum

Uygulamayı Çalıştırma

Uygulama Sekmeleri

Data Explorer (Veri Keşfi)

Model Training (Model Eğitimi)

Model Analytics (Model Analizi)

Model Comparison (Model Karşılaştırması)

Risk Predictor (Risk Tahmincisi)

Model Explanations (Model Açıklamaları)

Kullanılan Teknolojiler

Katkıda Bulunma

Lisans

✨ Özellikler
Etkileşimli Veri Keşfi: Veri setine göz atın ve özellikler arasındaki korelasyonları görselleştirin.

Çoklu Model Eğitimi: Lojistik Regresyon, Random Forest, Destek Vektör Makineleri (SVM) ve XGBoost gibi popüler makine öğrenimi algoritmalarını eğitin.

Model Performans Değerlendirmesi: Eğitim ve test setleri üzerindeki model metriklerini (Doğruluk, Duyarlılık, Özgüllük, F1 Skoru) görün.

ROC Eğrisi Karşılaştırması: Modellerin sınıflandırma performansını ROC eğrileri ile görselleştirin.

Özellik Önem Düzeyleri: Random Forest modeli için hangi özelliklerin tahmin üzerinde en büyük etkiye sahip olduğunu keşfedin.

Eğitim Süresi Analizi: Modellerin eğitim sürelerini karşılaştırın.

Özelleştirilebilir Görselleştirme: Seçtiğiniz modeller ve metrikler için kendi karşılaştırma grafiklerinizi oluşturun.

Risk Tahmincisi: Yeni hasta verileri girerek ölüm riskini anında tahmin edin.

Model Açıklamaları: Karar Ağacı gibi bazı modellerin nasıl çalıştığına dair basit görsel açıklamalar alın.

📊 Veri Seti
Bu uygulama, "Kalp Yetmezliği Klinik Kayıtları Veri Seti"ni kullanır. Bu veri seti, kalp yetmezliği olan hastaların tıbbi kayıtlarından derlenmiş çeşitli klinik özellikleri ve ölüm olayını (DEATH_EVENT) içerir. DEATH_EVENT hedef değişkenidir ve hastanın ölüm olayını gösterir (0: Hayır, 1: Evet).

Veri setindeki bazı önemli özellikler şunları içerebilir:

Yaş (age): Hastanın yaşı

Anemi (anaemia): Anemi varlığı (boolean)

Kreatinin Fosfokinaz (creatinine_phosphokinase): Kanda bulunan bir enzim seviyesi (mcg/L)

Diyabet (diabetes): Diyabet varlığı (boolean)

Ejekiyon Fraksiyonu (ejection_fraction): Kalpten pompalanan kan yüzdesi (%)

Yüksek Tansiyon (high_blood_pressure): Yüksek tansiyon varlığı (boolean)

Trombositler (platelets): Kandaki trombosit sayısı (kiloplatelets/mL)

Serum Kreatinin (serum_creatinine): Kandaki serum kreatinin seviyesi (mg/dL)

Serum Sodyum (serum_sodium): Kandaki serum sodyum seviyesi (mEq/L)

Cinsiyet (sex): Cinsiyet (0: Kadın, 1: Erkek)

Sigara (smoking): Sigara kullanımı (boolean)

Zaman (time): Hastanede takip süresi (gün)

🛠️ Kurulum
Bu Shiny uygulamasını kendi bilgisayarınızda çalıştırmak için R ve RStudio'nun yüklü olması gerekmektedir.

R ve RStudio'yu Yükleyin:

**R ve RStudio'yu Yükleyin:**
    * R'ı [buradan](https://cran.r-project.org/) indirin ve kurun.
    * RStudio'yu [buradan](https://posit.co/download/rstudio-desktop/) indirin ve kurun.

Gerekli R Paketlerini Yükleyin:
Uygulama çalışmadan önce bazı R paketlerinin yüklenmesi gerekir. RStudio'yu açın ve Konsol'a aşağıdaki komutları yapıştırın ve çalıştırın:

R

install.packages(c("shiny", "shinythemes", "caret", "DT", "ggplot2", "pROC",
                   "randomForest", "e1071", "nnet", "gbm", "xgboost",
                   "naivebayes", "glmnet", "rpart.plot", "corrplot",
                   "shinyWidgets", "plotly", "reshape2", "RColorBrewer",
                   "gridExtra", "knitr"))
Projeyi Klonlayın:
Bu GitHub deposunu yerel bilgisayarınıza klonlayın veya zip olarak indirin.

Bash

git clone https://github.com/ckrmustafa/HeartDiseasePrediction.git
cd HeartDiseasePrediction

Veri Setini Yerleştirin:
heart_failure_clinical_records_dataset.csv adlı veri setinin, app.R (veya ui.R ve server.R dosyalarınızın bulunduğu dizin) ile aynı klasörde olduğundan emin olun. Eğer veri setiniz farklı bir isimde veya konumdaysa, R kodundaki read.csv("heart_failure_clinical_records_dataset.csv") kısmını güncellemeyi unutmayın.

▶️ Uygulamayı Çalıştırma
RStudio'da Açın: RStudio'yu açın ve projenin ana klasörüne gidin. 
Uygulamayı Çalıştırın: RStudio'nun sağ üst köşesindeki "Run App" düğmesine tıklayın veya Konsol'a aşağıdaki komutu yazıp Enter'a basın:

shiny::runApp()
Uygulama varsayılan web tarayıcınızda açılacaktır.

📊 Uygulama Sekmeleri
Uygulama, farklı fonksiyonlar için birden fazla sekmeye sahiptir:

Data Explorer (Veri Keşfi)
Veri Tablosu: Yüklenen veri setinin tamamını etkileşimli bir tabloda görüntüleyin. Verileri arayabilir, sıralayabilir ve sayfalayabilirsiniz.

Korelasyon Grafiği: Sayısal özellikler arasındaki korelasyon matrisini renk kodlu bir grafikte gösterir. Bu, hangi özelliklerin birbiriyle veya hedef değişkenle ilişkili olduğunu anlamanıza yardımcı olur.

Model Training (Model Eğitimi)
Bu sekmede, makine öğrenimi modellerini eğitmek için ayarları yapılandırabilirsiniz:

Algoritmaları Seçin: Eğitmek istediğiniz makine öğrenimi algoritmalarını (örn. Lojistik Regresyon, Random Forest, XGBoost) seçin. Birden fazla algoritma seçebilirsiniz.

Eğitim/Test Bölme Oranı: Veri setinin ne kadarının eğitim için (modelleri öğretmek için), ne kadarının ise test için (modelleri değerlendirmek için) kullanılacağını ayarlayın.

Çapraz Doğrulama Katmanları (Cross-Validation Folds): Modelin sağlamlığını artırmak ve aşırı uyumu (overfitting) önlemek için kullanılan çapraz doğrulama sayısını belirtin.

Rastgele Çekirdek (Random Seed): Sonuçların tekrarlanabilir olmasını sağlamak için bir sayı girin.

Modelleri Eğit (Train Models): Seçtiğiniz ayarlarla modelleri eğitmeye başlamak için bu düğmeye tıklayın. Eğitim süreci biraz zaman alabilir.

Model Analytics (Model Analizi)
Modeller eğitildikten sonra bu sekmede detaylı analiz sonuçlarını bulabilirsiniz:

Model Özetleri: Eğitilen her modelin özet çıktısını (genellikle modelin iç detayları ve sonuçları) görüntüler.

Eğitim Metrikleri: Modellerin eğitim seti üzerindeki performans metriklerini (Doğruluk, Duyarlılık, Özgüllük, F1 Skoru) gösteren bir tablo.

Doğrulama Metrikleri: Modellerin test seti üzerindeki performans metriklerini (Doğruluk, Duyarlılık, Özgüllük, F1 Skoru) gösteren bir tablo. Bu metrikler, modelin yeni, daha önce görmediği verilere ne kadar iyi genellenebildiğini gösterir.

ROC Analizi: Her model için ROC (Receiver Operating Characteristic) eğrilerini karşılaştıran etkileşimli bir grafik. Alan eğrinin altında (AUC), modelin sınıflandırma performansının bir ölçüsüdür; daha yüksek AUC daha iyidir.

Özellik Önem Düzeyleri (Random Forest): Eğer Random Forest modelini eğittiyseniz, hangi özelliklerin ölüm olayını tahmin etmede en önemli olduğunu gösteren bir çubuk grafik.

Eğitim Süresi: Her bir modelin eğitiminin ne kadar sürdüğünü gösteren bir çubuk grafik.

Özelleştirilebilir Görselleştirme: İstediğiniz modelleri ve metrikleri seçerek kendi özel karşılaştırma grafiğinizi oluşturun.

Model Comparison (Model Karşılaştırması)
Karşılaştırma Tablosu: Tüm eğitilen modellerin test seti üzerindeki ana performans metriklerini içeren bir özet tablo.

Karşılaştırma Grafiği: Modellerin seçilen metrikler (Doğruluk, Duyarlılık, Özgüllük, F1 Skoru) bazında performansını görsel olarak karşılaştıran bir çubuk grafik.

Risk Predictor (Risk Tahmincisi)
Bu sekme, yeni hasta verileri girerek ölüm riskini tahmin etmenizi sağlar:

Girdi Alanları: Veri setindeki her özellik için (DEATH_EVENT hariç) değerleri girmeniz için etkileşimli kaydırıcılar veya seçim kutuları bulunur.

Riski Hesapla (Calculate Risk): Girilen değerlere dayanarak seçilen modellerin her biri için ölüm riskini (Evet/Hayır) tahmin etmek için bu düğmeye tıklayın.

Tahmin Çıktısı: Her modelin tahmin sonucunu gösteren bir tablo.

Model Explanations (Model Açıklamaları)
Bu sekme, eğitilen bazı modellerin nasıl çalıştığına dair basit açıklamalar sunar:

Karar Ağacı (Decision Tree): Eğer Karar Ağacı (rpart) modelini eğittiyseniz, modelin karar verme mantığını gösteren bir grafik görüntüler.

Lojistik Regresyon (Logistic Regression): Eğer Lojistik Regresyon modelini eğittiyseniz, modelin formülünü ve her bir özelliğin (değişkenin) risk üzerindeki etkisini gösteren katsayıları görüntüler.

💻 Kullanılan Teknolojiler
R

Shiny

caret

ggplot2

plotly

DT

pROC

randomForest

e1071

nnet

gbm

xgboost

naivebayes

glmnet

rpart.plot

corrplot

shinyWidgets

reshape2

RColorBrewer

gridExtra

knitr

🤝 Katkıda Bulunma
Bu projeye katkıda bulunmaktan çekinmeyin! Her türlü iyileştirme veya yeni özellik önerisi memnuniyetle karşılanır. Lütfen bir "issue" açın veya bir "pull request" gönderin.

📄 Lisans
Bu proje MIT Lisansı altında lisanslanmıştır. Daha fazla bilgi için LICENSE dosyasına bakın.

