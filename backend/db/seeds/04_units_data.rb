# Standard Units Database with Translations
# Categories: volume, weight, count, length, other
# Languages: en (canonical), ja, ko, zh_tw, zh_cn, es, fr

UNITS_DATA = {
  # === VOLUME ===
  "ml" => {
    category: :unit_volume,
    translations: { en: "ml", ja: "ml", ko: "ml", zh_tw: "ml", zh_cn: "ml", es: "ml", fr: "ml" }
  },
  "l" => {
    category: :unit_volume,
    translations: { en: "L", ja: "L", ko: "L", zh_tw: "L", zh_cn: "L", es: "L", fr: "L" }
  },
  "tsp" => {
    category: :unit_volume,
    translations: { en: "tsp", ja: "小さじ", ko: "작은술", zh_tw: "小匙", zh_cn: "小勺", es: "cdta", fr: "c. à c." }
  },
  "tbsp" => {
    category: :unit_volume,
    translations: { en: "tbsp", ja: "大さじ", ko: "큰술", zh_tw: "大匙", zh_cn: "大勺", es: "cda", fr: "c. à s." }
  },
  "cup" => {
    category: :unit_volume,
    translations: { en: "cup", ja: "カップ", ko: "컵", zh_tw: "杯", zh_cn: "杯", es: "taza", fr: "tasse" }
  },
  "fl oz" => {
    category: :unit_volume,
    translations: { en: "fl oz", ja: "液量オンス", ko: "액량 온스", zh_tw: "液盎司", zh_cn: "液盎司", es: "oz líq", fr: "oz liq" }
  },
  "pint" => {
    category: :unit_volume,
    translations: { en: "pint", ja: "パイント", ko: "파인트", zh_tw: "品脫", zh_cn: "品脱", es: "pinta", fr: "pinte" }
  },
  "quart" => {
    category: :unit_volume,
    translations: { en: "quart", ja: "クォート", ko: "쿼트", zh_tw: "夸脫", zh_cn: "夸脱", es: "cuarto", fr: "quart" }
  },
  "gallon" => {
    category: :unit_volume,
    translations: { en: "gallon", ja: "ガロン", ko: "갤런", zh_tw: "加侖", zh_cn: "加仑", es: "galón", fr: "gallon" }
  },
  "dash" => {
    category: :unit_volume,
    translations: { en: "dash", ja: "少々", ko: "약간", zh_tw: "少許", zh_cn: "少许", es: "pizca", fr: "trait" }
  },
  "pinch" => {
    category: :unit_volume,
    translations: { en: "pinch", ja: "ひとつまみ", ko: "꼬집", zh_tw: "一撮", zh_cn: "一撮", es: "pizca", fr: "pincée" }
  },
  "drop" => {
    category: :unit_volume,
    translations: { en: "drop", ja: "滴", ko: "방울", zh_tw: "滴", zh_cn: "滴", es: "gota", fr: "goutte" }
  },

  # === WEIGHT ===
  "g" => {
    category: :unit_weight,
    translations: { en: "g", ja: "g", ko: "g", zh_tw: "g", zh_cn: "g", es: "g", fr: "g" }
  },
  "kg" => {
    category: :unit_weight,
    translations: { en: "kg", ja: "kg", ko: "kg", zh_tw: "kg", zh_cn: "kg", es: "kg", fr: "kg" }
  },
  "mg" => {
    category: :unit_weight,
    translations: { en: "mg", ja: "mg", ko: "mg", zh_tw: "mg", zh_cn: "mg", es: "mg", fr: "mg" }
  },
  "oz" => {
    category: :unit_weight,
    translations: { en: "oz", ja: "オンス", ko: "온스", zh_tw: "盎司", zh_cn: "盎司", es: "oz", fr: "oz" }
  },
  "lb" => {
    category: :unit_weight,
    translations: { en: "lb", ja: "ポンド", ko: "파운드", zh_tw: "磅", zh_cn: "磅", es: "lb", fr: "lb" }
  },

  # === COUNT ===
  "piece" => {
    category: :unit_quantity,
    translations: { en: "piece", ja: "個", ko: "개", zh_tw: "個", zh_cn: "个", es: "pieza", fr: "pièce" }
  },
  "whole" => {
    category: :unit_quantity,
    translations: { en: "whole", ja: "個", ko: "개", zh_tw: "個", zh_cn: "个", es: "entero", fr: "entier" }
  },
  "clove" => {
    category: :unit_quantity,
    translations: { en: "clove", ja: "片", ko: "쪽", zh_tw: "瓣", zh_cn: "瓣", es: "diente", fr: "gousse" }
  },
  "slice" => {
    category: :unit_quantity,
    translations: { en: "slice", ja: "枚", ko: "장", zh_tw: "片", zh_cn: "片", es: "rebanada", fr: "tranche" }
  },
  "sprig" => {
    category: :unit_quantity,
    translations: { en: "sprig", ja: "枝", ko: "줄기", zh_tw: "枝", zh_cn: "枝", es: "ramita", fr: "brin" }
  },
  "stalk" => {
    category: :unit_quantity,
    translations: { en: "stalk", ja: "本", ko: "대", zh_tw: "根", zh_cn: "根", es: "tallo", fr: "tige" }
  },
  "head" => {
    category: :unit_quantity,
    translations: { en: "head", ja: "株", ko: "포기", zh_tw: "顆", zh_cn: "颗", es: "cabeza", fr: "tête" }
  },
  "bunch" => {
    category: :unit_quantity,
    translations: { en: "bunch", ja: "束", ko: "묶음", zh_tw: "束", zh_cn: "束", es: "manojo", fr: "botte" }
  },
  "leaf" => {
    category: :unit_quantity,
    translations: { en: "leaf", ja: "枚", ko: "장", zh_tw: "片", zh_cn: "片", es: "hoja", fr: "feuille" }
  },
  "handful" => {
    category: :unit_quantity,
    translations: { en: "handful", ja: "ひとつかみ", ko: "한 줌", zh_tw: "一把", zh_cn: "一把", es: "puñado", fr: "poignée" }
  },
  "can" => {
    category: :unit_quantity,
    translations: { en: "can", ja: "缶", ko: "캔", zh_tw: "罐", zh_cn: "罐", es: "lata", fr: "boîte" }
  },
  "package" => {
    category: :unit_quantity,
    translations: { en: "package", ja: "パック", ko: "팩", zh_tw: "包", zh_cn: "包", es: "paquete", fr: "paquet" }
  },
  "serving" => {
    category: :unit_quantity,
    translations: { en: "serving", ja: "人前", ko: "인분", zh_tw: "份", zh_cn: "份", es: "porción", fr: "portion" }
  },
  "strip" => {
    category: :unit_quantity,
    translations: { en: "strip", ja: "本", ko: "줄", zh_tw: "條", zh_cn: "条", es: "tira", fr: "bande" }
  },
  "wedge" => {
    category: :unit_quantity,
    translations: { en: "wedge", ja: "くし形", ko: "조각", zh_tw: "角", zh_cn: "角", es: "cuña", fr: "quartier" }
  },
  "fillet" => {
    category: :unit_quantity,
    translations: { en: "fillet", ja: "切り身", ko: "필레", zh_tw: "片", zh_cn: "片", es: "filete", fr: "filet" }
  },
  "sheet" => {
    category: :unit_quantity,
    translations: { en: "sheet", ja: "枚", ko: "장", zh_tw: "張", zh_cn: "张", es: "hoja", fr: "feuille" }
  },
  "stick" => {
    category: :unit_quantity,
    translations: { en: "stick", ja: "本", ko: "개", zh_tw: "條", zh_cn: "条", es: "barra", fr: "bâton" }
  },
  "block" => {
    category: :unit_quantity,
    translations: { en: "block", ja: "丁", ko: "모", zh_tw: "塊", zh_cn: "块", es: "bloque", fr: "bloc" }
  },
  "pod" => {
    category: :unit_quantity,
    translations: { en: "pod", ja: "さや", ko: "꼬투리", zh_tw: "莢", zh_cn: "荚", es: "vaina", fr: "gousse" }
  },
  "cube" => {
    category: :unit_quantity,
    translations: { en: "cube", ja: "個", ko: "개", zh_tw: "塊", zh_cn: "块", es: "cubo", fr: "cube" }
  },
  "jar" => {
    category: :unit_quantity,
    translations: { en: "jar", ja: "瓶", ko: "병", zh_tw: "罐", zh_cn: "罐", es: "frasco", fr: "pot" }
  },
  "dozen" => {
    category: :unit_quantity,
    translations: { en: "dozen", ja: "ダース", ko: "다스", zh_tw: "打", zh_cn: "打", es: "docena", fr: "douzaine" }
  },

  # === LENGTH ===
  "cm" => {
    category: :unit_length,
    translations: { en: "cm", ja: "cm", ko: "cm", zh_tw: "cm", zh_cn: "cm", es: "cm", fr: "cm" }
  },
  "inch" => {
    category: :unit_length,
    translations: { en: "inch", ja: "インチ", ko: "인치", zh_tw: "英寸", zh_cn: "英寸", es: "pulgada", fr: "pouce" }
  },

}.freeze

LOCALE_MAP = {
  :"zh-tw" => :zh_tw,
  :"zh-cn" => :zh_cn
}.freeze

# Maps legacy/plural unit strings to canonical unit names
UNIT_ALIASES = {
  "cloves" => "clove",
  "slices" => "slice",
  "sprigs" => "sprig",
  "stalks" => "stalk",
  "liters" => "l",
  "liter" => "l",
  "pieces" => "piece",
  "leaves" => "leaf",
  "heads" => "head",
  "bunches" => "bunch",
  "cans" => "can",
  "packages" => "package",
  "packet" => "package",
  "packets" => "package",
  "servings" => "serving",
  "strips" => "strip",
  "wedges" => "wedge",
  "fillets" => "fillet",
  "handfuls" => "handful",
  "drops" => "drop",
  "pinches" => "pinch",
  "dashes" => "dash",
  "cups" => "cup",
  "pints" => "pint",
  "quarts" => "quart",
  "gallons" => "gallon",
  "inches" => "inch",
  "sheets" => "sheet",
  "sticks" => "stick",
  "blocks" => "block",
  "pods" => "pod",
  "cubes" => "cube",
  "jars" => "jar",
  "dozens" => "dozen"
}.freeze
