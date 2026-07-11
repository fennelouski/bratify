#!/usr/bin/env python3
"""Add missing major-locale translations for 42 keys that only had minor-locale coverage."""
import json, sys

XCSTRINGS_PATH = "/Users/nathanfennel/Documents/GitHub/Bratify/brat/Localizable.xcstrings"

LOCALES = [
    "ar","cy","de","es","fr","fr-CA","ga","he","hi","it","ja","ko","nl","pl",
    "pt-BR","pt-PT","ru","sr-Latn","sv","tr","uk","vi","zh-Hans",
]

TRANSLATIONS = {
    "acid": {
        "ar":"حمض","cy":"asid","de":"Säure","es":"ácido","fr":"acide","fr-CA":"acide",
        "ga":"aigéad","he":"חומצה","hi":"अम्ल","it":"acido","ja":"酸","ko":"산",
        "nl":"zuur","pl":"kwas","pt-BR":"ácido","pt-PT":"ácido","ru":"кислота",
        "sr-Latn":"kiselina","sv":"syra","tr":"asit","uk":"кислота","vi":"axit","zh-Hans":"酸",
    },
    "BG": {
        "ar":"الخلفية","cy":"Cefndir","de":"Hintergrund","es":"Fondo","fr":"Fond","fr-CA":"Fond",
        "ga":"Cúlra","he":"רקע","hi":"पृष्ठभूमि","it":"Sfondo","ja":"背景","ko":"배경",
        "nl":"Achtergrond","pl":"Tło","pt-BR":"Fundo","pt-PT":"Fundo","ru":"Фон",
        "sr-Latn":"Pozadina","sv":"Bakgrund","tr":"Arka Plan","uk":"Фон","vi":"Nền","zh-Hans":"背景",
    },
    "bleach": {
        "ar":"تبييض","cy":"cannu","de":"bleichen","es":"lejía","fr":"décoloration","fr-CA":"décoloration",
        "ga":"tuarghealadh","he":"הלבנה","hi":"ब्लीच","it":"candeggina","ja":"漂白","ko":"표백",
        "nl":"bleek","pl":"wybielacz","pt-BR":"alvejante","pt-PT":"lixívia","ru":"отбеливание",
        "sr-Latn":"izbeljivanje","sv":"blekning","tr":"ağartıcı","uk":"відбілювач","vi":"tẩy trắng","zh-Hans":"漂白",
    },
    "Both": {
        "ar":"كلاهما","cy":"Y ddau","de":"Beide","es":"Ambos","fr":"Les deux","fr-CA":"Les deux",
        "ga":"Araon","he":"שניהם","hi":"दोनों","it":"Entrambi","ja":"両方","ko":"둘 다",
        "nl":"Beide","pl":"Oba","pt-BR":"Ambos","pt-PT":"Ambos","ru":"Оба",
        "sr-Latn":"Oboje","sv":"Båda","tr":"İkisi","uk":"Обидва","vi":"Cả hai","zh-Hans":"两者",
    },
    "Candlelight": {
        "ar":"ضوء الشموع","cy":"Golau Cannwyll","de":"Kerzenlicht","es":"Luz de vela","fr":"Lueur de bougie",
        "fr-CA":"Lueur de bougie","ga":"Solas Coinnle","he":"אור נרות","hi":"मोमबत्ती की रोशनी",
        "it":"Lume di candela","ja":"キャンドルライト","ko":"촛불","nl":"Kaarslicht","pl":"Blask świec",
        "pt-BR":"Luz de vela","pt-PT":"Luz de vela","ru":"Свет свечи","sr-Latn":"Svetlost sveće",
        "sv":"Levande ljus","tr":"Mum Işığı","uk":"Світло свічки","vi":"Ánh nến","zh-Hans":"烛光",
    },
    "Color Mode": {
        "ar":"وضع اللون","cy":"Modd Lliw","de":"Farbmodus","es":"Modo de color","fr":"Mode couleur",
        "fr-CA":"Mode couleur","ga":"Mód Datha","he":"מצב צבע","hi":"रंग मोड","it":"Modalità colore",
        "ja":"カラーモード","ko":"색상 모드","nl":"Kleurmodus","pl":"Tryb koloru","pt-BR":"Modo de cor",
        "pt-PT":"Modo de cor","ru":"Цветовой режим","sr-Latn":"Režim boje","sv":"Färgläge",
        "tr":"Renk Modu","uk":"Режим кольору","vi":"Chế độ màu","zh-Hans":"颜色模式",
    },
    "Cool Ice": {
        "ar":"جليد بارد","cy":"Iâ Oer","de":"Kühles Eis","es":"Hielo frío","fr":"Glace froide",
        "fr-CA":"Glace froide","ga":"Oighear Fuar","he":"קרח קריר","hi":"ठंडी बर्फ","it":"Ghiaccio freddo",
        "ja":"クールアイス","ko":"쿨 아이스","nl":"Koel ijs","pl":"Chłodny lód","pt-BR":"Gelo frio",
        "pt-PT":"Gelo frio","ru":"Холодный лёд","sr-Latn":"Hladan led","sv":"Kall is",
        "tr":"Serin Buz","uk":"Холодний лід","vi":"Băng lạnh","zh-Hans":"冷冽冰蓝",
    },
    "cyber": {
        "ar":"سايبر","cy":"seiber","de":"cyber","es":"ciber","fr":"cyber","fr-CA":"cyber",
        "ga":"cibear","he":"סייבר","hi":"साइबर","it":"cyber","ja":"サイバー","ko":"사이버",
        "nl":"cyber","pl":"cyber","pt-BR":"cyber","pt-PT":"cyber","ru":"кибер",
        "sr-Latn":"sajber","sv":"cyber","tr":"siber","uk":"кібер","vi":"cyber","zh-Hans":"赛博",
    },
    "deep noir": {
        "ar":"نوير عميق","cy":"nwar dwfn","de":"tiefes Noir","es":"noir profundo","fr":"noir profond",
        "fr-CA":"noir profond","ga":"nár domhain","he":"נואר עמוק","hi":"गहरा नोयर","it":"noir profondo",
        "ja":"ディープノワール","ko":"딥 누아르","nl":"diep noir","pl":"głębokie noir","pt-BR":"noir profundo",
        "pt-PT":"noir profundo","ru":"глубокий нуар","sr-Latn":"duboki nuar","sv":"djup noir",
        "tr":"derin noir","uk":"глибокий нуар","vi":"noir sâu","zh-Hans":"深邃黑色电影",
    },
    "Editorial": {
        "ar":"تحريري","cy":"Golygyddol","de":"Editorial","es":"Editorial","fr":"Éditorial",
        "fr-CA":"Éditorial","ga":"Eagarthóireachta","he":"עריכתי","hi":"संपादकीय","it":"Editoriale",
        "ja":"エディトリアル","ko":"에디토리얼","nl":"Redactioneel","pl":"Redakcyjny","pt-BR":"Editorial",
        "pt-PT":"Editorial","ru":"Редакционный","sr-Latn":"Uredništvo","sv":"Redaktionell",
        "tr":"Editoryal","uk":"Редакційний","vi":"Biên tập","zh-Hans":"时尚编辑风",
    },
    "ethereal": {
        "ar":"أثيري","cy":"ethera","de":"ätherisch","es":"etéreo","fr":"éthéré","fr-CA":"éthéré",
        "ga":"eithéarach","he":"אתרי","hi":"आकाशीय","it":"etereo","ja":"エーテリアル","ko":"에테리얼",
        "nl":"etherisch","pl":"eteryczny","pt-BR":"etéreo","pt-PT":"etéreo","ru":"эфирный",
        "sr-Latn":"eteričan","sv":"eterisk","tr":"eterik","uk":"ефірний","vi":"huyền ảo","zh-Hans":"空灵",
    },
    "golden": {
        "ar":"ذهبي","cy":"euraidd","de":"golden","es":"dorado","fr":"doré","fr-CA":"doré",
        "ga":"órga","he":"זהוב","hi":"सुनहरा","it":"dorato","ja":"ゴールデン","ko":"골든",
        "nl":"goud","pl":"złoty","pt-BR":"dourado","pt-PT":"dourado","ru":"золотой",
        "sr-Latn":"zlatan","sv":"gyllene","tr":"altın","uk":"золотий","vi":"vàng óng","zh-Hans":"金色",
    },
    "Import from web": {
        "ar":"استيراد من الويب","cy":"Mewnforio o'r we","de":"Aus dem Web importieren","es":"Importar desde la web",
        "fr":"Importer depuis le web","fr-CA":"Importer depuis le web","ga":"Iompórtáil ón ngréasán",
        "he":"ייבוא מהאינטרנט","hi":"वेब से आयात करें","it":"Importa dal web","ja":"ウェブからインポート",
        "ko":"웹에서 가져오기","nl":"Importeren vanaf internet","pl":"Importuj z internetu",
        "pt-BR":"Importar da web","pt-PT":"Importar da web","ru":"Импортировать из интернета",
        "sr-Latn":"Uvezi sa veba","sv":"Importera från webben","tr":"Web'den içe aktar",
        "uk":"Імпортувати з інтернету","vi":"Nhập từ web","zh-Hans":"从网页导入",
    },
    "infrared": {
        "ar":"الأشعة تحت الحمراء","cy":"isgoch","de":"infrarot","es":"infrarrojo","fr":"infrarouge",
        "fr-CA":"infrarouge","ga":"infridhearg","he":"אינפרה אדום","hi":"इन्फ्रारेड","it":"infrarosso",
        "ja":"赤外線","ko":"적외선","nl":"infrarood","pl":"podczerwień","pt-BR":"infravermelho",
        "pt-PT":"infravermelho","ru":"инфракрасный","sr-Latn":"infracrveno","sv":"infraröd",
        "tr":"kızılötesi","uk":"інфрачервоний","vi":"hồng ngoại","zh-Hans":"红外",
    },
    "lavender": {
        "ar":"خزامى","cy":"lafant","de":"Lavendel","es":"lavanda","fr":"lavande","fr-CA":"lavande",
        "ga":"labhandar","he":"לבנדר","hi":"लैवेंडर","it":"lavanda","ja":"ラベンダー","ko":"라벤더",
        "nl":"lavendel","pl":"lawenda","pt-BR":"lavanda","pt-PT":"lavanda","ru":"лаванда",
        "sr-Latn":"lavanda","sv":"lavendel","tr":"lavanta","uk":"лаванда","vi":"oải hương","zh-Hans":"薰衣草",
    },
    "matte": {
        "ar":"مطفي","cy":"mat","de":"matt","es":"mate","fr":"mat","fr-CA":"mat",
        "ga":"mat","he":"מט","hi":"मैट","it":"opaco","ja":"マット","ko":"매트",
        "nl":"mat","pl":"matowy","pt-BR":"fosco","pt-PT":"mate","ru":"матовый",
        "sr-Latn":"mat","sv":"matt","tr":"mat","uk":"матовий","vi":"mờ","zh-Hans":"哑光",
    },
    "Midnight Blue": {
        "ar":"أزرق منتصف الليل","cy":"Glas Hanner Nos","de":"Mitternachtsblau","es":"Azul medianoche",
        "fr":"Bleu minuit","fr-CA":"Bleu minuit","ga":"Gorm Meán Oíche","he":"כחול חצות",
        "hi":"मिडनाइट ब्लू","it":"Blu notte","ja":"ミッドナイトブルー","ko":"미드나잇 블루",
        "nl":"Middernachtblauw","pl":"Nocny błękit","pt-BR":"Azul-meia-noite","pt-PT":"Azul meia-noite",
        "ru":"Полуночно-синий","sr-Latn":"Ponoćno plava","sv":"Midnattsblå","tr":"Gece Yarısı Mavisi",
        "uk":"Опівнічно-синій","vi":"Xanh nửa đêm","zh-Hans":"午夜蓝",
    },
    "Mist": {
        "ar":"ضباب","cy":"Niwl","de":"Nebel","es":"Neblina","fr":"Brume","fr-CA":"Brume",
        "ga":"Ceo","he":"ערפל","hi":"कोहरा","it":"Nebbia","ja":"ミスト","ko":"미스트",
        "nl":"Nevel","pl":"Mgła","pt-BR":"Névoa","pt-PT":"Névoa","ru":"Дымка",
        "sr-Latn":"Magla","sv":"Dis","tr":"Sis","uk":"Серпанок","vi":"Sương mù","zh-Hans":"薄雾",
    },
    "Overexposed": {
        "ar":"مفرط التعريض","cy":"Gorddatgelu","de":"Überbelichtet","es":"Sobreexpuesto","fr":"Surexposé",
        "fr-CA":"Surexposé","ga":"Ró-nochtaithe","he":"חשיפת יתר","hi":"ओवरएक्सपोज़्ड","it":"Sovraesposto",
        "ja":"オーバー露出","ko":"오버노출","nl":"Overbelicht","pl":"Prześwietlone","pt-BR":"Superexposto",
        "pt-PT":"Sobreexposto","ru":"Пересвеченный","sr-Latn":"Preeksponirano","sv":"Överexponerad",
        "tr":"Aşırı Pozlanmış","uk":"Пересвічений","vi":"Cháy sáng","zh-Hans":"过曝",
    },
    "Pastel": {
        "ar":"باستيل","cy":"Pastel","de":"Pastell","es":"Pastel","fr":"Pastel","fr-CA":"Pastel",
        "ga":"Pastal","he":"פסטל","hi":"पेस्टल","it":"Pastello","ja":"パステル","ko":"파스텔",
        "nl":"Pastel","pl":"Pastelowy","pt-BR":"Pastel","pt-PT":"Pastel","ru":"Пастель",
        "sr-Latn":"Pastel","sv":"Pastell","tr":"Pastel","uk":"Пастель","vi":"Pastel","zh-Hans":"粉彩",
    },
    "Polaroid": {
        "ar":"بولارويد","cy":"Polaroid","de":"Polaroid","es":"Polaroid","fr":"Polaroid","fr-CA":"Polaroid",
        "ga":"Polaroid","he":"פולארויד","hi":"पोलेरॉइड","it":"Polaroid","ja":"ポラロイド","ko":"폴라로이드",
        "nl":"Polaroid","pl":"Polaroid","pt-BR":"Polaroid","pt-PT":"Polaroid","ru":"Полароид",
        "sr-Latn":"Polaroid","sv":"Polaroid","tr":"Polaroid","uk":"Полароїд","vi":"Polaroid","zh-Hans":"宝丽来",
    },
    "Primary Sliders": {
        "ar":"أشرطة التمرير الأساسية","cy":"Llithryddion Sylfaenol","de":"Primäre Regler",
        "es":"Controles principales","fr":"Curseurs principaux","fr-CA":"Curseurs principaux",
        "ga":"Sleamhnáin Phríomha","he":"מחוונים ראשיים","hi":"मुख्य स्लाइडर","it":"Cursori principali",
        "ja":"メインスライダー","ko":"기본 슬라이더","nl":"Primaire schuifregelaars","pl":"Suwaki podstawowe",
        "pt-BR":"Controles deslizantes principais","pt-PT":"Controlos deslizantes principais",
        "ru":"Основные ползунки","sr-Latn":"Osnovni klizači","sv":"Primära reglage",
        "tr":"Birincil Kaydırıcılar","uk":"Основні повзунки","vi":"Thanh trượt chính","zh-Hans":"主要滑块",
    },
    "process": {
        "ar":"معالجة","cy":"prosesu","de":"Prozess","es":"proceso","fr":"procédé","fr-CA":"procédé",
        "ga":"próiseas","he":"תהליך","hi":"प्रक्रिया","it":"processo","ja":"プロセス","ko":"프로세스",
        "nl":"proces","pl":"proces","pt-BR":"processo","pt-PT":"processo","ru":"процесс",
        "sr-Latn":"proces","sv":"process","tr":"işlem","uk":"процес","vi":"xử lý","zh-Hans":"冲印",
    },
    "Punch Mono": {
        "ar":"بانش مونو","cy":"Punch Mono","de":"Punch Mono","es":"Punch Mono","fr":"Punch Mono",
        "fr-CA":"Punch Mono","ga":"Punch Mono","he":"פאנץ' מונו","hi":"पंच मोनो","it":"Punch Mono",
        "ja":"パンチモノ","ko":"펀치 모노","nl":"Punch Mono","pl":"Punch Mono","pt-BR":"Punch Mono",
        "pt-PT":"Punch Mono","ru":"Панч Моно","sr-Latn":"Panč Mono","sv":"Punch Mono","tr":"Punch Mono",
        "uk":"Панч Моно","vi":"Punch Mono","zh-Hans":"拳打单色",
    },
    "radio": {
        "ar":"راديو","cy":"radio","de":"Radio","es":"radio","fr":"radio","fr-CA":"radio",
        "ga":"raidió","he":"רדיו","hi":"रेडियो","it":"radio","ja":"ラジオ","ko":"라디오",
        "nl":"radio","pl":"radio","pt-BR":"rádio","pt-PT":"rádio","ru":"радио",
        "sr-Latn":"radio","sv":"radio","tr":"radyo","uk":"радіо","vi":"radio","zh-Hans":"无线电",
    },
    "Redo": {
        "ar":"إعادة","cy":"Ailwneud","de":"Wiederholen","es":"Rehacer","fr":"Rétablir","fr-CA":"Rétablir",
        "ga":"Athdhéan","he":"חזור על הפעולה","hi":"फिर से करें","it":"Ripeti","ja":"やり直し","ko":"다시 실행",
        "nl":"Opnieuw","pl":"Ponów","pt-BR":"Refazer","pt-PT":"Refazer","ru":"Повторить",
        "sr-Latn":"Ponovi","sv":"Gör om","tr":"Yinele","uk":"Повторити","vi":"Làm lại","zh-Hans":"重做",
    },
    "Remove": {
        "ar":"إزالة","cy":"Dileu","de":"Entfernen","es":"Eliminar","fr":"Supprimer","fr-CA":"Supprimer",
        "ga":"Bain","he":"הסר","hi":"हटाएं","it":"Rimuovi","ja":"削除","ko":"제거",
        "nl":"Verwijderen","pl":"Usuń","pt-BR":"Remover","pt-PT":"Remover","ru":"Удалить",
        "sr-Latn":"Ukloni","sv":"Ta bort","tr":"Kaldır","uk":"Видалити","vi":"Xoá","zh-Hans":"移除",
    },
    "remove undo history": {
        "ar":"إزالة سجل التراجع","cy":"dileu hanes dadwneud","de":"Rückgängig-Verlauf entfernen",
        "es":"eliminar historial de deshacer","fr":"supprimer l'historique d'annulation",
        "fr-CA":"supprimer l'historique d'annulation","ga":"bain stair chealaithe",
        "he":"הסרת היסטוריית ביטול","hi":"पूर्ववत इतिहास हटाएं","it":"rimuovi cronologia annullamenti",
        "ja":"元に戻す履歴を削除","ko":"실행 취소 기록 삭제","nl":"ongedaan-maken-geschiedenis verwijderen",
        "pl":"usuń historię cofania","pt-BR":"remover histórico de desfazer","pt-PT":"remover histórico de anular",
        "ru":"удалить историю отмен","sr-Latn":"ukloni istoriju opozivanja","sv":"ta bort ångrahistorik",
        "tr":"geri alma geçmişini kaldır","uk":"видалити історію скасувань","vi":"xoá lịch sử hoàn tác",
        "zh-Hans":"移除撤销历史记录",
    },
    "Remove Undo History": {
        "ar":"إزالة سجل التراجع","cy":"Dileu hanes dadwneud","de":"Rückgängig-Verlauf entfernen",
        "es":"Eliminar historial de deshacer","fr":"Supprimer l'historique d'annulation",
        "fr-CA":"Supprimer l'historique d'annulation","ga":"Bain stair chealaithe",
        "he":"הסרת היסטוריית ביטול","hi":"पूर्ववत इतिहास हटाएं","it":"Rimuovi cronologia annullamenti",
        "ja":"元に戻す履歴を削除","ko":"실행 취소 기록 삭제","nl":"Ongedaan-maken-geschiedenis verwijderen",
        "pl":"Usuń historię cofania","pt-BR":"Remover histórico de desfazer","pt-PT":"Remover histórico de anular",
        "ru":"Удалить историю отмен","sr-Latn":"Ukloni istoriju opozivanja","sv":"Ta bort ångrahistorik",
        "tr":"Geri alma geçmişini kaldır","uk":"Видалити історію скасувань","vi":"Xoá lịch sử hoàn tác",
        "zh-Hans":"移除撤销历史记录",
    },
    "rose emerald": {
        "ar":"وردي زمردي","cy":"rhosyn emrallt","de":"Rosen-Smaragd","es":"rosa esmeralda","fr":"rose émeraude",
        "fr-CA":"rose émeraude","ga":"rós smaragaid","he":"ורוד אזמרגד","hi":"गुलाबी पन्ना","it":"rosa smeraldo",
        "ja":"ローズエメラルド","ko":"로즈 에메랄드","nl":"roze smaragd","pl":"różowy szmaragd","pt-BR":"rosa esmeralda",
        "pt-PT":"rosa esmeralda","ru":"розово-изумрудный","sr-Latn":"ružičasto-smaragdna","sv":"rosensmaragd",
        "tr":"gül zümrüt","uk":"рожево-смарагдовий","vi":"hồng ngọc lục bảo","zh-Hans":"玫瑰祖母绿",
    },
    "Silk Punch": {
        "ar":"سيلك بانش","cy":"Silk Punch","de":"Silk Punch","es":"Silk Punch","fr":"Silk Punch",
        "fr-CA":"Silk Punch","ga":"Silk Punch","he":"סילק פאנץ'","hi":"सिल्क पंच","it":"Silk Punch",
        "ja":"シルクパンチ","ko":"실크 펀치","nl":"Silk Punch","pl":"Silk Punch","pt-BR":"Silk Punch",
        "pt-PT":"Silk Punch","ru":"Силк Панч","sr-Latn":"Silk Panč","sv":"Silk Punch","tr":"Silk Punch",
        "uk":"Силк Панч","vi":"Silk Punch","zh-Hans":"丝绸拳打",
    },
    "strength": {
        "ar":"القوة","cy":"cryfder","de":"Stärke","es":"intensidad","fr":"intensité","fr-CA":"intensité",
        "ga":"neart","he":"עוצמה","hi":"तीव्रता","it":"intensità","ja":"強度","ko":"강도",
        "nl":"sterkte","pl":"siła","pt-BR":"intensidade","pt-PT":"intensidade","ru":"сила",
        "sr-Latn":"jačina","sv":"styrka","tr":"güç","uk":"сила","vi":"cường độ","zh-Hans":"强度",
    },
    "Sunset": {
        "ar":"غروب الشمس","cy":"Machlud","de":"Sonnenuntergang","es":"Atardecer","fr":"Coucher de soleil",
        "fr-CA":"Coucher de soleil","ga":"Luí na gréine","he":"שקיעה","hi":"सूर्यास्त","it":"Tramonto",
        "ja":"サンセット","ko":"선셋","nl":"Zonsondergang","pl":"Zachód słońca","pt-BR":"Pôr do sol",
        "pt-PT":"Pôr do sol","ru":"Закат","sr-Latn":"Zalazak sunca","sv":"Solnedgång","tr":"Gün Batımı",
        "uk":"Захід сонця","vi":"Hoàng hôn","zh-Hans":"日落",
    },
    "Teal Dusk": {
        "ar":"فيروزي الغسق","cy":"Cyfnos Gwyrddlas","de":"Türkisdämmerung","es":"Crepúsculo turquesa",
        "fr":"Crépuscule turquoise","fr-CA":"Crépuscule turquoise","ga":"Clapsholas Teal",
        "he":"דמדומי טורקיז","hi":"टील सांझ","it":"Crepuscolo verde acqua","ja":"ティールダスク",
        "ko":"틸 더스크","nl":"Turquoise schemering","pl":"Turkusowy zmierzch","pt-BR":"Crepúsculo verde-azulado",
        "pt-PT":"Crepúsculo turquesa","ru":"Бирюзовые сумерки","sr-Latn":"Tirkizni sumrak",
        "sv":"Turkos skymning","tr":"Deniz Mavisi Alacakaranlık","uk":"Бірюзові сутінки",
        "vi":"Hoàng hôn ngọc lam","zh-Hans":"青蓝暮色",
    },
    "Text": {
        "ar":"النص","cy":"Testun","de":"Text","es":"Texto","fr":"Texte","fr-CA":"Texte",
        "ga":"Téacs","he":"טקסט","hi":"टेक्स्ट","it":"Testo","ja":"テキスト","ko":"텍스트",
        "nl":"Tekst","pl":"Tekst","pt-BR":"Texto","pt-PT":"Texto","ru":"Текст",
        "sr-Latn":"Tekst","sv":"Text","tr":"Metin","uk":"Текст","vi":"Văn bản","zh-Hans":"文字",
    },
    "This will permanently delete undo history for all designs. Your designs are not affected.": {
        "ar":"سيؤدي هذا إلى حذف سجل التراجع لجميع التصاميم نهائيًا. لن تتأثر تصاميمك.",
        "cy":"Bydd hyn yn dileu hanes dadwneud pob dyluniad yn barhaol. Ni fydd eich dyluniadau'n cael eu heffeithio.",
        "de":"Dadurch wird der Rückgängig-Verlauf für alle Designs dauerhaft gelöscht. Deine Designs sind davon nicht betroffen.",
        "es":"Esto eliminará permanentemente el historial de deshacer de todos los diseños. Tus diseños no se verán afectados.",
        "fr":"Cela supprimera définitivement l'historique d'annulation de tous les designs. Vos designs ne seront pas affectés.",
        "fr-CA":"Cela supprimera définitivement l'historique d'annulation de tous les designs. Vos designs ne seront pas affectés.",
        "ga":"Scriosfaidh sé seo stair chealaithe do gach dearadh go buan. Ní chuirfear isteach ar do dhearaí.",
        "he":"פעולה זו תמחק לצמיתות את היסטוריית הביטול עבור כל העיצובים. העיצובים שלך לא יושפעו.",
        "hi":"यह सभी डिज़ाइनों के लिए पूर्ववत इतिहास को स्थायी रूप से हटा देगा। आपके डिज़ाइन प्रभावित नहीं होंगे।",
        "it":"Questa azione eliminerà definitivamente la cronologia degli annullamenti per tutti i design. I tuoi design non saranno interessati.",
        "ja":"これにより、すべてのデザインの元に戻す履歴が完全に削除されます。デザイン自体には影響ありません。",
        "ko":"이 작업은 모든 디자인의 실행 취소 기록을 영구적으로 삭제합니다. 디자인 자체에는 영향을 주지 않습니다.",
        "nl":"Dit verwijdert permanent de ongedaan-maken-geschiedenis voor alle ontwerpen. Je ontwerpen worden niet beïnvloed.",
        "pl":"Spowoduje to trwałe usunięcie historii cofania dla wszystkich projektów. Twoje projekty nie zostaną naruszone.",
        "pt-BR":"Isso excluirá permanentemente o histórico de desfazer de todos os designs. Seus designs não serão afetados.",
        "pt-PT":"Isto irá eliminar permanentemente o histórico de anular para todos os designs. Os seus designs não serão afetados.",
        "ru":"Это навсегда удалит историю отмен для всех дизайнов. Ваши дизайны не пострадают.",
        "sr-Latn":"Ovo će trajno izbrisati istoriju opozivanja za sve dizajne. Vaši dizajni neće biti pogođeni.",
        "sv":"Detta tar permanent bort ångrahistoriken för alla designer. Dina designer påverkas inte.",
        "tr":"Bu, tüm tasarımlar için geri alma geçmişini kalıcı olarak siler. Tasarımlarınız etkilenmez.",
        "uk":"Це остаточно видалить історію скасувань для всіх дизайнів. Ваші дизайни не постраждають.",
        "vi":"Thao tác này sẽ xoá vĩnh viễn lịch sử hoàn tác của tất cả thiết kế. Các thiết kế của bạn không bị ảnh hưởng.",
        "zh-Hans":"此操作将永久删除所有设计的撤销历史记录。您的设计本身不会受到影响。",
    },
    "Toggle Panels": {
        "ar":"تبديل اللوحات","cy":"Toglo Paneli","de":"Panels umschalten","es":"Alternar paneles",
        "fr":"Afficher/masquer les panneaux","fr-CA":"Afficher/masquer les panneaux","ga":"Scoránaigh Painéil",
        "he":"הצג/הסתר לוחות","hi":"पैनल टॉगल करें","it":"Alterna pannelli","ja":"パネルの表示切替",
        "ko":"패널 전환","nl":"Panelen in-/uitschakelen","pl":"Przełącz panele","pt-BR":"Alternar painéis",
        "pt-PT":"Alternar painéis","ru":"Показать/скрыть панели","sr-Latn":"Uključi/isključi panele",
        "sv":"Växla paneler","tr":"Panelleri Aç/Kapat","uk":"Перемкнути панелі","vi":"Bật/tắt bảng điều khiển",
        "zh-Hans":"切换面板",
    },
    "Tonal Lift": {
        "ar":"رفع لوني","cy":"Codi Tonyddol","de":"Tonal-Aufhellung","es":"Elevación tonal","fr":"Rehaussement tonal",
        "fr-CA":"Rehaussement tonal","ga":"Ardú Tonach","he":"הרמה טונאלית","hi":"टोनल लिफ्ट","it":"Sollevamento tonale",
        "ja":"トーナルリフト","ko":"톤 리프트","nl":"Tonale lift","pl":"Podniesienie tonalne","pt-BR":"Elevação tonal",
        "pt-PT":"Elevação tonal","ru":"Тональный подъём","sr-Latn":"Tonsko podizanje","sv":"Tonal lyftning",
        "tr":"Tonal Kaldırma","uk":"Тональний підйом","vi":"Nâng tông màu","zh-Hans":"色调提升",
    },
    "transfer": {
        "ar":"نقل","cy":"trosglwyddo","de":"Transfer","es":"transferencia","fr":"transfert","fr-CA":"transfert",
        "ga":"aistriú","he":"העברה","hi":"स्थानांतरण","it":"trasferimento","ja":"トランスファー","ko":"트랜스퍼",
        "nl":"overdracht","pl":"transfer","pt-BR":"transferência","pt-PT":"transferência","ru":"перенос",
        "sr-Latn":"transfer","sv":"överföring","tr":"transfer","uk":"перенесення","vi":"chuyển giao","zh-Hans":"转印",
    },
    "Undo": {
        "ar":"تراجع","cy":"Dadwneud","de":"Rückgängig","es":"Deshacer","fr":"Annuler","fr-CA":"Annuler",
        "ga":"Cealaigh","he":"בטל","hi":"पूर्ववत करें","it":"Annulla","ja":"元に戻す","ko":"실행 취소",
        "nl":"Ongedaan maken","pl":"Cofnij","pt-BR":"Desfazer","pt-PT":"Anular","ru":"Отменить",
        "sr-Latn":"Opozovi","sv":"Ångra","tr":"Geri Al","uk":"Скасувати","vi":"Hoàn tác","zh-Hans":"撤销",
    },
    "undo steps": {
        "ar":"خطوات التراجع","cy":"camau dadwneud","de":"Rückgängig-Schritte","es":"pasos de deshacer",
        "fr":"étapes d'annulation","fr-CA":"étapes d'annulation","ga":"céimeanna cealaithe","he":"שלבי ביטול",
        "hi":"पूर्ववत चरण","it":"passaggi di annullamento","ja":"元に戻す回数","ko":"실행 취소 단계",
        "nl":"stappen ongedaan maken","pl":"kroki cofania","pt-BR":"etapas de desfazer","pt-PT":"passos de anular",
        "ru":"шаги отмены","sr-Latn":"koraci opozivanja","sv":"ångrasteg","tr":"geri alma adımları",
        "uk":"кроки скасування","vi":"bước hoàn tác","zh-Hans":"撤销步骤",
    },
    "VHS": {
        "ar":"VHS","cy":"VHS","de":"VHS","es":"VHS","fr":"VHS","fr-CA":"VHS",
        "ga":"VHS","he":"VHS","hi":"वीएचएस","it":"VHS","ja":"VHS","ko":"VHS",
        "nl":"VHS","pl":"VHS","pt-BR":"VHS","pt-PT":"VHS","ru":"VHS",
        "sr-Latn":"VHS","sv":"VHS","tr":"VHS","uk":"VHS","vi":"VHS","zh-Hans":"VHS",
    },
}

def main():
    with open(XCSTRINGS_PATH, encoding="utf-8") as f:
        data = json.load(f)

    strings = data["strings"]
    updated_count = 0

    for key, translations in TRANSLATIONS.items():
        if key not in strings:
            print(f"WARNING: key {repr(key)} not found in xcstrings", file=sys.stderr)
            continue
        entry = strings[key]
        locs = entry.setdefault("localizations", {})
        for locale in LOCALES:
            if locale not in translations:
                print(f"WARNING: {repr(key)} missing locale {locale}", file=sys.stderr)
                continue
            if locale in locs:
                continue
            locs[locale] = {"stringUnit": {"state": "translated", "value": translations[locale]}}
            updated_count += 1

    print(f"Added {updated_count} translations")

    with open(XCSTRINGS_PATH, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
        f.write("\n")

    print("Done writing xcstrings")

if __name__ == "__main__":
    main()
