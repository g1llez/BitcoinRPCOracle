#!/bin/bash

# Usage: ./utxoracle_nagios_rrd.sh 2025-07-01 2025-07-16
# Generates 24 points per day (one per hour, from 00:00 to 23:00 UTC) for each day in the range

if [ $# -ne 2 ]; then
  echo "Usage: $0 START_DATE END_DATE (format: YYYY-MM-DD)"
  exit 1
fi

START_DATE="$1"
END_DATE="$2"

start_ts=$(date -u -d "$START_DATE" +%s)
end_ts=$(date -u -d "$END_DATE" +%s)

current_ts=$start_ts
while [ $current_ts -le $end_ts ]; do
  # Date au format YYYY/MM/DD pour UTXOracle
  DATE_UTXO=$(date -u -d "@$current_ts" +"%Y/%m/%d")
  # Date au format DD-MM-YYYY pour CoinGecko
  DATE_CG=$(date -u -d "@$current_ts" +"%d-%m-%Y")

  # Measure execution time
  start_time=$(date +%s)
  OUTPUT=$(python3 "$(dirname "$0")/UTXOracle.py" -d "$DATE_UTXO" --no-html 2>&1)
  end_time=$(date +%s)
  duration=$((end_time - start_time))

  PRICE_LINE=$(echo "$OUTPUT" | grep "price:")
  ORACLE_PRICE=$(echo "$PRICE_LINE" | grep -oE '\$[0-9,]+' | head -1 | sed 's/\$//;s/,//g')
  if [[ "$ORACLE_PRICE" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    ORACLE_PRICE=$(printf "%d" "${ORACLE_PRICE%%.*}")
  fi

  ONLINE_PRICE=$(curl -s "https://api.coingecko.com/api/v3/coins/bitcoin/history?date=$DATE_CG" | jq -r '.market_data.current_price.usd')
  if [[ "$ONLINE_PRICE" == "null" || -z "$ONLINE_PRICE" ]]; then
      ONLINE_PRICE="NA"
  else
      if [[ "$ONLINE_PRICE" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        ONLINE_PRICE=$(printf "%d" "${ONLINE_PRICE%%.*}")
      fi
  fi

  AGE=0

  # Debug if no price or execution too fast
  if [ -z "$ORACLE_PRICE" ] || [ "$duration" -lt 10 ]; then
    echo "[DEBUG] Date: $DATE_UTXO | Durée: ${duration}s | Prix Oracle: '$ORACLE_PRICE' | Ligne: '$PRICE_LINE' | Sortie: $OUTPUT" >&2
  fi

  # Generate 24 points spaced by 1h (00:00 to 23:00 UTC)
  for h in $(seq 0 23); do
    TS_DAY=$((current_ts + h * 3600))
    # Calcul du delta en pourcentage (si possible)
    if [[ "$ONLINE_PRICE" != "NA" && "$ONLINE_PRICE" -ne 0 && "$ORACLE_PRICE" != "" && "$ORACLE_PRICE" != "NA" ]]; then
      delta_pct=$(awk "BEGIN { d=100*($ORACLE_PRICE-$ONLINE_PRICE)/$ONLINE_PRICE; printf \"%.2f\", d }")
    else
      delta_pct="NA"
    fi
    echo "${TS_DAY}||bitcoin-knots||UTXOracle||UTXORACLE OK - Prix oracle = ${ORACLE_PRICE}\$, Age = ${AGE} min, Prix en ligne = ${ONLINE_PRICE}\$||oracle_price=${ORACLE_PRICE} online_price=${ONLINE_PRICE} delta_pct=${delta_pct}"
  done

  sleep 2
  current_ts=$((current_ts + 86400))
done 