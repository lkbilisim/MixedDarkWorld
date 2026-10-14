# Mixed Dark World 0.3.1 — İnsan Karakter Denemesi

**Durum:** Deneysel geliştirme dalı. Windows/Godot 4.7.2 gerçek uçtan uca test henüz yapılmadı. Mevcut 0.2.3 dünya ve kayıt kodlarına dokunulmaz.

## Amaç
- Hazır Diesel.glb, EMA.glb ve fatt tony.glb modellerini kullanan yalıtılmış karakter denemesi.
- Gerçek metre ölçeğinde yaklaşık 1,76 m görünür insan, çarpışma, üçüncü şahıs kamera, yürüme, koşma, zıplama ve engeller.
- İçe aktarılmış hareketler varsa oynatılır. Yoksa tanınan iskelet kemiklerinde deneysel kol-bacak canlandırması denenir.
- 1, 2, 3 tuşlarıyla gerçek zamanlı üç model arasından seçim.

## Kurulum
1. Bu daldaki MDW_0_3_1_Tek_Tik_Kur.bat dosyasını Windows'a indirip çalıştır.
2. Kurulumun sabit hedefi: E:\Mixed Dark World\Mixed Dark World Projesi
3. Üç yeni kaynak: scripts/character/mdw_player.gd, scripts/character/mdw_character_test.gd, scenes/MDW_Character_Test.tscn
4. Var olan aynı adlı dosyalar E:\Mixed Dark World\##SystemDriver\MDW_Yedekler altında yedeklenir.
5. Godot 4.7.2'de scenes/MDW_Character_Test.tscn dosyasını aç ve F6 ile bağımsız çalıştır.

## Tuşlar
- WASD veya oklar: yürü
- Shift: koş; Space: zıpla
- Fare: kamera; Escape: fareyi bırak; C: fareyi yeniden yakala
- 1: Diesel, 2: EMA, 3: Fatt Tony

## Henüz yapılmayanlar
- Windows üzerinde gerçek Godot ile ayrıştırma ve çalışma testi.
- 32 modelin tamamının teknik doğrulaması.
- Harici Mixamo hareketlerinin farklı iskeletlere otomatik uyarlanması.
- Kamera-ara nesne çarpışma önleme.
- Özgün gezegen ve Terrain3D arazisiyle bütünleştirme (0.3.2–0.3.3).

## Test kontrolü
- [ ] GDScript ayrıştırma hatası yok.
- [ ] Gerçek GLB model ekranda görünüyor.
- [ ] Hareket, koşu, zıplama, yerçekimi ve engel çarpışmaları çalışıyor.
- [ ] 1,2,3 model değişimi çalışıyor.
- [ ] Hareket animasyonu görünüyor; kaynak iskelet sınırları tespit edildi.
- [ ] Eski 0.2.3 testleri aynı şekilde başarılı.
- [ ] FPS ve kaplama kalitesi Windows bilgisayarda değerlendirildi.

NOT: Bu kaynakların yazılmış olması Godot testlerinin geçtiği anlamına gelmez.