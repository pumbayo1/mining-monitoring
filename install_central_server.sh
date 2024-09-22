#!/bin/bash

# Zmienna dla katalogu centralnego serwera
CENTRAL_DIR="/home/user/mining_data"
SCRIPT_DIR="/home/user/scripts"

# Utworzenie katalogów na dane z serwerów i na sumy
echo "Tworzenie katalogów..."
mkdir -p $CENTRAL_DIR/serwery
mkdir -p $CENTRAL_DIR/sumy
mkdir -p $SCRIPT_DIR

# Tworzenie skryptu sumującego dane
echo "Tworzenie skryptu sumującego zarobki..."
SUM_SCRIPT="$SCRIPT_DIR/sum_earnings.sh"

cat > $SUM_SCRIPT <<EOL
#!/bin/bash

# Folder, w którym znajdują się pliki mining_history.csv z serwerów
MINING_DIR="$CENTRAL_DIR/serwery"

# Plik, w którym zostanie zapisana suma zarobków
SUM_FILE="$CENTRAL_DIR/sumy/suma.csv"

# Inicjalizacja zmiennej do sumowania zarobków
TOTAL_EARNINGS=0

# Przetwarzanie wszystkich plików CSV w katalogu
for FILE in \$MINING_DIR/*.csv; do
    # Zczytaj wartość token_earnings z drugiego wiersza drugiej kolumny pliku CSV
    EARNINGS=\$(tail -n 1 \$FILE | cut -d',' -f2)
    TOTAL_EARNINGS=\$(echo "\$TOTAL_EARNINGS + \$EARNINGS" | bc)
done

# Zapisanie sumy zarobków do pliku suma.csv
echo "Data,Zarobek" > \$SUM_FILE
echo "\$(date +%Y-%m-%d),\$TOTAL_EARNINGS" >> \$SUM_FILE

# Wyświetlenie komunikatu potwierdzającego
echo "Suma zarobków zapisana do \$SUM_FILE. Łączny zarobek: \$TOTAL_EARNINGS tokenów."
EOL

# Ustawienie uprawnień do wykonywania skryptu
chmod +x $SUM_SCRIPT

# Dodanie zadania do cron, aby uruchamiało się co godzinę
echo "Konfiguracja cron..."
(crontab -l 2>/dev/null; echo "0 * * * * /bin/bash $SUM_SCRIPT") | crontab -

# Informacja o zakończeniu instalacji
echo "Instalacja zakończona! Dane będą sumowane co godzinę i zapisywane w pliku $CENTRAL_DIR/sumy/suma.csv."
