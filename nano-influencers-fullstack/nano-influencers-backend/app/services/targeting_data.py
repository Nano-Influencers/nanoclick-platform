"""
Static data tables for the targeting engine.

Contains:
  - NEIGHBOURING_LOCATIONS: city → list of neighbouring cities (Tier 7 expansion)
  - LOCATION_LANGUAGE_MAP: city → primary language(s) (Tier 8)
  - LOCATION_ETHNICITY_MAP: city → ethnicity/tribe (Tier 9)
  - AGE_BRACKETS_ORDERED: ordered list used for adjacent-bracket expansion
  - MARITAL_ADJACENT: adjacent statuses used for Tier 2 marital expansion
  - MALE_GROUP_KEYWORDS / FEMALE_GROUP_KEYWORDS / MARITAL_GROUP_KEYWORDS
"""

# ── Neighbouring locations (Tier 7 — Physical Proximity) ──────────────────────
# Built from TIER 7 Locations Neighbouring Locations doc (Nigeria + Ghana)
NEIGHBOURING_LOCATIONS: dict[str, list[str]] = {
    # FCT
    "abuja": ["gwarinpa","utako","jabi","maitama","wuse","garki","asokoro"],
    "gwagwalada": ["kuje","lugbe"],
    "kuje": ["gwagwalada","lugbe"],
    "nyanya": ["karu","jikwoyi"],
    "karu": ["nyanya","jikwoyi","mararaba"],
    "jikwoyi": ["karu","nyanya"],
    "lugbe": ["gwarinpa","garki","kuje"],
    "kubwa": ["gwarinpa","wuse","maitama"],
    "asokoro": ["garki","maitama","abuja"],
    "maitama": ["wuse","asokoro","gwarinpa","abuja"],
    "garki": ["asokoro","wuse","lugbe"],
    "wuse": ["maitama","garki","utako","jabi","gwarinpa"],
    "gwarinpa": ["utako","jabi","wuse","kubwa","lugbe"],
    "utako": ["jabi","gwarinpa","wuse"],
    "jabi": ["utako","gwarinpa","wuse"],
    # Benue
    "makurdi": ["gboko","otukpo"],
    "gboko": ["makurdi","katsina-ala"],
    "otukpo": ["makurdi"],
    "katsina-ala": ["zaki biam","gboko"],
    "zaki biam": ["katsina-ala"],
    # Kogi
    "lokoja": ["okene","idah","kabba"],
    "okene": ["lokoja","idah"],
    "idah": ["anyigba","ankpa"],
    "kabba": ["lokoja","egbe"],
    "anyigba": ["ankpa","idah"],
    "ankpa": ["anyigba","idah"],
    # Kwara
    "ilorin": ["offa","jebba"],
    "offa": ["ilorin","omu-aran"],
    "jebba": ["ilorin","mokwa"],
    "omu-aran": ["offa","lafiagi"],
    "lafiagi": ["patigi"],
    "patigi": ["lafiagi"],
    # Nasarawa
    "lafia": ["akwanga","keffi"],
    "keffi": ["lafia","karu","nasarawa"],
    "akwanga": ["lafia","wamba"],
    "nasarawa": ["keffi","mararaba"],
    "mararaba": ["karu","nasarawa"],
    # Niger
    "minna": ["bosso","zungeru","paikoro"],
    "bosso": ["minna","suleja"],
    "bida": ["minna","agaie"],
    "kontagora": ["new bussa","mokwa"],
    "suleja": ["minna","bosso","abuja"],
    "new bussa": ["kontagora","mokwa"],
    "mokwa": ["jebba","new bussa"],
    # Plateau
    "jos": ["bukuru","vom","barkin ladi"],
    "bukuru": ["jos","vom"],
    "vom": ["jos","bukuru","barkin ladi"],
    "pankshin": ["shendam","langtang"],
    "shendam": ["pankshin","langtang"],
    "langtang": ["shendam","pankshin"],
    "barkin ladi": ["jos","vom"],
    # Lagos
    "ikeja": ["mushin","oshodi","agege"],
    "lagos island": ["victoria island","apapa"],
    "victoria island": ["lagos island","lekki"],
    "lekki": ["victoria island","ajah","ikoyi"],
    "ikoyi": ["lekki","victoria island","lagos island"],
    "surulere": ["mushin","yaba","ajegunle"],
    "mushin": ["ikeja","surulere","oshodi","agege"],
    "yaba": ["surulere","ebute-metta","ojuelegba"],
    "agege": ["ikeja","mushin","ogba"],
    "oshodi": ["ikeja","mushin","isolo"],
    "isolo": ["oshodi","ejigbo","ikorodu"],
    "ikorodu": ["isolo","epe"],
    "epe": ["ikorodu","ajah"],
    "ajah": ["lekki","epe"],
    "apapa": ["lagos island","ajegunle","tin can"],
    "alimosho": ["agege","ikeja","iyana-ipaja"],
    "badagry": ["ojo"],
    "ojo": ["badagry","ajegunle"],
    "festac": ["amuwo-odofin","ojo"],
    "amuwo-odofin": ["festac","isolo"],
    "ogba": ["agege","ikeja"],
    # Ogun
    "abeokuta": ["sagamu","ijebu-ode"],
    "sagamu": ["abeokuta","ijebu-ode"],
    "ijebu-ode": ["sagamu","abeokuta"],
    # Oyo
    "ibadan": ["ogbomoso","oyo"],
    "ogbomoso": ["ibadan","oyo"],
    "oyo": ["ibadan","ogbomoso"],
    "ile-ife": ["ilesha","ondo"],
    "ilesha": ["ile-ife","ondo","akure"],
    # Osun
    "osogbo": ["ede","ile-ife"],
    "ede": ["osogbo","ile-ife"],
    # Ekiti
    "ado-ekiti": ["ikere-ekiti","efon-alaaye"],
    "ikere-ekiti": ["ado-ekiti"],
    # Ondo
    "akure": ["ondo","ilesha"],
    "ondo": ["akure","ile-ife"],
    # Edo
    "benin city": ["ekpoma","auchi","uromi"],
    "ekpoma": ["benin city","uromi"],
    "auchi": ["benin city","okene"],
    "uromi": ["ekpoma","benin city"],
    # Delta
    "asaba": ["benin city","agbor","sapele"],
    "agbor": ["asaba","benin city"],
    "sapele": ["warri","agbor"],
    "warri": ["sapele","effurun","ughelli"],
    "effurun": ["warri","ughelli"],
    "ughelli": ["warri","effurun"],
    # Anambra
    "awka": ["onitsha","nnewi"],
    "onitsha": ["awka","asaba","nnewi"],
    "nnewi": ["onitsha","awka"],
    "ekwulobia": ["awka","nnewi"],
    # Enugu
    "enugu": ["agbani","oji river","awgu"],
    "agbani": ["enugu","oji river"],
    "oji river": ["enugu","agbani","awgu"],
    "awgu": ["oji river","enugu"],
    "nsukka": ["enugu","obollo-afor"],
    # Imo
    "owerri": ["orlu","okigwe","mbaise"],
    "orlu": ["owerri","okigwe"],
    "okigwe": ["owerri","orlu"],
    # Abia
    "aba": ["umuahia","arochukwu"],
    "umuahia": ["aba","bende"],
    "bende": ["umuahia"],
    "arochukwu": ["aba"],
    # Ebonyi
    "abakaliki": ["afikpo","onueke"],
    "afikpo": ["abakaliki"],
    "onueke": ["abakaliki"],
    # Cross River
    "calabar": ["akamkpa","ikom"],
    "ikom": ["calabar","ogoja"],
    "ogoja": ["ikom"],
    # Akwa Ibom
    "uyo": ["eket","ikot ekpene"],
    "eket": ["uyo","ikot abasi"],
    "ikot ekpene": ["uyo","abak"],
    # Rivers
    "port harcourt": ["obio-akpor","eleme","bonny"],
    "obio-akpor": ["port harcourt","eleme"],
    "eleme": ["port harcourt","obio-akpor"],
    "bonny": ["port harcourt"],
    "buguma": ["port harcourt"],
    # Bayelsa
    "yenagoa": ["brass","sagbama"],
    "brass": ["yenagoa"],
    # Kano
    "kano": ["wudil","gaya","kumbotso","ungogo"],
    "wudil": ["gaya","kano"],
    "gaya": ["wudil","kano"],
    "gwarzo": ["karaye"],
    "kumbotso": ["kano","ungogo"],
    "ungogo": ["kano","kumbotso"],
    # Kaduna
    "kaduna": ["zaria","sabon gari"],
    "zaria": ["kaduna","sabon gari"],
    "kafanchan": ["kagoro","kachia"],
    "kagoro": ["kafanchan"],
    "kachia": ["kafanchan","kaduna"],
    "sabon gari": ["zaria","kaduna"],
    # Katsina
    "katsina": ["daura","mani"],
    "daura": ["katsina","mani"],
    "funtua": ["malumfashi"],
    "malumfashi": ["funtua","kankia"],
    "kankia": ["malumfashi","katsina"],
    # Kebbi
    "birnin kebbi": ["argungu"],
    "argungu": ["birnin kebbi"],
    # Sokoto
    "sokoto": ["gwadabawa","wurno"],
    "gwadabawa": ["sokoto","illela"],
    "wurno": ["sokoto","goronyo"],
    "goronyo": ["wurno"],
    # Zamfara
    "gusau": ["kaura namoda","talata mafara"],
    "kaura namoda": ["gusau","shinkafi"],
    "talata mafara": ["gusau","anka"],
    "anka": ["gummi","talata mafara"],
    # Gombe
    "gombe": ["kumo","deba"],
    "kumo": ["gombe","billiri","deba"],
    # Bauchi
    "bauchi": ["dass","toro"],
    "azare": ["misau","katagum"],
    # Borno
    "maiduguri": ["bama","dikwa","gwoza"],
    "bama": ["maiduguri","gwoza"],
    "dikwa": ["ngala","maiduguri"],
    # Adamawa
    "yola": ["jimeta","mayo-belwa"],
    "jimeta": ["yola","numan"],
    "mubi": ["michika"],
    # Taraba
    "jalingo": ["mutum biyu"],
    "wukari": ["takum","mutum biyu"],
    # Yobe
    "damaturu": ["potiskum"],
    "potiskum": ["damaturu"],
    "gashua": ["nguru","bade"],
    # Jigawa
    "dutse": ["birnin kudu"],
    "hadejia": ["gumel"],
    "gumel": ["hadejia","kazaure"],
}

# Normalise all keys and values to lowercase (already done above)
NEIGHBOURING_LOCATIONS = {
    k.lower(): [v.lower() for v in vs]
    for k, vs in NEIGHBOURING_LOCATIONS.items()
}


# ── Language → locations (Tier 8) ─────────────────────────────────────────────
# language → set of cities/states where that language is primary
LANGUAGE_LOCATIONS: dict[str, list[str]] = {
    "igbo":    ["aba","abakaliki","abeokuta","abia","agbani","aguata","agulu","arochukwu","asaba","awgu","awka","bende","calabar","edda","effium","enugu","ekwulobia","nnewi","nsukka","onitsha","oji river","orlu","owerri","umuahia","uyo"],
    "yoruba":  ["abeokuta","ado-ekiti","agege","ajah","akure","alimosho","apapa","asokoro","badagry","ede","efon-alaaye","epe","festac","garki","ibadan","ikeja","ijebu-ode","ilesha","ile-ife","ilorin","lagos island","lekki","mushin","ondo","ogbomoso","osogbo","oyo","sagamu","surulere","victoria island","yaba"],
    "hausa":   ["anka","argungu","azare","bagudo","bauchi","birnin kebbi","birnin kudu","bosso","dambatta","daura","dutse","funtua","gaya","goronyo","gumel","gummi","gwadabawa","gwarzo","hadejia","illela","kaduna","kano","kankia","karaye","katsina","kaura namoda","kazaure","kumbotso","malumfashi","mani","misau","ringim","sabon gari","shinkafi","sokoto","talata mafara","tambuwal","ungogo","wudil","wurno","zaria"],
    "edo":     ["benin city"],
    "igala":   ["ankpa","anyigba","idah","lokoja"],
    "tiv":     ["adikpo","gboko","katsina-ala","makurdi","zaki biam"],
    "nupe":    ["agaie","bida","gulu","minna"],
    "efik":    ["calabar"],
    "ibibio":  ["etinan","eket","ikot ekpene","uyo"],
    "ijaw":    ["bonny","brass","buguma","degema","yenagoa"],
    "urhobo":  ["abraka","effurun","warri"],
    "itsekiri": ["warri"],
    "kanuri":  ["bama","damaturu","dikwa","gwoza","maiduguri","monguno","ngala"],
    "fulfulde": ["bajoga","dukku","gombe","yola"],
    "berom":   ["barkin ladi","bukuru","jos"],
    "esan":    ["ekpoma"],
    "jukun":   ["bali"],
    "mambila": ["gembu"],
}

# ── Ethnicity → locations (Tier 9) ────────────────────────────────────────────
ETHNICITY_LOCATIONS: dict[str, list[str]] = {
    "igbo":    ["abia","anambra","ebonyi","enugu","imo","south east"],
    "yoruba":  ["ekiti","lagos","ogun","osun","oyo","ondo","south west"],
    "hausa":   ["kano","katsina","jigawa","sokoto","kebbi","zamfara","north west"],
    "fulani":  ["adamawa","bauchi","gombe","north east","north west"],
    "tiv":     ["benue","north central"],
    "igala":   ["kogi","north central"],
    "ijaw":    ["bayelsa","rivers","delta"],
    "urhobo":  ["delta"],
    "efik":    ["cross river"],
    "ibibio":  ["akwa ibom"],
    "edo":     ["edo"],
    "nupe":    ["niger"],
    "kanuri":  ["borno","yobe"],
    "berom":   ["plateau"],
    "jukun":   ["taraba"],
}

# ── Age brackets ordered (Tier 2 adjacent expansion) ─────────────────────────
AGE_BRACKETS_ORDERED = ["13-17","18-24","25-34","35-44","45-54","55-64","65+"]

# ── Marital adjacent statuses (Tier 2 — Adjacent) ────────────────────────────
MARITAL_ADJACENT: dict[str, list[str]] = {
    "married":   ["widowed","separated"],
    "single":    ["divorced"],
    "widowed":   ["married","separated"],
    "separated": ["married","divorced"],
    "divorced":  ["single","separated"],
}

# ── Marital group keywords ────────────────────────────────────────────────────
MARITAL_GROUP_KEYWORDS: dict[str, list[str]] = {
    "married":   ["couples","marriage","family ministry","parenting","maternal health","homeowners","landlords","savings","ajo","esusu","pta","resident union","community development","diy home","senior fellowship","estate","neighborhood watch"],
    "single":    ["youth ministry","campus fellowship","student union","departmental association","nysc","scholarship","exam preparation","japa","visa","immigration","gaming clan","esports","freelancer","remote work","digital nomad","dating","relationship discovery","skill acquisition","startup","founder","social media influencer"],
    "widowed":   ["senior fellowship","grief","loss","bereavement","self-help","social charity","welfare","philanthropic","faith discovery","state union","family union","senior citizen","retirement","legacy","inheritance"],
    "separated": ["family advice","anonymous support","self-help","mental health","counseling","faith discovery","gender support","single parents","legal","family law","mediation","independent","freelance"],
    "divorced":  ["family advice","anonymous support","self-help","mental health","counseling","faith discovery","gender support","single parents","legal","family law","estate inheritance","personal growth","wellness","spiritual circle"],
}

# ── Gender group keywords ─────────────────────────────────────────────────────
MALE_GROUP_KEYWORDS   = ["men support","traditional title","military","maritime","aviation","engineering society","security","bikers","hikers","gaming clan","esports","car enthusiast","sports fan","sports betting","arbitrage","forex","crypto trading","religious youth wing","state union","indigene union","rotary","cybersecurity"]
FEMALE_GROUP_KEYWORDS = ["female-only","women rights","market women","traders association","fashion designers","beauty","makeup","chef","caterers","nursing community","maternal health","gender equality","diy crafting","handmade","home interior","parenting","ladies welfare","luxury personal shopper","sme small business","girl guides","female volunteer","women support"]
