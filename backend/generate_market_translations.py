import re
import pandas as pd
from tqdm import tqdm
from ai4bharat.transliteration import XlitEngine

# --------------------------------------------------
# CONFIG
# --------------------------------------------------

INPUT_CSV = "markets.csv"
OUTPUT_CSV = "market_translations.csv"

# Better accuracy
BEAM_WIDTH = 10

# --------------------------------------------------
# LOAD MODELS
# --------------------------------------------------

print("Loading Malayalam model...")
ml_engine = XlitEngine(
    "ml",
    beam_width=BEAM_WIDTH,
    rescore=True,
    src_script_type="en"
)

print("Loading Hindi model...")
hi_engine = XlitEngine(
    "hi",
    beam_width=BEAM_WIDTH,
    rescore=True,
    src_script_type="en"
)

print("Models loaded.\n")

# --------------------------------------------------
# NORMALIZATION
# --------------------------------------------------

SPECIAL_TOKENS = {
    "APMC": {
        "ml": "എ.പി.എം.സി.",
        "hi": "एपीएमसी",
    },
    "F&V": {
        "ml": "എഫ് & വി",
        "hi": "एफ एंड वी",
    }
}

def normalize(text):

    text = str(text)

    text = text.strip()

    # collapse spaces
    text = re.sub(r"\s+", " ", text)

    # fix parentheses
    text = re.sub(r"\(", " (", text)
    text = re.sub(r"\)", ") ", text)

    text = re.sub(r"\s+", " ", text)

    # fix APMCKHEDBRAHMA
    text = re.sub(r"^APMC([A-Z])", r"APMC \1", text)

    return text.strip()

# --------------------------------------------------
# PLACEHOLDER REPLACEMENT
# --------------------------------------------------

def protect(text):

    replacements = {}

    i = 0

    for token in SPECIAL_TOKENS:

        if token in text:

            key = f"__TOKEN{i}__"

            replacements[key] = token

            text = text.replace(token, key)

            i += 1

    return text, replacements


def restore(text, replacements, lang):

    for key, token in replacements.items():

        text = text.replace(
            key,
            SPECIAL_TOKENS[token][lang]
        )

    return text

# --------------------------------------------------
# TRANSLITERATION
# --------------------------------------------------

def transliterate(text):

    clean = normalize(text)

    protected, repl = protect(clean)

    ml = ml_engine.translit_sentence(protected)["ml"]

    hi = hi_engine.translit_sentence(protected)["hi"]

    ml = restore(ml, repl, "ml")
    hi = restore(hi, repl, "hi")

    return ml, hi

# --------------------------------------------------
# MAIN
# --------------------------------------------------

df = pd.read_csv(INPUT_CSV)

rows = []

for _, row in tqdm(df.iterrows(), total=len(df)):

    market_id = int(row["id"])

    name = row["name"]

    try:

        ml, hi = transliterate(name)

    except Exception as e:

        print("FAILED:", name)

        ml = name
        hi = name

    rows.append({
        "market_id": market_id,
        "language_code": "ml",
        "translated_name": ml
    })

    rows.append({
        "market_id": market_id,
        "language_code": "hi",
        "translated_name": hi
    })

out = pd.DataFrame(rows)

out.to_csv(
    OUTPUT_CSV,
    index=False,
    encoding="utf-8-sig"
)

print("\nDone.")
print(f"Generated {len(out)} rows.")
print(OUTPUT_CSV)