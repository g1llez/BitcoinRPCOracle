#!/bin/bash

# Dossier de cache
CACHE_DIR="/var/cache/utxoracle"
CACHE_FILE="$CACHE_DIR/last_price.txt"

# Chemin vers le script principal
UTXORACLE_SCRIPT="$(dirname "$0")/UTXOracle.py"
SCRIPT_DIR="$(dirname "$0")"

# Créer le dossier de cache si besoin
mkdir -p "$CACHE_DIR"

# Exécuter le script Python
cd "$(dirname "$UTXORACLE_SCRIPT")"
OUTPUT=$(python3 "$UTXORACLE_SCRIPT" -rb --no-html 2>&1)

# Extraire la ligne contenant le prix (ex: "Jul 14, 2025 price: $100,361"), ignorer les espaces en début de ligne
PRICE_LINE=$(echo "$OUTPUT" | grep "price:")
PRICE=$(echo "$PRICE_LINE" | grep -oE '\\$[0-9,]+' | head -1 | sed 's/\\$//;s/,//g')

# Extraire la date au format international (YYYY-MM-DD)
# On suppose que la date anglaise est du type "Jul 14, 2025"
DATE_EN=$(echo "$PRICE_LINE" | grep -oE '^[A-Z][a-z]{2} [0-9]{1,2}, [0-9]{4}')
DATE_ISO=$(date -d "$DATE_EN" +"%Y-%m-%d" 2>/dev/null)

# Extraire le prix comme nombre entier (ex: 99999)
PRICE_RAW=$(echo "$PRICE_LINE" | grep -oE '\$[0-9,]+')
PRICE=$(echo "$PRICE_RAW" | sed 's/\$//;s/,//g')

# Si la date n'est pas trouvée, fallback sur la date du jour
if [ -z "$DATE_ISO" ]; then
  DATE_ISO=$(date -u +"%Y-%m-%d")
fi

# Sauvegarder dans le fichier cache
{
  echo "date: $DATE_ISO"
  echo "price: $PRICE"
  echo "timestamp: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
} > "$CACHE_FILE" 