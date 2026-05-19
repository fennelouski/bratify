#!/usr/bin/env python3
"""Add translations for the 43 remaining untranslated keys (filter names, UI strings)."""
import json, sys

XCSTRINGS_PATH = "/Users/nathanfennel/Documents/GitHub/Bratify/brat/Localizable.xcstrings"

LOCALES = [
    "af","ar","be","bg","bn","ca","cs","cy","da","de","el",
    "en","en-AU","en-CA","en-GB","en-IN",
    "es","es-419","es-US","et","eu","fa","fi","fil",
    "fr","fr-CA","ga","gl","he","hi","hr","hu","hy",
    "id","is","it","ja","ka","kk","ko","lt","lv","mk","mn","ms",
    "nb","nl","pl","pt-BR","pt-PT","ro","ru","sk","sl","sq",
    "sr","sr-Latn","sv","sw","ta","te","th","tr","uk","ur","uz",
    "vi","zh-HK","zh-Hans","zh-Hant"
]

def same(v):
    """Return dict with same value for all locales."""
    return {loc: v for loc in LOCALES}

def en_same(v):
    """English-region locales use the same English value, others use provided mapping."""
    return v  # use as-is when called with a full dict

TRANSLATIONS = {
    # ── Filter preset proper names kept in English everywhere ──────────────────
    "Brat Punch":    same("Brat Punch"),
    "Chrome Pop":    same("Chrome Pop"),
    "Negative Pop":  same("Negative Pop"),
    "Photo Noir":    same("Photo Noir"),
    "Soft Dream":    same("Soft Dream"),
    "Warm Fade":     same("Warm Fade"),
    "Zine":          same("Zine"),
    "Instant":       same("Instant"),
    "Process":       same("Process"),
    "Transfer":      same("Transfer"),
    "Tonal":         same("Tonal"),
    "Noir":          same("Noir"),
    "Chrome":        same("Chrome"),

    # ── Filter names with established translations ─────────────────────────────
    "Bloom": {
        "af":"Bloom","ar":"إضاءة","be":"Bloom","bg":"Bloom","bn":"ব্লুম",
        "ca":"Bloom","cs":"Bloom","cy":"Bloom","da":"Bloom","de":"Bloom",
        "el":"Bloom","en":"Bloom","en-AU":"Bloom","en-CA":"Bloom","en-GB":"Bloom","en-IN":"Bloom",
        "es":"Bloom","es-419":"Bloom","es-US":"Bloom","et":"Bloom","eu":"Bloom",
        "fa":"درخشش","fi":"Bloom","fil":"Bloom","fr":"Bloom","fr-CA":"Bloom",
        "ga":"Bloom","gl":"Bloom","he":"Bloom","hi":"ब्लूम","hr":"Bloom","hu":"Bloom",
        "hy":"Bloom","id":"Bloom","is":"Bloom","it":"Bloom","ja":"ブルーム",
        "ka":"Bloom","kk":"Bloom","ko":"블룸","lt":"Bloom","lv":"Bloom",
        "mk":"Bloom","mn":"Bloom","ms":"Bloom","nb":"Bloom","nl":"Bloom",
        "pl":"Bloom","pt-BR":"Bloom","pt-PT":"Bloom","ro":"Bloom","ru":"Bloom",
        "sk":"Bloom","sl":"Bloom","sq":"Bloom","sr":"Блум","sr-Latn":"Bloom",
        "sv":"Bloom","sw":"Bloom","ta":"ப்ளூம்","te":"బ్లూమ్","th":"Bloom",
        "tr":"Bloom","uk":"Bloom","ur":"بلوم","uz":"Bloom","vi":"Bloom",
        "zh-HK":"光暈","zh-Hans":"光晕","zh-Hant":"光暈",
    },

    "Duotone": {
        "af":"Duotoon","ar":"ثنائي اللون","be":"Двухтоновы","bg":"Двутонов","bn":"ডুওটোন",
        "ca":"Duotó","cs":"Duotón","cy":"Deulliw","da":"Duotone","de":"Duoton",
        "el":"Δίτονο","en":"Duotone","en-AU":"Duotone","en-CA":"Duotone","en-GB":"Duotone","en-IN":"Duotone",
        "es":"Duotono","es-419":"Duotono","es-US":"Duotone","et":"Duotoon","eu":"Duotono",
        "fa":"دوتون","fi":"Duotoni","fil":"Duotone","fr":"Bichromie","fr-CA":"Bichromie",
        "ga":"Duatón","gl":"Duotono","he":"דו-גוני","hi":"द्विस्वर","hr":"Duoton","hu":"Duotón",
        "hy":"Երկգույն","id":"Duotone","is":"Tvenntóna","it":"Duotono","ja":"デュオトーン",
        "ka":"Duotone","kk":"Дуотон","ko":"듀오톤","lt":"Duotonas","lv":"Duotons",
        "mk":"Дуотон","mn":"Хоёр өнгөт","ms":"Duoton","nb":"Duotone","nl":"Duotoon",
        "pl":"Duoton","pt-BR":"Duotone","pt-PT":"Duotone","ro":"Duoton","ru":"Дуотон",
        "sk":"Duotón","sl":"Duoton","sq":"Duoton","sr":"Дуотон","sr-Latn":"Duoton",
        "sv":"Duotone","sw":"Duotoni","ta":"டூடோன்","te":"డ్యూటోన్","th":"ดูโอโทน",
        "tr":"Duoton","uk":"Дуотон","ur":"دوٹون","uz":"Duoton","vi":"Hai tông màu",
        "zh-HK":"雙色調","zh-Hans":"双色调","zh-Hant":"雙色調",
    },

    "Fade": {
        "af":"Vervaag","ar":"بهوت","be":"Зацямненне","bg":"Избледняване","bn":"ফেড",
        "ca":"Esvaiment","cs":"Vybledlý","cy":"Pylu","da":"Faded","de":"Verblasst",
        "el":"Εξασθένηση","en":"Fade","en-AU":"Fade","en-CA":"Fade","en-GB":"Fade","en-IN":"Fade",
        "es":"Desvanecido","es-419":"Desvanecido","es-US":"Fade","et":"Tuhmunud","eu":"Biluztua",
        "fa":"محو","fi":"Haalistunut","fil":"Fade","fr":"Estompe","fr-CA":"Estompe",
        "ga":"Meath","gl":"Esvaecido","he":"דהייה","hi":"फीका","hr":"Izblijedio","hu":"Halvány",
        "hy":"Մարող","id":"Pudar","is":"Þverr","it":"Sbiadito","ja":"フェード",
        "ka":"გაცრეცილება","kk":"Солу","ko":"페이드","lt":"Blukimas","lv":"Izbalēšana",
        "mk":"Избледен","mn":"Бүдгэрүүлэх","ms":"Pudar","nb":"Falmet","nl":"Vervaagd",
        "pl":"Wyblakłe","pt-BR":"Desbotado","pt-PT":"Desbotado","ro":"Estompat","ru":"Выцветший",
        "sk":"Vyblednutý","sl":"Zbledelo","sq":"Zbehur","sr":"Избледело","sr-Latn":"Izbledelo",
        "sv":"Blekning","sw":"Fifia","ta":"மங்கிய","te":"ఫేడ్","th":"จาง",
        "tr":"Solar","uk":"Вицвілий","ur":"دھندلا","uz":"Oʻngan","vi":"Mờ dần",
        "zh-HK":"褪色","zh-Hans":"褪色","zh-Hant":"褪色",
    },

    "Grain": {
        "af":"Grein","ar":"حبيبات","be":"Збожжа","bg":"Зърно","bn":"গ্রেইন",
        "ca":"Gra","cs":"Zrno","cy":"Graen","da":"Korn","de":"Korn",
        "el":"Κόκκος","en":"Grain","en-AU":"Grain","en-CA":"Grain","en-GB":"Grain","en-IN":"Grain",
        "es":"Grano","es-419":"Grano","es-US":"Grain","et":"Tera","eu":"Alea",
        "fa":"دانه","fi":"Rakeisuus","fil":"Grain","fr":"Grain","fr-CA":"Grain",
        "ga":"Gráin","gl":"Gran","he":"גרגר","hi":"दाना","hr":"Zrno","hu":"Szemcsés",
        "hy":"Հատիկ","id":"Butiran","is":"Korn","it":"Grana","ja":"グレイン",
        "ka":"მარცვლი","kk":"Дән","ko":"그레인","lt":"Grūdeliavimas","lv":"Graudiņi",
        "mk":"Зрно","mn":"Ширхэг","ms":"Butiran","nb":"Korn","nl":"Graan",
        "pl":"Ziarno","pt-BR":"Granulado","pt-PT":"Granulado","ro":"Grăunțe","ru":"Зерно",
        "sk":"Zrno","sl":"Zrnitost","sq":"Grimcë","sr":"Зрно","sr-Latn":"Zrno",
        "sv":"Korn","sw":"Chembechembe","ta":"தானிய","te":"గ్రెయిన్","th":"เกรน",
        "tr":"Tane","uk":"Зерно","ur":"گرین","uz":"Don","vi":"Hạt",
        "zh-HK":"顆粒","zh-Hans":"颗粒","zh-Hant":"顆粒",
    },

    "Halftone": {
        "af":"Halftoon","ar":"نصف درجة","be":"Паўтон","bg":"Полутон","bn":"হাফটোন",
        "ca":"Mig to","cs":"Polotón","cy":"Hanner tôn","da":"Halvtone","de":"Halbton",
        "el":"Ημιτόνιο","en":"Halftone","en-AU":"Halftone","en-CA":"Halftone","en-GB":"Halftone","en-IN":"Halftone",
        "es":"Semitono","es-419":"Semitono","es-US":"Halftone","et":"Pooltoon","eu":"Erdipuntua",
        "fa":"نیم‌تُن","fi":"Rasterointi","fil":"Halftone","fr":"Demi-teinte","fr-CA":"Demi-teinte",
        "ga":"Leath-ton","gl":"Semitono","he":"חצי טון","hi":"हाफटोन","hr":"Polutón","hu":"Féltónus",
        "hy":"Կիսատոն","id":"Halftone","is":"Hálfblær","it":"Mezzotono","ja":"ハーフトーン",
        "ka":"ნახევარტონი","kk":"Жартылай тон","ko":"하프톤","lt":"Pustoniai","lv":"Pustoņi",
        "mk":"Полутон","mn":"Хагас өнгийн","ms":"Separuh nada","nb":"Halvtone","nl":"Halftoon",
        "pl":"Półton","pt-BR":"Meio-tom","pt-PT":"Meio-tom","ro":"Semiton","ru":"Полутон",
        "sk":"Polotón","sl":"Polton","sq":"Gjysëm toni","sr":"Полутон","sr-Latn":"Poluton",
        "sv":"Halvton","sw":"Nusu sauti","ta":"அரைத்தொனி","te":"హాఫ్‌టోన్","th":"ฮาล์ฟโทน",
        "tr":"Yarı ton","uk":"Напівтон","ur":"آدھا ٹون","uz":"Yarim ton","vi":"Nửa tông",
        "zh-HK":"半色調","zh-Hans":"半色调","zh-Hant":"半色調",
    },

    "Highlights": {
        "af":"Hoogtepunte","ar":"الإضاءات","be":"Яркія дзялянкі","bg":"Светлини","bn":"হাইলাইট",
        "ca":"Il·luminacions","cs":"Světlá místa","cy":"Uchafbwyntiau","da":"Højlys","de":"Glanzlichter",
        "el":"Φωτεινά σημεία","en":"Highlights","en-AU":"Highlights","en-CA":"Highlights","en-GB":"Highlights","en-IN":"Highlights",
        "es":"Iluminaciones","es-419":"Iluminaciones","es-US":"Highlights","et":"Eredimad alad","eu":"Argitasun handiak",
        "fa":"نقاط روشن","fi":"Kirkkaat alueet","fil":"Highlights","fr":"Hautes lumières","fr-CA":"Hautes lumières",
        "ga":"Buaicphointí","gl":"Iluminacións","he":"אזורים בהירים","hi":"हाइलाइट्स","hr":"Svjetla mjesta","hu":"Csúcsfények",
        "hy":"Պայծառ հատվածներ","id":"Sorotan","is":"Hámörk","it":"Luci","ja":"ハイライト",
        "ka":"ნათელი ადგილები","kk":"Ашық аймақтар","ko":"하이라이트","lt":"Ryškios vietos","lv":"Gaišas vietas",
        "mk":"Светли места","mn":"Тод гэрэлтэй хэсэг","ms":"Sorotan","nb":"Lys","nl":"Hooglichten",
        "pl":"Światła","pt-BR":"Tons claros","pt-PT":"Tons claros","ro":"Zone luminoase","ru":"Светлые участки",
        "sk":"Svetlé oblasti","sl":"Svetle točke","sq":"Zonat e ndritshme","sr":"Светле области","sr-Latn":"Svetle oblasti",
        "sv":"Ljusområden","sw":"Maeneo Mkali","ta":"ஒளிர்வுகள்","te":"హైలైట్లు","th":"ไฮไลท์",
        "tr":"Parlak Alanlar","uk":"Яскраві ділянки","ur":"روشن حصے","uz":"Yorqin joylar","vi":"Vùng sáng",
        "zh-HK":"亮部","zh-Hans":"高光","zh-Hant":"亮部",
    },

    "Hue": {
        "af":"Kleurskakering","ar":"تدرج اللون","be":"Адценне","bg":"Нюанс","bn":"হিউ",
        "ca":"To","cs":"Odstín","cy":"Gwawr","da":"Farvetone","de":"Farbton",
        "el":"Απόχρωση","en":"Hue","en-AU":"Hue","en-CA":"Hue","en-GB":"Hue","en-IN":"Hue",
        "es":"Tono","es-419":"Tono","es-US":"Hue","et":"Toon","eu":"Tintua",
        "fa":"رنگ","fi":"Värisävy","fil":"Hue","fr":"Teinte","fr-CA":"Teinte",
        "ga":"Dath","gl":"Ton","he":"גוון","hi":"रंगत","hr":"Nijansa","hu":"Árnyalat",
        "hy":"Երանգ","id":"Rona warna","is":"Litblær","it":"Tonalità","ja":"色相",
        "ka":"ელფერი","kk":"Реңк","ko":"색조","lt":"Atspalvis","lv":"Nokrāsa",
        "mk":"Тон","mn":"Өнгийн тон","ms":"Rona","nb":"Fargetone","nl":"Tint",
        "pl":"Barwa","pt-BR":"Matiz","pt-PT":"Matiz","ro":"Nuanță","ru":"Оттенок",
        "sk":"Odtieň","sl":"Barvni ton","sq":"Nuanca","sr":"Нијанса","sr-Latn":"Nijansa",
        "sv":"Kulörton","sw":"Toni","ta":"நிறத்திட்டம்","te":"హ్యూ","th":"สีโทน",
        "tr":"Renk tonu","uk":"Відтінок","ur":"رنگت","uz":"Rang toni","vi":"Sắc độ",
        "zh-HK":"色相","zh-Hans":"色相","zh-Hant":"色相",
    },

    "Posterize": {
        "af":"Posteriseer","ar":"تحديد مستويات","be":"Пастэрызаваць","bg":"Постеризиране","bn":"পোস্টারাইজ",
        "ca":"Posteritzar","cs":"Posterizovat","cy":"Posteru","da":"Posteriser","de":"Posterisieren",
        "el":"Αφαίρεση τόνων","en":"Posterize","en-AU":"Posterize","en-CA":"Posterize","en-GB":"Posterise","en-IN":"Posterize",
        "es":"Posterizar","es-419":"Posterizar","es-US":"Posterize","et":"Posteriseerima","eu":"Posterizatu",
        "fa":"پوستراکریشن","fi":"Posterisoi","fil":"Posterize","fr":"Postérisation","fr-CA":"Postérisation",
        "ga":"Póstaer","gl":"Posterizar","he":"פוסטריזציה","hi":"पोस्टराइज़","hr":"Posterizacija","hu":"Plakáttá alakítás",
        "hy":"Տպագրացնել","id":"Posterisasi","is":"Posterisera","it":"Posterizzare","ja":"ポスタリゼーション",
        "ka":"Posterizacia","kk":"Постеризация","ko":"포스터화","lt":"Posterizavimas","lv":"Posterizēšana",
        "mk":"Постеризација","mn":"Постеризаци","ms":"Posterisasi","nb":"Posterisering","nl":"Posterisering",
        "pl":"Posteryzacja","pt-BR":"Posterização","pt-PT":"Posterização","ro":"Posterizare","ru":"Постеризация",
        "sk":"Posterizovanie","sl":"Posterizacija","sq":"Posterizoim","sr":"Постеризација","sr-Latn":"Posterizacija",
        "sv":"Posterisering","sw":"Posterize","ta":"போஸ்டரைஸ்","te":"పోస్టరైజ్","th":"โปสเตอร์ไรซ์",
        "tr":"Posterleştir","uk":"Постеризація","ur":"پوسٹرائز","uz":"Posterizatsiya","vi":"Posterize",
        "zh-HK":"海報化","zh-Hans":"色调分离","zh-Hant":"海報化",
    },

    "Shadows": {
        "af":"Skaduwees","ar":"الظلال","be":"Ценявыя вобласці","bg":"Сенки","bn":"শ্যাডো",
        "ca":"Ombres","cs":"Stíny","cy":"Cysgodion","da":"Skygger","de":"Schatten",
        "el":"Σκιές","en":"Shadows","en-AU":"Shadows","en-CA":"Shadows","en-GB":"Shadows","en-IN":"Shadows",
        "es":"Sombras","es-419":"Sombras","es-US":"Shadows","et":"Varjud","eu":"Itzalak",
        "fa":"سایه‌ها","fi":"Varjot","fil":"Shadows","fr":"Ombres","fr-CA":"Ombres",
        "ga":"Scáthanna","gl":"Sombras","he":"צלליות","hi":"परछाईं","hr":"Sjene","hu":"Árnyékok",
        "hy":"Ստվերներ","id":"Bayangan","is":"Skuggar","it":"Ombre","ja":"シャドウ",
        "ka":"ჩრდილები","kk":"Көлеңкелер","ko":"그림자","lt":"Šešėliai","lv":"Ēnas",
        "mk":"Сенки","mn":"Сүүдэр","ms":"Bayang-bayang","nb":"Skygger","nl":"Schaduwen",
        "pl":"Cienie","pt-BR":"Sombras","pt-PT":"Sombras","ro":"Umbre","ru":"Тени",
        "sk":"Tiene","sl":"Sence","sq":"Hijet","sr":"Сенке","sr-Latn":"Senke",
        "sv":"Skuggor","sw":"Vivuli","ta":"நிழல்கள்","te":"నీడలు","th":"เงา",
        "tr":"Gölgeler","uk":"Тіні","ur":"سائے","uz":"Soyalar","vi":"Bóng tối",
        "zh-HK":"陰影","zh-Hans":"阴影","zh-Hant":"陰影",
    },

    "Temperature": {
        "af":"Temperatuur","ar":"درجة الحرارة","be":"Тэмпература","bg":"Температура","bn":"তাপমাত্রা",
        "ca":"Temperatura","cs":"Teplota","cy":"Tymheredd","da":"Temperatur","de":"Temperatur",
        "el":"Θερμοκρασία","en":"Temperature","en-AU":"Temperature","en-CA":"Temperature","en-GB":"Temperature","en-IN":"Temperature",
        "es":"Temperatura","es-419":"Temperatura","es-US":"Temperature","et":"Temperatuur","eu":"Tenperatura",
        "fa":"دما","fi":"Värilämpötila","fil":"Temperature","fr":"Température","fr-CA":"Température",
        "ga":"Teocht","gl":"Temperatura","he":"טמפרטורה","hi":"तापमान","hr":"Temperatura","hu":"Hőmérséklet",
        "hy":"Ջերմաստիճան","id":"Suhu","is":"Hitastig","it":"Temperatura","ja":"色温度",
        "ka":"ტემპერატურა","kk":"Температура","ko":"색 온도","lt":"Temperatūra","lv":"Temperatūra",
        "mk":"Температура","mn":"Температур","ms":"Suhu","nb":"Fargetemperatur","nl":"Temperatuur",
        "pl":"Temperatura","pt-BR":"Temperatura","pt-PT":"Temperatura","ro":"Temperatură","ru":"Температура",
        "sk":"Teplota","sl":"Temperatura","sq":"Temperatura","sr":"Температура","sr-Latn":"Temperatura",
        "sv":"Temperatur","sw":"Joto","ta":"வெப்பநிலை","te":"ఉష్ణోగ్రత","th":"อุณหภูมิสี",
        "tr":"Renk Sıcaklığı","uk":"Температура","ur":"رنگ درجہ حرارت","uz":"Harorat","vi":"Nhiệt độ màu",
        "zh-HK":"色溫","zh-Hans":"色温","zh-Hant":"色溫",
    },

    "Tint": {
        "af":"Tint","ar":"صبغة","be":"Адценне","bg":"Оцветяване","bn":"টিন্ট",
        "ca":"Tint","cs":"Odstín","cy":"Lliw","da":"Farvetone","de":"Farbstich",
        "el":"Απόχρωση","en":"Tint","en-AU":"Tint","en-CA":"Tint","en-GB":"Tint","en-IN":"Tint",
        "es":"Tinte","es-419":"Tinte","es-US":"Tint","et":"Toon","eu":"Tinta",
        "fa":"رنگ‌آمیزی","fi":"Värivivahdus","fil":"Tint","fr":"Teinte","fr-CA":"Teinte",
        "ga":"Dathúchán","gl":"Tinte","he":"גוון","hi":"रंगत","hr":"Ton boje","hu":"Tónus",
        "hy":"Ներկ","id":"Rona","is":"Litblær","it":"Tinta","ja":"ティント",
        "ka":"ელფერი","kk":"Реңк","ko":"색조","lt":"Spalvos tonas","lv":"Toņojums",
        "mk":"Нијанса","mn":"Өнгийн нюанс","ms":"Tona","nb":"Fargenyanse","nl":"Tint",
        "pl":"Zabarwienie","pt-BR":"Matiz","pt-PT":"Matiz","ro":"Nuanță","ru":"Оттенок",
        "sk":"Tón","sl":"Barvni odtenek","sq":"Nuanca","sr":"Нијанса","sr-Latn":"Nijansa",
        "sv":"Tonskiftning","sw":"Rangi","ta":"நிரப்பி","te":"టింట్","th":"สีย้อม",
        "tr":"Renk tonu","uk":"Відтінок","ur":"رنگت","uz":"Rang nozikligi","vi":"Tông màu",
        "zh-HK":"色調","zh-Hans":"色调","zh-Hant":"色調",
    },

    "Unsharp Mask": {
        "af":"Skerp masker","ar":"قناع الحدة","be":"Нерэзкая маска","bg":"Маска за острота","bn":"আনশার্প মাস্ক",
        "ca":"Màscara de desenfocament","cs":"Maska doostření","cy":"Mwgwd Ansharb","da":"Unskarp maske","de":"Unscharf maskieren",
        "el":"Μη εστιασμένη μάσκα","en":"Unsharp Mask","en-AU":"Unsharp Mask","en-CA":"Unsharp Mask","en-GB":"Unsharp Mask","en-IN":"Unsharp Mask",
        "es":"Máscara de enfoque","es-419":"Máscara de enfoque","es-US":"Unsharp Mask","et":"Teravustamise mask","eu":"Zorroztze-maskara",
        "fa":"ماسک تیزی","fi":"Epätarkka peite","fil":"Unsharp Mask","fr":"Masque flou","fr-CA":"Masque flou",
        "ga":"Masc Neamhghéar","gl":"Máscara de nitidez","he":"מסכה לא חדה","hi":"अनशार्प मास्क","hr":"Maska izoštravanja","hu":"Életlen maszk",
        "hy":"Անկտուր դիմակ","id":"Masker tidak tajam","is":"Óskarpa grímur","it":"Maschera di contrasto","ja":"アンシャープマスク",
        "ka":"დამახინჯებული ნიღაბი","kk":"Бұлдыр маска","ko":"언샤프 마스크","lt":"Neaštri kaukė","lv":"Neasā maska",
        "mk":"Нечиста маска","mn":"Тод бус маск","ms":"Topeng tidak tajam","nb":"Uskarp maske","nl":"Onscherp masker",
        "pl":"Maska niezaostrzająca","pt-BR":"Máscara de contraste","pt-PT":"Máscara de realce","ro":"Mască neclară","ru":"Нерезкая маска",
        "sk":"Maska doostrovania","sl":"Maska za ostrenje","sq":"Maska e pandrequr","sr":"Мека маска","sr-Latn":"Meka maska",
        "sv":"Oskarp mask","sw":"Kidago kisichokuwa wazi","ta":"அரிக்கப்படாத மாஸ்க்","te":"అస్పష్ట మాస్క్","th":"อันชาร์ปมาสก์",
        "tr":"Keskin olmayan maske","uk":"Нерізка маска","ur":"غیر واضح ماسک","uz":"Noaniq niqob","vi":"Mặt nạ mờ",
        "zh-HK":"不銳利遮罩","zh-Hans":"不锐化蒙版","zh-Hant":"不銳利遮罩",
    },

    "Vibrance": {
        "af":"Lewendigheid","ar":"الحيوية","be":"Насычанасць","bg":"Наситеност","bn":"ভাইব্রেন্স",
        "ca":"Vibràncies","cs":"Živost","cy":"Bywiogrwydd","da":"Livfuldhed","de":"Dynamik",
        "el":"Ζωντάνια","en":"Vibrance","en-AU":"Vibrance","en-CA":"Vibrance","en-GB":"Vibrance","en-IN":"Vibrance",
        "es":"Intensidad","es-419":"Intensidad","es-US":"Vibrance","et":"Elujõud","eu":"Biztasuna",
        "fa":"سرزندگی","fi":"Eloisuus","fil":"Vibrance","fr":"Vibrance","fr-CA":"Vibrance",
        "ga":"Beocht","gl":"Viveza","he":"חיוניות","hi":"ज्वलंतता","hr":"Živost boja","hu":"Élénkség",
        "hy":"Կենսունակություն","id":"Kecemerlangan","is":"Lífleiki","it":"Naturalezza","ja":"自然な彩度",
        "ka":"სიცოცხლისუნარიანობა","kk":"Қайнарлық","ko":"바이브런스","lt":"Gyvumas","lv":"Dzīvīgums",
        "mk":"Живост","mn":"Тод байдал","ms":"Kecemerlangan","nb":"Livlighet","nl":"Levendigheid",
        "pl":"Żywość","pt-BR":"Vibração","pt-PT":"Vibração","ro":"Vivacitate","ru":"Живость",
        "sk":"Živosť","sl":"Živahnost","sq":"Gjallëria","sr":"Живост","sr-Latn":"Živost",
        "sv":"Livlighet","sw":"Msisimko","ta":"துடிப்பு","te":"వైభ్రెన్స్","th":"ความสดใส",
        "tr":"Canlılık","uk":"Жвавість","ur":"توانائی","uz":"Quvvat","vi":"Độ rực rỡ",
        "zh-HK":"自然飽和度","zh-Hans":"自然饱和度","zh-Hant":"自然飽和度",
    },

    # ── Background + filter compound names ────────────────────────────────────
}

# Auto-generate Background variants from base filter names
BASE_FILTER_KEYS = [
    "Bloom","Duotone","Grain","Halftone","Highlights","Hue",
    "Posterize","Shadows","Temperature","Tint","Unsharp Mask","Vibrance"
]

def make_bg(base_translations, locale_prefixer):
    """Build Background X translations by prepending the locale-appropriate prefix."""
    bg_prefixes = {
        "af":"Agtergrond","ar":"خلفية","be":"Фон","bg":"Фон","bn":"পটভূমি",
        "ca":"Fons","cs":"Pozadí","cy":"Cefndir","da":"Baggrund","de":"Hintergrund",
        "el":"Φόντο","en":"Background","en-AU":"Background","en-CA":"Background","en-GB":"Background","en-IN":"Background",
        "es":"Fondo","es-419":"Fondo","es-US":"Background","et":"Taust","eu":"Atzealdia",
        "fa":"پس‌زمینه","fi":"Tausta","fil":"Background","fr":"Arrière-plan","fr-CA":"Arrière-plan",
        "ga":"Cúlra","gl":"Fondo","he":"רקע","hi":"पृष्ठभूमि","hr":"Pozadina","hu":"Háttér",
        "hy":"Ֆոն","id":"Latar belakang","is":"Bakgrunnur","it":"Sfondo","ja":"背景",
        "ka":"ფონი","kk":"Фон","ko":"배경","lt":"Fonas","lv":"Fons",
        "mk":"Позадина","mn":"Дэвсгэр","ms":"Latar belakang","nb":"Bakgrunn","nl":"Achtergrond",
        "pl":"Tło","pt-BR":"Fundo","pt-PT":"Fundo","ro":"Fundal","ru":"Фон",
        "sk":"Pozadie","sl":"Ozadje","sq":"Sfondi","sr":"Позадина","sr-Latn":"Pozadina",
        "sv":"Bakgrund","sw":"Mandharinyuma","ta":"பின்னணி","te":"నేపథ్యం","th":"พื้นหลัง",
        "tr":"Arka plan","uk":"Фон","ur":"پس منظر","uz":"Fon","vi":"Nền",
        "zh-HK":"背景","zh-Hans":"背景","zh-Hant":"背景",
    }
    result = {}
    for loc in LOCALES:
        prefix = bg_prefixes.get(loc, "Background")
        base_val = base_translations.get(loc, base_translations.get("en", ""))
        result[loc] = f"{prefix} {base_val}"
    return result

for base_key in BASE_FILTER_KEYS:
    bg_key = f"Background {base_key}"
    if base_key in TRANSLATIONS:
        TRANSLATIONS[bg_key] = make_bg(TRANSLATIONS[base_key], None)

# ── UI strings ────────────────────────────────────────────────────────────────

TRANSLATIONS["Styles"] = {
    "af":"Style","ar":"الأنماط","be":"Стылі","bg":"Стилове","bn":"স্টাইল",
    "ca":"Estils","cs":"Styly","cy":"Arddulliau","da":"Stilarter","de":"Stile",
    "el":"Στυλ","en":"Styles","en-AU":"Styles","en-CA":"Styles","en-GB":"Styles","en-IN":"Styles",
    "es":"Estilos","es-419":"Estilos","es-US":"Styles","et":"Stiilid","eu":"Estiloak",
    "fa":"سبک‌ها","fi":"Tyylit","fil":"Mga estilo","fr":"Styles","fr-CA":"Styles",
    "ga":"Stíleanna","gl":"Estilos","he":"סגנונות","hi":"शैलियाँ","hr":"Stilovi","hu":"Stílusok",
    "hy":"Ոճեր","id":"Gaya","is":"Stílar","it":"Stili","ja":"スタイル",
    "ka":"სტილები","kk":"Стильдер","ko":"스타일","lt":"Stiliai","lv":"Stili",
    "mk":"Стилови","mn":"Загвар","ms":"Gaya","nb":"Stiler","nl":"Stijlen",
    "pl":"Style","pt-BR":"Estilos","pt-PT":"Estilos","ro":"Stiluri","ru":"Стили",
    "sk":"Štýly","sl":"Slogi","sq":"Stile","sr":"Стилови","sr-Latn":"Stilovi",
    "sv":"Stilar","sw":"Mitindo","ta":"பாணிகள்","te":"శైలులు","th":"สไตล์",
    "tr":"Stiller","uk":"Стилі","ur":"طرز","uz":"Uslublar","vi":"Kiểu dáng",
    "zh-HK":"風格","zh-Hans":"风格","zh-Hant":"風格",
}

TRANSLATIONS["Reset Background Filters"] = {
    "af":"Agtergrondfilters terugstel","ar":"إعادة تعيين مرشحات الخلفية",
    "be":"Скінуць фільтры фону","bg":"Нулиране на филтрите на фона",
    "bn":"পটভূমি ফিল্টার রিসেট করুন","ca":"Restablir els filtres del fons",
    "cs":"Obnovit filtry pozadí","cy":"Ailosod Hidlyddion Cefndir",
    "da":"Nulstil baggrundsfiltre","de":"Hintergrundfilter zurücksetzen",
    "el":"Επαναφορά φίλτρων φόντου","en":"Reset Background Filters",
    "en-AU":"Reset Background Filters","en-CA":"Reset Background Filters",
    "en-GB":"Reset Background Filters","en-IN":"Reset Background Filters",
    "es":"Restablecer filtros de fondo","es-419":"Restablecer filtros de fondo",
    "es-US":"Reset Background Filters","et":"Lähtesta taustafiltrid","eu":"Berrezarri atzealdearen iragazkiak",
    "fa":"بازنشانی فیلترهای پس‌زمینه","fi":"Nollaa taustasuotimet","fil":"I-reset ang mga background filter",
    "fr":"Réinitialiser les filtres d'arrière-plan","fr-CA":"Réinitialiser les filtres d'arrière-plan",
    "ga":"Athshocraigh Scagairí Cúlra","gl":"Restablecer filtros de fondo",
    "he":"אפס פילטרי רקע","hi":"पृष्ठभूमि फ़िल्टर रीसेट करें","hr":"Poništi filtere pozadine","hu":"Háttérszűrők visszaállítása",
    "hy":"Վերականգնել ֆոնի ֆիլտրերը","id":"Setel ulang filter latar belakang","is":"Endurstilla bakgrunnsíur","it":"Reimposta filtri sfondo",
    "ja":"背景フィルタをリセット","ka":"ფონის ფილტრების გადატვირთვა","kk":"Фон сүзгілерін қалпына келтіру","ko":"배경 필터 재설정",
    "lt":"Atstatyti fono filtrus","lv":"Atiestatīt fona filtrus","mk":"Ресетирај ги филтрите на позадината","mn":"Арын дэвсгэрийн шүүлтүүрийг дахин тохируулах",
    "ms":"Tetapkan semula penapis latar belakang","nb":"Tilbakestill bakgrunnsfiltre","nl":"Achtergrondfilters opnieuw instellen","pl":"Resetuj filtry tła",
    "pt-BR":"Redefinir filtros de fundo","pt-PT":"Repor filtros do fundo","ro":"Resetare filtre fundal","ru":"Сброс фильтров фона",
    "sk":"Obnoviť filtre pozadia","sl":"Ponastavi filtre ozadja","sq":"Rivendos filtrat e sfondit","sr":"Ресетуј филтере позадине",
    "sr-Latn":"Resetuj filtere pozadine","sv":"Återställ bakgrundsfilter","sw":"Weka upya vichujio vya mandharinyuma","ta":"பின்னணி வடிகட்டிகளை மீட்டமைக்கவும்",
    "te":"నేపథ్య ఫిల్టర్లను రీసెట్ చేయండి","th":"รีเซ็ตตัวกรองพื้นหลัง","tr":"Arka plan filtrelerini sıfırla","uk":"Скинути фільтри фону",
    "ur":"پس منظر فلٹر ری سیٹ کریں","uz":"Fon filtrlarini tiklash","vi":"Đặt lại bộ lọc nền",
    "zh-HK":"重設背景濾鏡","zh-Hans":"重置背景滤镜","zh-Hant":"重設背景濾鏡",
}

TRANSLATIONS["Reset Main Filters"] = {
    "af":"Hooffilters terugstel","ar":"إعادة تعيين المرشحات الرئيسية",
    "be":"Скінуць асноўныя фільтры","bg":"Нулиране на основните филтри",
    "bn":"মূল ফিল্টার রিসেট করুন","ca":"Restablir els filtres principals",
    "cs":"Obnovit hlavní filtry","cy":"Ailosod Prif Hidlyddion",
    "da":"Nulstil hovedfiltre","de":"Hauptfilter zurücksetzen",
    "el":"Επαναφορά κύριων φίλτρων","en":"Reset Main Filters",
    "en-AU":"Reset Main Filters","en-CA":"Reset Main Filters",
    "en-GB":"Reset Main Filters","en-IN":"Reset Main Filters",
    "es":"Restablecer filtros principales","es-419":"Restablecer filtros principales",
    "es-US":"Reset Main Filters","et":"Lähtesta peamised filtrid","eu":"Berrezarri iragazki nagusiak",
    "fa":"بازنشانی فیلترهای اصلی","fi":"Nollaa pääsuotimet","fil":"I-reset ang mga pangunahing filter",
    "fr":"Réinitialiser les filtres principaux","fr-CA":"Réinitialiser les filtres principaux",
    "ga":"Athshocraigh Príomhscagairí","gl":"Restablecer filtros principais",
    "he":"אפס פילטרים ראשיים","hi":"मुख्य फ़िल्टर रीसेट करें","hr":"Poništi glavne filtere","hu":"Főszűrők visszaállítása",
    "hy":"Վերականգնել հիմնական ֆիլտրերը","id":"Setel ulang filter utama","is":"Endurstilla aðalsíur","it":"Reimposta filtri principali",
    "ja":"メインフィルタをリセット","ka":"მთავარი ფილტრების გადატვირთვა","kk":"Негізгі сүзгілерді қалпына келтіру","ko":"주요 필터 재설정",
    "lt":"Atstatyti pagrindinius filtrus","lv":"Atiestatīt galvenos filtrus","mk":"Ресетирај ги главните филтри","mn":"Үндсэн шүүлтүүрийг дахин тохируулах",
    "ms":"Tetapkan semula penapis utama","nb":"Tilbakestill hovedfiltre","nl":"Hoofdfilters opnieuw instellen","pl":"Resetuj główne filtry",
    "pt-BR":"Redefinir filtros principais","pt-PT":"Repor filtros principais","ro":"Resetare filtre principale","ru":"Сброс основных фильтров",
    "sk":"Obnoviť hlavné filtre","sl":"Ponastavi glavne filtre","sq":"Rivendos filtrat kryesore","sr":"Ресетуј главне филтере",
    "sr-Latn":"Resetuj glavne filtere","sv":"Återställ huvudfilter","sw":"Weka upya vichujio vikuu","ta":"முக்கிய வடிகட்டிகளை மீட்டமைக்கவும்",
    "te":"ప్రధాన ఫిల్టర్లను రీసెట్ చేయండి","th":"รีเซ็ตตัวกรองหลัก","tr":"Ana filtreleri sıfırla","uk":"Скинути основні фільтри",
    "ur":"مرکزی فلٹر ری سیٹ کریں","uz":"Asosiy filtrlarni tiklash","vi":"Đặt lại bộ lọc chính",
    "zh-HK":"重設主要濾鏡","zh-Hans":"重置主要滤镜","zh-Hant":"重設主要濾鏡",
}

TRANSLATIONS["Copy Background → Main"] = {
    "af":"Kopieer Agtergrond → Hoof","ar":"نسخ الخلفية → الرئيسي",
    "be":"Капіяваць фон → асноўнае","bg":"Копирай фон → Основен",
    "bn":"পটভূমি কপি করুন → মূল","ca":"Copia fons → Principal",
    "cs":"Zkopírovat pozadí → Hlavní","cy":"Copïo Cefndir → Prif",
    "da":"Kopiér baggrund → Hoved","de":"Hintergrund → Haupt kopieren",
    "el":"Αντιγραφή Φόντου → Κύριο","en":"Copy Background → Main",
    "en-AU":"Copy Background → Main","en-CA":"Copy Background → Main",
    "en-GB":"Copy Background → Main","en-IN":"Copy Background → Main",
    "es":"Copiar fondo → Principal","es-419":"Copiar fondo → Principal",
    "es-US":"Copy Background → Main","et":"Kopeeri taust → Peamine","eu":"Kopiatu atzealdia → Nagusia",
    "fa":"کپی پس‌زمینه → اصلی","fi":"Kopioi tausta → pää","fil":"Kopyahin ang Background → Pangunahin",
    "fr":"Copier l'arrière-plan → Principal","fr-CA":"Copier l'arrière-plan → Principal",
    "ga":"Cóipeáil Cúlra → Príomh","gl":"Copiar fondo → Principal",
    "he":"העתק רקע → ראשי","hi":"पृष्ठभूमि कॉपी करें → मुख्य","hr":"Kopiraj pozadinu → Glavno","hu":"Háttér másolása → Fő",
    "hy":"Պատճենել ֆոն → Հիմնական","id":"Salin latar belakang → Utama","is":"Afrita bakgrunn → Aðal","it":"Copia sfondo → Principale",
    "ja":"背景をメインへコピー","ka":"ფონის კოპირება → მთავარი","kk":"Фонды көшіру → Негізгі","ko":"배경 복사 → 메인",
    "lt":"Kopijuoti foną → Pagrindinis","lv":"Kopēt fonu → Galvenais","mk":"Копирај позадина → Главно","mn":"Фонийг хуулах → Гол",
    "ms":"Salin latar belakang → Utama","nb":"Kopier bakgrunn → Hoved","nl":"Achtergrond kopiëren → Hoofd","pl":"Kopiuj tło → Główne",
    "pt-BR":"Copiar fundo → Principal","pt-PT":"Copiar fundo → Principal","ro":"Copiați fundalul → Principal","ru":"Скопировать фон → Основной",
    "sk":"Kopírovať pozadie → Hlavné","sl":"Kopiraj ozadje → Glavno","sq":"Kopjo sfondin → Kryesor","sr":"Копирај позадину → Главно",
    "sr-Latn":"Kopiraj pozadinu → Glavno","sv":"Kopiera bakgrund → Huvud","sw":"Nakili Mandharinyuma → Kuu","ta":"பின்னணியை நகலெடு → பிரதான",
    "te":"నేపథ్యాన్ని కాపీ చేయండి → ప్రధాన","th":"คัดลอกพื้นหลัง → หลัก","tr":"Arka planı kopyala → Ana","uk":"Копіювати фон → Основний",
    "ur":"پس منظر کاپی کریں → مرکزی","uz":"Fonni nusxalash → Asosiy","vi":"Sao chép nền → Chính",
    "zh-HK":"複製背景 → 主要","zh-Hans":"复制背景 → 主","zh-Hant":"複製背景 → 主要",
}

TRANSLATIONS["Clears filter looks and resets background zoom, flip, blur, and transparency"] = {
    "af":"Verwyder filterstyle en herstel agtergrondzoem, -spieëling, -waas en deurskynendheid",
    "ar":"يمسح مظاهر المرشح ويعيد تعيين تكبير الخلفية والتقليب والضبابية والشفافية",
    "be":"Ачышчае стылі фільтраў і скідвае маштаб, адлюстраванне, размытасць і празрыстасць фону",
    "bg":"Изчиства изгледите на филтъра и нулира мащаба, флипа, размиването и прозрачността на фона",
    "bn":"ফিল্টার লুক মুছে দেয় এবং পটভূমির জুম, ফ্লিপ, ব্লার এবং স্বচ্ছতা রিসেট করে",
    "ca":"Esborra els aspectes de filtre i restableix el zoom, gir, desenfocament i transparència del fons",
    "cs":"Vymaže filtry a obnoví zoom, překlop, rozostření a průhlednost pozadí",
    "cy":"Clirio ymddangosiadau hidlen ac ailosod zoom, fflip, niwl a thryloywder y cefndir",
    "da":"Rydder filterudseende og nulstiller baggrundszoom, vend, sløring og gennemsigtighed",
    "de":"Löscht Filteraussehen und setzt Hintergrund-Zoom, -Spiegelung, -Unschärfe und -Transparenz zurück",
    "el":"Καθαρίζει τα φίλτρα και επαναφέρει ζουμ, αναστροφή, θόλωση και διαφάνεια φόντου",
    "en":"Clears filter looks and resets background zoom, flip, blur, and transparency",
    "en-AU":"Clears filter looks and resets background zoom, flip, blur, and transparency",
    "en-CA":"Clears filter looks and resets background zoom, flip, blur, and transparency",
    "en-GB":"Clears filter looks and resets background zoom, flip, blur, and transparency",
    "en-IN":"Clears filter looks and resets background zoom, flip, blur, and transparency",
    "es":"Borra los filtros y restablece el zoom, volteo, desenfoque y transparencia del fondo",
    "es-419":"Borra los filtros y restablece el zoom, volteo, desenfoque y transparencia del fondo",
    "es-US":"Clears filter looks and resets background zoom, flip, blur, and transparency",
    "et":"Kustutab filtri välimuse ja lähtestab tausta suumi, pöörde, hägususe ja läbipaistvuse",
    "eu":"Iragazkien itxurak garbitzen ditu eta atzealdearen zooma, iraulketa, lainoa eta gardentasuna berrezartzen ditu",
    "fa":"ظاهر فیلترها را پاک می‌کند و زوم، چرخش، تاری و شفافیت پس‌زمینه را بازنشانی می‌کند",
    "fi":"Tyhjentää suodatinulkoasut ja palauttaa taustan zoomin, kääntämisen, sumennuksen ja läpinäkyvyyden",
    "fil":"Nililinis ang mga hitsura ng filter at nire-reset ang zoom, flip, blur, at transparency ng background",
    "fr":"Efface les apparences des filtres et réinitialise le zoom, retournement, flou et transparence de l'arrière-plan",
    "fr-CA":"Efface les apparences des filtres et réinitialise le zoom, retournement, flou et transparence de l'arrière-plan",
    "ga":"Glanann cuma na scagairí agus athshocraíonn sé zúmáil, smeach, doiléire agus trédhearcacht an chúlra",
    "gl":"Borra os filtros e restablece o zoom, volteo, desenfoque e transparencia do fondo",
    "he":"מנקה מראה פילטרים ומאפס זום, הפיכה, טשטוש ושקיפות של הרקע",
    "hi":"फ़िल्टर लुक हटाता है और पृष्ठभूमि ज़ूम, फ़्लिप, ब्लर और पारदर्शिता रीसेट करता है",
    "hr":"Briše filtere i ponišava zoom, preokret, zamućenost i prozirnost pozadine",
    "hu":"Törli a szűrőbeállításokat és visszaállítja a háttér nagyítást, tükrözést, elmosást és átlátszóságot",
    "hy":"Մաքրում է ֆիլտրի տեսքը և վերականգնում ֆոնի մասշտաբը, շրջումը, մշուշը և թափանցիկությունը",
    "id":"Menghapus tampilan filter dan mengatur ulang zoom, balik, blur, dan transparansi latar belakang",
    "is":"Hreinsar útlit síu og endurstillir suðum, flökkun, þokustigul og gegnsæi bakgrunns",
    "it":"Cancella gli effetti filtro e reimposta zoom, capovolgimento, sfocatura e trasparenza dello sfondo",
    "ja":"フィルタのルックをクリアし、背景のズーム・反転・ぼかし・透明度をリセットします",
    "ka":"ფილტრის გარეგნობას ასუფთავებს და ფონის ზუმს, გადაბრუნებას, ბუნდოვანებას და გამჭვირვალობას აბრუნებს",
    "kk":"Фильтр көрінісін тазартады және фонның масштабын, аудармасын, бұлдырлығын және мөлдірлігін қалпына келтіреді",
    "ko":"필터 모양을 지우고 배경 확대/축소, 뒤집기, 흐림 및 투명도를 재설정합니다",
    "lt":"Pašalina filtrų išvaizdą ir atkeičia fono priartinimą, apvertimą, suliejimą ir skaidrumą",
    "lv":"Notīra filtru izskatu un atjauno fona tālummaiņu, apgriešanu, izplūšanu un caurspīdīgumu",
    "mk":"Ги брише изгледите на филтрите и ги ресетира зумот, превртувањето, замаглувањето и проѕирноста на позадината",
    "mn":"Шүүлтүүрийн харагдах байдлыг цэвэрлэж, фонын томруулалт, эргэлт, бүдгэрэл болон ил тод байдлыг дахин тохируулна",
    "ms":"Membersihkan penampilan penapis dan menetapkan semula zum, flip, kabur, dan ketelusan latar belakang",
    "nb":"Sletter filterutseende og tilbakestiller bakgrunns-zoom, flip, uskarphet og gjennomsiktighet",
    "nl":"Wist filteruiterlijken en reset achtergrond zoom, omklapping, vervaging en transparantie",
    "pl":"Usuwa wyglądy filtrów i resetuje zoom, odwrócenie, rozmycie i przejrzystość tła",
    "pt-BR":"Limpa as aparências dos filtros e redefine zoom, espelhamento, desfoque e transparência do fundo",
    "pt-PT":"Limpa as aparências dos filtros e repõe zoom, espelhamento, desfoque e transparência do fundo",
    "ro":"Șterge aspectele filtrului și resetează zoom-ul, răsturnarea, estomparea și transparența fundalului",
    "ru":"Убирает стили фильтров и сбрасывает масштаб, отражение, размытие и прозрачность фона",
    "sk":"Vymaže vzhľady filtrov a obnoví zoom, prevrátenie, rozostrenie a priehľadnosť pozadia",
    "sl":"Počisti izglede filtrov in ponastavi povečavo, obrat, zamegljanje in prosojnost ozadja",
    "sq":"Fshin pamjet e filtrave dhe rivendos zoomin, rrotullimin, sfondin e turbullt dhe transparencën",
    "sr":"Брише изглед филтера и ресетује зум, окретање, замућење и провидност позадине",
    "sr-Latn":"Briše izgled filtera i resetuje zum, okretanje, zamućenje i providnost pozadine",
    "sv":"Rensar filterutseenden och återställer bakgrundens zoom, spegling, oskärpa och genomskinlighet",
    "sw":"Inafuta mwonekano wa vichujio na kuweka upya kukuza, kugeuka, ukungu, na uwazi wa mandharinyuma",
    "ta":"வடிகட்டி தோற்றங்களை நீக்கி பின்னணி ஜூம், புரட்டு, மங்கல் மற்றும் வெளிப்படைத்தன்மையை மீட்டமைக்கிறது",
    "te":"ఫిల్టర్ రూపాన్ని తొలగిస్తుంది మరియు నేపథ్య జూమ్, ఫ్లిప్, బ్లర్ మరియు పారదర్శకతను రీసెట్ చేస్తుంది",
    "th":"ล้างลักษณะตัวกรองและรีเซ็ตการซูม พลิก เบลอ และความโปร่งใสของพื้นหลัง",
    "tr":"Filtre görünümlerini temizler ve arka plan yakınlaştırma, çevirme, bulanıklık ve şeffaflığı sıfırlar",
    "uk":"Очищає вигляд фільтрів і скидає масштаб, відображення, розмиття та прозорість фону",
    "ur":"فلٹر کی ظاہری شکل صاف کرتا ہے اور پس منظر کا زوم، فلپ، بلر اور شفافیت ری سیٹ کرتا ہے",
    "uz":"Filtr ko'rinishlarini tozalaydi va fon masshtabi, ag'darish, xiralik va shaffofligini tiklaydi",
    "vi":"Xóa giao diện bộ lọc và đặt lại thu phóng, lật, làm mờ và độ trong suốt của nền",
    "zh-HK":"清除濾鏡外觀並重設背景縮放、翻轉、模糊和透明度",
    "zh-Hans":"清除滤镜外观并重置背景缩放、翻转、模糊和透明度",
    "zh-Hant":"清除濾鏡外觀並重設背景縮放、翻轉、模糊和透明度",
}


def main():
    with open(XCSTRINGS_PATH, encoding="utf-8") as f:
        data = json.load(f)

    strings = data["strings"]
    updated_count = 0

    for key, translations in TRANSLATIONS.items():
        if key not in strings:
            print(f"WARNING: key {repr(key)} not found", file=sys.stderr)
            continue
        entry = strings[key]
        if "localizations" not in entry:
            entry["localizations"] = {}
        locs = entry["localizations"]
        for locale, value in translations.items():
            if locale not in locs:
                locs[locale] = {
                    "stringUnit": {
                        "state": "translated",
                        "value": value
                    }
                }
                updated_count += 1

    print(f"Added {updated_count} translations")

    with open(XCSTRINGS_PATH, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False, separators=(",", " : "))
        f.write("\n")

    print("Done writing xcstrings")

if __name__ == "__main__":
    main()
