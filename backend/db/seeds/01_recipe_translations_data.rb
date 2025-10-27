# Recipe Translation Data - Compact format for seeding
# This file contains translations for all 15 recipes in 6 languages

def deep_symbolize_keys(hash)
  hash.transform_keys { |k| k.to_sym }.transform_values do |v|
    case v
    when Hash
      deep_symbolize_keys(v)
    when Array
      v.map { |item| item.is_a?(Hash) ? deep_symbolize_keys(item) : item }
    else
      v
    end
  end
end

RECIPE_TRANSLATIONS = deep_symbolize_keys(YAML.safe_load(<<~YAML))
  margherita:
    ja:
      name: マルゲリータピザ
      description: カリカリの生地、酸っぱいトマトソース、クリーミーなフレッシュモッツァレラ、香り高いバジルを組み合わせた、イタリアン・ナポリタンピザの最高峰。シンプルな材料を最小限の準備で仕上げるという哲学を示す一品です。
    ko:
      name: 마르게리타 피자
      description: 바삭한 크러스트, 톡 쏘는 토마토 소스, 크리미한 신선한 모짜렐라, 향긋한 바질을 완벽하게 조합한 이탈리아 나폴리 피자의 대표주자. 질 좋은 재료는 최소한의 준비로 충분하다는 철학을 보여주는 클래식입니다.
    zh_tw:
      name: 瑪格麗塔披薩
      description: 結合酥脆外皮、酸番茄醬、奶油新鮮莫札瑞拉起司和香氣十足羅勒的義大利拿坡里經典披薩。這道菜展現了高品質食材只需最少的準備工作就能完成的烹飪哲學。
    zh_cn:
      name: 玛格丽塔披萨
      description: 结合酥脆外皮、酸番茄酱、奶油新鲜莫萨里拉奶酪和香气十足罗勒的意大利那不勒斯经典披萨。这道菜展现了高品质食材只需最少的准备工作就能完成的烹饪哲学。
    es:
      name: Pizza Margherita
      description: La pizza italiana más icónica que combina una corteza crujiente, salsa de tomate ácida, mozzarella fresca cremosa y albahaca aromática. Este clásico de Nápoles demuestra la filosofía de que los ingredientes de calidad requieren una preparación mínima.
    fr:
      name: Pizza Margherita
      description: La pizza italienne emblématique combinant une croûte croustillante, une sauce tomate acidulée, de la mozzarella fraîche crémeuse et du basilic aromatique. Ce classique napolitain démontre la philosophie selon laquelle les ingrédients de qualité nécessitent un minimum de préparation.

  pad_thai:
    ja:
      name: パッタイ
      description: 米の麺、エビ、豆もやし、唐辛子を使った本格的なタイ式炒め麺。甘辛い味わいが特徴で、タイの国民食として愛されています。
    ko:
      name: 팟타이
      description: 쌀국수, 새우, 콩나물, 고추를 사용한 정통 태국식 볶음국수. 달콤한 맛이 특징이며 태국의 국민음식입니다.
    zh_tw:
      name: 泰式炒河粉
      description: 用米河粉、蝦、豆芽和辣椒做成的道地泰國炒麵。甜辣的滋味是其特色，是泰國的國民美食。
    zh_cn:
      name: 泰式炒河粉
      description: 用米河粉、虾、豆芽和辣椒做成的地道泰国炒面。甜辣的滋味是其特色，是泰国的国民美食。
    es:
      name: Pad Thai
      description: Fideos de arroz salteados auténticos con camarones, brotes de soja y chiles. Tienen un sabor dulce-salado que es característico y es el plato nacional tailandés.
    fr:
      name: Pad Thai
      description: Nouilles de riz sautées authentiques avec crevettes, germes de soja et piments. Elles ont une saveur douce-salée caractéristique et c'est le plat national thaïlandais.

  shakshuka:
    ja:
      name: シャクシューカ
      description: トマトソースに卵を落とした中東の伝統料理。スパイスが効いた温かい朝食やブランチとして人気があります。
    ko:
      name: 샥슈카
      description: 토마토 소스에 계란을 넣은 중동의 전통 요리입니다. 향신료가 들어간 따뜻한 아침 식사 또는 브런치로 인기가 있습니다。
    zh_tw:
      name: 番茄煎蛋
      description: 在番茄醬中加入雞蛋的中東傳統菜餚。這是一道充滿香料的溫暖早餐或午餐選擇。
    zh_cn:
      name: 番茄煎蛋
      description: 在番茄酱中加入鸡蛋的中东传统菜肴。这是一道充满香料的温暖早餐或午餐选择。
    es:
      name: Shakshuka
      description: Plato tradicional de Oriente Medio con huevos en salsa de tomate. Es un desayuno o almuerzo cálido y especiado muy popular.
    fr:
      name: Shakshuka
      description: Plat traditionnel du Moyen-Orient avec des œufs dans une sauce tomate. C'est un petit-déjeuner ou déjeuner chaud et épicé très populaire.

  tom_yum:
    ja:
      name: トムヤムスープ
      description: タイの代表的なスープで、唐辛子、レモングラス、ガランガルの香りが特徴。酸っぱくて辛い味わいです。
    ko:
      name: 똠얌
      description: 태국의 대표적인 스ープ로, 고추, 레몬그라스, 갈랑갈의 향이 특징입니다. 시고 맵고 향긋한 맛이 특징입니다.
    zh_tw:
      name: 冬陰功湯
      description: 泰國代表性湯品，以辣椒、香茅、南薑香氣為特色。酸、辣、香氣十足的風味。
    zh_cn:
      name: 冬阴功汤
      description: 泰国代表性汤品，以辣椒、香茅、南姜香气为特色。酸、辣、香气十足的风味。
    es:
      name: Tom Yum
      description: Sopa tailandesa representativa con aromas de chile, hierba de limón y galanga. Tiene un sabor agrio, picante y aromático.
    fr:
      name: Tom Yum
      description: Soupe thaïlandaise représentative avec des arômes de piment, de citronnelle et de galanga. Elle a un goût aigre, épicé et aromatique.

  aglio_olio:
    ja:
      name: スパゲッティ・アーリオ・エ・オーリオ
      description: イタリアの最もシンプルなパスタ料理。ニンニク、唐辛子、オリーブオイルだけでシンプルながら深い味わいを実現。
    ko:
      name: 스파게티 알리오 올리오
      description: 이탈리아의 가장 간단한 파스타 요리. 마늘, 고추, 올리브유만으로 단순하면서도 깊은 맛을 연출합니다.
    zh_tw:
      name: 大蒜油義大利麵
      description: 義大利最簡單的義大利麵料理。只用大蒜、辣椒和橄欖油就能呈現出簡單卻深邃的風味。
    zh_cn:
      name: 大蒜油意大利面
      description: 意大利最简单的意大利面料理。只用大蒜、辣椒和橄榄油就能呈现出简单却深邃的风味。
    es:
      name: Spaghetti Aglio e Olio
      description: El plato de pasta italiano más simple. Con solo ajo, chile y aceite de oliva se consigue un sabor simple pero profundo.
    fr:
      name: Spaghetti Aglio e Olio
      description: Le plat de pâtes italien le plus simple. Avec juste de l'ail, du piment et de l'huile d'olive, on obtient une saveur simple mais profonde.

  oyakodon:
    ja:
      name: 親子丼
      description: 鶏肉と卵を使った日本の伝統的な丼。とろける食感と深い味わいが特徴で、日本人に最も愛されている家庭料理の一つです。
    ko:
      name: 오야코돈
      description: 닭고기와 계란으로 만든 일본의 전통 덮밥. 부드러운 식감과 깊은 맛이 특징이며, 일본인들이 가장 사랑하는 가정식 중 하나입니다.
    zh_tw:
      name: 親子丼
      description: 用雞肉和雞蛋做成的日本傳統蓋飯。以柔軟的口感和深邃的風味著稱，是日本人最喜愛的家常菜之一。
    zh_cn:
      name: 亲子丼
      description: 用鸡肉和鸡蛋做成的日本传统盖饭。以柔软的口感和深邃的风味著称，是日本人最喜爱的家常菜之一。
    es:
      name: Oyakodon
      description: Un plato japonés tradicional hecho con pollo y huevo. Se caracteriza por su textura suave y profundo sabor, y es uno de los platos caseros más amados por los japoneses.
    fr:
      name: Oyakodon
      description: Un plat japonais traditionnel fait avec du poulet et un œuf. Il se caractérise par sa texture douce et sa saveur profonde, et c'est l'un des plats familiaux les plus aimés des Japonais.

  greek_salad:
    ja:
      name: ギリシャサラダ
      description: トマト、キュウリ、フェタチーズ、オリーブで作るシンプルで爽やかなサラダ。地中海を代表する健康的な一品。
    ko:
      name: 그릭 샐러드
      description: 토마토, 오이, 페타 치즈, 올리브로 만든 간단하고 상큼한 샐러드. 지중해를 대표하는 건강한 요리입니다.
    zh_tw:
      name: 希臘沙拉
      description: 番茄、黃瓜、羊乳起司和橄欖製成的簡單清爽沙拉。地中海代表性的健康菜餚。
    zh_cn:
      name: 希腊沙拉
      description: 番茄、黄瓜、羊乳酪和橄榄制成的简单清爽沙拉。地中海代表性的健康菜肴。
    es:
      name: Ensalada Griega
      description: Ensalada simple y refrescante hecha con tomate, pepino, queso feta y aceitunas. Un plato saludable representativo del Mediterráneo.
    fr:
      name: Salade Grecque
      description: Salade simple et rafraîchissante faite avec des tomates, des concombres, du fromage feta et des olives. Un plat sain représentatif de la Méditerranée.

  sourdough:
    ja:
      name: サワードゥブレッド
      description: 自然発酵種で作った酸味が特徴のパン。深い風味とクリスピーな皮が特徴で、伝統的なベーカリーの代表的なパンです。
    ko:
      name: 사워도우 브레드
      description: 천연 발효종으로 만든 신맛이 특징인 빵입니다. 깊은 풍미와 바삭한 껍질이 특징이며, 전통 베이커리를 대표하는 빵입니다.
    zh_tw:
      name: 酸種麵包
      description: 用天然發酵種製作的酸味特色麵包。深邃的風味和脆皮是其特徵，是傳統麵包店的代表麵包。
    zh_cn:
      name: 酸种面包
      description: 用天然发酵种制作的酸味特色面包。深邃的风味和脆皮是其特征，是传统面包店的代表面包。
    es:
      name: Pan de Masa Madre
      description: Pan con sabor ácido hecho con un iniciador de fermentación natural. Se caracteriza por su profundo sabor y corteza crujiente, y es un pan representativo de las panaderías tradicionales.
    fr:
      name: Pain au Levain
      description: Pain au goût aigre fait avec un levain de fermentation naturelle. Il se caractérise par sa profonde saveur et sa croûte croustillante, et c'est un pain représentatif des boulangeries traditionnelles.

  beef_tacos:
    ja:
      name: ビーフタコス
      description: スパイスを効かせた牛肉とサルサを使ったメキシコの伝統料理。トルティーヤに包まれたジューシーな一品です。
    ko:
      name: 비프 타코
      description: 향신료가 곁들인 소고기와 살사를 사용한 멕시코 전통 요리. 토르티야에 싸인 육즙 많은 한 접시입니다.
    zh_tw:
      name: 牛肉玉米捲
      description: 用香料牛肉和莎莎醬製作的墨西哥傳統菜餚。用玉米粉薄餅包裹的多汁佳餚。
    zh_cn:
      name: 牛肉玉米卷
      description: 用香料牛肉和莎莎酱制作的墨西哥传统菜肴。用玉米粉薄饼包裹的多汁佳肴。
    es:
      name: Tacos de Carne de Res
      description: Plato tradicional mexicano hecho con carne de res sazonada y salsa. Un delicioso plato de carne jugosa envuelta en tortillas.
    fr:
      name: Tacos de Boeuf
      description: Plat mexicain traditionnel fait avec du boeuf assaisonné et de la salsa. Un délicieux plat de viande juteux enveloppé dans des tortillas.

  kimchi_jjigae:
    ja:
      name: キムチチゲ
      description: キムチ、豆腐、豚肉またはツナを使った辛い韓国の鍋料理
    ko:
      name: 김치찌개
      description: 김치, 두부, 돼지고기 또는 참치로 만든 얼큰한 한국 찌개
    zh_tw:
      name: 泡菜鍋
      description: 用泡菜、豆腐和豬肉或鮪魚製作的辣味韓式燉菜
    zh_cn:
      name: 泡菜锅
      description: 用泡菜、豆腐和猪肉或金枪鱼制作的辣味韩式炖菜
    es:
      name: Kimchi Jjigae
      description: Un guiso coreano picante hecho con kimchi, tofu y cerdo o atún
    fr:
      name: Kimchi Jjigae
      description: Un ragoût coréen épicé fait avec du kimchi, du tofu et du porc ou du thon

  onion_soup:
    ja:
      name: フレンチオニオンスープ
      description: キャラメリゼした玉ねぎと溶けたグリュイエールチーズの伝統的なフランス風スープ
    ko:
      name: 프렌치 어니언 수프
      description: 캐러멜라이즈한 양파와 녹인 그뤼에르 치즈를 곁들인 클래식 프렌치 수프
    zh_tw:
      name: 法式洋蔥湯
      description: 經典法式湯品，配有焦糖洋蔥和融化的格呂耶爾起司
    zh_cn:
      name: 法式洋葱汤
      description: 经典法式汤品，配有焦糖洋葱和融化的格鲁耶尔奶酪
    es:
      name: Sopa de Cebolla Francesa
      description: Sopa francesa clásica con cebollas caramelizadas y queso Gruyère derretido
    fr:
      name: Soupe à l'Oignon
      description: Soupe française classique avec oignons caramélisés et fromage Gruyère fondu

  cookies:
    ja:
      name: チョコレートチップクッキー
      description: アメリカの定番クッキー、チョコレートチップ入り - サクサクの縁としっとりした中心
    ko:
      name: 초콜릿 칩 쿠키
      description: 초콜릿 칩이 들어간 미국 전통 쿠키 - 바삭한 가장자리와 쫄깃한 중심
    zh_tw:
      name: 巧克力豆餅乾
      description: 經典美式巧克力豆餅乾 - 酥脆邊緣與Q彈中心
    zh_cn:
      name: 巧克力豆曲奇
      description: 经典美式巧克力豆曲奇 - 酥脆边缘与软糯中心
    es:
      name: Galletas con Chispas de Chocolate
      description: Galletas americanas clásicas con chispas de chocolate - bordes crujientes y centro masticable
    fr:
      name: Cookies aux Pépites de Chocolat
      description: Cookies américains classiques aux pépites de chocolat - bords croustillants et centre moelleux

  guacamole:
    ja:
      name: ワカモレ
      description: ライムとコリアンダーを使った新鮮でクリーミーなメキシコ風アボカドディップ
    ko:
      name: 과카몰리
      description: 라임과 고수를 곁들인 신선하고 크리미한 멕시코 아보카도 딥
    zh_tw:
      name: 酪梨醬
      description: 新鮮滑順的墨西哥酪梨醬，搭配萊姆和香菜
    zh_cn:
      name: 鳄梨酱
      description: 新鲜顺滑的墨西哥鳄梨酱，搭配青柠和香菜
    es:
      name: Guacamole
      description: Dip mexicano de aguacate fresco y cremoso con lima y cilantro
    fr:
      name: Guacamole
      description: Trempette mexicaine à l'avocat fraîche et crémeuse avec citron vert et coriandre

  ratatouille:
    ja:
      name: ラタトゥイユ
      description: ナス、ズッキーニ、トマトを使った伝統的なプロヴァンス風野菜煮込み
    ko:
      name: 라따뚜이
      description: 가지, 주키니, 토마토를 사용한 클래식 프로방스 스타일 야채 스튜
    zh_tw:
      name: 普羅旺斯燉菜
      description: 經典普羅旺斯風味蔬菜燉菜，包含茄子、櫛瓜和番茄
    zh_cn:
      name: 普罗旺斯炖菜
      description: 经典普罗旺斯风味蔬菜炖菜，包含茄子、西葫芦和番茄
    es:
      name: Ratatouille
      description: Guiso clásico de verduras provenzales con berenjena, calabacín y tomates
    fr:
      name: Ratatouille
      description: Ragoût classique de légumes provençaux aux aubergines, courgettes et tomates

  teriyaki:
    ja:
      name: 照り焼きチキン
      description: 甘辛い照り焼きソースで艶やかに仕上げた日本の鶏肉料理
    ko:
      name: 치킨 데리야끼
      description: 데리야끼 소스로 윤기나게 구운 달콤하고 짭짤한 일본식 닭고기 요리
    zh_tw:
      name: 照燒雞
      description: 淋上照燒醬汁的甜鹹日式雞肉料理
    zh_cn:
      name: 照烧鸡
      description: 淋上照烧酱汁的甜咸日式鸡肉料理
    es:
      name: Pollo Teriyaki
      description: Pollo japonés dulce y salado glaseado con salsa teriyaki
    fr:
      name: Poulet Teriyaki
      description: Poulet japonais sucré-salé glacé à la sauce teriyaki
YAML
