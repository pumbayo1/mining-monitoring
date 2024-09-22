#!/bin/bash

# Pytanie o adres IP centralnego serwera
read -p "Podaj adres IP centralnego serwera: " CENTRAL_SERVER_IP

# Pytanie o katalog na centralnym serwerze, gdzie mają być przechowywane dane
read -p "Podaj katalog na centralnym serwerze, gdzie będą przechowywane dane (domyślnie: /root/mining_data/serwery): " CENTRAL_DIR
CENTRAL_DIR=${CENTRAL_DIR:-/root/mining_data/serwery}

# Tworzenie katalogu na skrypty
echo "Tworzenie katalogu na skrypty..."
mkdir -p /root/scripts

# Tworzenie skryptu do przesyłania danych na centralny serwer
SEND_SCRIPT="/root/scripts/send_data_to_central_server.sh"

cat > $SEND_SCRIPT <<EOL
#!/bin/bash

# Ścieżka do lokalnego pliku mining_history.csv
LOCAL_FILE="/root/scripts/mining_history.csv"

# Przesyłanie pliku mining_history.csv na centralny serwer z dodaniem nazwy serwera
scp \$LOCAL_FILE root@$CENTRAL_SERVER_IP:$CENTRAL_DIR/\$(hostname)_mining_history.csv
EOL

# Ustawienie uprawnień do wykonywania skryptu
chmod +x $SEND_SCRIPT

# Dodanie zadania do cron, aby uruchamiało się co godzinę
echo "Konfiguracja cron..."
(crontab -l 2>/dev/null; echo "0 * * * * /bin/bash $SEND_SCRIPT") | crontab -

# Informacja o zakończeniu instalacji
echo "Instalacja zakończona! Dane będą przesyłane co godzinę na centralny serwer."
