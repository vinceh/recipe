# Standardized Cuisine Types Reference

This document defines all allowed cuisine types for recipes.

**Coverage:** This list includes all 20 Edamam standard cuisines plus 80+ additional specific regional cuisines for better granularity.

**Edamam Compatibility:** All Edamam cuisines map to our list:
- American ✓, Asian ✓ (broad - we have specific), British ✓, Caribbean ✓ (via caribbean), Central Europe ✓ (via polish, german, etc.), Chinese ✓, Eastern Europe ✓ (via russian, ukrainian, polish), French ✓, Greek ✓, Indian ✓, Italian ✓, Japanese ✓, Korean ✓, Kosher ✓ (via kosher tag), Mediterranean ✓ (via mediterranean), Mexican ✓, Middle Eastern ✓ (via middle_eastern), Nordic ✓ (via scandinavian), South American ✓ (via brazilian, peruvian, etc.), South East Asian ✓ (via thai, vietnamese, etc.)

## Cuisine Classification

**Key**: `cuisines`
**Type**: Array of strings
**Purpose**: Categorize recipes by cultural/regional origin
**Format**: lowercase with underscores

### Allowed Values

```yaml
# Asian Cuisines
- japanese            # Japanese cuisine
- korean              # Korean cuisine
- chinese             # Chinese cuisine (general)
- cantonese           # Cantonese/Hong Kong cuisine
- sichuan             # Sichuan/Szechuan cuisine
- taiwanese           # Taiwanese cuisine
- thai                # Thai cuisine
- vietnamese          # Vietnamese cuisine
- filipino            # Filipino cuisine
- indonesian          # Indonesian cuisine
- malaysian           # Malaysian cuisine
- singaporean         # Singaporean cuisine
- indian              # Indian cuisine (general)
- north_indian        # North Indian cuisine
- south_indian        # South Indian cuisine
- pakistani           # Pakistani cuisine
- bangladeshi         # Bangladeshi cuisine
- nepalese            # Nepalese cuisine
- sri_lankan          # Sri Lankan cuisine
- burmese             # Burmese/Myanmar cuisine
- cambodian           # Cambodian/Khmer cuisine
- laotian             # Laotian cuisine
- mongolian           # Mongolian cuisine

# European Cuisines
- italian             # Italian cuisine
- french              # French cuisine
- spanish             # Spanish cuisine
- greek               # Greek cuisine
- portuguese          # Portuguese cuisine
- german              # German cuisine
- austrian            # Austrian cuisine
- swiss               # Swiss cuisine
- polish              # Polish cuisine
- russian             # Russian cuisine
- ukrainian           # Ukrainian cuisine
- hungarian           # Hungarian cuisine
- czech               # Czech cuisine
- scandinavian        # Scandinavian (general)
- swedish             # Swedish cuisine
- norwegian           # Norwegian cuisine
- danish              # Danish cuisine
- finnish             # Finnish cuisine
- dutch               # Dutch/Netherlands cuisine
- belgian             # Belgian cuisine
- irish               # Irish cuisine
- scottish            # Scottish cuisine
- welsh               # Welsh cuisine
- british             # British/English cuisine
- turkish             # Turkish cuisine
- georgian            # Georgian cuisine
- armenian            # Armenian cuisine

# Middle Eastern & North African
- middle_eastern      # Middle Eastern (general)
- lebanese            # Lebanese cuisine
- israeli             # Israeli cuisine
- persian             # Persian/Iranian cuisine
- iraqi               # Iraqi cuisine
- syrian              # Syrian cuisine
- jordanian           # Jordanian cuisine
- moroccan            # Moroccan cuisine
- egyptian            # Egyptian cuisine
- tunisian            # Tunisian cuisine
- algerian            # Algerian cuisine
- libyan              # Libyan cuisine
- ethiopian           # Ethiopian cuisine
- somali              # Somali cuisine

# African Cuisines
- west_african        # West African (general)
- nigerian            # Nigerian cuisine
- ghanaian            # Ghanaian cuisine
- senegalese          # Senegalese cuisine
- south_african       # South African cuisine
- kenyan              # Kenyan cuisine
- tanzanian           # Tanzanian cuisine
- ugandan             # Ugandan cuisine

# Latin American & Caribbean
- mexican             # Mexican cuisine
- tex_mex             # Tex-Mex fusion
- guatemalan          # Guatemalan cuisine
- salvadoran          # Salvadoran cuisine
- honduran            # Honduran cuisine
- nicaraguan          # Nicaraguan cuisine
- costa_rican         # Costa Rican cuisine
- panamanian          # Panamanian cuisine
- cuban               # Cuban cuisine
- puerto_rican        # Puerto Rican cuisine
- dominican           # Dominican cuisine
- jamaican            # Jamaican cuisine
- haitian             # Haitian cuisine
- trinidadian         # Trinidadian cuisine
- brazilian           # Brazilian cuisine
- peruvian            # Peruvian cuisine
- colombian           # Colombian cuisine
- venezuelan          # Venezuelan cuisine
- ecuadorian          # Ecuadorian cuisine
- bolivian            # Bolivian cuisine
- chilean             # Chilean cuisine
- argentinian         # Argentinian cuisine
- uruguayan           # Uruguayan cuisine
- paraguayan          # Paraguayan cuisine

# North American
- american            # American cuisine (general)
- soul_food           # African American soul food
- cajun               # Cajun cuisine
- creole              # Creole cuisine
- southern            # Southern US cuisine
- southwestern        # Southwestern US cuisine
- california          # California cuisine
- hawaiian            # Hawaiian cuisine
- canadian            # Canadian cuisine

# Oceania
- australian          # Australian cuisine
- new_zealand         # New Zealand cuisine
- pacific_islander    # Pacific Island cuisine

# Fusion & Modern
- fusion              # Fusion (multiple cuisines)
- modern              # Modern/contemporary cuisine
- molecular           # Molecular gastronomy
- nouvelle            # Nouvelle cuisine
- californian_fusion  # California fusion

# Other Categories
- international       # International/multi-cultural
- comfort_food        # Comfort food (not region-specific)
- home_cooking        # Home cooking (not region-specific)
```

## Usage in Recipe Schema

**Single Cuisine:**
```json
{
  "cuisine": "japanese",
  ...
}
```

**Fusion Dishes (multiple cuisines):**
```json
{
  "cuisine": ["japanese", "peruvian"],  // Nikkei cuisine
  ...
}
```

## Human-Readable Labels (for UI)

```javascript
const CUISINE_LABELS = {
  // Asian
  japanese: "Japanese",
  korean: "Korean",
  chinese: "Chinese",
  cantonese: "Cantonese",
  sichuan: "Sichuan",
  taiwanese: "Taiwanese",
  thai: "Thai",
  vietnamese: "Vietnamese",
  filipino: "Filipino",
  indonesian: "Indonesian",
  malaysian: "Malaysian",
  singaporean: "Singaporean",
  indian: "Indian",
  north_indian: "North Indian",
  south_indian: "South Indian",
  pakistani: "Pakistani",
  bangladeshi: "Bangladeshi",
  nepalese: "Nepalese",
  sri_lankan: "Sri Lankan",
  burmese: "Burmese",
  cambodian: "Cambodian",
  laotian: "Laotian",
  mongolian: "Mongolian",

  // European
  italian: "Italian",
  french: "French",
  spanish: "Spanish",
  greek: "Greek",
  portuguese: "Portuguese",
  german: "German",
  austrian: "Austrian",
  swiss: "Swiss",
  polish: "Polish",
  russian: "Russian",
  ukrainian: "Ukrainian",
  hungarian: "Hungarian",
  czech: "Czech",
  scandinavian: "Scandinavian",
  swedish: "Swedish",
  norwegian: "Norwegian",
  danish: "Danish",
  finnish: "Finnish",
  dutch: "Dutch",
  belgian: "Belgian",
  irish: "Irish",
  scottish: "Scottish",
  welsh: "Welsh",
  british: "British",
  turkish: "Turkish",
  georgian: "Georgian",
  armenian: "Armenian",

  // Middle Eastern & North African
  middle_eastern: "Middle Eastern",
  lebanese: "Lebanese",
  israeli: "Israeli",
  persian: "Persian",
  iraqi: "Iraqi",
  syrian: "Syrian",
  jordanian: "Jordanian",
  moroccan: "Moroccan",
  egyptian: "Egyptian",
  tunisian: "Tunisian",
  algerian: "Algerian",
  libyan: "Libyan",
  ethiopian: "Ethiopian",
  somali: "Somali",

  // African
  west_african: "West African",
  nigerian: "Nigerian",
  ghanaian: "Ghanaian",
  senegalese: "Senegalese",
  south_african: "South African",
  kenyan: "Kenyan",
  tanzanian: "Tanzanian",
  ugandan: "Ugandan",

  // Latin American & Caribbean
  mexican: "Mexican",
  tex_mex: "Tex-Mex",
  guatemalan: "Guatemalan",
  salvadoran: "Salvadoran",
  honduran: "Honduran",
  nicaraguan: "Nicaraguan",
  costa_rican: "Costa Rican",
  panamanian: "Panamanian",
  cuban: "Cuban",
  puerto_rican: "Puerto Rican",
  dominican: "Dominican",
  jamaican: "Jamaican",
  haitian: "Haitian",
  trinidadian: "Trinidadian",
  brazilian: "Brazilian",
  peruvian: "Peruvian",
  colombian: "Colombian",
  venezuelan: "Venezuelan",
  ecuadorian: "Ecuadorian",
  bolivian: "Bolivian",
  chilean: "Chilean",
  argentinian: "Argentinian",
  uruguayan: "Uruguayan",
  paraguayan: "Paraguayan",

  // North American
  american: "American",
  soul_food: "Soul Food",
  cajun: "Cajun",
  creole: "Creole",
  southern: "Southern",
  southwestern: "Southwestern",
  california: "California",
  hawaiian: "Hawaiian",
  canadian: "Canadian",

  // Oceania
  australian: "Australian",
  new_zealand: "New Zealand",
  pacific_islander: "Pacific Islander",

  // Fusion & Modern
  fusion: "Fusion",
  modern: "Modern",
  molecular: "Molecular Gastronomy",
  nouvelle: "Nouvelle Cuisine",
  californian_fusion: "California Fusion",

  // Other
  international: "International",
  comfort_food: "Comfort Food",
  home_cooking: "Home Cooking"
}
```

## Grouping for UI Filters

```javascript
const CUISINE_GROUPS = {
  "East Asian": ["japanese", "korean", "chinese", "cantonese", "sichuan", "taiwanese"],
  "Southeast Asian": ["thai", "vietnamese", "filipino", "indonesian", "malaysian", "singaporean", "burmese", "cambodian", "laotian"],
  "South Asian": ["indian", "north_indian", "south_indian", "pakistani", "bangladeshi", "nepalese", "sri_lankan"],
  "European": ["italian", "french", "spanish", "greek", "portuguese", "german", "british", "irish", "scandinavian", "russian", "polish", "turkish"],
  "Middle Eastern": ["middle_eastern", "lebanese", "israeli", "persian", "iraqi", "syrian", "jordanian", "moroccan", "egyptian"],
  "Latin American": ["mexican", "tex_mex", "brazilian", "peruvian", "colombian", "argentinian", "cuban", "puerto_rican", "venezuelan"],
  "North American": ["american", "soul_food", "cajun", "creole", "southern", "southwestern", "canadian", "hawaiian"],
  "African": ["west_african", "nigerian", "ethiopian", "south_african", "moroccan", "egyptian"],
  "Fusion & Modern": ["fusion", "modern", "molecular", "californian_fusion"]
}
```

## AI Prompt Integration

```
Available cuisines (use exact string values):

East Asian: japanese, korean, chinese, cantonese, sichuan, taiwanese
Southeast Asian: thai, vietnamese, filipino, indonesian, malaysian, singaporean, burmese, cambodian, laotian
South Asian: indian, north_indian, south_indian, pakistani, bangladeshi, nepalese, sri_lankan
European: italian, french, spanish, greek, portuguese, german, british, russian, polish, turkish, scandinavian
Middle Eastern: middle_eastern, lebanese, israeli, persian, moroccan, egyptian
Latin American: mexican, tex_mex, brazilian, peruvian, colombian, argentinian, cuban, puerto_rican
North American: american, soul_food, cajun, creole, southern, southwestern, canadian, hawaiian
African: west_african, nigerian, ethiopian, south_african
Fusion: fusion, modern, molecular, californian_fusion

For fusion dishes, return an array: ["japanese", "peruvian"]
For single cuisine, return a string: "japanese"
```

## Validation Rules

1. All cuisines must be lowercase with underscores
2. Single cuisine = string, Fusion = array of 2-3 cuisines
3. Avoid overly broad tags if specific option exists (use "sichuan" not "chinese" if Sichuan-specific)

## Future Additions

When adding new cuisines:
1. Update this document
2. Update database validation
3. Update frontend filter UI
4. Update AI prompts
5. Add to appropriate regional group
