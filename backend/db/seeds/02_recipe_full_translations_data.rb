# Full Recipe Translations - Uses English recipe names as keys
# Contains ingredient groups, ingredients, steps, and equipment translations
# Languages: ja, ko, zh_tw, zh_cn, es, fr
#
# DO NOT EDIT MANUALLY - Regenerate with: rake recipes:generate_seed_translations

RECIPE_FULL_TRANSLATIONS = {
  "Margherita Pizza" => {
    ja: {
      name: "マルゲリータピザ",
      description: "イタリアを代表するピザ。カリッとした生地、酸味のあるトマトソース、クリーミーなフレッシュモッツァレラ、香り高いバジルの完璧な組み合わせが特徴です。このナポリの名作は、上質な食材にはシンプルな調理で十分という哲学を体現しています。",
      ingredient_groups: [
        {
          name: "ピザ生地",
          items: [
            { name: "強力粉", preparation: "00粉（ゼロゼロ粉）があれば尚良い" },
            { name: "水", preparation: "常温" },
            { name: "塩", preparation: nil },
            { name: "インスタントイースト", preparation: nil },
            { name: "オリーブオイル", preparation: "エクストラバージン" }
          ]
        },
        {
          name: "トッピング",
          items: [
            { name: "トマトソース", preparation: "サンマルツァーノ種（イタリア産トマト）があれば尚良い" },
            { name: "モッツァレラチーズ", preparation: "水牛モッツァレラ、スライスする" },
            { name: "バジル", preparation: "葉を手でちぎり、焼き上がり後にのせる" }
          ]
        }
      ],
      steps: [
        { instruction: "大きなボウルに強力粉と水を入れて混ぜる。20分間休ませる（オートリーズ）。" },
        { instruction: "イーストと塩を加える。滑らかで弾力が出るまで10分間こねる。" },
        { instruction: "オリーブオイルを加え、完全に馴染むまでさらに5分間こねる。" },
        { instruction: "ラップなどで覆い、室温で4〜6時間、2倍の大きさになるまで発酵させる。" },
        { instruction: "ピザストーンをオーブンに入れ、245°Cに予熱し、30分間温めておく。" },
        { instruction: "生地を2等分する。それぞれを直径約25cmの円形にやさしく伸ばす。" },
        { instruction: "縁を約2.5cm残してトマトソースを塗る。モッツァレラチーズをのせる。" },
        { instruction: "生地がきつね色になり、チーズがとろけて泡立つまで12分間焼く。" },
        { instruction: "オーブンから取り出す。バジルの葉を手でちぎってピザの上に散らし、オリーブオイルを回しかける。" }
      ],
      equipment: ["ピザストーン", "ミキシングボウル", "ピザピール（ピザを出し入れするヘラ）"]
    },
    ko: {
      name: "마르게리타 피자",
      description: "바삭한 크러스트, 상큼한 토마토 소스, 크리미한 신선한 모차렐라, 향긋한 바질이 완벽하게 어우러진 이탈리아의 대표 피자입니다. 이 나폴리 전통 피자는 좋은 재료에는 최소한의 조리만 필요하다는 철학을 보여줍니다.",
      ingredient_groups: [
        {
          name: "피자 도우",
          items: [
            { name: "강력분", preparation: "티포 00 밀가루(이탈리아산 제분 밀가루) 권장" },
            { name: "물", preparation: "실온" },
            { name: "소금", preparation: nil },
            { name: "인스턴트 이스트", preparation: nil },
            { name: "올리브 오일", preparation: "엑스트라 버진" }
          ]
        },
        {
          name: "토핑",
          items: [
            { name: "토마토 소스", preparation: "산 마르자노(이탈리아산 토마토) 권장" },
            { name: "생 모차렐라 치즈", preparation: "부팔라 모차렐라(물소 우유 치즈), 슬라이스" },
            { name: "신선한 바질", preparation: "잎을 손으로 찢어서, 굽기 후 올리기" }
          ]
        }
      ],
      steps: [
        { instruction: "큰 볼에 밀가루와 물을 섞습니다. 20분간 그대로 둡니다 (오토리즈)." },
        { instruction: "이스트와 소금을 넣습니다. 매끄럽고 탄력이 생길 때까지 10분간 반죽합니다." },
        { instruction: "올리브 오일을 넣고 완전히 흡수될 때까지 5분간 더 반죽합니다." },
        { instruction: "덮어서 실온에서 4-6시간 동안 2배로 부풀 때까지 발효시킵니다." },
        { instruction: "피자 스톤을 오븐에 넣고 475°F (245°C)로 30분간 예열합니다." },
        { instruction: "도우를 2등분합니다. 각각을 부드럽게 늘려 10인치(약 25cm) 원형으로 만듭니다." },
        { instruction: "1인치(약 2.5cm) 크러스트를 남기고 토마토 소스를 펴 바릅니다. 모차렐라 조각을 올립니다." },
        { instruction: "크러스트가 노릇해지고 치즈가 보글보글 녹을 때까지 12분간 굽습니다." },
        { instruction: "오븐에서 꺼냅니다. 신선한 바질 잎을 손으로 찢어 피자 위에 뿌립니다. 올리브 오일을 뿌려 마무리합니다." }
      ],
      equipment: ["피자 스톤", "믹싱 볼", "피자 필(피자 삽)"]
    },
    zh_tw: {
      name: "瑪格麗特披薩",
      description: "這是經典的義大利披薩，完美結合了酥脆的餅皮、微酸的番茄醬、綿密的新鮮莫札瑞拉起司，以及芳香的羅勒。這道拿坡里經典料理體現了優質食材只需簡單烹調的料理哲學。",
      ingredient_groups: [
        {
          name: "披薩麵團",
          items: [
            { name: "高筋麵粉", preparation: "建議使用義大利00號麵粉" },
            { name: "水", preparation: "室溫" },
            { name: "鹽", preparation: nil },
            { name: "即發酵母", preparation: nil },
            { name: "橄欖油", preparation: "特級初榨" }
          ]
        },
        {
          name: "配料",
          items: [
            { name: "番茄醬", preparation: "建議使用聖馬札諾番茄（義大利頂級番茄品種）" },
            { name: "新鮮莫札瑞拉起司", preparation: "水牛莫札瑞拉起司，切片" },
            { name: "新鮮羅勒", preparation: "手撕葉片，出爐後添加" }
          ]
        }
      ],
      steps: [
        { instruction: "在大碗中混合麵粉和水，靜置20分鐘進行水合（自解法）。" },
        { instruction: "加入酵母和鹽，揉製10分鐘，直到麵團光滑且有彈性。" },
        { instruction: "加入橄欖油，繼續揉製5分鐘，直到完全吸收。" },
        { instruction: "覆蓋麵團，在室溫下發酵4-6小時，直到體積膨脹為兩倍。" },
        { instruction: "將烤箱預熱至475°F（245°C），並將披薩石板放入烤箱預熱30分鐘。" },
        { instruction: "將麵團分成2等份，輕輕將每份延展成直徑約25公分的圓形。" },
        { instruction: "塗抹番茄醬，邊緣留約2.5公分作為餅皮。擺上莫札瑞拉起司片。" },
        { instruction: "烘烤12分鐘，直到餅皮呈金黃色且起司冒泡。" },
        { instruction: "從烤箱取出，手撕新鮮羅勒葉撒在披薩上，最後淋上橄欖油。" }
      ],
      equipment: ["披薩石板", "攪拌盆", "披薩鏟"]
    },
    zh_cn: {
      name: "玛格丽特披萨",
      description: "这是意大利最经典的披萨，完美结合了酥脆的饼底、酸甜的番茄酱、绵密的新鲜马苏里拉奶酪和芳香的罗勒。这道那不勒斯经典美食诠释了一个理念：优质食材只需简单烹饪。",
      ingredient_groups: [
        {
          name: "披萨面团",
          items: [
            { name: "高筋面粉", preparation: "意式00号面粉为佳" },
            { name: "水", preparation: "室温" },
            { name: "盐", preparation: nil },
            { name: "即发酵母", preparation: nil },
            { name: "橄榄油", preparation: "特级初榨" }
          ]
        },
        {
          name: "披萨配料",
          items: [
            { name: "番茄酱", preparation: "圣马扎诺番茄酱为佳（意大利优质番茄品种）" },
            { name: "新鲜马苏里拉奶酪", preparation: "水牛奶酪，切片" },
            { name: "新鲜罗勒", preparation: "手撕叶片，出炉后添加" }
          ]
        }
      ],
      steps: [
        { instruction: "在大碗中混合面粉和水，静置20分钟（水合法）。" },
        { instruction: "加入酵母和盐，揉面10分钟至面团光滑有弹性。" },
        { instruction: "加入橄榄油，继续揉5分钟至完全融合。" },
        { instruction: "盖上保鲜膜，室温发酵4-6小时至体积翻倍。" },
        { instruction: "将披萨石放入烤箱，预热至475°F（245°C），预热30分钟。" },
        { instruction: "将面团分成2份，轻轻拉伸成直径约25厘米的圆形。" },
        { instruction: "涂抹番茄酱，边缘留出约2.5厘米的饼边，铺上马苏里拉奶酪。" },
        { instruction: "烘烤12分钟至饼边金黄、奶酪融化冒泡。" },
        { instruction: "出炉后，手撕新鲜罗勒叶撒在披萨上，淋上橄榄油即可。" }
      ],
      equipment: ["披萨石", "搅拌盆", "披萨铲"]
    },
    es: {
      name: "Pizza Margherita",
      description: "La pizza italiana por excelencia que presenta una combinación perfecta de masa crujiente, salsa de tomate con un toque ácido, cremosa mozzarella fresca y aromática albahaca. Este clásico napolitano demuestra la filosofía de que los ingredientes de calidad requieren una preparación mínima.",
      ingredient_groups: [
        {
          name: "Masa de Pizza",
          items: [
            { name: "harina de fuerza", preparation: "preferiblemente harina tipo 00" },
            { name: "agua", preparation: "a temperatura ambiente" },
            { name: "sal", preparation: nil },
            { name: "levadura instantánea", preparation: nil },
            { name: "aceite de oliva", preparation: "virgen extra" }
          ]
        },
        {
          name: "Ingredientes para Cubrir",
          items: [
            { name: "salsa de tomate", preparation: "preferiblemente tomate San Marzano" },
            { name: "mozzarella fresca", preparation: "mozzarella di bufala, en rodajas" },
            { name: "albahaca fresca", preparation: "rasgar las hojas, añadir después de hornear" }
          ]
        }
      ],
      steps: [
        { instruction: "Mezclar la harina y el agua en un bol grande. Dejar reposar 20 minutos (autólisis)." },
        { instruction: "Añadir la levadura y la sal. Amasar durante 10 minutos hasta obtener una masa lisa y elástica." },
        { instruction: "Añadir el aceite de oliva y continuar amasando 5 minutos hasta que esté completamente incorporado." },
        { instruction: "Cubrir y dejar fermentar a temperatura ambiente durante 4-6 horas hasta que duplique su volumen." },
        { instruction: "Precalentar el horno a 475°F (245°C) con la piedra para pizza dentro durante 30 minutos." },
        { instruction: "Dividir la masa en 2 porciones. Estirar suavemente cada una formando un círculo de 25 cm." },
        { instruction: "Extender la salsa de tomate dejando 2,5 cm de borde para la corteza. Cubrir con trozos de mozzarella." },
        { instruction: "Hornear 12 minutos hasta que la corteza esté dorada y el queso burbujeante." },
        { instruction: "Retirar del horno. Rasgar las hojas de albahaca fresca y esparcir sobre la pizza. Rociar con aceite de oliva." }
      ],
      equipment: ["Piedra para Pizza", "Bol para Mezclar", "Pala para Pizza"]
    },
    fr: {
      name: "Pizza Margherita",
      description: "La pizza italienne par excellence, présentant une combinaison parfaite de croûte croustillante, de sauce tomate acidulée, de mozzarella fraîche crémeuse et de basilic aromatique. Ce classique napolitain illustre la philosophie selon laquelle des ingrédients de qualité nécessitent une préparation minimale.",
      ingredient_groups: [
        {
          name: "Pâte à pizza",
          items: [
            { name: "farine de gruau", preparation: "farine de type 00 de préférence" },
            { name: "eau", preparation: "à température ambiante" },
            { name: "sel", preparation: nil },
            { name: "levure instantanée", preparation: nil },
            { name: "huile d'olive", preparation: "extra vierge" }
          ]
        },
        {
          name: "Garniture",
          items: [
            { name: "sauce tomate", preparation: "San Marzano de préférence (tomates italiennes AOP)" },
            { name: "mozzarella fraîche", preparation: "mozzarella di bufala, tranchée" },
            { name: "basilic frais", preparation: "effeuiller et déchirer les feuilles, ajouter après cuisson" }
          ]
        }
      ],
      steps: [
        { instruction: "Mélanger la farine et l'eau dans un grand saladier. Laisser reposer 20 minutes (autolyse)." },
        { instruction: "Ajouter la levure et le sel. Pétrir pendant 10 minutes jusqu'à obtenir une pâte lisse et élastique." },
        { instruction: "Ajouter l'huile d'olive et continuer à pétrir pendant 5 minutes jusqu'à incorporation complète." },
        { instruction: "Couvrir et laisser lever à température ambiante pendant 4 à 6 heures jusqu'à ce que la pâte ait doublé de volume." },
        { instruction: "Préchauffer le four à 245°C (475°F) avec la pierre à pizza à l'intérieur pendant 30 minutes." },
        { instruction: "Diviser la pâte en 2 portions. Étirer délicatement chaque portion en un cercle de 25 cm de diamètre." },
        { instruction: "Étaler la sauce tomate en laissant un bord de 2,5 cm pour la croûte. Répartir les morceaux de mozzarella." },
        { instruction: "Enfourner pendant 12 minutes jusqu'à ce que la croûte soit dorée et le fromage bien fondu et légèrement doré." },
        { instruction: "Sortir du four. Déchirer les feuilles de basilic frais et les parsemer sur la pizza. Arroser d'un filet d'huile d'olive." }
      ],
      equipment: ["Pierre à pizza", "Saladier", "Pelle à pizza"]
    }
  },
  "Pad Thai" => {
    ja: {
      name: "パッタイ",
      description: "タイで最も有名な麺料理で、甘味、酸味、塩味、辛味の絶妙なバランスが特徴です。米麺を卵、エビ、豆腐と手早く炒め合わせたこの屋台料理は、自分好みにアレンジでき、家庭でもレストラン品質の味を楽しめます。",
      ingredient_groups: [
        {
          name: "麺とソース",
          items: [
            { name: "乾燥ライスヌードル（センレック）", preparation: "幅約6mm、水に30分浸して戻す" },
            { name: "タマリンドペースト（酸味のある果実のペースト）", preparation: "またはライムジュースで代用可" },
            { name: "ナンプラー", preparation: nil },
            { name: "パームシュガー（ヤシ砂糖）", preparation: "または黒砂糖で代用可" }
          ]
        },
        {
          name: "タンパク質と野菜",
          items: [
            { name: "エビ", preparation: "殻をむき、背わたを取る" },
            { name: "卵", preparation: "溶きほぐす" },
            { name: "にんにく", preparation: "みじん切り" },
            { name: "もやし", preparation: "新鮮なもの" },
            { name: "青ねぎ", preparation: "5cm幅に切る" }
          ]
        },
        {
          name: "トッピングと付け合わせ",
          items: [
            { name: "砕いたピーナッツ", preparation: "ローストした無塩のもの" },
            { name: "ライム", preparation: "くし形に切る" },
            { name: "植物油", preparation: nil }
          ]
        }
      ],
      steps: [
        { instruction: "乾燥ライスヌードルを水に30分浸して柔らかくする。水気をしっかり切る。" },
        { instruction: "小さなボウルにタマリンドペースト、ナンプラー、パームシュガーを混ぜ合わせる。" },
        { instruction: "大きめの中華鍋またはフライパンを強火で熱し、油大さじ1を入れる。" },
        { instruction: "みじん切りにしたにんにくを加え、香りが立つまで約10秒炒める。" },
        { instruction: "エビを加え、ピンク色になるまで約2分炒める。鍋の端に寄せる。" },
        { instruction: "空いたスペースに溶き卵を流し入れる。スクランブル状にしてエビと混ぜ合わせる。" },
        { instruction: "水気を切った麺とソースを加える。全体を2分ほど炒め合わせる。" },
        { instruction: "もやしと青ねぎを加える。30秒ほどさっと炒め合わせる。" },
        { instruction: "皿に盛り付け、砕いたピーナッツをのせ、ライムのくし切りを添える。" }
      ],
      equipment: ["中華鍋", "木べら"]
    },
    ko: {
      name: "팟타이",
      description: "태국의 가장 대표적인 볶음 쌀국수 요리로, 달콤함, 새콤함, 짭짤함, 매콤함의 완벽한 균형으로 유명합니다. 쌀국수를 계란, 새우, 두부와 함께 빠르게 볶아내는 이 길거리 음식은 취향에 맞게 변형이 가능하며, 가정에서도 레스토랑 수준의 맛을 낼 수 있습니다.",
      ingredient_groups: [
        {
          name: "면 & 소스",
          items: [
            { name: "건 쌀국수", preparation: "약 6mm 너비, 물에 30분간 불리기" },
            { name: "타마린드 페이스트 (새콤한 열대과일 농축액)", preparation: "또는 라임즙으로 대체 가능" },
            { name: "피시 소스 (액젓)", preparation: nil },
            { name: "팜 슈가 (야자 설탕)", preparation: "또는 흑설탕으로 대체 가능" }
          ]
        },
        {
          name: "단백질 & 채소",
          items: [
            { name: "새우", preparation: "껍질 벗기고 내장 제거" },
            { name: "계란", preparation: "풀어두기" },
            { name: "마늘", preparation: "다지기" },
            { name: "숙주나물", preparation: "생것" },
            { name: "쪽파", preparation: "5cm 길이로 썰기" }
          ]
        },
        {
          name: "고명 & 곁들임",
          items: [
            { name: "땅콩", preparation: "볶아서 굵게 다진 것, 무염" },
            { name: "라임", preparation: "웨지 모양으로 썰기" },
            { name: "식용유", preparation: nil }
          ]
        }
      ],
      steps: [
        { instruction: "건 쌀국수를 물에 30분간 담가 부드러워질 때까지 불린다. 물기를 충분히 뺀다." },
        { instruction: "작은 볼에 타마린드 페이스트, 피시 소스, 팜 슈가를 넣고 섞어 소스를 만들어 둔다." },
        { instruction: "큰 웍이나 프라이팬을 센 불에 올려 달군다. 식용유 1큰술을 두른다." },
        { instruction: "다진 마늘을 넣고 향이 날 때까지 약 10초간 볶는다." },
        { instruction: "새우를 넣고 분홍색이 될 때까지 약 2분간 볶는다. 웍 한쪽으로 밀어둔다." },
        { instruction: "빈 공간에 풀어둔 계란을 붓는다. 스크램블한 후 새우와 섞는다." },
        { instruction: "불린 쌀국수와 소스를 넣는다. 모든 재료를 2분간 고루 볶아 섞는다." },
        { instruction: "숙주나물과 쪽파를 넣는다. 30초간 빠르게 볶아 섞는다." },
        { instruction: "접시에 담고 굵게 다진 땅콩을 올린다. 라임 웨지를 곁들여 낸다." }
      ],
      equipment: ["웍", "나무 뒤집개"]
    },
    zh_tw: {
      name: "泰式炒河粉",
      description: "泰國最具代表性的麵食料理，以其完美平衡的酸、甜、鹹、辣風味聞名於世。河粉與蛋、蝦仁、豆腐一同大火快炒，這道街頭美食可依個人喜好調整配料，讓您在家也能做出餐廳級的美味。",
      ingredient_groups: [
        {
          name: "河粉與醬汁",
          items: [
            { name: "乾河粉", preparation: "約0.6公分寬，浸泡水中30分鐘" },
            { name: "羅望子醬（泰式酸子醬）", preparation: "或以檸檬汁替代" },
            { name: "魚露", preparation: nil },
            { name: "椰糖", preparation: "或以黑糖替代" }
          ]
        },
        {
          name: "蛋白質與蔬菜",
          items: [
            { name: "蝦仁", preparation: "去殼去腸泥" },
            { name: "雞蛋", preparation: "打散" },
            { name: "蒜頭", preparation: "切末" },
            { name: "豆芽菜", preparation: "新鮮" },
            { name: "青蔥", preparation: "切成約5公分段" }
          ]
        },
        {
          name: "裝飾與配料",
          items: [
            { name: "碎花生", preparation: "烘烤過、無鹽" },
            { name: "萊姆", preparation: "切成角狀" },
            { name: "植物油", preparation: nil }
          ]
        }
      ],
      steps: [
        { instruction: "將乾河粉浸泡在水中30分鐘至軟化，瀝乾備用。" },
        { instruction: "將羅望子醬、魚露和椰糖在小碗中混合均勻，備用。" },
        { instruction: "大火加熱炒鍋或平底鍋，加入1大匙油。" },
        { instruction: "加入蒜末，快炒約10秒至香氣散出。" },
        { instruction: "加入蝦仁，炒至變成粉紅色，約2分鐘。將蝦仁推至鍋邊。" },
        { instruction: "將打散的蛋液倒入空出的位置，炒散後與蝦仁混合。" },
        { instruction: "加入瀝乾的河粉和調好的醬汁，翻炒均勻約2分鐘。" },
        { instruction: "加入豆芽菜和青蔥，快速翻炒30秒使其混合均勻。" },
        { instruction: "盛盤，撒上碎花生，並附上萊姆角於旁邊享用。" }
      ],
      equipment: ["炒鍋", "木鏟"]
    },
    zh_cn: {
      name: "泰式炒河粉",
      description: "泰国最具代表性的面食，以其完美的酸、甜、咸、辣四味平衡而闻名。将河粉与鸡蛋、虾仁和豆腐快速翻炒，这道街头美食可根据个人口味调整，让您在家也能做出餐厅级的美味。",
      ingredient_groups: [
        {
          name: "河粉与酱汁",
          items: [
            { name: "干河粉", preparation: "约0.6厘米宽，用水浸泡30分钟" },
            { name: "罗望子酱（一种东南亚常用的酸味调料）", preparation: "或用青柠汁代替" },
            { name: "鱼露", preparation: nil },
            { name: "椰糖", preparation: "或用红糖代替" }
          ]
        },
        {
          name: "蛋白质与蔬菜",
          items: [
            { name: "虾仁", preparation: "去壳去虾线" },
            { name: "鸡蛋", preparation: "打散" },
            { name: "大蒜", preparation: "切末" },
            { name: "豆芽", preparation: "新鲜" },
            { name: "小葱", preparation: "切成5厘米段" }
          ]
        },
        {
          name: "装饰与配料",
          items: [
            { name: "碎花生", preparation: "烤熟，无盐" },
            { name: "青柠", preparation: "切角" },
            { name: "植物油", preparation: nil }
          ]
        }
      ],
      steps: [
        { instruction: "将干河粉用水浸泡30分钟至软化，沥干水分备用。" },
        { instruction: "将罗望子酱、鱼露和椰糖在小碗中混合均匀，备用。" },
        { instruction: "大火烧热炒锅，加入1汤匙油。" },
        { instruction: "加入蒜末爆香约10秒，炒出香味。" },
        { instruction: "加入虾仁翻炒约2分钟至变色熟透，推至锅边。" },
        { instruction: "将打散的蛋液倒入锅中空出的位置，炒散后与虾仁混合。" },
        { instruction: "加入沥干的河粉和调好的酱汁，翻炒均匀约2分钟。" },
        { instruction: "加入豆芽和小葱段，快速翻炒30秒混合均匀。" },
        { instruction: "盛盘，撒上碎花生，旁边放青柠角即可上桌。" }
      ],
      equipment: ["炒锅", "木铲"]
    },
    es: {
      name: "Pad Thai",
      description: "El plato de fideos más icónico de Tailandia, famoso por su equilibrio perfecto de sabores dulces, ácidos, salados y picantes. Fideos de arroz salteados rápidamente con huevos, camarones y tofu, este favorito de la comida callejera es personalizable y trae resultados de calidad de restaurante a las cocinas caseras.",
      ingredient_groups: [
        {
          name: "Fideos y Salsa",
          items: [
            { name: "fideos de arroz secos", preparation: "de aproximadamente 6 mm de ancho, remojados en agua 30 minutos" },
            { name: "pasta de tamarindo", preparation: "o jugo de limón" },
            { name: "salsa de pescado (nam pla, condimento tailandés fermentado)", preparation: nil },
            { name: "azúcar de palma (azúcar tailandés sin refinar)", preparation: "o azúcar moreno" }
          ]
        },
        {
          name: "Proteínas y Vegetales",
          items: [
            { name: "camarones", preparation: "pelados, desvenados" },
            { name: "huevos", preparation: "batidos" },
            { name: "ajo", preparation: "picado finamente" },
            { name: "brotes de soja", preparation: "frescos" },
            { name: "cebolletas", preparation: "cortadas en trozos de 5 cm" }
          ]
        },
        {
          name: "Guarnición y Acompañamientos",
          items: [
            { name: "cacahuetes triturados", preparation: "tostados, sin sal" },
            { name: "lima", preparation: "cortada en gajos" },
            { name: "aceite vegetal", preparation: nil }
          ]
        }
      ],
      steps: [
        { instruction: "Remojar los fideos de arroz secos en agua durante 30 minutos hasta que se ablanden. Escurrir bien." },
        { instruction: "Mezclar la pasta de tamarindo, la salsa de pescado y el azúcar de palma en un bol pequeño. Reservar." },
        { instruction: "Calentar un wok grande o sartén a fuego alto. Añadir 1 cucharada de aceite." },
        { instruction: "Añadir el ajo picado y saltear durante 10 segundos hasta que esté aromático." },
        { instruction: "Añadir los camarones y cocinar hasta que estén rosados, aproximadamente 2 minutos. Empujar hacia un lado del wok." },
        { instruction: "Verter los huevos batidos en el espacio vacío. Revolver y mezclar con los camarones." },
        { instruction: "Añadir los fideos escurridos y la mezcla de salsa. Saltear todo junto durante 2 minutos." },
        { instruction: "Añadir los brotes de soja y las cebolletas. Saltear durante 30 segundos para integrar." },
        { instruction: "Servir en platos. Cubrir con los cacahuetes triturados y los gajos de lima a un lado." }
      ],
      equipment: ["Wok", "Espátula de madera"]
    },
    fr: {
      name: "Pad Thai",
      description: "Le plat de nouilles le plus emblématique de Thaïlande, célèbre pour son équilibre parfait entre saveurs sucrées, acides, salées et épicées. Des nouilles de riz sautées rapidement avec des œufs, des crevettes et du tofu. Ce classique de la street food thaïlandaise est personnalisable et permet d'obtenir des résultats dignes d'un restaurant à la maison.",
      ingredient_groups: [
        {
          name: "Nouilles et sauce",
          items: [
            { name: "nouilles de riz séchées", preparation: "environ 6 mm de large, trempées dans l'eau 30 minutes" },
            { name: "pâte de tamarin", preparation: "ou jus de citron vert" },
            { name: "nuoc-mâm (sauce de poisson fermenté)", preparation: nil },
            { name: "sucre de palme", preparation: "ou cassonade" }
          ]
        },
        {
          name: "Protéines et légumes",
          items: [
            { name: "crevettes", preparation: "décortiquées, déveinées" },
            { name: "œufs", preparation: "battus" },
            { name: "ail", preparation: "émincé" },
            { name: "germes de soja", preparation: "frais" },
            { name: "ciboules", preparation: "coupées en tronçons de 5 cm" }
          ]
        },
        {
          name: "Garniture et accompagnements",
          items: [
            { name: "cacahuètes concassées", preparation: "grillées, non salées" },
            { name: "citron vert", preparation: "coupé en quartiers" },
            { name: "huile végétale", preparation: nil }
          ]
        }
      ],
      steps: [
        { instruction: "Faire tremper les nouilles de riz séchées dans l'eau pendant 30 minutes jusqu'à ce qu'elles soient ramollies. Bien égoutter." },
        { instruction: "Mélanger la pâte de tamarin, le nuoc-mâm et le sucre de palme dans un petit bol. Réserver." },
        { instruction: "Faire chauffer un grand wok ou une poêle à feu vif. Ajouter 1 c. à s. d'huile." },
        { instruction: "Ajouter l'ail émincé et faire sauter pendant 10 secondes jusqu'à ce qu'il soit parfumé." },
        { instruction: "Ajouter les crevettes et cuire jusqu'à ce qu'elles soient roses, environ 2 minutes. Les pousser sur le côté du wok." },
        { instruction: "Verser les œufs battus dans l'espace libre. Les brouiller et mélanger avec les crevettes." },
        { instruction: "Ajouter les nouilles égouttées et le mélange de sauce. Faire sauter le tout pendant 2 minutes." },
        { instruction: "Ajouter les germes de soja et les ciboules. Faire sauter pendant 30 secondes pour bien mélanger." },
        { instruction: "Dresser dans les assiettes. Garnir de cacahuètes concassées et servir avec des quartiers de citron vert à côté." }
      ],
      equipment: ["Wok", "Spatule en bois"]
    }
  },
  "Shakshuka" => {
    ja: {
      name: "シャクシュカ",
      description: "中東で愛される朝食・ブランチの定番料理。スパイスの効いた濃厚なトマトとパプリカのソースの中で卵をポーチドエッグ風に仕上げます。大人数のおもてなしにぴったりで、事前に準備できるため週末のホームパーティーに最適です。",
      ingredient_groups: [
        {
          name: "ソース",
          items: [
            { name: "オリーブオイル", preparation: "エクストラバージン" },
            { name: "玉ねぎ", preparation: "さいの目切り" },
            { name: "にんにく", preparation: "みじん切り" },
            { name: "トマト缶", preparation: "クラッシュまたはダイスカット" },
            { name: "クミン", preparation: nil },
            { name: "パプリカパウダー", preparation: nil },
            { name: "塩こしょう", preparation: "適量" }
          ]
        },
        {
          name: "卵",
          items: [
            { name: "卵", preparation: nil }
          ]
        },
        {
          name: "トッピング",
          items: [
            { name: "パクチー", preparation: "刻む" },
            { name: "ピタパン（中東の平焼きパン）", preparation: "添え用" }
          ]
        }
      ],
      steps: [
        { instruction: "大きなフライパンにオリーブオイルを入れ、中火で熱する。" },
        { instruction: "さいの目切りにした玉ねぎを加え、3〜4分ほど柔らかくなるまで炒める。" },
        { instruction: "みじん切りにしたにんにくを加え、香りが立つまで約1分炒める。" },
        { instruction: "トマト缶、クミン、パプリカパウダーを加えて混ぜ、10分ほど煮込む。" },
        { instruction: "塩こしょうで味を調える。" },
        { instruction: "スプーンの背を使って、ソースに6つのくぼみを作る。" },
        { instruction: "それぞれのくぼみに卵を1つずつ割り入れる。蓋をする。" },
        { instruction: "5〜7分、白身が固まり黄身がとろりとした状態になるまで加熱する。" },
        { instruction: "パクチーを散らして仕上げる。ピタパンを添えて熱いうちに召し上がれ。" }
      ],
      equipment: ["大きめのフライパン", "フライパンの蓋"]
    },
    ko: {
      name: "샥슈카",
      description: "중동의 대표적인 아침 식사이자 브런치 요리로, 풍부한 향신료가 들어간 토마토와 피망 소스에 수란을 올린 요리입니다. 향긋한 이 요리는 여러 명이 함께 먹기에 좋으며 미리 준비해 둘 수 있어 주말 홈파티에 안성맞춤입니다.",
      ingredient_groups: [
        {
          name: "소스",
          items: [
            { name: "올리브 오일", preparation: "엑스트라 버진" },
            { name: "양파", preparation: "깍둑썰기" },
            { name: "마늘", preparation: "다진 것" },
            { name: "토마토 통조림", preparation: "으깬 것 또는 깍둑썰기" },
            { name: "쿠민 (큐민, 중동 향신료)", preparation: nil },
            { name: "파프리카 가루", preparation: nil },
            { name: "소금과 후추", preparation: "기호에 맞게" }
          ]
        },
        {
          name: "달걀",
          items: [
            { name: "달걀", preparation: nil }
          ]
        },
        {
          name: "고명",
          items: [
            { name: "고수 (실란트로)", preparation: "다진 것" },
            { name: "피타 브레드 (중동식 납작빵)", preparation: "곁들임용" }
          ]
        }
      ],
      steps: [
        { instruction: "큰 프라이팬에 올리브 오일을 두르고 중불로 가열합니다." },
        { instruction: "깍둑썬 양파를 넣고 3-4분간 부드러워질 때까지 볶습니다." },
        { instruction: "다진 마늘을 넣고 향이 날 때까지 1분간 볶습니다." },
        { instruction: "토마토 통조림, 쿠민, 파프리카 가루를 넣고 섞은 뒤 10분간 끓입니다." },
        { instruction: "소금과 후추로 기호에 맞게 간합니다." },
        { instruction: "숟가락 뒷면으로 소스에 6개의 홈을 만듭니다." },
        { instruction: "각 홈에 달걀을 하나씩 깨서 넣습니다. 프라이팬 뚜껑을 덮습니다." },
        { instruction: "흰자는 익고 노른자는 흐르는 상태가 될 때까지 5-7분간 조리합니다." },
        { instruction: "다진 고수를 올려 장식합니다. 피타 브레드와 함께 따뜻하게 냅니다." }
      ],
      equipment: ["큰 프라이팬", "프라이팬 뚜껑"]
    },
    zh_tw: {
      name: "夏舒卡（中東番茄燉蛋）",
      description: "夏舒卡是深受喜愛的中東早午餐經典料理，將雞蛋水波煮在香料豐富的番茄甜椒醬汁中。這道香氣四溢的料理非常適合多人享用，且可提前準備，是週末招待客人的理想選擇。",
      ingredient_groups: [
        {
          name: "醬汁",
          items: [
            { name: "橄欖油", preparation: "特級初榨" },
            { name: "洋蔥", preparation: "切丁" },
            { name: "蒜頭", preparation: "切末" },
            { name: "罐頭番茄", preparation: "碎狀或切丁" },
            { name: "孜然粉", preparation: nil },
            { name: "紅椒粉", preparation: nil },
            { name: "鹽和胡椒", preparation: "適量" }
          ]
        },
        {
          name: "雞蛋",
          items: [
            { name: "雞蛋", preparation: nil }
          ]
        },
        {
          name: "裝飾配料",
          items: [
            { name: "新鮮香菜", preparation: "切碎" },
            { name: "皮塔餅（中東口袋餅）", preparation: "搭配食用" }
          ]
        }
      ],
      steps: [
        { instruction: "在大型平底鍋中以中火加熱橄欖油。" },
        { instruction: "加入洋蔥丁拌炒3-4分鐘至軟化。" },
        { instruction: "加入蒜末炒約1分鐘至香氣散出。" },
        { instruction: "倒入罐頭番茄，加入孜然粉和紅椒粉拌勻，燉煮10分鐘。" },
        { instruction: "以鹽和胡椒調味。" },
        { instruction: "用湯匙背面在醬汁中壓出6個凹槽。" },
        { instruction: "將雞蛋分別打入每個凹槽中，蓋上鍋蓋。" },
        { instruction: "煮5-7分鐘，直到蛋白凝固但蛋黃仍呈流動狀態。" },
        { instruction: "撒上新鮮香菜裝飾，趁熱搭配皮塔餅享用。" }
      ],
      equipment: ["大型平底鍋", "鍋蓋"]
    },
    zh_cn: {
      name: "夏克舒卡（中东番茄蛋）",
      description: "夏克舒卡是深受喜爱的中东早餐和早午餐经典菜肴，将水波蛋嵌入香料浓郁的番茄甜椒酱汁中。这道香气四溢的菜肴非常适合多人聚餐，可以提前准备，是周末宴客的理想选择。",
      ingredient_groups: [
        {
          name: "酱汁",
          items: [
            { name: "橄榄油", preparation: "特级初榨" },
            { name: "洋葱", preparation: "切丁" },
            { name: "大蒜", preparation: "切末" },
            { name: "罐装番茄", preparation: "碎番茄或番茄丁" },
            { name: "孜然粉", preparation: nil },
            { name: "甜椒粉", preparation: nil },
            { name: "盐和胡椒", preparation: "适量" }
          ]
        },
        {
          name: "鸡蛋",
          items: [
            { name: "鸡蛋", preparation: nil }
          ]
        },
        {
          name: "装饰配料",
          items: [
            { name: "新鲜香菜", preparation: "切碎" },
            { name: "皮塔饼（中东口袋饼）", preparation: "搭配食用" }
          ]
        }
      ],
      steps: [
        { instruction: "在大煎锅中倒入橄榄油，中火加热。" },
        { instruction: "加入洋葱丁，翻炒3-4分钟至软化。" },
        { instruction: "加入蒜末，炒1分钟至散发香气。" },
        { instruction: "倒入罐装番茄，加入孜然粉和甜椒粉拌匀，小火炖煮10分钟。" },
        { instruction: "根据口味加盐和胡椒调味。" },
        { instruction: "用勺背在酱汁中压出6个凹槽。" },
        { instruction: "在每个凹槽中打入一个鸡蛋，盖上锅盖。" },
        { instruction: "煮5-7分钟，直到蛋白凝固但蛋黄仍呈溏心状态。" },
        { instruction: "撒上新鲜香菜装饰，趁热搭配皮塔饼享用。" }
      ],
      equipment: ["大煎锅", "锅盖"]
    },
    es: {
      name: "Shakshuka",
      description: "Un plato querido del Medio Oriente para desayuno y brunch, con huevos escalfados anidados en una salsa de tomate y pimientos ricamente especiada. Este aromático plato es perfecto para alimentar a un grupo y se puede preparar con anticipación, siendo ideal para reuniones de fin de semana.",
      ingredient_groups: [
        {
          name: "Salsa",
          items: [
            { name: "aceite de oliva", preparation: "extra virgen" },
            { name: "cebolla", preparation: "cortada en cubitos" },
            { name: "ajo", preparation: "picado" },
            { name: "tomates en lata", preparation: "triturados o en cubitos" },
            { name: "comino", preparation: nil },
            { name: "pimentón", preparation: nil },
            { name: "sal y pimienta", preparation: "al gusto" }
          ]
        },
        {
          name: "Huevos",
          items: [
            { name: "huevos", preparation: nil }
          ]
        },
        {
          name: "Guarnición",
          items: [
            { name: "cilantro fresco", preparation: "picado" },
            { name: "pan pita", preparation: "para acompañar" }
          ]
        }
      ],
      steps: [
        { instruction: "Calentar el aceite de oliva en una sartén grande a fuego medio." },
        { instruction: "Añadir la cebolla cortada en cubitos y sofreír durante 3-4 minutos hasta que esté tierna." },
        { instruction: "Agregar el ajo picado y cocinar durante 1 minuto hasta que esté aromático." },
        { instruction: "Incorporar los tomates en lata, el comino y el pimentón. Cocinar a fuego lento durante 10 minutos." },
        { instruction: "Sazonar con sal y pimienta al gusto." },
        { instruction: "Hacer 6 huecos en la salsa con el reverso de una cuchara." },
        { instruction: "Cascar un huevo en cada hueco. Tapar la sartén con una tapa." },
        { instruction: "Cocinar durante 5-7 minutos hasta que las claras estén cuajadas pero las yemas sigan líquidas." },
        { instruction: "Decorar con cilantro fresco. Servir caliente con pan pita." }
      ],
      equipment: ["Sartén grande", "Tapa para sartén"]
    },
    fr: {
      name: "Shakshuka",
      description: "Un incontournable du petit-déjeuner et du brunch au Moyen-Orient, composé d'œufs pochés nichés dans une sauce tomate aux poivrons richement épicée. Ce plat aromatique est parfait pour nourrir un groupe et peut être préparé à l'avance, ce qui le rend idéal pour recevoir le week-end.",
      ingredient_groups: [
        {
          name: "Sauce",
          items: [
            { name: "huile d'olive", preparation: "extra vierge" },
            { name: "oignon", preparation: "coupé en dés" },
            { name: "ail", preparation: "émincé" },
            { name: "tomates en conserve", preparation: "concassées ou en dés" },
            { name: "cumin", preparation: nil },
            { name: "paprika", preparation: nil },
            { name: "sel et poivre", preparation: "selon le goût" }
          ]
        },
        {
          name: "Œufs",
          items: [
            { name: "œufs", preparation: nil }
          ]
        },
        {
          name: "Garniture",
          items: [
            { name: "coriandre fraîche", preparation: "ciselée" },
            { name: "pita (pain plat du Moyen-Orient)", preparation: "pour servir" }
          ]
        }
      ],
      steps: [
        { instruction: "Faire chauffer l'huile d'olive dans une grande poêle à feu moyen." },
        { instruction: "Ajouter l'oignon coupé en dés et faire revenir 3-4 minutes jusqu'à ce qu'il soit tendre." },
        { instruction: "Ajouter l'ail émincé et cuire 1 minute jusqu'à ce qu'il soit parfumé." },
        { instruction: "Incorporer les tomates en conserve, le cumin et le paprika. Laisser mijoter 10 minutes." },
        { instruction: "Assaisonner de sel et poivre selon le goût." },
        { instruction: "Creuser 6 puits dans la sauce avec le dos d'une cuillère." },
        { instruction: "Casser un œuf dans chaque puits. Couvrir la poêle avec un couvercle." },
        { instruction: "Cuire 5-7 minutes jusqu'à ce que les blancs soient pris mais les jaunes encore coulants." },
        { instruction: "Garnir de coriandre fraîche. Servir chaud avec du pain pita." }
      ],
      equipment: ["Grande poêle", "Couvercle de poêle"]
    }
  },
  "Tom Yum Soup" => {
    ja: {
      name: "トムヤムクン",
      description: "タイで最も有名なスープ。レモングラス、ガランガル、ライムの香りが溶け込んだ芳醇で味わい深いスープです。辛味、酸味、スパイシーさの絶妙なバランスと、プリプリのエビが楽しめる人気のレストランメニューですが、ご家庭でも意外と簡単に再現できます。",
      ingredient_groups: [
        {
          name: "スープベース",
          items: [
            { name: "鶏がらスープ", preparation: nil },
            { name: "レモングラス（タイ料理に使う香草）", preparation: "5cm程度に切り、叩いて香りを出す" },
            { name: "ガランガル（タイの生姜の一種）", preparation: "薄切り" },
            { name: "こぶみかんの葉（バイマックルー）", preparation: nil }
          ]
        },
        {
          name: "具材",
          items: [
            { name: "エビ", preparation: "殻をむき、背わたを取る" },
            { name: "マッシュルーム", preparation: "マッシュルームまたはふくろたけ、半分に切る" },
            { name: "ミニトマト", preparation: "半分に切る" }
          ]
        },
        {
          name: "調味料",
          items: [
            { name: "ナンプラー", preparation: nil },
            { name: "ライム果汁", preparation: "生のもの" },
            { name: "ナムプリックパオ（タイのチリペースト）", preparation: "または唐辛子フレーク" },
            { name: "パクチー", preparation: "刻んで仕上げ用" }
          ]
        }
      ],
      steps: [
        { instruction: "大きな鍋に鶏がらスープを入れ、沸騰させる。" },
        { instruction: "レモングラス、ガランガル、こぶみかんの葉を加え、5分間煮込む。" },
        { instruction: "マッシュルームを加え、3分間煮る。" },
        { instruction: "エビを加え、ピンク色になるまで2〜3分加熱する。" },
        { instruction: "ミニトマトを加え、1分間煮る。" },
        { instruction: "ナンプラー、ライム果汁、チリペーストを加えて混ぜる。" },
        { instruction: "味見をして調味料を調整する。辛味、酸味、スパイシーさのバランスが取れているか確認する。" },
        { instruction: "器に盛り付け、パクチーを散らして完成。" }
      ],
      equipment: ["大きな鍋"]
    },
    ko: {
      name: "똠얌꿍",
      description: "태국에서 가장 유명한 수프로, 레몬그라스, 갈랑갈, 라임으로 우려낸 향긋하고 깊은 맛의 육수입니다. 매콤하고 새콤한 맛의 완벽한 조화와 탱글탱글한 새우가 어우러져 레스토랑 인기 메뉴이지만 집에서도 쉽게 만들 수 있습니다.",
      ingredient_groups: [
        {
          name: "육수 베이스",
          items: [
            { name: "닭 육수", preparation: nil },
            { name: "레몬그라스 (태국 허브)", preparation: "5cm 길이로 잘라 두드려 향을 낸다" },
            { name: "갈랑갈 (태국 생강)", preparation: "얇게 슬라이스" },
            { name: "카피르 라임잎 (태국 라임잎)", preparation: nil }
          ]
        },
        {
          name: "단백질 & 채소",
          items: [
            { name: "새우", preparation: "껍질 벗기고 내장 제거" },
            { name: "양송이버섯", preparation: "양송이 또는 풀버섯, 반으로 자른다" },
            { name: "방울토마토", preparation: "반으로 자른다" }
          ]
        },
        {
          name: "양념",
          items: [
            { name: "피쉬소스 (태국 액젓)", preparation: nil },
            { name: "라임즙", preparation: "생즙" },
            { name: "남프릭파오 (태국 칠리 페이스트)", preparation: "또는 고춧가루" },
            { name: "고수", preparation: "다져서 고명용" }
          ]
        }
      ],
      steps: [
        { instruction: "큰 냄비에 닭 육수를 넣고 끓인다." },
        { instruction: "레몬그라스, 갈랑갈, 카피르 라임잎을 넣고 5분간 끓인다." },
        { instruction: "버섯을 넣고 3분간 끓인다." },
        { instruction: "새우를 넣고 분홍색이 될 때까지 2-3분간 익힌다." },
        { instruction: "방울토마토를 넣고 1분간 익힌다." },
        { instruction: "피쉬소스, 라임즙, 칠리 페이스트를 넣고 섞는다." },
        { instruction: "간을 보고 조절한다. 매콤하고 새콤하며 얼큰해야 한다." },
        { instruction: "그릇에 담고 신선한 고수를 올려 마무리한다." }
      ],
      equipment: ["큰 냄비"]
    },
    zh_tw: {
      name: "泰式酸辣湯",
      description: "泰國最著名的湯品，以香茅、南薑和萊姆調製出香氣四溢、風味濃郁的湯底。酸、辣、鮮的完美平衡搭配鮮嫩的蝦子，使這道深受喜愛的餐廳招牌菜在家也能輕鬆重現。",
      ingredient_groups: [
        {
          name: "湯底",
          items: [
            { name: "雞高湯", preparation: nil },
            { name: "香茅", preparation: "切成約5公分段，拍扁" },
            { name: "南薑", preparation: "切薄片" },
            { name: "泰國檸檬葉（卡菲爾萊姆葉）", preparation: nil }
          ]
        },
        {
          name: "蛋白質與蔬菜",
          items: [
            { name: "蝦子", preparation: "去殼去腸泥" },
            { name: "蘑菇", preparation: "洋菇或草菇，對半切" },
            { name: "小番茄", preparation: "對半切" }
          ]
        },
        {
          name: "調味料",
          items: [
            { name: "魚露", preparation: nil },
            { name: "萊姆汁", preparation: "新鮮現榨" },
            { name: "泰式辣椒醬（冬蔭醬）", preparation: "或辣椒片" },
            { name: "新鮮香菜", preparation: "切碎，裝飾用" }
          ]
        }
      ],
      steps: [
        { instruction: "將雞高湯倒入大湯鍋中煮沸。" },
        { instruction: "加入香茅、南薑和泰國檸檬葉，小火燉煮5分鐘。" },
        { instruction: "加入蘑菇，燉煮3分鐘。" },
        { instruction: "加入蝦子，煮2-3分鐘至蝦子變成粉紅色。" },
        { instruction: "加入小番茄，煮1分鐘。" },
        { instruction: "拌入魚露、萊姆汁和辣椒醬。" },
        { instruction: "試味並調整調味料，湯應該呈現酸、辣、鮮的風味。" },
        { instruction: "盛入碗中，撒上新鮮香菜裝飾即可享用。" }
      ],
      equipment: ["大湯鍋"]
    },
    zh_cn: {
      name: "冬阴功汤",
      description: "泰国最著名的汤品，一道以香茅、南姜和青柠调味的芳香浓郁汤品。酸、辣、鲜的完美平衡搭配鲜嫩的虾仁，使这道深受喜爱的餐厅经典菜肴在家也能轻松复刻。",
      ingredient_groups: [
        {
          name: "汤底",
          items: [
            { name: "鸡汤", preparation: nil },
            { name: "香茅", preparation: "切成5厘米段，拍扁" },
            { name: "南姜", preparation: "切薄片" },
            { name: "泰国青柠叶", preparation: nil }
          ]
        },
        {
          name: "主料与蔬菜",
          items: [
            { name: "虾仁", preparation: "去壳去虾线" },
            { name: "蘑菇", preparation: "口蘑或草菇，对半切开" },
            { name: "圣女果", preparation: "对半切开" }
          ]
        },
        {
          name: "调味料",
          items: [
            { name: "鱼露", preparation: nil },
            { name: "青柠汁", preparation: "新鲜现榨" },
            { name: "冬阴功酱（泰式酸辣酱）", preparation: "或用辣椒碎代替" },
            { name: "香菜", preparation: "切碎，用于装饰" }
          ]
        }
      ],
      steps: [
        { instruction: "在大锅中将鸡汤煮沸。" },
        { instruction: "加入香茅、南姜和青柠叶，小火煮5分钟。" },
        { instruction: "加入蘑菇，继续煮3分钟。" },
        { instruction: "加入虾仁，煮2-3分钟至虾仁变粉红色。" },
        { instruction: "加入圣女果，煮1分钟。" },
        { instruction: "加入鱼露、青柠汁和冬阴功酱，搅拌均匀。" },
        { instruction: "试味并调整调料，汤品应呈现酸、辣、鲜的风味。" },
        { instruction: "盛入碗中，撒上香菜点缀即可。" }
      ],
      equipment: ["大汤锅"]
    },
    es: {
      name: "Tom Yum - Sopa Tailandesa Agripicante",
      description: "La sopa más famosa de Tailandia, un caldo aromático e intensamente sabroso infusionado con hierba limón, galangal y lima. El equilibrio perfecto entre notas picantes, ácidas y especiadas con tiernos langostinos la convierte en un clásico de restaurante muy querido que es sorprendentemente fácil de recrear en casa.",
      ingredient_groups: [
        {
          name: "Base del Caldo",
          items: [
            { name: "caldo de pollo", preparation: nil },
            { name: "lemongrass (hierba limón tailandesa)", preparation: "cortado en trozos de 5 cm, machacado" },
            { name: "galangal (jengibre tailandés)", preparation: "rodajas finas" },
            { name: "hojas de lima kaffir (hojas de lima tailandesa)", preparation: nil }
          ]
        },
        {
          name: "Proteína y Verduras",
          items: [
            { name: "langostinos", preparation: "pelados, desvenados" },
            { name: "champiñones", preparation: "champiñones blancos o de paja, cortados por la mitad" },
            { name: "tomates cherry", preparation: "cortados por la mitad" }
          ]
        },
        {
          name: "Condimentos",
          items: [
            { name: "salsa de pescado", preparation: nil },
            { name: "zumo de lima", preparation: "recién exprimido" },
            { name: "nam prik pao (pasta de chile tailandesa)", preparation: "o escamas de chile" },
            { name: "cilantro fresco", preparation: "picado, para decorar" }
          ]
        }
      ],
      steps: [
        { instruction: "Llevar el caldo de pollo a ebullición en una olla grande." },
        { instruction: "Añadir el lemongrass, el galangal y las hojas de lima kaffir. Cocinar a fuego lento durante 5 minutos." },
        { instruction: "Añadir los champiñones y cocinar a fuego lento durante 3 minutos." },
        { instruction: "Añadir los langostinos y cocinar durante 2-3 minutos hasta que estén rosados." },
        { instruction: "Añadir los tomates cherry y cocinar durante 1 minuto." },
        { instruction: "Incorporar la salsa de pescado, el zumo de lima y la pasta de chile." },
        { instruction: "Probar y ajustar los condimentos. La sopa debe ser picante, ácida y especiada." },
        { instruction: "Servir en cuencos con un cucharón y decorar con cilantro fresco." }
      ],
      equipment: ["Olla Grande"]
    },
    fr: {
      name: "Tom Yum",
      description: "La soupe la plus célèbre de Thaïlande, un bouillon aromatique aux saveurs intenses infusé de citronnelle, de galanga et de citron vert. L'équilibre parfait entre notes piquantes, acidulées et épicées, accompagnées de crevettes tendres, fait de ce plat un classique des restaurants étonnamment facile à reproduire chez soi.",
      ingredient_groups: [
        {
          name: "Base du bouillon",
          items: [
            { name: "bouillon de volaille", preparation: nil },
            { name: "citronnelle", preparation: "coupée en morceaux de 5 cm, écrasée" },
            { name: "galanga (rhizome thaïlandais cousin du gingembre)", preparation: "tranches fines" },
            { name: "feuilles de combava", preparation: nil }
          ]
        },
        {
          name: "Protéines et légumes",
          items: [
            { name: "crevettes", preparation: "décortiquées, déveinées" },
            { name: "champignons", preparation: "champignons de Paris ou champignons de paille, coupés en deux" },
            { name: "tomates cerises", preparation: "coupées en deux" }
          ]
        },
        {
          name: "Assaisonnements",
          items: [
            { name: "nuoc-mâm (sauce de poisson)", preparation: nil },
            { name: "jus de citron vert", preparation: "frais" },
            { name: "nam prik pao (pâte de piment thaïlandaise)", preparation: "ou flocons de piment" },
            { name: "coriandre fraîche", preparation: "ciselée, pour la garniture" }
          ]
        }
      ],
      steps: [
        { instruction: "Porter le bouillon de volaille à ébullition dans une grande marmite." },
        { instruction: "Ajouter la citronnelle, le galanga et les feuilles de combava. Laisser mijoter 5 minutes." },
        { instruction: "Ajouter les champignons et laisser mijoter 3 minutes." },
        { instruction: "Ajouter les crevettes et cuire 2 à 3 minutes jusqu'à ce qu'elles deviennent roses." },
        { instruction: "Ajouter les tomates cerises et cuire 1 minute." },
        { instruction: "Incorporer le nuoc-mâm, le jus de citron vert et la pâte de piment." },
        { instruction: "Goûter et rectifier l'assaisonnement. La soupe doit être piquante, acidulée et épicée." },
        { instruction: "Verser à la louche dans des bols et garnir de coriandre fraîche." }
      ],
      equipment: ["Grande marmite"]
    }
  },
  "Spaghetti Aglio e Olio" => {
    ja: {
      name: "スパゲッティ・アーリオ・オーリオ",
      description: "ローマを代表するパスタ料理で、パスタ、にんにく、オリーブオイル、唐辛子だけで作るシンプルな一品。良質な食材と適切な技術があれば、20分以内で忘れられない味わいを生み出せることを証明する傑作です。",
      ingredient_groups: [
        {
          name: "材料",
          items: [
            { name: "スパゲッティ", preparation: nil },
            { name: "にんにく", preparation: "薄切り" },
            { name: "エクストラバージンオリーブオイル", preparation: "良質なもの" },
            { name: "唐辛子フレーク（ペペロンチーノ）", preparation: "お好みで" },
            { name: "塩", preparation: "パスタの茹で汁用" }
          ]
        }
      ],
      steps: [
        { instruction: "大きな鍋にたっぷりの塩水を沸かし、スパゲッティをアルデンテに茹でる（約9〜10分）。" },
        { instruction: "パスタを茹でている間に、大きなフライパンにオリーブオイルを入れ、中火で温める。" },
        { instruction: "薄切りにしたにんにくをオイルに加え、頻繁にかき混ぜながら2〜3分かけてゆっくり火を通す。" },
        { instruction: "にんにくを焦がさないこと。きつね色になり香りが立ったら火から下ろす。" },
        { instruction: "にんにくオイルに唐辛子フレークを加え、混ぜ合わせる。" },
        { instruction: "パスタの湯を切り、茹で汁を1カップ取り置く。" },
        { instruction: "熱いパスタをにんにくオイルに加え、全体に絡める。なめらかになるよう、必要に応じて茹で汁を加える。" },
        { instruction: "温めた器にすぐに盛り付け、塩とこしょうで味を調える。" }
      ],
      equipment: ["大きな鍋", "大きなフライパン"]
    },
    ko: {
      name: "스파게티 알리오 올리오",
      description: "파스타, 마늘, 올리브 오일, 고춧가루만으로 만드는 상징적인 로마식 파스타 요리입니다. 이 미니멀리스트 걸작은 좋은 재료와 올바른 기술만으로 20분 이내에 잊을 수 없는 한 끼를 만들 수 있다는 것을 보여줍니다.",
      ingredient_groups: [
        {
          name: "재료",
          items: [
            { name: "스파게티", preparation: nil },
            { name: "마늘", preparation: "얇게 슬라이스" },
            { name: "엑스트라 버진 올리브 오일", preparation: "좋은 품질로" },
            { name: "고춧가루", preparation: "기호에 따라" },
            { name: "소금", preparation: "면수용" }
          ]
        }
      ],
      steps: [
        { instruction: "큰 냄비에 소금을 넣은 물을 끓입니다. 스파게티를 알덴테(약간 씹히는 정도)로 약 9-10분간 삶습니다." },
        { instruction: "파스타가 삶아지는 동안, 큰 프라이팬에 올리브 오일을 넣고 중불로 가열합니다." },
        { instruction: "슬라이스한 마늘을 오일에 넣습니다. 자주 저어가며 2-3분간 부드럽게 익힙니다." },
        { instruction: "마늘이 갈색으로 변하지 않도록 주의하세요. 황금빛이 나고 향이 나면 불에서 내립니다." },
        { instruction: "마늘 오일에 고춧가루를 넣고 잘 섞어줍니다." },
        { instruction: "파스타의 물을 빼고, 면수 1컵을 따로 남겨둡니다." },
        { instruction: "뜨거운 파스타를 마늘 오일에 넣습니다. 골고루 버무리면서 부드러운 질감을 위해 필요에 따라 면수를 추가합니다." },
        { instruction: "따뜻한 그릇에 바로 담아 냅니다. 기호에 따라 소금과 후추로 간을 합니다." }
      ],
      equipment: ["큰 냄비", "큰 프라이팬"]
    },
    zh_tw: {
      name: "蒜香辣椒義大利麵",
      description: "這是一道經典的羅馬義大利麵，僅使用義大利麵、大蒜、橄欖油和辣椒片。這道極簡主義的傑作展現了如何用優質食材和適當技巧，在20分鐘內創造出令人難忘的美味。",
      ingredient_groups: [
        {
          name: "食材",
          items: [
            { name: "義大利直麵（Spaghetti）", preparation: nil },
            { name: "大蒜", preparation: "切薄片" },
            { name: "特級初榨橄欖油", preparation: "品質優良的" },
            { name: "辣椒片", preparation: "適量" },
            { name: "鹽", preparation: "煮麵水用" }
          ]
        }
      ],
      steps: [
        { instruction: "取一大鍋加入鹽水煮沸。放入義大利麵煮至彈牙（al dente），約9-10分鐘。" },
        { instruction: "煮麵的同時，在大平底鍋中以中火加熱橄欖油。" },
        { instruction: "將切片的大蒜放入油中，輕輕翻炒2-3分鐘，期間需頻繁攪拌。" },
        { instruction: "注意不要讓大蒜變焦。當大蒜呈金黃色且散發香氣時，將鍋子離火。" },
        { instruction: "將辣椒片加入蒜油中，攪拌均勻。" },
        { instruction: "將義大利麵瀝乾，保留1杯煮麵水。" },
        { instruction: "將熱騰騰的義大利麵加入蒜油中，翻拌均勻使麵條裹上油脂，視需要加入煮麵水使口感更滑順。" },
        { instruction: "立即盛入溫熱的碗中上桌。依個人口味以鹽和胡椒調味。" }
      ],
      equipment: ["大湯鍋", "大平底鍋"]
    },
    zh_cn: {
      name: "蒜香辣椒意大利面",
      description: "一道经典的罗马意大利面，仅用意大利面、大蒜、橄榄油和红辣椒片制作而成。这道极简主义杰作展示了优质食材与精湛技艺如何在20分钟内创造出令人难忘的美味。",
      ingredient_groups: [
        {
          name: "食材",
          items: [
            { name: "意大利面（spaghetti，细长条形意大利面）", preparation: nil },
            { name: "大蒜", preparation: "切薄片" },
            { name: "特级初榨橄榄油", preparation: "优质" },
            { name: "红辣椒片", preparation: "适量" },
            { name: "盐", preparation: "用于煮面水" }
          ]
        }
      ],
      steps: [
        { instruction: "取一大锅加盐的水烧开。将意大利面煮至有嚼劲（al dente），约9-10分钟。" },
        { instruction: "在煮面的同时，用大煎锅以中火加热橄榄油。" },
        { instruction: "将蒜片放入油中，小火慢煎2-3分钟，期间经常翻动。" },
        { instruction: "注意不要让大蒜变焦。当蒜片呈金黄色且散发香气时离火。" },
        { instruction: "将红辣椒片加入蒜油中，搅拌均匀。" },
        { instruction: "沥干意大利面，保留1杯煮面水。" },
        { instruction: "将热意大利面加入蒜油中，翻拌均匀使其裹上油脂，根据需要添加煮面水以增加顺滑度。" },
        { instruction: "立即盛入预热的碗中。根据口味加盐和胡椒调味。" }
      ],
      equipment: ["大锅", "大煎锅"]
    },
    es: {
      name: "Spaghetti Aglio e Olio",
      description: "Un icónico plato de pasta romano que combina simplemente pasta, ajo, aceite de oliva y hojuelas de chile. Esta obra maestra minimalista demuestra cómo ingredientes de calidad y una técnica adecuada pueden crear una comida inolvidable en menos de 20 minutos.",
      ingredient_groups: [
        {
          name: "Ingredientes",
          items: [
            { name: "espaguetis", preparation: nil },
            { name: "ajo", preparation: "cortado en láminas finas" },
            { name: "aceite de oliva virgen extra", preparation: "de buena calidad" },
            { name: "hojuelas de chile rojo", preparation: "al gusto" },
            { name: "sal", preparation: "para el agua de la pasta" }
          ]
        }
      ],
      steps: [
        { instruction: "Poner a hervir una olla grande con agua salada. Cocinar los espaguetis hasta que estén al dente, aproximadamente 9-10 minutos." },
        { instruction: "Mientras se cocina la pasta, calentar el aceite de oliva en una sartén grande a fuego medio." },
        { instruction: "Añadir el ajo laminado al aceite. Cocinar suavemente durante 2-3 minutos, removiendo con frecuencia." },
        { instruction: "No dejar que el ajo se dore demasiado. Retirar del fuego cuando esté dorado y aromático." },
        { instruction: "Añadir las hojuelas de chile al aceite con ajo. Mezclar bien." },
        { instruction: "Escurrir la pasta, reservando 1 taza del agua de cocción." },
        { instruction: "Añadir la pasta caliente al aceite con ajo. Mezclar bien para que se impregne, añadiendo agua de la pasta según sea necesario para lograr una textura sedosa." },
        { instruction: "Servir inmediatamente en platos hondos calientes. Sazonar con sal y pimienta al gusto." }
      ],
      equipment: ["Olla grande", "Sartén grande"]
    },
    fr: {
      name: "Spaghetti Aglio e Olio",
      description: "Un plat de pâtes romain emblématique composé simplement de pâtes, d'ail, d'huile d'olive et de piment. Ce chef-d'œuvre minimaliste démontre comment des ingrédients de qualité et une technique appropriée peuvent créer un repas inoubliable en moins de 20 minutes.",
      ingredient_groups: [
        {
          name: "Ingrédients",
          items: [
            { name: "spaghetti", preparation: nil },
            { name: "ail", preparation: "émincé finement" },
            { name: "huile d'olive vierge extra", preparation: "de bonne qualité" },
            { name: "piment rouge en flocons", preparation: "selon le goût" },
            { name: "sel", preparation: "pour l'eau de cuisson des pâtes" }
          ]
        }
      ],
      steps: [
        { instruction: "Porter une grande casserole d'eau salée à ébullition. Faire cuire les spaghetti al dente, environ 9-10 minutes." },
        { instruction: "Pendant la cuisson des pâtes, faire chauffer l'huile d'olive dans une grande poêle à feu moyen." },
        { instruction: "Ajouter l'ail émincé dans l'huile. Faire revenir doucement pendant 2-3 minutes en remuant fréquemment." },
        { instruction: "Ne pas laisser l'ail brunir. Retirer du feu lorsqu'il est doré et parfumé." },
        { instruction: "Ajouter le piment en flocons à l'huile à l'ail. Mélanger pour bien incorporer." },
        { instruction: "Égoutter les pâtes en réservant une tasse d'eau de cuisson." },
        { instruction: "Ajouter les pâtes chaudes à l'huile à l'ail. Mélanger pour bien enrober, en ajoutant de l'eau de cuisson si nécessaire pour obtenir une texture soyeuse." },
        { instruction: "Servir immédiatement dans des assiettes creuses chaudes. Assaisonner de sel et de poivre selon le goût." }
      ],
      equipment: ["Grande casserole", "Grande poêle"]
    }
  },
  "Oyakodon" => {
    ja: {
      name: "親子丼",
      description: "日本の定番家庭料理。柔らかい鶏肉とふんわり半熟の卵を、出汁の効いた甘辛い煮汁でとじ、熱々のご飯の上にのせた一品。「親子」という名前は鶏肉と卵の組み合わせに由来し、心も体も温まる満足感のある料理です。",
      ingredient_groups: [
        {
          name: "主な材料",
          items: [
            { name: "鶏もも肉", preparation: "骨なし・皮なし、一口大に切る" },
            { name: "卵", preparation: "溶きほぐす" },
            { name: "玉ねぎ", preparation: "薄切り" }
          ]
        },
        {
          name: "煮汁",
          items: [
            { name: "出汁", preparation: nil },
            { name: "醤油", preparation: nil },
            { name: "みりん", preparation: nil },
            { name: "酒", preparation: nil }
          ]
        },
        {
          name: "仕上げ用",
          items: [
            { name: "ご飯", preparation: "炊きたて、温かいもの" },
            { name: "小ねぎ", preparation: "小口切り" }
          ]
        }
      ],
      steps: [
        { instruction: "小さなボウルに出汁、醤油、みりん、酒を合わせておく。" },
        { instruction: "親子鍋または中くらいのフライパンを中強火で熱する。" },
        { instruction: "玉ねぎを入れ、しんなりするまで約2分炒める。" },
        { instruction: "鶏肉を加え、時々混ぜながら3〜4分炒める。" },
        { instruction: "合わせた煮汁を注ぎ入れ、鶏肉に火が通るまで約3分煮る。" },
        { instruction: "溶き卵を回し入れながら、菜箸で軽くかき混ぜる。" },
        { instruction: "約30秒、卵が固まりかけて少しとろっとした状態になるまで加熱する。火を通しすぎないこと。" },
        { instruction: "丼にご飯を盛り、鶏肉と卵をのせる。" },
        { instruction: "小ねぎを散らし、熱いうちにすぐ召し上がれ。" }
      ],
      equipment: ["親子鍋またはフライパン", "炊飯器"]
    },
    ko: {
      name: "오야코동",
      description: "부드러운 닭고기와 부드럽게 익힌 달걀을 감칠맛 나는 다시 국물과 함께 따끈한 밥 위에 올린 일본의 대표적인 가정식입니다. '오야코'는 부모와 자식을 의미하며, 닭고기와 달걀의 조합을 뜻하는 이름으로 마음까지 따뜻해지는 한 그릇 요리입니다.",
      ingredient_groups: [
        {
          name: "주재료",
          items: [
            { name: "닭다리살", preparation: "뼈와 껍질 제거, 한입 크기로 썰기" },
            { name: "달걀", preparation: "풀어두기" },
            { name: "양파", preparation: "얇게 채 썰기" }
          ]
        },
        {
          name: "소스",
          items: [
            { name: "다시 육수", preparation: nil },
            { name: "간장", preparation: nil },
            { name: "미림 (일본 맛술)", preparation: nil },
            { name: "사케 (일본 청주)", preparation: nil }
          ]
        },
        {
          name: "마무리 재료",
          items: [
            { name: "밥", preparation: "따뜻하게 갓 지은 것" },
            { name: "쪽파", preparation: "송송 썰기" }
          ]
        }
      ],
      steps: [
        { instruction: "작은 볼에 다시 육수, 간장, 미림, 사케를 넣고 섞어주세요." },
        { instruction: "중간 크기의 프라이팬이나 덮밥용 팬을 중강 불에 올려 달궈주세요." },
        { instruction: "채 썬 양파를 넣고 2분간 부드러워질 때까지 볶아주세요." },
        { instruction: "닭고기를 넣고 가끔 저어가며 3-4분간 볶아주세요." },
        { instruction: "소스를 부어주세요. 닭고기가 완전히 익을 때까지 3분간 끓여주세요." },
        { instruction: "풀어둔 달걀을 닭고기 위에 천천히 골고루 부으면서 살살 저어주세요." },
        { instruction: "달걀이 막 익되 약간 촉촉함이 남을 때까지 30초간 익혀주세요. 너무 익히지 마세요." },
        { instruction: "그릇에 따뜻한 밥을 담고, 그 위에 닭고기와 달걀을 올려주세요." },
        { instruction: "송송 썬 쪽파로 장식하고, 따뜻할 때 바로 드세요." }
      ],
      equipment: ["덮밥용 팬 또는 프라이팬", "밥솥"]
    },
    zh_tw: {
      name: "親子丼",
      description: "親子丼是日本經典的家常料理，以軟嫩的雞肉和滑嫩的半熟蛋，淋在熱騰騰的白飯上，搭配鮮美的高湯醬汁。「親子」之名來自雞肉與雞蛋的組合，象徵著母子之情，是一道溫暖人心的療癒美食。",
      ingredient_groups: [
        {
          name: "主要食材",
          items: [
            { name: "去骨雞腿肉", preparation: "去皮，切成一口大小" },
            { name: "雞蛋", preparation: "打散" },
            { name: "洋蔥", preparation: "切薄片" }
          ]
        },
        {
          name: "醬汁",
          items: [
            { name: "高湯（日式柴魚昆布高湯）", preparation: nil },
            { name: "醬油", preparation: nil },
            { name: "味醂（日式甜料理酒）", preparation: nil },
            { name: "清酒（日本料理酒）", preparation: nil }
          ]
        },
        {
          name: "盛盤配料",
          items: [
            { name: "白飯", preparation: "熱的，剛蒸好" },
            { name: "青蔥", preparation: "切蔥花" }
          ]
        }
      ],
      steps: [
        { instruction: "將高湯、醬油、味醂和清酒在小碗中混合均勻。" },
        { instruction: "取一個中型平底鍋或丼飯專用鍋，以中大火加熱。" },
        { instruction: "放入洋蔥片，拌炒約2分鐘至軟化。" },
        { instruction: "加入雞肉塊，翻炒3-4分鐘，期間不時攪拌。" },
        { instruction: "倒入調好的醬汁，燉煮約3分鐘直到雞肉完全熟透。" },
        { instruction: "將打散的蛋液均勻淋在雞肉上，同時輕輕攪動。" },
        { instruction: "煮約30秒，讓蛋液剛剛凝固但仍保持滑嫩濕潤的狀態。切勿煮過熟。" },
        { instruction: "將熱騰騰的白飯盛入碗中，把雞肉蛋液淋在飯上。" },
        { instruction: "撒上蔥花點綴，趁熱立即享用。" }
      ],
      equipment: ["丼飯鍋或平底鍋", "電鍋"]
    },
    es: {
      name: "Oyakodon",
      description: "Un reconfortante plato japonés muy querido que consiste en tierno pollo y huevos sedosos escalfados servidos sobre arroz humeante en un sabroso caldo dashi. El nombre 'oyako' significa padre e hijo, refiriéndose a la combinación de pollo y huevo, haciendo de este un plato que reconforta el alma.",
      ingredient_groups: [
        {
          name: "Ingredientes Principales",
          items: [
            { name: "contramuslo de pollo", preparation: "deshuesado, sin piel, cortado en trozos pequeños" },
            { name: "huevos", preparation: "batidos" },
            { name: "cebolla", preparation: "cortada en rodajas finas" }
          ]
        },
        {
          name: "Salsa",
          items: [
            { name: "dashi (caldo japonés a base de alga kombu y bonito seco)", preparation: nil },
            { name: "salsa de soja", preparation: nil },
            { name: "mirin (vino de arroz dulce japonés)", preparation: nil },
            { name: "sake (vino de arroz japonés)", preparation: nil }
          ]
        },
        {
          name: "Para Servir",
          items: [
            { name: "arroz cocido", preparation: "caliente, al vapor" },
            { name: "cebolleta", preparation: "cortada en rodajas finas" }
          ]
        }
      ],
      steps: [
        { instruction: "Mezclar el caldo dashi, la salsa de soja, el mirin y el sake en un bol pequeño." },
        { instruction: "Calentar una sartén mediana o una sartén donburi a fuego medio-alto." },
        { instruction: "Añadir la cebolla en rodajas y cocinar durante 2 minutos hasta que esté tierna." },
        { instruction: "Añadir los trozos de pollo y cocinar durante 3-4 minutos, removiendo ocasionalmente." },
        { instruction: "Verter la mezcla de salsa. Cocinar a fuego lento durante 3 minutos hasta que el pollo esté completamente cocido." },
        { instruction: "Verter los huevos batidos sobre el pollo en un chorro constante mientras se remueve suavemente." },
        { instruction: "Cocinar durante 30 segundos hasta que los huevos estén apenas cuajados pero aún ligeramente húmedos. No cocinar en exceso." },
        { instruction: "Colocar el arroz caliente en un bol. Verter la mezcla de pollo y huevo sobre el arroz." },
        { instruction: "Decorar con la cebolleta en rodajas. Servir inmediatamente mientras esté caliente." }
      ],
      equipment: ["Sartén Donburi o Sartén", "Arrocera"]
    },
    fr: {
      name: "Oyakodon",
      description: "Un plat réconfortant japonais très apprécié, composé de poulet tendre et d'œufs pochés soyeux servis sur du riz fumant dans un bouillon savoureux au dashi. Le nom 'oyako' signifie parent et enfant, en référence à la combinaison poulet et œuf, ce qui en fait un repas nourrissant pour l'âme.",
      ingredient_groups: [
        {
          name: "Ingrédients principaux",
          items: [
            { name: "haut de cuisse de poulet", preparation: "désossé, sans peau, coupé en morceaux" },
            { name: "œufs", preparation: "battus" },
            { name: "oignon", preparation: "émincé" }
          ]
        },
        {
          name: "Sauce",
          items: [
            { name: "dashi (bouillon japonais à base d'algues et de bonite)", preparation: nil },
            { name: "sauce soja", preparation: nil },
            { name: "mirin (vin de riz doux japonais)", preparation: nil },
            { name: "saké (alcool de riz japonais)", preparation: nil }
          ]
        },
        {
          name: "Pour servir",
          items: [
            { name: "riz cuit", preparation: "chaud, cuit à la vapeur" },
            { name: "ciboule", preparation: "émincée" }
          ]
        }
      ],
      steps: [
        { instruction: "Mélanger le dashi, la sauce soja, le mirin et le saké dans un petit bol." },
        { instruction: "Faire chauffer une poêle moyenne ou une poêle à donburi à feu moyen-vif." },
        { instruction: "Ajouter l'oignon émincé et faire revenir pendant 2 minutes jusqu'à ce qu'il soit ramolli." },
        { instruction: "Ajouter les morceaux de poulet et faire cuire 3-4 minutes en remuant de temps en temps." },
        { instruction: "Verser le mélange de sauce. Laisser mijoter 3 minutes jusqu'à ce que le poulet soit bien cuit." },
        { instruction: "Verser les œufs battus sur le poulet en un filet régulier tout en remuant délicatement." },
        { instruction: "Faire cuire 30 secondes jusqu'à ce que les œufs soient juste pris mais encore légèrement baveux. Ne pas trop cuire." },
        { instruction: "Disposer le riz chaud dans un bol. Verser le mélange poulet-œufs sur le riz." },
        { instruction: "Garnir de ciboule émincée. Servir immédiatement bien chaud." }
      ],
      equipment: ["Poêle à donburi ou poêle classique", "Cuiseur à riz"]
    },
    zh_cn: {
      name: "亲子丼",
      description: "一道深受喜爱的日式家常料理，由鲜嫩的鸡肉和滑嫩的半熟鸡蛋覆盖在热腾腾的米饭上，浸润在鲜美的高汤中。'亲子'在日语中意为父母与孩子，指的是鸡肉与鸡蛋的组合，是一道温暖人心的美食。",
      ingredient_groups: [
        {
          name: "主料",
          items: [
            { name: "鸡腿肉", preparation: "去骨去皮，切成一口大小" },
            { name: "鸡蛋", preparation: "打散" },
            { name: "洋葱", preparation: "切薄片" }
          ]
        },
        {
          name: "酱汁",
          items: [
            { name: "出汁（日式高汤）", preparation: nil },
            { name: "酱油", preparation: nil },
            { name: "味淋（日式甜料酒）", preparation: nil },
            { name: "清酒", preparation: nil }
          ]
        },
        {
          name: "配餐",
          items: [
            { name: "米饭", preparation: "热的，蒸熟的" },
            { name: "小葱", preparation: "切葱花" }
          ]
        }
      ],
      steps: [
        { instruction: "将出汁、酱油、味淋和清酒在小碗中混合均匀。" },
        { instruction: "用中大火加热中号平底锅或亲子丼专用锅。" },
        { instruction: "放入洋葱片，翻炒约2分钟至变软。" },
        { instruction: "加入鸡肉块，翻炒3-4分钟，偶尔搅拌。" },
        { instruction: "倒入调好的酱汁，小火煮3分钟，直到鸡肉完全熟透。" },
        { instruction: "将打散的蛋液均匀地淋在鸡肉上，同时轻轻搅动。" },
        { instruction: "煮约30秒，直到鸡蛋刚刚凝固但仍带有少许湿润感。切勿煮过头。" },
        { instruction: "将热米饭盛入碗中，把鸡肉蛋液浇在米饭上。" },
        { instruction: "撒上葱花点缀，趁热立即享用。" }
      ],
      equipment: ["亲子丼专用锅或平底锅", "电饭煲"]
    }
  },
  "Greek Salad" => {
    ja: {
      name: "グリークサラダ",
      description: "シャキシャキの野菜、クリーミーなフェタチーズ、塩気のあるカラマタオリーブを、シンプルなオリーブオイルとオレガノのドレッシングで和えた、鮮やかな地中海の定番料理です。夏の爽やかさとギリシャ料理の真髄を楽しめるサラダです。",
      ingredient_groups: [
        {
          name: "サラダ",
          items: [
            { name: "トマト", preparation: "一口大に切る" },
            { name: "きゅうり", preparation: "角切りにする" },
            { name: "赤たまねぎ", preparation: "薄切りにする" },
            { name: "カラマタオリーブ（ギリシャ産の黒オリーブ）", preparation: nil },
            { name: "フェタチーズ（ギリシャの白い羊乳チーズ）", preparation: "崩す" }
          ]
        },
        {
          name: "ドレッシング",
          items: [
            { name: "エクストラバージンオリーブオイル", preparation: nil },
            { name: "赤ワインビネガー", preparation: nil },
            { name: "オレガノ", preparation: "乾燥" },
            { name: "塩こしょう", preparation: "適量" }
          ]
        }
      ],
      steps: [
        { instruction: "大きなボウルにトマト、きゅうり、赤たまねぎを入れて合わせます。" },
        { instruction: "カラマタオリーブを加え、やさしく混ぜ合わせます。" },
        { instruction: "小さなボウルにオリーブオイル、赤ワインビネガー、オレガノ、塩こしょうを入れてよく混ぜ合わせます。" },
        { instruction: "ドレッシングをサラダにかけ、やさしく全体を和えます。" },
        { instruction: "食べる直前に崩したフェタチーズをのせて完成です。" }
      ],
      equipment: ["まな板", "大きなボウル"]
    },
    zh_tw: {
      name: "希臘沙拉",
      description: "一道充滿活力的地中海經典料理，結合爽脆的蔬菜、綿密的菲達起司和鹹香的卡拉馬塔橄欖，佐以簡單的橄欖油和奧勒岡調味。這道清爽的沙拉完美展現夏日風情與希臘料理的精髓。",
      ingredient_groups: [
        {
          name: "沙拉",
          items: [
            { name: "番茄", preparation: "切塊" },
            { name: "小黃瓜", preparation: "切丁" },
            { name: "紅洋蔥", preparation: "切薄片" },
            { name: "卡拉馬塔橄欖（希臘黑橄欖）", preparation: nil },
            { name: "菲達起司（希臘羊奶白起司）", preparation: "捏碎" }
          ]
        },
        {
          name: "醬汁",
          items: [
            { name: "特級初榨橄欖油", preparation: nil },
            { name: "紅酒醋", preparation: nil },
            { name: "奧勒岡（披薩草）", preparation: "乾燥" },
            { name: "鹽和胡椒", preparation: "適量" }
          ]
        }
      ],
      steps: [
        { instruction: "將番茄、小黃瓜和紅洋蔥放入大碗中混合。" },
        { instruction: "加入卡拉馬塔橄欖，輕輕拌勻。" },
        { instruction: "在小碗中將橄欖油、紅酒醋、奧勒岡、鹽和胡椒攪拌均勻。" },
        { instruction: "將醬汁淋在沙拉上，輕輕拌勻。" },
        { instruction: "上桌前撒上捏碎的菲達起司。" }
      ],
      equipment: ["砧板", "大碗"]
    },
    fr: {
      name: "Salade grecque",
      description: "Un grand classique méditerranéen associant des légumes croquants, de la feta crémeuse et des olives de Kalamata saumurées, le tout assaisonné d'une simple vinaigrette à l'huile d'olive et à l'origan. Cette salade rafraîchissante célèbre l'essence de l'été et de la cuisine grecque.",
      ingredient_groups: [
        {
          name: "Salade",
          items: [
            { name: "tomates", preparation: "coupées en morceaux" },
            { name: "concombres", preparation: "coupés en dés" },
            { name: "oignon rouge", preparation: "émincé finement" },
            { name: "olives de Kalamata", preparation: nil },
            { name: "feta", preparation: "émiettée" }
          ]
        },
        {
          name: "Vinaigrette",
          items: [
            { name: "huile d'olive extra vierge", preparation: nil },
            { name: "vinaigre de vin rouge", preparation: nil },
            { name: "origan", preparation: "séché" },
            { name: "sel et poivre", preparation: "selon le goût" }
          ]
        }
      ],
      steps: [
        { instruction: "Dans un grand saladier, mélanger les tomates, les concombres et l'oignon rouge." },
        { instruction: "Ajouter les olives de Kalamata et mélanger délicatement." },
        { instruction: "Dans un petit bol, fouetter ensemble l'huile d'olive, le vinaigre de vin rouge, l'origan, le sel et le poivre." },
        { instruction: "Verser la vinaigrette sur la salade et mélanger délicatement." },
        { instruction: "Parsemer de feta émiettée juste avant de servir." }
      ],
      equipment: ["Planche à découper", "Grand saladier"]
    },
    ko: {
      name: "그리스 샐러드",
      description: "신선한 채소, 크리미한 페타 치즈, 짭짤한 칼라마타 올리브를 올리브 오일과 오레가노 드레싱으로 버무린 활기 넘치는 지중해 요리의 정수입니다. 여름의 싱그러움과 그리스 요리의 진수를 담은 상큼한 샐러드입니다.",
      ingredient_groups: [
        {
          name: "샐러드",
          items: [
            { name: "토마토", preparation: "큼직하게 썬 것" },
            { name: "오이", preparation: "깍둑썰기" },
            { name: "적양파", preparation: "얇게 썬 것" },
            { name: "칼라마타 올리브 (그리스산 검은 올리브)", preparation: nil },
            { name: "페타 치즈 (그리스 염소젖 치즈)", preparation: "부순 것" }
          ]
        },
        {
          name: "드레싱",
          items: [
            { name: "엑스트라 버진 올리브 오일", preparation: nil },
            { name: "레드 와인 식초", preparation: nil },
            { name: "오레가노", preparation: "건조" },
            { name: "소금과 후추", preparation: "기호에 맞게" }
          ]
        }
      ],
      steps: [
        { instruction: "큰 볼에 토마토, 오이, 적양파를 넣고 섞습니다." },
        { instruction: "칼라마타 올리브를 넣고 가볍게 버무립니다." },
        { instruction: "작은 볼에 올리브 오일, 레드 와인 식초, 오레가노, 소금, 후추를 넣고 잘 섞어 드레싱을 만듭니다." },
        { instruction: "샐러드 위에 드레싱을 뿌리고 가볍게 버무립니다." },
        { instruction: "서빙 직전에 부순 페타 치즈를 위에 올립니다." }
      ],
      equipment: ["도마", "큰 볼"]
    },
    zh_cn: {
      name: "希腊沙拉",
      description: "这道充满活力的地中海经典美食，将爽脆的蔬菜、奶香浓郁的菲达奶酪和咸鲜的卡拉马塔橄榄混合在一起，淋上简单的橄榄油和牛至调味汁。这道清爽的沙拉完美诠释了夏日的美好和希腊美食的精髓。",
      ingredient_groups: [
        {
          name: "沙拉",
          items: [
            { name: "番茄", preparation: "切成块" },
            { name: "黄瓜", preparation: "切丁" },
            { name: "紫洋葱", preparation: "切成薄片" },
            { name: "卡拉马塔橄榄（希腊黑橄榄）", preparation: nil },
            { name: "菲达奶酪（希腊羊奶白奶酪）", preparation: "捏碎" }
          ]
        },
        {
          name: "调味汁",
          items: [
            { name: "特级初榨橄榄油", preparation: nil },
            { name: "红酒醋", preparation: nil },
            { name: "牛至（又称披萨草）", preparation: "干燥的" },
            { name: "盐和胡椒粉", preparation: "适量" }
          ]
        }
      ],
      steps: [
        { instruction: "将番茄、黄瓜和紫洋葱放入一个大碗中混合。" },
        { instruction: "加入卡拉马塔橄榄，轻轻拌匀。" },
        { instruction: "在一个小碗中，将橄榄油、红酒醋、牛至、盐和胡椒粉搅拌均匀。" },
        { instruction: "将调味汁淋在沙拉上，轻轻拌匀。" },
        { instruction: "上桌前撒上捏碎的菲达奶酪。" }
      ],
      equipment: ["砧板", "大碗"]
    },
    es: {
      name: "Ensalada Griega",
      description: "Un vibrante clásico mediterráneo que combina vegetales crujientes, queso feta cremoso y aceitunas Kalamata saladas, todo aderezado con un sencillo aliño de aceite de oliva y orégano. Esta refrescante ensalada celebra la esencia del verano y la cocina griega.",
      ingredient_groups: [
        {
          name: "Ensalada",
          items: [
            { name: "tomates", preparation: "cortados en trozos" },
            { name: "pepinos", preparation: "en cubos" },
            { name: "cebolla morada", preparation: "en rodajas finas" },
            { name: "aceitunas Kalamata (variedad griega de color morado oscuro)", preparation: nil },
            { name: "queso feta (queso griego de leche de oveja)", preparation: "desmenuzado" }
          ]
        },
        {
          name: "Aliño",
          items: [
            { name: "aceite de oliva virgen extra", preparation: nil },
            { name: "vinagre de vino tinto", preparation: nil },
            { name: "orégano", preparation: "seco" },
            { name: "sal y pimienta", preparation: "al gusto" }
          ]
        }
      ],
      steps: [
        { instruction: "Combina los tomates, los pepinos y la cebolla morada en un bol grande." },
        { instruction: "Añade las aceitunas Kalamata y mezcla suavemente." },
        { instruction: "En un bol pequeño, bate el aceite de oliva, el vinagre de vino tinto, el orégano, la sal y la pimienta." },
        { instruction: "Vierte el aliño sobre la ensalada y mezcla suavemente para integrar." },
        { instruction: "Corona con el queso feta desmenuzado justo antes de servir." }
      ],
      equipment: ["Tabla de cortar", "Bol grande"]
    }
  },
  "Sourdough Bread" => {
    ja: {
      name: "サワードウブレッド",
      description: "長時間発酵と丁寧な技法により、独特の酸味と美しい気泡構造を持つ素朴なアルチザンパン。週末のプロジェクトとして、市販のパンでは味わえない素晴らしい風味と食感を楽しめます。",
      ingredient_groups: [
        {
          name: "生地",
          items: [
            { name: "強力粉", preparation: "タイプ00またはタンパク質含有量の高いもの" },
            { name: "水", preparation: "浄水、常温" },
            { name: "サワードウスターター（天然酵母種）", preparation: "元気な状態、加水率100%" },
            { name: "塩", preparation: "細粒の海塩" }
          ]
        }
      ],
      steps: [
        { instruction: "強力粉と水を混ぜ合わせる。30分休ませる（オートリーズ）、粉が十分に水分を吸収するまで。" },
        { instruction: "サワードウスターターと塩を加える。完全に混ざるまでこねる。" },
        { instruction: "30分ごとにストレッチ＆フォールド（生地を伸ばして折りたたむ）を行い、2時間続ける。ボウルにふんわりとラップをかける。" },
        { instruction: "室温（20-22℃）で4〜6時間一次発酵させ、生地が2倍になるまで待つ。" },
        { instruction: "打ち粉をした台に生地を取り出す。丸く成形する。20分休ませる。" },
        { instruction: "最終成形として、生地を手前に引きながら回転させ、表面が張るまで続ける。" },
        { instruction: "バヌトン（発酵かご）に綴じ目を上にして入れる。冷蔵庫で8〜16時間低温発酵させる。" },
        { instruction: "ダッチオーブンを入れたオーブンを260℃（500°F）に予熱し、30分温める。" },
        { instruction: "よく切れるナイフで生地にクープ（切り込み）を入れる。蓋をして20分焼く。" },
        { instruction: "蓋を外し、さらに25分焼いて濃いきつね色になるまで焼き上げる。" }
      ],
      equipment: ["ダッチオーブン（鋳鉄鍋）", "バヌトン（発酵かご）", "パン切りナイフ"]
    },
    ko: {
      name: "사워도우 브레드",
      description: "느린 발효와 세심한 기술을 통해 톡 쏘는 풍미와 아름다운 기공 구조를 가진 소박한 장인 빵입니다. 주말에 시간을 들여 만들면 시판 빵으로는 결코 얻을 수 없는 놀라운 맛과 식감을 선사합니다.",
      ingredient_groups: [
        {
          name: "반죽",
          items: [
            { name: "강력분", preparation: "타입 00 또는 고단백 밀가루" },
            { name: "물", preparation: "정수, 실온" },
            { name: "사워도우 스타터 (천연 발효종)", preparation: "활성화된 상태, 100% 수분율" },
            { name: "소금", preparation: "고운 천일염" }
          ]
        }
      ],
      steps: [
        { instruction: "밀가루와 물을 섞습니다. 수분이 충분히 흡수될 때까지 30분간 휴지합니다 (오토리즈)." },
        { instruction: "사워도우 스타터와 소금을 넣고 완전히 섞일 때까지 혼합합니다." },
        { instruction: "2시간 동안 30분 간격으로 스트레치 앤 폴드(반죽을 잡아당겨 접기)를 합니다. 볼을 느슨하게 덮어둡니다." },
        { instruction: "실온(20-22°C)에서 반죽이 두 배로 부풀 때까지 4-6시간 1차 발효합니다." },
        { instruction: "반죽을 밀가루 뿌린 작업대에 올립니다. 둥글게 예비 성형한 후 20분간 휴지합니다." },
        { instruction: "반죽을 몸 쪽으로 당기며 회전시켜 표면이 팽팽해질 때까지 최종 성형합니다." },
        { instruction: "바네통(발효 바구니)에 이음새가 위로 오도록 넣습니다. 냉장고에서 8-16시간 저온 숙성합니다." },
        { instruction: "더치 오븐(무쇠 냄비)을 넣은 상태로 오븐을 260°C(500°F)로 30분간 예열합니다." },
        { instruction: "날카로운 칼로 반죽에 칼집을 냅니다. 뚜껑을 덮고 20분간 굽습니다." },
        { instruction: "뚜껑을 열고 진한 황금빛 갈색이 될 때까지 25분간 더 굽습니다." }
      ],
      equipment: ["더치 오븐 (무쇠 냄비)", "바네통 (발효 바구니)", "빵 칼"]
    },
    zh_tw: {
      name: "酸種麵包",
      description: "這是一款帶有微酸風味和漂亮開放氣孔結構的手工鄉村麵包，透過長時間發酵和細心的技巧製作而成。這個週末烘焙計畫需要耐心等待，但能獲得商業麵包無法比擬的絕佳風味和口感。",
      ingredient_groups: [
        {
          name: "麵糰",
          items: [
            { name: "高筋麵粉", preparation: "Type 00 或高蛋白質含量" },
            { name: "水", preparation: "過濾水，室溫" },
            { name: "酸種starter（活躍的酸種酵母）", preparation: "活躍狀態，100%水合率" },
            { name: "鹽", preparation: "細海鹽" }
          ]
        }
      ],
      steps: [
        { instruction: "將麵粉和水混合，靜置30分鐘進行水合（autolyse自解），直到完全吸收水分。" },
        { instruction: "加入酸種酵母和鹽，攪拌至完全混合均勻。" },
        { instruction: "每隔30分鐘進行一次拉折（stretch and fold），持續2小時。用保鮮膜或蓋子輕輕覆蓋麵糰。" },
        { instruction: "在室溫（20-22°C）下進行基礎發酵4-6小時，直到麵糰體積膨脹至兩倍大。" },
        { instruction: "將麵糰倒在撒有麵粉的工作台上，預整形成圓形，靜置鬆弛20分鐘。" },
        { instruction: "進行最終整形：將麵糰向自己方向拉緊，同時旋轉，直到表面緊實光滑。" },
        { instruction: "將麵糰收口朝上放入發酵籃中，放入冰箱進行低溫冷藏發酵8-16小時。" },
        { instruction: "將烤箱連同鑄鐵鍋一起預熱至260°C（500°F），預熱30分鐘。" },
        { instruction: "用鋒利的刀在麵糰表面劃出割紋，蓋上鍋蓋烘烤20分鐘。" },
        { instruction: "取下鍋蓋，繼續烘烤25分鐘，直到表面呈現深金黃色。" }
      ],
      equipment: ["鑄鐵鍋（Dutch Oven，附蓋的厚底鍋）", "發酵籃（Banneton，藤編發酵籃）", "麵包刀"]
    },
    zh_cn: {
      name: "酸种面包",
      description: "这是一款质朴的手工面包，带有微酸的风味和漂亮的开放式气孔结构，通过缓慢发酵和精细的技巧来实现。这个周末项目会用令人难以置信的风味和口感来回报你的耐心，这是商业面包无法比拟的。",
      ingredient_groups: [
        {
          name: "面团",
          items: [
            { name: "高筋面粉", preparation: "意式00型粉或高蛋白面粉" },
            { name: "水", preparation: "过滤水，室温" },
            { name: "酸种（sourdough starter，天然酵母面种）", preparation: "活跃状态，100%水合率" },
            { name: "盐", preparation: "细海盐" }
          ]
        }
      ],
      steps: [
        { instruction: "将面粉和水混合。静置30分钟（水合法/autolyse），直到面粉充分吸水。" },
        { instruction: "加入酸种和盐，搅拌至完全混合均匀。" },
        { instruction: "每隔30分钟进行一次拉伸折叠，持续2小时。用盖子松松地盖住碗。" },
        { instruction: "在室温（20-22°C）下进行基础发酵4-6小时，直到面团体积翻倍。" },
        { instruction: "将面团倒在撒了面粉的操作台上。预整形成圆形，静置20分钟。" },
        { instruction: "最终整形：将面团向自己方向拉扯并旋转，直到表面紧实光滑。" },
        { instruction: "将面团收口朝上放入发酵篮（banneton）中。放入冰箱冷藏发酵8-16小时。" },
        { instruction: "将铸铁锅放入烤箱，预热至260°C（500°F），预热30分钟。" },
        { instruction: "用锋利的刀在面团表面割花。盖上锅盖烘烤20分钟。" },
        { instruction: "取下锅盖，继续烘烤25分钟，直到表面呈深金黄色。" }
      ],
      equipment: ["铸铁锅（Dutch Oven，带盖的厚底锅）", "发酵篮（Banneton，藤制面包发酵篮）", "面包刀"]
    },
    es: {
      name: "Pan de Masa Madre",
      description: "Un pan artesanal rústico con un sabor ácido característico y una miga abierta y hermosa, logrado mediante fermentación lenta y técnica cuidadosa. Este proyecto de fin de semana recompensa la paciencia con un sabor y textura increíbles que los panes comerciales no pueden igualar.",
      ingredient_groups: [
        {
          name: "Masa",
          items: [
            { name: "harina de fuerza", preparation: "Tipo 00 o alta en proteínas" },
            { name: "agua", preparation: "filtrada, a temperatura ambiente" },
            { name: "masa madre", preparation: "activa, hidratación al 100%" },
            { name: "sal", preparation: "sal marina fina" }
          ]
        }
      ],
      steps: [
        { instruction: "Mezclar la harina y el agua. Dejar reposar durante 30 minutos (autólisis) hasta que esté hidratada." },
        { instruction: "Añadir la masa madre y la sal. Mezclar hasta que estén completamente incorporadas." },
        { instruction: "Realizar pliegues cada 30 minutos durante 2 horas. Cubrir el bol holgadamente." },
        { instruction: "Fermentar en bloque a temperatura ambiente (20-22°C) durante 4-6 horas hasta que la masa duplique su tamaño." },
        { instruction: "Volcar la masa sobre una superficie enharinada. Preformar en forma redonda. Dejar reposar 20 minutos." },
        { instruction: "Formar definitivamente tirando la masa hacia ti y rotando, hasta que la superficie esté tensa." },
        { instruction: "Colocar en el banneton (cesto de fermentación) con el pliegue hacia arriba. Retardar en frío en la nevera durante 8-16 horas." },
        { instruction: "Precalentar el horno a 260°C con la olla de hierro fundido dentro durante 30 minutos." },
        { instruction: "Hacer cortes en la masa con un cuchillo afilado. Hornear tapado durante 20 minutos." },
        { instruction: "Retirar la tapa y hornear otros 25 minutos hasta que esté dorado intenso." }
      ],
      equipment: ["Olla de hierro fundido con tapa", "Banneton (cesto de fermentación)", "Cuchillo de pan"]
    },
    fr: {
      name: "Pain au levain",
      description: "Un pain artisanal rustique au goût légèrement acidulé et à la mie alvéolée, obtenu grâce à une fermentation lente et une technique soignée. Ce projet de week-end récompense la patience par une saveur et une texture incomparables que les pains industriels ne peuvent égaler.",
      ingredient_groups: [
        {
          name: "Pâte",
          items: [
            { name: "farine de blé T65", preparation: "ou farine de gruau riche en protéines" },
            { name: "eau", preparation: "filtrée, à température ambiante" },
            { name: "levain", preparation: "actif, hydratation 100%" },
            { name: "sel", preparation: "sel de mer fin" }
          ]
        }
      ],
      steps: [
        { instruction: "Mélanger la farine et l'eau. Laisser reposer 30 minutes (autolyse) jusqu'à complète hydratation." },
        { instruction: "Ajouter le levain et le sel. Mélanger jusqu'à incorporation complète." },
        { instruction: "Effectuer des rabats (étirer et replier) toutes les 30 minutes pendant 2 heures. Couvrir le saladier sans serrer." },
        { instruction: "Laisser fermenter en masse à température ambiante (20-22°C) pendant 4 à 6 heures jusqu'à ce que la pâte double de volume." },
        { instruction: "Retourner la pâte sur un plan de travail fariné. Préformer en boule. Laisser reposer 20 minutes." },
        { instruction: "Façonner définitivement en tirant la pâte vers vous tout en la faisant pivoter, jusqu'à obtenir une surface bien tendue." },
        { instruction: "Placer dans un banneton, soudure vers le haut. Retarder au réfrigérateur pendant 8 à 16 heures." },
        { instruction: "Préchauffer le four à 260°C avec la cocotte en fonte à l'intérieur pendant 30 minutes." },
        { instruction: "Grigner la pâte avec une lame bien aiguisée. Enfourner et cuire à couvert pendant 20 minutes." },
        { instruction: "Retirer le couvercle et poursuivre la cuisson 25 minutes supplémentaires jusqu'à obtenir une croûte bien dorée." }
      ],
      equipment: ["Cocotte en fonte", "Banneton", "Couteau à pain"]
    }
  },
  "Beef Tacos" => {
    ja: {
      name: "ビーフタコス",
      description: "本格的なメキシカンストリートスタイルのタコス。スパイスで味付けした牛ひき肉を柔らかいトルティーヤに包み、新鮮なシラントロ、玉ねぎ、ライムを添えて。手軽に作れて、アレンジも自在。カジュアルなディナーやおもてなしにぴったりの一品です。",
      ingredient_groups: [
        {
          name: "肉とシーズニング",
          items: [
            { name: "牛ひき肉", preparation: "赤身80%脂身20%のもの" },
            { name: "クミン（香辛料）", preparation: nil },
            { name: "チリパウダー", preparation: nil },
            { name: "ガーリックパウダー", preparation: nil },
            { name: "オニオンパウダー", preparation: nil },
            { name: "塩こしょう", preparation: "適量" }
          ]
        },
        {
          name: "トルティーヤとトッピング",
          items: [
            { name: "コーントルティーヤ（トウモロコシ粉の薄焼き生地）", preparation: "温めたもの" },
            { name: "レタス", preparation: "千切り" },
            { name: "トマト", preparation: "角切り" },
            { name: "チェダーチーズ", preparation: "細切り" },
            { name: "サワークリーム", preparation: nil },
            { name: "サルサソース（メキシコ風トマトソース）", preparation: nil }
          ]
        }
      ],
      steps: [
        { instruction: "大きめのフライパンを中強火で熱し、牛ひき肉を入れる。" },
        { instruction: "木べらでほぐしながら、肉に焼き色がつくまで約5分炒める。" },
        { instruction: "余分な脂が出たら取り除く。クミン、チリパウダー、ガーリックパウダー、オニオンパウダーを加える。" },
        { instruction: "水60mlを加え、ソースにとろみがつくまで約3分煮詰める。" },
        { instruction: "塩こしょうで味を調える。" },
        { instruction: "コーントルティーヤを油をひかないフライパンか直火で、片面30秒ずつ温める。" },
        { instruction: "温めたトルティーヤに味付けした牛肉をのせる。" },
        { instruction: "お好みでレタス、トマト、チーズ、サワークリーム、サルサソースをトッピングする。" }
      ],
      equipment: ["大きめのフライパン"]
    },
    ko: {
      name: "비프 타코",
      description: "부드러운 토르티야에 양념한 소고기를 넣고 신선한 고수, 양파, 라임즙을 곁들인 정통 멕시코 길거리 스타일 타코입니다. 준비가 간편하고 다양하게 활용할 수 있어 가벼운 저녁 식사나 손님 접대에 완벽합니다.",
      ingredient_groups: [
        {
          name: "고기 & 양념",
          items: [
            { name: "소고기 다짐육", preparation: "지방 20% 함유" },
            { name: "쿠민 (큐민, 향신료)", preparation: nil },
            { name: "칠리 파우더", preparation: nil },
            { name: "마늘 가루", preparation: nil },
            { name: "양파 가루", preparation: nil },
            { name: "소금과 후추", preparation: "기호에 맞게" }
          ]
        },
        {
          name: "껍질 & 토핑",
          items: [
            { name: "콘 토르티야 (옥수수 납작빵)", preparation: "따뜻하게 데운 것" },
            { name: "양상추", preparation: "채 썬 것" },
            { name: "토마토", preparation: "깍둑썰기" },
            { name: "체다 치즈", preparation: "채 썬 것" },
            { name: "사워크림 (발효 크림)", preparation: nil },
            { name: "살사 소스 (멕시코식 토마토 소스)", preparation: nil }
          ]
        }
      ],
      steps: [
        { instruction: "큰 프라이팬을 중강불에 올려 예열합니다. 소고기 다짐육을 넣습니다." },
        { instruction: "숟가락으로 고기를 부숴가며 약 5분간 갈색이 될 때까지 볶습니다." },
        { instruction: "필요하면 기름을 따라 버립니다. 쿠민, 칠리 파우더, 마늘 가루, 양파 가루를 넣습니다." },
        { instruction: "물 1/4컵을 넣고 소스가 걸쭉해질 때까지 약 3분간 끓입니다." },
        { instruction: "소금과 후추로 기호에 맞게 간을 합니다." },
        { instruction: "콘 토르티야를 기름 없이 달군 프라이팬이나 직화에서 한 면당 30초씩 데웁니다." },
        { instruction: "각 토르티야에 양념한 소고기를 넣습니다." },
        { instruction: "기호에 따라 양상추, 토마토, 치즈, 사워크림, 살사 소스를 올려 완성합니다." }
      ],
      equipment: ["큰 프라이팬"]
    },
    zh_tw: {
      name: "墨西哥牛肉塔可",
      description: "正宗墨西哥街頭風味塔可，以調味牛絞肉搭配柔軟的玉米餅，佐以新鮮香菜、洋蔥，再擠上萊姆汁。製作快速且變化多端，非常適合輕鬆的家庭晚餐或招待客人。",
      ingredient_groups: [
        {
          name: "肉類與調味料",
          items: [
            { name: "牛絞肉", preparation: "肥瘦比2:8" },
            { name: "孜然粉", preparation: nil },
            { name: "墨西哥辣椒粉（chili powder，混合辣椒香料粉）", preparation: nil },
            { name: "蒜粉", preparation: nil },
            { name: "洋蔥粉", preparation: nil },
            { name: "鹽和胡椒", preparation: "適量" }
          ]
        },
        {
          name: "餅皮與配料",
          items: [
            { name: "玉米薄餅（tortilla，墨西哥玉米餅）", preparation: "加熱備用" },
            { name: "萵苣", preparation: "切絲" },
            { name: "番茄", preparation: "切丁" },
            { name: "乾酪絲（cheddar cheese，切達起司）", preparation: "刨絲" },
            { name: "酸奶油（sour cream，發酵鮮奶油）", preparation: nil },
            { name: "莎莎醬（salsa，墨西哥番茄辣醬）", preparation: nil }
          ]
        }
      ],
      steps: [
        { instruction: "取一大型平底鍋以中大火加熱，放入牛絞肉。" },
        { instruction: "邊煎邊用鍋鏟將絞肉撥散，煎至肉色轉褐，約5分鐘。" },
        { instruction: "如有多餘油脂可瀝除。加入孜然粉、墨西哥辣椒粉、蒜粉和洋蔥粉拌勻。" },
        { instruction: "加入1/4杯水，燉煮約3分鐘至醬汁收濃。" },
        { instruction: "以鹽和胡椒調味至喜好的口味。" },
        { instruction: "將玉米薄餅放入乾鍋中或直接在爐火上烘烤，每面約30秒至軟化。" },
        { instruction: "在每片玉米薄餅中填入調味好的牛絞肉。" },
        { instruction: "依個人喜好放上萵苣絲、番茄丁、起司絲、酸奶油和莎莎醬即可享用。" }
      ],
      equipment: ["大型平底鍋"]
    },
    zh_cn: {
      name: "墨西哥牛肉塔可",
      description: "正宗墨西哥街头风味塔可，以调味牛肉末搭配柔软的玉米饼，配上新鲜香菜、洋葱和青柠汁。制作快捷、搭配多变，非常适合家庭便餐或聚会招待。",
      ingredient_groups: [
        {
          name: "肉类与调味料",
          items: [
            { name: "牛肉末", preparation: "肥瘦比2:8" },
            { name: "孜然粉", preparation: nil },
            { name: "辣椒粉", preparation: nil },
            { name: "蒜粉", preparation: nil },
            { name: "洋葱粉", preparation: nil },
            { name: "盐和胡椒", preparation: "适量" }
          ]
        },
        {
          name: "饼皮与配料",
          items: [
            { name: "玉米饼（Tortilla，墨西哥薄饼）", preparation: "加热" },
            { name: "生菜", preparation: "切丝" },
            { name: "番茄", preparation: "切丁" },
            { name: "切达芝士（Cheddar，英式硬质奶酪）", preparation: "刨丝" },
            { name: "酸奶油（Sour Cream，西式发酵奶油）", preparation: nil },
            { name: "莎莎酱（Salsa，墨西哥番茄辣酱）", preparation: nil }
          ]
        }
      ],
      steps: [
        { instruction: "大火加热平底锅，放入牛肉末。" },
        { instruction: "用勺子将牛肉末炒散，煎至变色，约5分钟。" },
        { instruction: "如有需要，沥去多余油脂。加入孜然粉、辣椒粉、蒜粉和洋葱粉。" },
        { instruction: "加入1/4杯水，小火煮3分钟至酱汁收浓。" },
        { instruction: "加盐和胡椒调味，按个人口味调整。" },
        { instruction: "将玉米饼放入干锅中或在明火上加热，每面约30秒。" },
        { instruction: "在每张玉米饼中放入调味牛肉末。" },
        { instruction: "根据喜好，撒上生菜丝、番茄丁、芝士丝，淋上酸奶油和莎莎酱即可。" }
      ],
      equipment: ["大号平底锅"]
    },
    es: {
      name: "Tacos de Carne Molida",
      description: "Auténticos tacos callejeros al estilo mexicano con carne molida de res sazonada en tortillas suaves, cubiertos con cilantro fresco, cebolla y un toque de limón. Rápidos de preparar e increíblemente versátiles, estos tacos son perfectos para cenas casuales y reuniones.",
      ingredient_groups: [
        {
          name: "Carne y Condimentos",
          items: [
            { name: "carne molida de res", preparation: "mezcla 80/20" },
            { name: "comino", preparation: nil },
            { name: "chile en polvo", preparation: nil },
            { name: "ajo en polvo", preparation: nil },
            { name: "cebolla en polvo", preparation: nil },
            { name: "sal y pimienta", preparation: "al gusto" }
          ]
        },
        {
          name: "Tortillas y Acompañamientos",
          items: [
            { name: "tortillas de maíz", preparation: "calientes" },
            { name: "lechuga", preparation: "rallada" },
            { name: "jitomate", preparation: "en cubitos" },
            { name: "queso cheddar", preparation: "rallado" },
            { name: "crema agria", preparation: nil },
            { name: "salsa", preparation: nil }
          ]
        }
      ],
      steps: [
        { instruction: "Calienta un sartén grande a fuego medio-alto. Agrega la carne molida." },
        { instruction: "Cocina la carne, desmenuzándola con una cuchara, hasta que se dore, aproximadamente 5 minutos." },
        { instruction: "Escurre el exceso de grasa si es necesario. Agrega el comino, chile en polvo, ajo en polvo y cebolla en polvo." },
        { instruction: "Añade 1/4 de taza de agua y cocina a fuego lento por 3 minutos hasta que la salsa espese." },
        { instruction: "Sazona con sal y pimienta al gusto." },
        { instruction: "Calienta las tortillas de maíz en un comal seco o directamente sobre la flama por 30 segundos de cada lado." },
        { instruction: "Rellena cada tortilla con la carne sazonada." },
        { instruction: "Agrega lechuga, jitomate, queso, crema y salsa al gusto." }
      ],
      equipment: ["Sartén grande"]
    },
    fr: {
      name: "Tacos au bœuf",
      description: "Authentiques tacos mexicains de rue avec du bœuf haché assaisonné dans des tortillas souples, garnis de coriandre fraîche, d'oignons et d'un filet de citron vert. Rapides à préparer et incroyablement polyvalents, ces tacos sont parfaits pour les dîners décontractés et les repas entre amis.",
      ingredient_groups: [
        {
          name: "Viande et assaisonnements",
          items: [
            { name: "bœuf haché", preparation: "mélange 80/20" },
            { name: "cumin", preparation: nil },
            { name: "chili powder (mélange d'épices mexicain à base de piment)", preparation: nil },
            { name: "ail en poudre", preparation: nil },
            { name: "oignon en poudre", preparation: nil },
            { name: "sel et poivre", preparation: "selon le goût" }
          ]
        },
        {
          name: "Tortillas et garnitures",
          items: [
            { name: "tortillas de maïs", preparation: "réchauffées" },
            { name: "laitue", preparation: "ciselée" },
            { name: "tomates", preparation: "coupées en dés" },
            { name: "cheddar", preparation: "râpé" },
            { name: "crème aigre", preparation: nil },
            { name: "salsa (sauce mexicaine à base de tomates et piments)", preparation: nil }
          ]
        }
      ],
      steps: [
        { instruction: "Faire chauffer une grande poêle à feu moyen-vif. Ajouter le bœuf haché." },
        { instruction: "Faire cuire le bœuf en l'émiettant à l'aide d'une cuillère jusqu'à ce qu'il soit doré, environ 5 minutes." },
        { instruction: "Égoutter l'excès de gras si nécessaire. Ajouter le cumin, le chili powder, l'ail en poudre et l'oignon en poudre." },
        { instruction: "Ajouter 60 ml d'eau et laisser mijoter pendant 3 minutes jusqu'à ce que la sauce épaississe." },
        { instruction: "Assaisonner de sel et de poivre selon le goût." },
        { instruction: "Réchauffer les tortillas de maïs dans une poêle sèche ou à la flamme pendant 30 secondes de chaque côté." },
        { instruction: "Garnir chaque tortilla de bœuf assaisonné." },
        { instruction: "Ajouter selon vos envies la laitue, les tomates, le fromage, la crème aigre et la salsa." }
      ],
      equipment: ["Grande poêle"]
    }
  },
  "Kimchi Jjigae" => {
    ja: {
      name: "キムチチゲ",
      description: "韓国の定番鍋料理。ピリ辛の発酵キムチと柔らかい豚バラ肉、豆腐を濃厚で体が温まるスープで煮込んだ一品です。韓国料理の奥深い味わいを楽しめる香り豊かな料理で、炊きたてのご飯と一緒にどうぞ。",
      ingredient_groups: [
        {
          name: "主な材料",
          items: [
            { name: "豚バラ肉", preparation: "薄切り" },
            { name: "キムチ", preparation: "ざく切り、汁ごと" },
            { name: "豆腐", preparation: "絹ごし、一口大に切る" },
            { name: "玉ねぎ", preparation: "薄切り" }
          ]
        },
        {
          name: "スープ・調味料",
          items: [
            { name: "煮干しだし", preparation: nil },
            { name: "コチュカル", preparation: "韓国産粗挽き唐辛子" },
            { name: "醤油", preparation: nil },
            { name: "にんにく", preparation: "みじん切り" }
          ]
        },
        {
          name: "トッピング",
          items: [
            { name: "長ねぎ", preparation: "小口切り" },
            { name: "白ごま", preparation: nil }
          ]
        }
      ],
      steps: [
        { instruction: "大きな鍋またはトゥッペギ（韓国式土鍋）を中強火で熱し、豚バラ肉を入れる。" },
        { instruction: "豚肉の縁に焼き色がつくまで約2分炒める。こまめにかき混ぜる。" },
        { instruction: "みじん切りにしたにんにくを加え、香りが立つまで約30秒炒める。" },
        { instruction: "ざく切りにしたキムチと汁を加え、混ぜながら2分炒める。" },
        { instruction: "煮干しだしを注ぎ、コチュカルと醤油を加えて沸騰させる。" },
        { instruction: "薄切りの玉ねぎと豆腐を加え、火を弱めて10分煮込む。" },
        { instruction: "味見をして、必要に応じてキムチの汁や醤油で味を調える。" },
        { instruction: "器に盛り付け、小口切りの長ねぎと白ごまをトッピングする。" }
      ],
      equipment: ["トゥッペギ（韓国式土鍋）または鍋"]
    },
    ko: {
      name: "김치찌개",
      description: "매콤한 발효 김치와 부드러운 삼겹살, 두부를 함께 넣고 푹 끓여낸 한국의 대표적인 국민 음식입니다. 깊고 진한 국물이 일품이며, 갓 지은 따뜻한 밥과 함께 먹으면 더욱 맛있습니다.",
      ingredient_groups: [
        {
          name: "주재료",
          items: [
            { name: "삼겹살", preparation: "얇게 썬 것" },
            { name: "김치", preparation: "송송 썰어 국물과 함께" },
            { name: "두부", preparation: "순두부, 먹기 좋게 썬 것" },
            { name: "양파", preparation: "채 썬 것" }
          ]
        },
        {
          name: "육수 및 양념",
          items: [
            { name: "멸치육수", preparation: nil },
            { name: "고춧가루", preparation: nil },
            { name: "간장", preparation: nil },
            { name: "마늘", preparation: "다진 것" }
          ]
        },
        {
          name: "고명",
          items: [
            { name: "대파", preparation: "송송 썬 것" },
            { name: "통깨", preparation: nil }
          ]
        }
      ],
      steps: [
        { instruction: "뚝배기나 냄비를 중강불에 올리고 삼겹살을 넣습니다." },
        { instruction: "삼겹살 가장자리가 노릇해질 때까지 약 2분간 볶아줍니다. 자주 저어줍니다." },
        { instruction: "다진 마늘을 넣고 향이 올라올 때까지 약 30초간 볶아줍니다." },
        { instruction: "썬 김치와 김치 국물을 넣고 2분간 볶아줍니다." },
        { instruction: "멸치육수를 붓고 고춧가루와 간장을 넣어 끓입니다." },
        { instruction: "채 썬 양파와 두부를 넣고 불을 줄여 10분간 보글보글 끓입니다." },
        { instruction: "간을 보고 필요하면 김치 국물이나 간장으로 간을 맞춥니다." },
        { instruction: "그릇에 담고 송송 썬 대파와 통깨를 올려 마무리합니다." }
      ],
      equipment: ["뚝배기 또는 냄비"]
    },
    zh_tw: {
      name: "韓式泡菜鍋",
      description: "深受喜愛的韓式暖心燉鍋，將辛辣的發酵泡菜與軟嫩的五花肉和豆腐結合，在濃郁溫暖的湯底中慢燉。這道香氣四溢的料理展現了韓國料理的豐富層次風味，最適合搭配熱騰騰的白飯一起享用。",
      ingredient_groups: [
        {
          name: "主要食材",
          items: [
            { name: "五花肉", preparation: "切薄片" },
            { name: "韓式泡菜", preparation: "切塊，連同泡菜汁" },
            { name: "豆腐", preparation: "嫩豆腐，切塊" },
            { name: "洋蔥", preparation: "切片" }
          ]
        },
        {
          name: "湯底與調味料",
          items: [
            { name: "小魚乾高湯", preparation: nil },
            { name: "韓式辣椒粉（gochugaru，粗粒辣椒片）", preparation: "韓式粗辣椒粉" },
            { name: "醬油", preparation: nil },
            { name: "蒜頭", preparation: "切末" }
          ]
        },
        {
          name: "裝飾配料",
          items: [
            { name: "青蔥", preparation: "切段" },
            { name: "白芝麻", preparation: nil }
          ]
        }
      ],
      steps: [
        { instruction: "將大鍋或石鍋以中大火加熱，放入五花肉片。" },
        { instruction: "將五花肉煎至邊緣金黃，約2分鐘，期間不時翻炒。" },
        { instruction: "加入蒜末，炒約30秒至香氣散出。" },
        { instruction: "加入切塊的泡菜及泡菜汁，翻炒約2分鐘。" },
        { instruction: "倒入小魚乾高湯，加入韓式辣椒粉和醬油，煮至沸騰。" },
        { instruction: "加入洋蔥片和豆腐塊，轉小火燉煮10分鐘。" },
        { instruction: "試味道，依個人喜好加入更多泡菜汁或醬油調整鹹淡。" },
        { instruction: "盛入碗中，撒上蔥花和白芝麻即可享用。" }
      ],
      equipment: ["石鍋或湯鍋"]
    },
    zh_cn: {
      name: "韩式泡菜汤",
      description: "一道深受喜爱的韩国暖心炖菜，将辛辣的发酵泡菜与嫩滑的五花肉和豆腐相结合，在浓郁温暖的汤底中慢炖而成。这道香气四溢的菜肴展现了韩国料理的复杂风味，最适合搭配热腾腾的米饭享用。",
      ingredient_groups: [
        {
          name: "主料",
          items: [
            { name: "五花肉", preparation: "切薄片" },
            { name: "韩式泡菜", preparation: "切碎，保留泡菜汁" },
            { name: "豆腐", preparation: "嫩豆腐，切块" },
            { name: "洋葱", preparation: "切片" }
          ]
        },
        {
          name: "汤底和调味料",
          items: [
            { name: "小鱼干高汤", preparation: nil },
            { name: "韩式辣椒粉", preparation: "고추가루，韩国粗辣椒粉" },
            { name: "酱油", preparation: nil },
            { name: "大蒜", preparation: "切末" }
          ]
        },
        {
          name: "装饰配料",
          items: [
            { name: "小葱", preparation: "切段" },
            { name: "芝麻", preparation: nil }
          ]
        }
      ],
      steps: [
        { instruction: "将大锅或石锅置于中高火上加热，放入五花肉片。" },
        { instruction: "将五花肉煎至边缘焦黄，约2分钟，期间经常翻动。" },
        { instruction: "加入蒜末，翻炒约30秒至蒜香四溢。" },
        { instruction: "加入切碎的韩式泡菜及泡菜汁，翻炒2分钟。" },
        { instruction: "倒入小鱼干高汤，加入韩式辣椒粉和酱油，煮至沸腾。" },
        { instruction: "加入洋葱片和豆腐块，转小火慢炖10分钟。" },
        { instruction: "尝一下味道，如需要可加入更多泡菜汁或酱油调味。" },
        { instruction: "盛入碗中，撒上葱花和芝麻作为装饰即可享用。" }
      ],
      equipment: ["石锅或炖锅"]
    },
    es: {
      name: "Kimchi Jjigae (Estofado Coreano de Kimchi)",
      description: "Un reconfortante estofado coreano que combina kimchi fermentado picante con tierna panceta de cerdo y tofu, cocido a fuego lento en un caldo rico y reconfortante. Este aromático plato destaca los sabores complejos de la cocina coreana y se disfruta mejor acompañado de arroz al vapor.",
      ingredient_groups: [
        {
          name: "Ingredientes Principales",
          items: [
            { name: "panceta de cerdo", preparation: "cortada en láminas finas" },
            { name: "kimchi (col fermentada coreana picante)", preparation: "picado, con su jugo" },
            { name: "tofu", preparation: "sedoso, cortado en cubos" },
            { name: "cebolla", preparation: "en rodajas" }
          ]
        },
        {
          name: "Caldo y Condimentos",
          items: [
            { name: "caldo de anchoas", preparation: nil },
            { name: "gochugaru (hojuelas de chile coreano)", preparation: "hojuelas de chile coreano" },
            { name: "salsa de soja", preparation: nil },
            { name: "ajo", preparation: "picado" }
          ]
        },
        {
          name: "Guarnición",
          items: [
            { name: "cebolletas", preparation: "en rodajas" },
            { name: "semillas de sésamo", preparation: nil }
          ]
        }
      ],
      steps: [
        { instruction: "Calentar una olla grande o un cuenco de piedra a fuego medio-alto. Añadir las láminas de panceta de cerdo." },
        { instruction: "Cocinar la panceta hasta que los bordes estén dorados, aproximadamente 2 minutos. Remover con frecuencia." },
        { instruction: "Añadir el ajo picado y cocinar durante 30 segundos hasta que esté aromático." },
        { instruction: "Añadir el kimchi picado y su jugo. Remover y cocinar durante 2 minutos." },
        { instruction: "Verter el caldo de anchoas. Añadir el gochugaru y la salsa de soja. Llevar a ebullición." },
        { instruction: "Añadir la cebolla en rodajas y los cubos de tofu. Reducir el fuego y cocinar a fuego lento durante 10 minutos." },
        { instruction: "Probar y ajustar los condimentos con más jugo de kimchi o salsa de soja si es necesario." },
        { instruction: "Servir en cuencos con un cucharón. Decorar con cebolletas en rodajas y semillas de sésamo." }
      ],
      equipment: ["Cuenco de Piedra u Olla"]
    },
    fr: {
      name: "Kimchi Jjigae (Ragoût coréen au kimchi)",
      description: "Un ragoût coréen réconfortant très apprécié, associant du kimchi fermenté épicé à de la poitrine de porc fondante et du tofu, mijoté dans un bouillon riche et réchauffant. Ce plat aromatique met en valeur les saveurs complexes de la cuisine coréenne et se déguste idéalement avec du riz nature.",
      ingredient_groups: [
        {
          name: "Ingrédients principaux",
          items: [
            { name: "poitrine de porc", preparation: "émincée finement" },
            { name: "kimchi (chou fermenté coréen épicé)", preparation: "haché, avec son jus" },
            { name: "tofu", preparation: "soyeux, coupé en dés" },
            { name: "oignon", preparation: "émincé" }
          ]
        },
        {
          name: "Bouillon et assaisonnements",
          items: [
            { name: "bouillon d'anchois", preparation: nil },
            { name: "gochugaru (flocons de piment coréen)", preparation: nil },
            { name: "sauce soja", preparation: nil },
            { name: "ail", preparation: "émincé" }
          ]
        },
        {
          name: "Garniture",
          items: [
            { name: "ciboule", preparation: "émincée" },
            { name: "graines de sésame", preparation: nil }
          ]
        }
      ],
      steps: [
        { instruction: "Faire chauffer une grande marmite ou un dolsot (bol en pierre coréen) à feu moyen-vif. Ajouter les tranches de poitrine de porc." },
        { instruction: "Faire cuire le porc jusqu'à ce que les bords soient dorés, environ 2 minutes. Remuer souvent." },
        { instruction: "Ajouter l'ail émincé et faire revenir 30 secondes jusqu'à ce qu'il embaume." },
        { instruction: "Ajouter le kimchi haché et son jus. Mélanger et faire cuire 2 minutes." },
        { instruction: "Verser le bouillon d'anchois. Ajouter le gochugaru et la sauce soja. Porter à ébullition." },
        { instruction: "Ajouter l'oignon émincé et les morceaux de tofu. Réduire le feu et laisser mijoter 10 minutes." },
        { instruction: "Goûter et ajuster l'assaisonnement avec plus de jus de kimchi ou de sauce soja si nécessaire." },
        { instruction: "Servir à la louche dans des bols. Garnir de ciboule émincée et de graines de sésame." }
      ],
      equipment: ["Dolsot (bol en pierre) ou marmite"]
    }
  },
  "French Onion Soup" => {
    ja: {
      name: "フレンチオニオンスープ",
      description: "フランスのビストロを代表するクラシックなスープ。じっくりと飴色にキャラメリゼした玉ねぎを濃厚なビーフブロスで煮込み、カリカリのパンととろけるグリュイエールチーズをのせて仕上げます。素朴でありながら上品な、心温まる一品です。",
      ingredient_groups: [
        {
          name: "玉ねぎとベース",
          items: [
            { name: "玉ねぎ", preparation: "薄切り" },
            { name: "バター", preparation: nil },
            { name: "オリーブオイル", preparation: nil }
          ]
        },
        {
          name: "ブロス",
          items: [
            { name: "ビーフストック（牛肉の出汁）", preparation: nil },
            { name: "辛口白ワイン", preparation: nil },
            { name: "ローリエ（月桂樹の葉）", preparation: nil },
            { name: "タイム", preparation: "生" }
          ]
        },
        {
          name: "パンとチーズのトッピング",
          items: [
            { name: "バゲットなどのハード系パン", preparation: "厚さ約1.5cm" },
            { name: "グリュイエールチーズ（スイス産ハードチーズ）", preparation: "すりおろす" }
          ]
        }
      ],
      steps: [
        { instruction: "大きめの厚手の鍋にバターとオリーブオイルを入れ、中火で熱する。" },
        { instruction: "薄切りにした玉ねぎを加え、頻繁にかき混ぜながら約40分炒め、深い飴色になるまでキャラメリゼする。" },
        { instruction: "玉ねぎは黄金色になり、甘みが出るまで炒める。この工程は急がないこと。" },
        { instruction: "辛口白ワインを加え、鍋底についた焦げ（うま味）をこそげ取るようにしてデグラッセする。" },
        { instruction: "ビーフストック、ローリエ、タイムを加え、沸騰させる。" },
        { instruction: "火を弱め、20分煮込む。味見をして塩こしょうで味を調える。" },
        { instruction: "オーブンのグリル（ブロイラー）を強火で予熱する。パンを天板に並べ、きつね色になるまでトーストする。" },
        { instruction: "オーブン対応のスープボウルにスープを注ぎ、トーストしたパンを1枚ずつのせる。" },
        { instruction: "パンの上にすりおろしたグリュイエールチーズをたっぷりのせる。グリルで2〜3分、チーズが溶けて泡立つまで焼く。" }
      ],
      equipment: ["大きめの厚手の鍋", "オーブン対応のスープボウル"]
    },
    ko: {
      name: "프렌치 어니언 수프",
      description: "깊게 캐러멜라이즈한 양파를 진한 소고기 육수에 끓여낸 클래식한 프랑스 비스트로 수프입니다. 바삭한 빵과 녹인 그뤼예르 치즈를 올려 완성하는 이 우아하면서도 소박한 요리는 한 그릇에 담긴 순수한 위안입니다.",
      ingredient_groups: [
        {
          name: "양파 & 베이스",
          items: [
            { name: "양파", preparation: "얇게 슬라이스" },
            { name: "버터", preparation: nil },
            { name: "올리브 오일", preparation: nil }
          ]
        },
        {
          name: "육수",
          items: [
            { name: "소고기 육수", preparation: nil },
            { name: "드라이 화이트 와인", preparation: nil },
            { name: "월계수 잎", preparation: nil },
            { name: "타임 (백리향)", preparation: "신선한 것" }
          ]
        },
        {
          name: "빵 & 치즈 토핑",
          items: [
            { name: "바삭한 빵 (바게트 등)", preparation: "1.5cm 두께" },
            { name: "그뤼예르 치즈 (스위스산 경성 치즈)", preparation: "채 썬 것" }
          ]
        }
      ],
      steps: [
        { instruction: "크고 무거운 냄비에 버터와 올리브 오일을 넣고 중불에서 가열합니다." },
        { instruction: "슬라이스한 양파를 넣고 자주 저어주며 40분간 깊게 캐러멜라이즈될 때까지 볶습니다." },
        { instruction: "양파가 황금빛 갈색이 되고 달콤해져야 합니다. 이 단계를 서두르지 마세요." },
        { instruction: "드라이 화이트 와인을 넣어 디글레이징하며 냄비 바닥에 눌어붙은 갈색 부분을 긁어냅니다." },
        { instruction: "소고기 육수, 월계수 잎, 타임을 넣고 끓입니다." },
        { instruction: "불을 줄이고 20분간 끓입니다. 맛을 보고 소금과 후추로 간합니다." },
        { instruction: "브로일러(그릴)를 강으로 예열합니다. 베이킹 시트에 빵 조각을 올리고 황금색이 될 때까지 굽습니다." },
        { instruction: "오븐용 그릇에 수프를 담고 각 그릇 위에 구운 빵 한 조각을 올립니다." },
        { instruction: "빵 위에 채 썬 그뤼예르 치즈를 듬뿍 올립니다. 치즈가 녹고 거품이 생길 때까지 2-3분간 브로일합니다." }
      ],
      equipment: ["크고 무거운 냄비", "오븐용 그릇"]
    },
    zh_tw: {
      name: "法式洋蔥湯",
      description: "經典的法式小酒館湯品，以深度焦糖化的洋蔥在濃郁牛肉高湯中慢燉，最後覆上酥脆麵包與融化的格呂耶爾起司。這道優雅而樸實的料理，是碗中最溫暖的慰藉。",
      ingredient_groups: [
        {
          name: "洋蔥與基底",
          items: [
            { name: "黃洋蔥", preparation: "切薄片" },
            { name: "奶油", preparation: nil },
            { name: "橄欖油", preparation: nil }
          ]
        },
        {
          name: "高湯",
          items: [
            { name: "牛肉高湯", preparation: nil },
            { name: "不甜白酒", preparation: nil },
            { name: "月桂葉", preparation: nil },
            { name: "百里香", preparation: "新鮮" }
          ]
        },
        {
          name: "麵包與起司配料",
          items: [
            { name: "法式硬皮麵包", preparation: "切約1.5公分厚片" },
            { name: "格呂耶爾起司（Gruyère，瑞士硬質起司）", preparation: "刨絲" }
          ]
        }
      ],
      steps: [
        { instruction: "在大型厚底鍋中以中火加熱奶油和橄欖油。" },
        { instruction: "加入切片洋蔥，不時翻炒，持續約40分鐘直到呈現深度焦糖化。" },
        { instruction: "洋蔥應呈現金黃褐色且帶有甜味。此步驟切勿急躁趕時間。" },
        { instruction: "倒入不甜白酒收汁，同時刮起鍋底的焦香精華。" },
        { instruction: "加入牛肉高湯、月桂葉和百里香，煮至沸騰。" },
        { instruction: "轉小火燉煮20分鐘。試味後以鹽和胡椒調味。" },
        { instruction: "將烤箱上火預熱至高溫。將麵包片放在烤盤上，烤至金黃色。" },
        { instruction: "將湯舀入可進烤箱的湯碗中，每碗放上一片烤好的麵包。" },
        { instruction: "在麵包上堆滿刨絲的格呂耶爾起司。以上火烤2-3分鐘，直到起司融化並冒泡。" }
      ],
      equipment: ["大型厚底鍋", "可進烤箱的湯碗"]
    },
    zh_cn: {
      name: "法式洋葱汤",
      description: "一道经典的法式小酒馆汤品，以深度焦糖化的洋葱慢炖于浓郁的牛肉高汤中，表面覆盖着酥脆的面包片和融化的格吕耶尔奶酪。这道优雅而质朴的料理，是碗中纯粹的温暖与慰藉。",
      ingredient_groups: [
        {
          name: "洋葱及基底",
          items: [
            { name: "黄洋葱", preparation: "切成薄片" },
            { name: "黄油", preparation: nil },
            { name: "橄榄油", preparation: nil }
          ]
        },
        {
          name: "高汤",
          items: [
            { name: "牛肉高汤", preparation: nil },
            { name: "干白葡萄酒", preparation: nil },
            { name: "香叶", preparation: nil },
            { name: "百里香", preparation: "新鲜" }
          ]
        },
        {
          name: "面包及奶酪配料",
          items: [
            { name: "法棍面包", preparation: "切成1厘米厚片" },
            { name: "格吕耶尔奶酪（Gruyère，一种瑞士硬质奶酪）", preparation: "刨成丝" }
          ]
        }
      ],
      steps: [
        { instruction: "在大号厚底锅中，以中火加热黄油和橄榄油。" },
        { instruction: "加入洋葱片，频繁翻炒，约40分钟，直至洋葱深度焦糖化。" },
        { instruction: "洋葱应呈金棕色且带有甜味。此步骤切勿急躁。" },
        { instruction: "倒入干白葡萄酒为锅底脱釉，用锅铲刮起锅底的焦香物质。" },
        { instruction: "加入牛肉高汤、香叶和百里香，大火煮沸。" },
        { instruction: "转小火慢炖20分钟。尝味后用盐和黑胡椒调味。" },
        { instruction: "将烤箱上火预热至高温。将面包片放在烤盘上，烤至金黄色。" },
        { instruction: "将汤盛入可进烤箱的汤碗中，每碗上面放一片烤好的面包。" },
        { instruction: "在面包上堆放格吕耶尔奶酪丝，用上火烤2-3分钟，直至奶酪融化起泡。" }
      ],
      equipment: ["大号厚底锅", "可进烤箱的汤碗"]
    },
    es: {
      name: "Sopa de Cebolla Francesa",
      description: "Una clásica sopa de bistró francés con cebollas profundamente caramelizadas cocidas a fuego lento en un sabroso caldo de res, coronada con pan crujiente y queso Gruyère derretido. Este plato elegante pero humilde es puro confort en un tazón.",
      ingredient_groups: [
        {
          name: "Cebollas y Base",
          items: [
            { name: "cebollas amarillas", preparation: "cortadas en rodajas finas" },
            { name: "mantequilla", preparation: nil },
            { name: "aceite de oliva", preparation: nil }
          ]
        },
        {
          name: "Caldo",
          items: [
            { name: "caldo de res", preparation: nil },
            { name: "vino blanco seco", preparation: nil },
            { name: "laurel", preparation: nil },
            { name: "tomillo", preparation: "fresco" }
          ]
        },
        {
          name: "Pan y Queso para Gratinar",
          items: [
            { name: "pan crujiente", preparation: "de 1 cm de grosor" },
            { name: "queso Gruyère (queso suizo de sabor intenso y ligeramente dulce)", preparation: "rallado" }
          ]
        }
      ],
      steps: [
        { instruction: "Calentar la mantequilla y el aceite de oliva en una olla grande y pesada a fuego medio." },
        { instruction: "Añadir las cebollas en rodajas y cocinar, removiendo frecuentemente, durante 40 minutos hasta que estén profundamente caramelizadas." },
        { instruction: "Las cebollas deben quedar doradas y dulces. No acelerar este paso." },
        { instruction: "Desglasar la olla con el vino blanco seco, raspando los trocitos dorados del fondo." },
        { instruction: "Añadir el caldo de res, el laurel y el tomillo. Llevar a ebullición." },
        { instruction: "Reducir el fuego y cocinar a fuego lento durante 20 minutos. Probar y sazonar con sal y pimienta." },
        { instruction: "Precalentar el gratinador a temperatura alta. Colocar las rebanadas de pan en una bandeja de horno. Tostar hasta que estén doradas." },
        { instruction: "Servir la sopa con un cucharón en tazones aptos para horno. Colocar una rebanada de pan tostado encima de cada uno." },
        { instruction: "Cubrir generosamente con el queso Gruyère rallado sobre el pan. Gratinar durante 2-3 minutos hasta que el queso se derrita y burbujee." }
      ],
      equipment: ["Olla grande y pesada", "Tazones aptos para horno"]
    },
    fr: {
      name: "Soupe à l'oignon gratinée",
      description: "Une soupe classique de bistrot français composée d'oignons longuement caramélisés mijotés dans un bouillon de bœuf savoureux, couronnée de pain croustillant et de gruyère fondu. Ce plat élégant et humble est le réconfort absolu dans un bol.",
      ingredient_groups: [
        {
          name: "Oignons et base",
          items: [
            { name: "oignons jaunes", preparation: "émincés finement" },
            { name: "beurre", preparation: nil },
            { name: "huile d'olive", preparation: nil }
          ]
        },
        {
          name: "Bouillon",
          items: [
            { name: "bouillon de bœuf", preparation: nil },
            { name: "vin blanc sec", preparation: nil },
            { name: "feuille de laurier", preparation: nil },
            { name: "thym", preparation: "frais" }
          ]
        },
        {
          name: "Garniture pain et fromage",
          items: [
            { name: "pain de campagne", preparation: "tranches de 1 cm d'épaisseur" },
            { name: "gruyère", preparation: "râpé" }
          ]
        }
      ],
      steps: [
        { instruction: "Faites chauffer le beurre et l'huile d'olive dans une grande cocotte à feu moyen." },
        { instruction: "Ajoutez les oignons émincés et faites-les revenir en remuant régulièrement pendant 40 minutes jusqu'à ce qu'ils soient bien caramélisés." },
        { instruction: "Les oignons doivent être dorés et fondants. Ne brusquez pas cette étape." },
        { instruction: "Déglacez la cocotte avec le vin blanc sec en grattant les sucs de cuisson au fond." },
        { instruction: "Ajoutez le bouillon de bœuf, les feuilles de laurier et le thym. Portez à ébullition." },
        { instruction: "Baissez le feu et laissez mijoter 20 minutes. Goûtez et assaisonnez de sel et de poivre." },
        { instruction: "Préchauffez le gril du four à puissance maximale. Disposez les tranches de pain sur une plaque de cuisson. Faites-les griller jusqu'à ce qu'elles soient dorées." },
        { instruction: "Répartissez la soupe dans des bols allant au four. Déposez une tranche de pain grillé sur chaque bol." },
        { instruction: "Recouvrez généreusement de gruyère râpé. Passez sous le gril 2 à 3 minutes jusqu'à ce que le fromage soit fondu et gratiné." }
      ],
      equipment: ["Grande cocotte", "Bols allant au four"]
    }
  },
  "Chocolate Chip Cookies" => {
    ja: {
      name: "チョコレートチップクッキー",
      description: "バター、ブラウンシュガー、ダークチョコレートチップを使った究極のアメリカンクラシック。外はサクサク、中はしっとりとした完璧な焼き上がりのクッキーです。何世代にもわたって愛され続けている、色あせることのない定番レシピです。",
      ingredient_groups: [
        {
          name: "粉類",
          items: [
            { name: "薄力粉", preparation: "2カップ、すり切りで計量" },
            { name: "重曹", preparation: nil },
            { name: "塩", preparation: nil }
          ]
        },
        {
          name: "バター・砂糖類",
          items: [
            { name: "バター", preparation: "室温に戻したもの、6オンス" },
            { name: "グラニュー糖", preparation: "3/4カップ" },
            { name: "ブラウンシュガー（黒糖に似た風味の砂糖）", preparation: "3/4カップ、押し固めて計量" },
            { name: "バニラエッセンス", preparation: nil }
          ]
        },
        {
          name: "卵・チョコレート",
          items: [
            { name: "卵", preparation: nil },
            { name: "チョコレートチップ", preparation: "セミスイート（甘さ控えめ）、2カップ" }
          ]
        }
      ],
      steps: [
        { instruction: "オーブンを190℃（375°F）に予熱します。" },
        { instruction: "小さめのボウルに薄力粉、重曹、塩を入れて混ぜ合わせ、脇に置いておきます。" },
        { instruction: "大きめのボウルに室温に戻したバターと2種類の砂糖を入れ、クリーム状になるまで混ぜます。" },
        { instruction: "バニラエッセンスと卵を加え、よく混ざるまで混ぜ合わせます。" },
        { instruction: "粉類を少しずつ加え、混ぜすぎないようにさっくりと混ぜ合わせます。" },
        { instruction: "チョコレートチップを加え、ゴムベラで折り込むように混ぜます。" },
        { instruction: "油を塗っていない天板に、大さじ1杯程度の生地を丸く落としていきます。" },
        { instruction: "10〜12分、縁がきつね色になるまで焼きます。" },
        { instruction: "天板の上で2分冷ましてから、ケーキクーラーに移して冷まします。" }
      ],
      equipment: ["天板", "ボウル"]
    },
    ko: {
      name: "초콜릿 칩 쿠키",
      description: "버터, 황설탕, 다크 초콜릿 칩을 넣어 촉촉하면서도 바삭하게 구워낸 미국의 대표적인 클래식 쿠키입니다. 오랜 세월 사랑받아 온 이 레시피는 세대를 넘어 변함없는 인기를 자랑합니다.",
      ingredient_groups: [
        {
          name: "건조 재료",
          items: [
            { name: "중력분", preparation: "2컵, 수북하게 담아 평평하게 깎기" },
            { name: "베이킹소다", preparation: nil },
            { name: "소금", preparation: nil }
          ]
        },
        {
          name: "버터 & 설탕",
          items: [
            { name: "버터", preparation: "실온에 부드럽게 둔 것, 6 oz" },
            { name: "백설탕", preparation: "3/4컵" },
            { name: "흑설탕", preparation: "3/4컵, 꾹꾹 눌러 담기" },
            { name: "바닐라 익스트랙 (바닐라 농축액)", preparation: nil }
          ]
        },
        {
          name: "달걀 & 초콜릿",
          items: [
            { name: "달걀", preparation: nil },
            { name: "초콜릿 칩", preparation: "세미스위트 (반단맛), 2컵" }
          ]
        }
      ],
      steps: [
        { instruction: "오븐을 375°F (190°C)로 예열합니다." },
        { instruction: "작은 볼에 밀가루, 베이킹소다, 소금을 넣고 섞은 후 따로 둡니다." },
        { instruction: "큰 볼에 실온에 둔 버터와 두 종류의 설탕을 넣고 크림처럼 부드러워질 때까지 휘핑합니다." },
        { instruction: "바닐라 익스트랙과 달걀을 넣고 잘 섞일 때까지 저어줍니다." },
        { instruction: "밀가루 혼합물을 조금씩 넣으며 반죽이 막 섞일 정도로만 저어줍니다." },
        { instruction: "초콜릿 칩을 넣고 주걱으로 접듯이 섞어줍니다." },
        { instruction: "기름칠하지 않은 베이킹 시트 위에 반죽을 둥글게 한 큰술씩 떨어뜨려 올립니다." },
        { instruction: "가장자리가 황금빛 갈색이 될 때까지 10-12분간 굽습니다." },
        { instruction: "베이킹 시트 위에서 2분간 식힌 후 식힘망으로 옮깁니다." }
      ],
      equipment: ["베이킹 시트", "믹싱 볼"]
    },
    zh_cn: {
      name: "巧克力豆曲奇饼干",
      description: "这是一款经典的美式甜点，以黄油、红糖和黑巧克力豆烘焙而成，口感外酥内软，完美平衡。这款经久不衰的配方深受几代人喜爱，永不过时。",
      ingredient_groups: [
        {
          name: "干性材料",
          items: [
            { name: "中筋面粉", preparation: "约2杯，用勺舀入后刮平" },
            { name: "小苏打", preparation: nil },
            { name: "盐", preparation: nil }
          ]
        },
        {
          name: "黄油与糖",
          items: [
            { name: "黄油", preparation: "软化，约6盎司" },
            { name: "细砂糖", preparation: "约3/4杯" },
            { name: "红糖", preparation: "约3/4杯，压实" },
            { name: "香草精", preparation: nil }
          ]
        },
        {
          name: "鸡蛋与巧克力",
          items: [
            { name: "鸡蛋", preparation: nil },
            { name: "巧克力豆", preparation: "半甜型，约2杯" }
          ]
        }
      ],
      steps: [
        { instruction: "将烤箱预热至375°F（190°C）。" },
        { instruction: "在小碗中混合面粉、小苏打和盐，搅拌均匀后备用。" },
        { instruction: "在大碗中，将软化的黄油与两种糖一起打发至顺滑蓬松。" },
        { instruction: "加入香草精和鸡蛋，搅打至完全融合。" },
        { instruction: "分次加入面粉混合物，搅拌至刚好混合均匀即可。" },
        { instruction: "轻轻拌入巧克力豆。" },
        { instruction: "用汤匙舀取面团，做成圆球状，放置在未涂油的烤盘上。" },
        { instruction: "烘烤10-12分钟，直到边缘呈金黄色。" },
        { instruction: "在烤盘上冷却2分钟，然后转移到冷却架上继续冷却。" }
      ],
      equipment: ["烤盘", "搅拌碗"]
    },
    es: {
      name: "Galletas con Chips de Chocolate",
      description: "El clásico estadounidense por excelencia con mantequilla, azúcar moreno y chips de chocolate negro horneados hasta lograr la galleta perfecta, crujiente por fuera y suave por dentro. Esta receta atemporal ha sido amada por generaciones y nunca pasa de moda.",
      ingredient_groups: [
        {
          name: "Ingredientes Secos",
          items: [
            { name: "harina común", preparation: "2 tazas, medidas sin comprimir" },
            { name: "bicarbonato de sodio", preparation: nil },
            { name: "sal", preparation: nil }
          ]
        },
        {
          name: "Mantequilla y Azúcar",
          items: [
            { name: "mantequilla", preparation: "a temperatura ambiente, 6 oz" },
            { name: "azúcar blanco", preparation: "3/4 taza" },
            { name: "azúcar moreno", preparation: "3/4 taza bien compactada" },
            { name: "extracto de vainilla", preparation: nil }
          ]
        },
        {
          name: "Huevos y Chocolate",
          items: [
            { name: "huevos", preparation: nil },
            { name: "chips de chocolate", preparation: "semi-amargo, 2 tazas" }
          ]
        }
      ],
      steps: [
        { instruction: "Precalentar el horno a 190°C (375°F)." },
        { instruction: "En un bowl pequeño, mezclar la harina, el bicarbonato de sodio y la sal. Reservar." },
        { instruction: "En un bowl grande, batir la mantequilla a temperatura ambiente con ambos tipos de azúcar hasta obtener una mezcla cremosa." },
        { instruction: "Añadir el extracto de vainilla y los huevos. Batir hasta que estén bien integrados." },
        { instruction: "Incorporar gradualmente la mezcla de harina hasta que apenas se combine." },
        { instruction: "Agregar los chips de chocolate con movimientos envolventes." },
        { instruction: "Colocar cucharadas redondeadas de masa sobre bandejas para hornear sin engrasar." },
        { instruction: "Hornear durante 10-12 minutos hasta que los bordes estén dorados." },
        { instruction: "Dejar enfriar en la bandeja durante 2 minutos, luego transferir a una rejilla." }
      ],
      equipment: ["Bandeja para hornear", "Bowls para mezclar"]
    },
    fr: {
      name: "Cookies aux pépites de chocolat",
      description: "Le grand classique américain associant beurre, cassonade et pépites de chocolat noir pour obtenir le cookie parfait, à la fois moelleux et croustillant. Cette recette intemporelle est adorée depuis des générations et ne se démode jamais.",
      ingredient_groups: [
        {
          name: "Ingrédients secs",
          items: [
            { name: "farine", preparation: "2 tasses, mesurées et nivelées" },
            { name: "bicarbonate de soude", preparation: nil },
            { name: "sel", preparation: nil }
          ]
        },
        {
          name: "Beurre et sucre",
          items: [
            { name: "beurre", preparation: "ramolli, 6 oz" },
            { name: "sucre en poudre", preparation: "3/4 tasse" },
            { name: "cassonade", preparation: "3/4 tasse bien tassée" },
            { name: "extrait de vanille", preparation: nil }
          ]
        },
        {
          name: "Œufs et chocolat",
          items: [
            { name: "œufs", preparation: nil },
            { name: "pépites de chocolat", preparation: "mi-sucré, 2 tasses" }
          ]
        }
      ],
      steps: [
        { instruction: "Préchauffer le four à 190°C (375°F)." },
        { instruction: "Dans un petit bol, mélanger la farine, le bicarbonate de soude et le sel. Réserver." },
        { instruction: "Dans un grand bol, battre le beurre ramolli avec les deux sucres jusqu'à obtenir une texture crémeuse." },
        { instruction: "Ajouter l'extrait de vanille et les œufs. Battre jusqu'à ce que le mélange soit homogène." },
        { instruction: "Incorporer progressivement le mélange de farine jusqu'à ce qu'il soit juste combiné." },
        { instruction: "Incorporer délicatement les pépites de chocolat." },
        { instruction: "Déposer des cuillères à soupe bombées de pâte sur des plaques de cuisson non graissées." },
        { instruction: "Cuire pendant 10 à 12 minutes jusqu'à ce que les bords soient dorés." },
        { instruction: "Laisser refroidir sur la plaque pendant 2 minutes, puis transférer sur une grille de refroidissement." }
      ],
      equipment: ["Plaque de cuisson", "Bols à mélanger"]
    },
    zh_tw: {
      name: "巧克力豆餅乾",
      description: "經典美式餅乾，以奶油、黑糖和黑巧克力豆烘烤成外酥內軟的完美口感。這道經典食譜深受世代喜愛，永不退流行。",
      ingredient_groups: [
        {
          name: "乾料",
          items: [
            { name: "中筋麵粉", preparation: "2杯，以湯匙舀取後刮平" },
            { name: "小蘇打粉", preparation: nil },
            { name: "鹽", preparation: nil }
          ]
        },
        {
          name: "奶油與糖",
          items: [
            { name: "奶油", preparation: "軟化，6盎司" },
            { name: "細砂糖", preparation: "3/4杯" },
            { name: "黑糖", preparation: "3/4杯，壓實" },
            { name: "香草精", preparation: nil }
          ]
        },
        {
          name: "蛋與巧克力",
          items: [
            { name: "雞蛋", preparation: nil },
            { name: "巧克力豆", preparation: "半甜，2杯" }
          ]
        }
      ],
      steps: [
        { instruction: "烤箱預熱至375°F（190°C）。" },
        { instruction: "在小碗中混合麵粉、小蘇打粉和鹽，備用。" },
        { instruction: "在大碗中，將軟化的奶油與兩種糖攪打至綿密滑順。" },
        { instruction: "加入香草精和雞蛋，攪打均勻。" },
        { instruction: "逐漸拌入麵粉混合物，攪拌至剛好混合即可。" },
        { instruction: "拌入巧克力豆。" },
        { instruction: "用湯匙舀取圓球狀麵糰，放置於未抹油的烤盤上。" },
        { instruction: "烘烤10-12分鐘，直到邊緣呈金黃色。" },
        { instruction: "在烤盤上靜置冷卻2分鐘，然後移至冷卻架上。" }
      ],
      equipment: ["烤盤", "攪拌盆"]
    }
  },
  "Guacamole" => {
    ja: {
      name: "ワカモレ",
      description: "クリーミーなアボカド、フレッシュなライム、コリアンダー、トマトで作るシンプルながら伝説的なメキシコ料理のディップです。トルティーヤチップスと一緒に前菜として、またはタコスなどのメキシコ料理のトッピングとしても最適。パーティーの定番料理が数分で完成します。",
      ingredient_groups: [
        {
          name: "材料",
          items: [
            { name: "アボカド", preparation: "熟したもの、縦半分に切って種を除く" },
            { name: "ライム", preparation: "絞りたての果汁" },
            { name: "塩", preparation: "適量" },
            { name: "白玉ねぎ", preparation: "細かくみじん切り" },
            { name: "パクチー（コリアンダーの葉）", preparation: "生、刻む" },
            { name: "ハラペーニョ（メキシコの青唐辛子）", preparation: "みじん切り、種を除く" },
            { name: "トマト", preparation: "角切り、お好みで" }
          ]
        }
      ],
      steps: [
        { instruction: "アボカドを縦半分に切る。種を取り除き、果肉をスプーンですくってボウルに入れる。" },
        { instruction: "変色を防ぐため、すぐにライム果汁をアボカドにかける。" },
        { instruction: "フォークでアボカドをお好みの固さに潰す。少し塊を残すとよい。" },
        { instruction: "みじん切りの白玉ねぎ、刻んだパクチー、みじん切りのハラペーニョを加える。" },
        { instruction: "お好みで角切りトマトを加える。" },
        { instruction: "塩で味を調える。全体をやさしく混ぜ合わせる。" },
        { instruction: "味見をして調味料を調整する。トルティーヤチップスを添えてすぐに召し上がれ。" }
      ],
      equipment: ["ボウル", "フォーク"]
    },
    ko: {
      name: "과카몰리",
      description: "크리미한 아보카도, 신선한 라임, 고수, 토마토로 만드는 간단하지만 전설적인 멕시코 딥입니다. 토르티야 칩과 함께 애피타이저로 즐기거나 타코 및 다른 멕시코 요리의 토핑으로 완벽하며, 이 파티 인기 메뉴는 단 몇 분이면 준비할 수 있습니다.",
      ingredient_groups: [
        {
          name: "재료",
          items: [
            { name: "아보카도", preparation: "잘 익은 것, 반으로 잘라 씨 제거" },
            { name: "라임", preparation: "즙을 짜서 사용" },
            { name: "소금", preparation: "기호에 맞게" },
            { name: "양파", preparation: "잘게 다진 것" },
            { name: "실란트로 (멕시코 고수)", preparation: "신선한 것, 다진 것" },
            { name: "할라페뇨 (멕시코 청고추)", preparation: "씨를 제거하고 잘게 다진 것" },
            { name: "토마토", preparation: "깍둑 썬 것, 선택 사항" }
          ]
        }
      ],
      steps: [
        { instruction: "아보카도를 세로로 반으로 자릅니다. 씨를 제거하고 과육을 볼에 담습니다." },
        { instruction: "갈변을 방지하기 위해 즉시 라임즙을 아보카도 위에 뿌립니다." },
        { instruction: "포크로 아보카도를 원하는 질감이 될 때까지 으깹니다. 약간의 덩어리가 남도록 합니다." },
        { instruction: "다진 양파, 다진 실란트로, 다진 할라페뇨를 넣습니다." },
        { instruction: "원하시면 깍둑 썬 토마토를 추가합니다." },
        { instruction: "기호에 맞게 소금으로 간합니다. 부드럽게 섞어줍니다." },
        { instruction: "맛을 보고 간을 조절합니다. 토르티야 칩과 함께 바로 서빙합니다." }
      ],
      equipment: ["볼", "포크"]
    },
    zh_tw: {
      name: "酪梨醬",
      description: "一道簡單卻經典的墨西哥沾醬，以滑順的酪梨、新鮮萊姆汁、香菜和番茄製成。無論是搭配墨西哥玉米片作為開胃菜，或是作為塔可和其他墨西哥料理的配料都非常適合，這道派對必備美食只需幾分鐘即可完成。",
      ingredient_groups: [
        {
          name: "食材",
          items: [
            { name: "酪梨", preparation: "熟透，對半切開去籽" },
            { name: "萊姆", preparation: "現榨汁" },
            { name: "鹽", preparation: "適量" },
            { name: "白洋蔥", preparation: "切細丁" },
            { name: "香菜", preparation: "新鮮，切碎" },
            { name: "墨西哥辣椒（jalapeño，一種中等辣度的青辣椒）", preparation: "切末，去籽" },
            { name: "番茄", preparation: "切丁，可省略" }
          ]
        }
      ],
      steps: [
        { instruction: "將酪梨縱向對半切開，去除果核，將果肉挖入碗中。" },
        { instruction: "立即擠入萊姆汁在酪梨上，防止氧化變色。" },
        { instruction: "用叉子將酪梨搗成喜歡的濃稠度，保留一些小塊增加口感。" },
        { instruction: "加入切丁的白洋蔥、切碎的香菜和切末的墨西哥辣椒。" },
        { instruction: "依個人喜好加入切丁的番茄。" },
        { instruction: "以鹽調味至喜歡的鹹度，輕輕拌勻。" },
        { instruction: "試吃並調整調味，搭配墨西哥玉米片立即享用。" }
      ],
      equipment: ["碗", "叉子"]
    },
    zh_cn: {
      name: "牛油果酱（Guacamole）",
      description: "一道简单却经典的墨西哥蘸酱，由细腻的牛油果、新鲜青柠、香菜和番茄制成。无论是搭配玉米片作为开胃小食，还是作为塔可及其他墨西哥菜肴的配料，这道派对必备美食只需几分钟即可完成。",
      ingredient_groups: [
        {
          name: "食材",
          items: [
            { name: "牛油果", preparation: "成熟，对半切开去核" },
            { name: "青柠", preparation: "现榨汁" },
            { name: "盐", preparation: "适量" },
            { name: "白洋葱", preparation: "切细丁" },
            { name: "香菜", preparation: "新鲜，切碎" },
            { name: "墨西哥辣椒（jalapeño，一种青绿色小辣椒）", preparation: "切碎，去籽" },
            { name: "番茄", preparation: "切丁，可选" }
          ]
        }
      ],
      steps: [
        { instruction: "将牛油果纵向对半切开，去除果核，用勺子将果肉挖入碗中。" },
        { instruction: "立即将青柠汁挤在牛油果上，防止氧化变色。" },
        { instruction: "用叉子将牛油果捣成喜欢的质地，保留一些小块增加口感。" },
        { instruction: "加入切好的白洋葱丁、香菜碎和墨西哥辣椒碎。" },
        { instruction: "如果喜欢，可以加入番茄丁。" },
        { instruction: "根据口味加盐调味，轻轻搅拌均匀。" },
        { instruction: "尝一下味道，调整调味料。立即搭配玉米片享用。" }
      ],
      equipment: ["碗", "叉子"]
    },
    es: {
      name: "Guacamole",
      description: "Un dip mexicano sencillo pero legendario hecho con aguacates cremosos, limón fresco, cilantro y tomates. Perfecto como aperitivo con totopos o como complemento para tacos y otros platillos mexicanos, este favorito de las fiestas se prepara en solo minutos.",
      ingredient_groups: [
        {
          name: "Ingredientes",
          items: [
            { name: "aguacates", preparation: "maduros, cortados por la mitad y sin hueso" },
            { name: "limón", preparation: "jugo recién exprimido" },
            { name: "sal", preparation: "al gusto" },
            { name: "cebolla blanca", preparation: "finamente picada" },
            { name: "cilantro", preparation: "fresco, picado" },
            { name: "chile jalapeño", preparation: "finamente picado, sin semillas" },
            { name: "jitomate", preparation: "picado en cubitos, opcional" }
          ]
        }
      ],
      steps: [
        { instruction: "Corta los aguacates por la mitad a lo largo. Retira el hueso y coloca la pulpa en un tazón." },
        { instruction: "Exprime el jugo de limón sobre los aguacates inmediatamente para evitar que se oxiden." },
        { instruction: "Machaca los aguacates con un tenedor hasta obtener la consistencia deseada. Deja algunos trozos." },
        { instruction: "Agrega la cebolla blanca picada, el cilantro picado y el chile jalapeño finamente picado." },
        { instruction: "Añade el jitomate picado si lo deseas." },
        { instruction: "Sazona con sal al gusto. Mezcla suavemente para integrar." },
        { instruction: "Prueba y ajusta los condimentos. Sirve inmediatamente con totopos." }
      ],
      equipment: ["Tazón", "Tenedor"]
    },
    fr: {
      name: "Guacamole",
      description: "Une sauce mexicaine simple mais légendaire préparée avec des avocats crémeux, du citron vert frais, de la coriandre et des tomates. Parfait en apéritif avec des chips de tortilla ou en garniture pour tacos et autres plats mexicains, ce favori des fêtes se prépare en quelques minutes.",
      ingredient_groups: [
        {
          name: "Ingrédients",
          items: [
            { name: "avocats", preparation: "mûrs, coupés en deux et dénoyautés" },
            { name: "citron vert", preparation: "jus fraîchement pressé" },
            { name: "sel", preparation: "selon le goût" },
            { name: "oignon blanc", preparation: "finement émincé" },
            { name: "coriandre", preparation: "fraîche, ciselée" },
            { name: "jalapeño (piment mexicain)", preparation: "émincé, épépiné" },
            { name: "tomate", preparation: "coupée en dés, facultatif" }
          ]
        }
      ],
      steps: [
        { instruction: "Couper les avocats en deux dans le sens de la longueur. Retirer le noyau et prélever la chair à l'aide d'une cuillère, puis la mettre dans un bol." },
        { instruction: "Verser immédiatement le jus de citron vert sur les avocats pour éviter qu'ils ne noircissent." },
        { instruction: "Écraser les avocats à la fourchette jusqu'à obtenir la consistance désirée. Laisser quelques morceaux." },
        { instruction: "Ajouter l'oignon blanc émincé, la coriandre ciselée et le jalapeño émincé." },
        { instruction: "Ajouter la tomate en dés si désiré." },
        { instruction: "Assaisonner avec du sel selon le goût. Mélanger délicatement." },
        { instruction: "Goûter et ajuster l'assaisonnement. Servir immédiatement avec des chips de tortilla." }
      ],
      equipment: ["Bol", "Fourchette"]
    }
  },
  "Ratatouille" => {
    ko: {
      name: "라타투이",
      description: "가지, 주키니호박, 파프리카, 토마토를 허브와 함께 푹 끓여낸 프랑스 프로방스 지방의 소박하고 색감이 아름다운 채소 스튜입니다. 따뜻하게 또는 상온으로 모두 맛있게 즐길 수 있어 손님 접대 요리로도 제격입니다.",
      ingredient_groups: [
        {
          name: "채소류",
          items: [
            { name: "가지", preparation: "깍둑썰기" },
            { name: "주키니호박 (서양 애호박)", preparation: "깍둑썰기" },
            { name: "파프리카", preparation: "깍둑썰기, 여러 색상 혼합" },
            { name: "토마토", preparation: "깍둑썰기 또는 캔 토마토" },
            { name: "양파", preparation: "깍둑썰기" }
          ]
        },
        {
          name: "양념 및 오일",
          items: [
            { name: "올리브 오일", preparation: nil },
            { name: "마늘", preparation: "다진 것" },
            { name: "타임 (백리향)", preparation: "건조" },
            { name: "바질 (나즐잎)", preparation: "건조" },
            { name: "소금과 후추", preparation: "기호에 맞게" }
          ]
        }
      ],
      steps: [
        { instruction: "크고 깊은 프라이팬에 올리브 오일을 넣고 중불로 가열합니다." },
        { instruction: "깍둑썬 양파를 넣고 부드러워질 때까지 3분간 볶습니다." },
        { instruction: "다진 마늘을 넣고 향이 날 때까지 1분간 볶습니다." },
        { instruction: "깍둑썬 가지와 파프리카를 넣고 가끔 저어주며 5분간 볶습니다." },
        { instruction: "깍둑썬 주키니호박과 토마토를 넣고 타임과 바질을 넣어 섞어줍니다." },
        { instruction: "불을 약하게 줄이고 뚜껑을 열어둔 채로 채소가 부드러워질 때까지 30분간 끓입니다." },
        { instruction: "가끔 저어주며 큰 채소 덩어리는 으깨줍니다." },
        { instruction: "소금과 후추로 기호에 맞게 간을 합니다." },
        { instruction: "따뜻하게 또는 상온으로 서빙합니다. 다음 날 먹으면 더욱 맛있습니다." }
      ],
      equipment: ["크고 깊은 프라이팬"]
    },
    zh_tw: {
      name: "普羅旺斯燉菜",
      description: "這道質樸而色彩繽紛的法國普羅旺斯蔬菜燉煮料理，以茄子、櫛瓜、甜椒和番茄搭配香草一同慢燉而成。這道百搭的料理無論溫熱或放涼食用都同樣美味，非常適合宴客時準備。",
      ingredient_groups: [
        {
          name: "蔬菜",
          items: [
            { name: "茄子", preparation: "切丁" },
            { name: "櫛瓜", preparation: "切丁" },
            { name: "甜椒", preparation: "切丁，混合多種顏色" },
            { name: "番茄", preparation: "切丁或使用罐頭" },
            { name: "洋蔥", preparation: "切丁" }
          ]
        },
        {
          name: "調味料與油",
          items: [
            { name: "橄欖油", preparation: nil },
            { name: "蒜頭", preparation: "切末" },
            { name: "百里香", preparation: "乾燥" },
            { name: "羅勒", preparation: "乾燥" },
            { name: "鹽和胡椒", preparation: "適量" }
          ]
        }
      ],
      steps: [
        { instruction: "在大型深煎鍋中倒入橄欖油，以中火加熱。" },
        { instruction: "加入洋蔥丁，拌炒約3分鐘至軟化。" },
        { instruction: "加入蒜末，拌炒約1分鐘至散發香氣。" },
        { instruction: "加入茄子丁和甜椒丁，不時翻炒，煮約5分鐘。" },
        { instruction: "加入櫛瓜丁和番茄，拌入百里香和羅勒。" },
        { instruction: "轉小火，不加蓋燉煮30分鐘，直到蔬菜變軟。" },
        { instruction: "期間不時翻攪，並將較大塊的蔬菜弄散。" },
        { instruction: "以鹽和胡椒調味至喜好的味道。" },
        { instruction: "可溫熱或放涼至室溫後食用。隔天風味更佳。" }
      ],
      equipment: ["大型深煎鍋"]
    },
    zh_cn: {
      name: "普罗旺斯杂烩（Ratatouille）",
      description: "一道质朴而色彩丰富的法式普罗旺斯蔬菜炖菜，以茄子、西葫芦、彩椒和番茄为主料，配以芳香草本慢炖而成。这道百搭的菜肴无论温热或常温食用都同样美味，非常适合宴客。",
      ingredient_groups: [
        {
          name: "蔬菜类",
          items: [
            { name: "茄子", preparation: "切丁" },
            { name: "西葫芦", preparation: "切丁" },
            { name: "彩椒", preparation: "切丁，多种颜色混合" },
            { name: "番茄", preparation: "切丁或使用罐头番茄" },
            { name: "洋葱", preparation: "切丁" }
          ]
        },
        {
          name: "调味料及油",
          items: [
            { name: "橄榄油", preparation: nil },
            { name: "大蒜", preparation: "切末" },
            { name: "百里香（Thyme，一种地中海香草）", preparation: "干燥" },
            { name: "罗勒（Basil，又称九层塔）", preparation: "干燥" },
            { name: "盐和胡椒", preparation: "适量" }
          ]
        }
      ],
      steps: [
        { instruction: "在大而深的煎锅中倒入橄榄油，以中火加热。" },
        { instruction: "加入洋葱丁，翻炒3分钟至软化。" },
        { instruction: "加入蒜末，翻炒1分钟至香气散发。" },
        { instruction: "加入茄子丁和彩椒丁，翻炒5分钟，期间偶尔翻动。" },
        { instruction: "加入西葫芦丁和番茄，拌入百里香和罗勒。" },
        { instruction: "转小火，不加盖炖煮30分钟，直至蔬菜变软。" },
        { instruction: "期间偶尔翻动，将较大的蔬菜块搅散。" },
        { instruction: "根据口味加入盐和胡椒调味。" },
        { instruction: "可趁热食用或放至常温享用。隔夜后风味更佳。" }
      ],
      equipment: ["大号深煎锅"]
    },
    es: {
      name: "Ratatouille",
      description: "Un guiso rústico y colorido de verduras de la Provenza francesa con berenjena, calabacín, pimientos y tomates cocidos a fuego lento con hierbas aromáticas. Este plato versátil es igualmente delicioso servido caliente o a temperatura ambiente, perfecto para recibir invitados.",
      ingredient_groups: [
        {
          name: "Verduras",
          items: [
            { name: "berenjena", preparation: "en cubos" },
            { name: "calabacín", preparation: "en cubos" },
            { name: "pimiento", preparation: "en cubos, colores variados" },
            { name: "tomates", preparation: "en cubos o enlatados" },
            { name: "cebolla", preparation: "en cubos" }
          ]
        },
        {
          name: "Condimentos y aceite",
          items: [
            { name: "aceite de oliva", preparation: nil },
            { name: "ajo", preparation: "picado" },
            { name: "tomillo", preparation: "seco" },
            { name: "albahaca", preparation: "seca" },
            { name: "sal y pimienta", preparation: "al gusto" }
          ]
        }
      ],
      steps: [
        { instruction: "Calentar el aceite de oliva en una sartén grande y profunda a fuego medio." },
        { instruction: "Añadir la cebolla en cubos y cocinar durante 3 minutos hasta que esté tierna." },
        { instruction: "Agregar el ajo picado y cocinar durante 1 minuto hasta que desprenda su aroma." },
        { instruction: "Añadir la berenjena y los pimientos en cubos. Cocinar durante 5 minutos, revolviendo ocasionalmente." },
        { instruction: "Agregar el calabacín y los tomates en cubos. Incorporar el tomillo y la albahaca." },
        { instruction: "Reducir el fuego a bajo y cocinar a fuego lento sin tapar durante 30 minutos hasta que las verduras estén tiernas." },
        { instruction: "Revolver ocasionalmente y desmenuzar los trozos grandes de verdura." },
        { instruction: "Sazonar con sal y pimienta al gusto." },
        { instruction: "Servir caliente o a temperatura ambiente. Sabe aún mejor al día siguiente." }
      ],
      equipment: ["Sartén grande y profunda"]
    },
    ja: {
      name: "ラタトゥイユ",
      description: "フランス・プロヴァンス地方の素朴で彩り豊かな野菜の煮込み料理。なす、ズッキーニ、パプリカ、トマトを香り高いハーブと一緒にじっくり煮込みます。温かくても常温でも美味しく、おもてなし料理にぴったりの一品です。",
      ingredient_groups: [
        {
          name: "野菜",
          items: [
            { name: "なす", preparation: "角切り" },
            { name: "ズッキーニ", preparation: "角切り" },
            { name: "パプリカ", preparation: "角切り、数色混ぜて" },
            { name: "トマト", preparation: "角切りまたは缶詰" },
            { name: "玉ねぎ", preparation: "角切り" }
          ]
        },
        {
          name: "調味料・油",
          items: [
            { name: "オリーブオイル", preparation: nil },
            { name: "にんにく", preparation: "みじん切り" },
            { name: "タイム", preparation: "乾燥" },
            { name: "バジル", preparation: "乾燥" },
            { name: "塩こしょう", preparation: "適量" }
          ]
        }
      ],
      steps: [
        { instruction: "大きめの深いフライパンにオリーブオイルを入れ、中火で熱する。" },
        { instruction: "角切りにした玉ねぎを加え、しんなりするまで3分ほど炒める。" },
        { instruction: "みじん切りにしたにんにくを加え、香りが立つまで1分ほど炒める。" },
        { instruction: "角切りにしたなすとパプリカを加え、時々かき混ぜながら5分ほど炒める。" },
        { instruction: "角切りにしたズッキーニとトマトを加え、タイムとバジルを混ぜ合わせる。" },
        { instruction: "火を弱め、蓋をせずに野菜が柔らかくなるまで30分ほど煮込む。" },
        { instruction: "時々かき混ぜ、大きな野菜があれば崩す。" },
        { instruction: "塩こしょうで味を調える。" },
        { instruction: "温かいまま、または常温で盛り付ける。翌日はさらに美味しくなります。" }
      ],
      equipment: ["大きめの深いフライパン"]
    },
    fr: {
      name: "Ratatouille",
      description: "Un ragoût de légumes rustique et coloré de la Provence, composé d'aubergines, de courgettes, de poivrons et de tomates mijotés ensemble avec des herbes aromatiques. Ce plat polyvalent est aussi délicieux servi chaud qu'à température ambiante, ce qui en fait un choix parfait pour recevoir.",
      ingredient_groups: [
        {
          name: "Légumes",
          items: [
            { name: "aubergine", preparation: "en dés" },
            { name: "courgette", preparation: "en dés" },
            { name: "poivron", preparation: "en dés, couleurs mélangées" },
            { name: "tomates", preparation: "en dés ou en conserve" },
            { name: "oignon", preparation: "en dés" }
          ]
        },
        {
          name: "Assaisonnements et huile",
          items: [
            { name: "huile d'olive", preparation: nil },
            { name: "ail", preparation: "émincé" },
            { name: "thym", preparation: "séché" },
            { name: "basilic", preparation: "séché" },
            { name: "sel et poivre", preparation: "selon le goût" }
          ]
        }
      ],
      steps: [
        { instruction: "Faire chauffer l'huile d'olive dans une grande poêle profonde à feu moyen." },
        { instruction: "Ajouter l'oignon en dés et faire revenir pendant 3 minutes jusqu'à ce qu'il soit ramolli." },
        { instruction: "Ajouter l'ail émincé et faire revenir pendant 1 minute jusqu'à ce qu'il soit parfumé." },
        { instruction: "Ajouter l'aubergine et les poivrons en dés. Faire cuire pendant 5 minutes en remuant de temps en temps." },
        { instruction: "Ajouter la courgette et les tomates en dés. Incorporer le thym et le basilic." },
        { instruction: "Réduire le feu à doux et laisser mijoter à découvert pendant 30 minutes jusqu'à ce que les légumes soient tendres." },
        { instruction: "Remuer de temps en temps et écraser les gros morceaux de légumes." },
        { instruction: "Assaisonner de sel et de poivre selon le goût." },
        { instruction: "Servir chaud ou à température ambiante. Encore meilleur le lendemain." }
      ],
      equipment: ["Grande poêle profonde"]
    }
  },
  "Chicken Teriyaki" => {
    ja: {
      name: "鶏の照り焼き",
      description: "甘辛い自家製照り焼きソースで焼き上げた、日本の定番料理です。手軽に作れるのに、おもてなしにもぴったりの一品。炊きたてのご飯と新鮮な野菜を添えてお召し上がりください。",
      ingredient_groups: [
        {
          name: "鶏肉",
          items: [
            { name: "鶏もも肉", preparation: "皮なし、骨なし、5cm角に切る" },
            { name: "塩こしょう", preparation: "適量" }
          ]
        },
        {
          name: "照り焼きソース",
          items: [
            { name: "醤油", preparation: nil },
            { name: "みりん", preparation: nil },
            { name: "酒", preparation: nil },
            { name: "砂糖", preparation: nil },
            { name: "にんにく", preparation: "みじん切り" },
            { name: "生姜", preparation: "すりおろす" }
          ]
        },
        {
          name: "盛り付け用",
          items: [
            { name: "ご飯", preparation: "炊きたて" },
            { name: "小ねぎ", preparation: "小口切り" },
            { name: "白ごま", preparation: "炒りごま" }
          ]
        }
      ],
      steps: [
        { instruction: "小鍋に醤油、みりん、酒、砂糖を入れて混ぜ合わせる。" },
        { instruction: "みじん切りにしたにんにくとすりおろした生姜を加え、中火で煮立たせる。" },
        { instruction: "5分ほど煮詰めて、ソースに少しとろみがついたら火から下ろしておく。" },
        { instruction: "鶏肉に塩こしょうで下味をつける。" },
        { instruction: "フライパンまたはグリルパンを中強火で熱し、鶏肉を並べる。" },
        { instruction: "両面を各4〜5分ずつ、こんがりと焼き色がつき中まで火が通るまで焼く。" },
        { instruction: "フライパンの鶏肉に照り焼きソースを回しかける。" },
        { instruction: "鶏肉を返しながらソースを全体に絡め、2〜3分煮詰めて照りを出す。" },
        { instruction: "炊きたてのご飯の上に鶏肉とソースを盛り付け、小ねぎと白ごまを散らして完成。" }
      ],
      equipment: ["フライパン", "小鍋"]
    },
    ko: {
      name: "치킨 데리야끼",
      description: "달콤하고 짭짤한 홈메이드 데리야끼 소스로 윤기 나게 구운 일본의 대표 요리입니다. 간단하게 준비할 수 있으면서도 손님 접대용으로도 손색없는 이 요리는 따뜻한 밥과 신선한 채소와 함께 곁들이면 가장 맛있습니다.",
      ingredient_groups: [
        {
          name: "닭고기",
          items: [
            { name: "닭 넓적다리살", preparation: "뼈와 껍질 제거, 5cm 크기로 자르기" },
            { name: "소금과 후추", preparation: "적당량" }
          ]
        },
        {
          name: "데리야끼 소스",
          items: [
            { name: "간장", preparation: nil },
            { name: "미림", preparation: nil },
            { name: "사케 (일본 청주)", preparation: nil },
            { name: "설탕", preparation: nil },
            { name: "마늘", preparation: "다지기" },
            { name: "생강", preparation: "갈기" }
          ]
        },
        {
          name: "곁들임",
          items: [
            { name: "밥", preparation: "따뜻하게 지은 것" },
            { name: "파", preparation: "송송 썰기" },
            { name: "참깨", preparation: "볶은 것" }
          ]
        }
      ],
      steps: [
        { instruction: "작은 냄비에 간장, 미림, 사케, 설탕을 넣고 섞어줍니다." },
        { instruction: "다진 마늘과 간 생강을 넣고 중불에서 끓입니다." },
        { instruction: "약 5분간 끓여 소스가 살짝 걸쭉해지면 불을 끄고 따로 둡니다." },
        { instruction: "닭고기에 소금과 후추로 간을 합니다." },
        { instruction: "큰 프라이팬이나 그릴팬을 중강불로 달군 후 닭고기를 올립니다." },
        { instruction: "닭고기 양면을 각각 4-5분씩 노릇하게 익을 때까지 구워줍니다." },
        { instruction: "준비해둔 데리야끼 소스를 팬의 닭고기 위에 부어줍니다." },
        { instruction: "닭고기에 소스가 골고루 입혀지도록 뒤적이며 2-3분간 소스가 약간 캐러멜화될 때까지 조립니다." },
        { instruction: "따뜻한 밥 위에 닭고기와 소스를 올리고 파와 참깨를 뿌려 완성합니다." }
      ],
      equipment: ["큰 프라이팬", "냄비"]
    },
    zh_tw: {
      name: "日式照燒雞",
      description: "這道深受喜愛的日本料理，以甜鹹醬汁醃製燒烤的雞肉為特色，搭配自製的照燒醬。製作快速卻不失精緻，非常適合宴客。最佳享用方式是搭配白飯和新鮮蔬菜。",
      ingredient_groups: [
        {
          name: "雞肉",
          items: [
            { name: "雞腿肉", preparation: "去骨去皮，切成約5公分塊狀" },
            { name: "鹽和胡椒", preparation: "適量" }
          ]
        },
        {
          name: "照燒醬",
          items: [
            { name: "醬油", preparation: nil },
            { name: "味醂（日式甜料酒）", preparation: nil },
            { name: "清酒", preparation: nil },
            { name: "糖", preparation: nil },
            { name: "蒜頭", preparation: "切末" },
            { name: "薑", preparation: "磨成泥" }
          ]
        },
        {
          name: "配菜",
          items: [
            { name: "白飯", preparation: "熱騰騰的蒸飯" },
            { name: "青蔥", preparation: "切成蔥花" },
            { name: "白芝麻", preparation: "烘烤過" }
          ]
        }
      ],
      steps: [
        { instruction: "在小湯鍋中，將醬油、味醂、清酒和糖混合均勻。" },
        { instruction: "加入蒜末和薑泥，以中火煮至微滾。" },
        { instruction: "小火煨煮5分鐘，直到醬汁稍微濃稠。取出備用。" },
        { instruction: "將雞肉塊以鹽和胡椒調味。" },
        { instruction: "將大平底鍋或煎烤盤以中大火加熱，放入雞肉塊。" },
        { instruction: "每面煎4-5分鐘，直到表面金黃且熟透。" },
        { instruction: "將備好的照燒醬倒入鍋中與雞肉拌合。" },
        { instruction: "翻炒雞肉使其均勻裹上醬汁，續煮2-3分鐘直到醬汁微微焦糖化。" },
        { instruction: "將雞肉連同醬汁盛在熱白飯上，撒上蔥花和白芝麻即可享用。" }
      ],
      equipment: ["大平底鍋", "湯鍋"]
    },
    zh_cn: {
      name: "日式照烧鸡",
      description: "一道深受喜爱的日本料理，以甜咸酱汁腌制烤制的鸡肉为特色。这道菜准备简单却足够惊艳，适合宴客。搭配热腾腾的米饭和新鲜蔬菜食用最佳。",
      ingredient_groups: [
        {
          name: "鸡肉",
          items: [
            { name: "鸡腿肉", preparation: "去骨去皮，切成5厘米块" },
            { name: "盐和胡椒粉", preparation: "适量" }
          ]
        },
        {
          name: "照烧酱",
          items: [
            { name: "酱油", preparation: nil },
            { name: "味淋（日式甜料酒）", preparation: nil },
            { name: "清酒（日式料酒）", preparation: nil },
            { name: "白糖", preparation: nil },
            { name: "大蒜", preparation: "切末" },
            { name: "生姜", preparation: "磨碎" }
          ]
        },
        {
          name: "配餐",
          items: [
            { name: "米饭", preparation: "热的，蒸好的" },
            { name: "小葱", preparation: "切葱花" },
            { name: "芝麻", preparation: "烘烤过的" }
          ]
        }
      ],
      steps: [
        { instruction: "在小锅中，将酱油、味淋、清酒和白糖混合。" },
        { instruction: "加入蒜末和姜末，中火加热至微沸。" },
        { instruction: "小火煮5分钟，直至酱汁稍微浓稠。备用。" },
        { instruction: "用盐和胡椒粉给鸡块调味。" },
        { instruction: "大火预热平底锅或煎烤锅，放入鸡块。" },
        { instruction: "每面煎4-5分钟，直至表面金黄、完全熟透。" },
        { instruction: "将准备好的照烧酱倒入锅中。" },
        { instruction: "翻炒鸡块使其均匀裹上酱汁。继续煮2-3分钟，直至酱汁微微焦糖化。" },
        { instruction: "将鸡肉和酱汁盛在热米饭上，撒上葱花和芝麻即可享用。" }
      ],
      equipment: ["大平底锅", "小炖锅"]
    },
    es: {
      name: "Pollo Teriyaki",
      description: "Un plato japonés muy apreciado que presenta pollo glaseado y asado con una salsa teriyaki casera dulce y salada. Rápido de preparar pero lo suficientemente impresionante para recibir invitados, este plato se sirve mejor sobre arroz al vapor con verduras frescas.",
      ingredient_groups: [
        {
          name: "Pollo",
          items: [
            { name: "muslos de pollo", preparation: "deshuesados, sin piel, cortados en trozos de 5 cm" },
            { name: "sal y pimienta", preparation: "al gusto" }
          ]
        },
        {
          name: "Salsa Teriyaki",
          items: [
            { name: "salsa de soja", preparation: nil },
            { name: "mirin (vino de arroz dulce japonés)", preparation: nil },
            { name: "sake (vino de arroz japonés)", preparation: nil },
            { name: "azúcar", preparation: nil },
            { name: "ajo", preparation: "picado" },
            { name: "jengibre", preparation: "rallado" }
          ]
        },
        {
          name: "Para Servir",
          items: [
            { name: "arroz cocido", preparation: "caliente, al vapor" },
            { name: "cebolletas", preparation: "en rodajas" },
            { name: "semillas de sésamo", preparation: "tostadas" }
          ]
        }
      ],
      steps: [
        { instruction: "En una cacerola pequeña, combinar la salsa de soja, el mirin, el sake y el azúcar." },
        { instruction: "Añadir el ajo picado y el jengibre rallado. Llevar a ebullición suave a fuego medio." },
        { instruction: "Cocinar a fuego lento durante 5 minutos hasta que la salsa espese ligeramente. Reservar." },
        { instruction: "Sazonar los trozos de pollo con sal y pimienta." },
        { instruction: "Calentar una sartén grande o plancha a fuego medio-alto. Añadir los trozos de pollo." },
        { instruction: "Cocinar el pollo durante 4-5 minutos por cada lado hasta que esté dorado y completamente cocido." },
        { instruction: "Verter la salsa teriyaki preparada sobre el pollo en la sartén." },
        { instruction: "Mezclar el pollo para cubrirlo uniformemente. Cocinar durante 2-3 minutos hasta que la salsa se caramelice ligeramente." },
        { instruction: "Servir el pollo con la salsa sobre el arroz caliente al vapor. Decorar con cebolletas y semillas de sésamo." }
      ],
      equipment: ["Sartén grande", "Cacerola"]
    },
    fr: {
      name: "Poulet Teriyaki",
      description: "Un plat japonais très apprécié composé de poulet glacé et grillé nappé d'une sauce teriyaki maison sucrée-salée. Rapide à préparer mais suffisamment élégant pour recevoir, ce plat se déguste idéalement sur un lit de riz vapeur accompagné de légumes frais.",
      ingredient_groups: [
        {
          name: "Poulet",
          items: [
            { name: "hauts de cuisses de poulet", preparation: "désossés, sans peau, coupés en morceaux de 5 cm" },
            { name: "sel et poivre", preparation: "selon le goût" }
          ]
        },
        {
          name: "Sauce Teriyaki",
          items: [
            { name: "sauce soja", preparation: nil },
            { name: "mirin (vin de riz doux japonais)", preparation: nil },
            { name: "saké (alcool de riz japonais)", preparation: nil },
            { name: "sucre", preparation: nil },
            { name: "ail", preparation: "émincé" },
            { name: "gingembre", preparation: "râpé" }
          ]
        },
        {
          name: "Pour servir",
          items: [
            { name: "riz cuit", preparation: "chaud, cuit à la vapeur" },
            { name: "ciboules", preparation: "émincées" },
            { name: "graines de sésame", preparation: "torréfiées" }
          ]
        }
      ],
      steps: [
        { instruction: "Dans une petite casserole, mélanger la sauce soja, le mirin, le saké et le sucre." },
        { instruction: "Ajouter l'ail émincé et le gingembre râpé. Porter à frémissement à feu moyen." },
        { instruction: "Laisser mijoter 5 minutes jusqu'à ce que la sauce épaississe légèrement. Réserver." },
        { instruction: "Assaisonner les morceaux de poulet avec le sel et le poivre." },
        { instruction: "Faire chauffer une grande poêle ou un gril à feu vif. Ajouter les morceaux de poulet." },
        { instruction: "Cuire le poulet 4 à 5 minutes de chaque côté jusqu'à ce qu'il soit doré et bien cuit à cœur." },
        { instruction: "Verser la sauce teriyaki préparée sur le poulet dans la poêle." },
        { instruction: "Remuer le poulet pour bien l'enrober. Cuire 2 à 3 minutes jusqu'à ce que la sauce caramélise légèrement." },
        { instruction: "Servir le poulet et sa sauce sur un lit de riz vapeur chaud. Garnir de ciboules et de graines de sésame." }
      ],
      equipment: ["Grande poêle", "Casserole"]
    }
  }
}.freeze
