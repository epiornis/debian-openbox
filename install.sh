#!/bin/bash
#
# Główny instalator środowiska Openbox dla laptopa X553M
# Autor: [epiornis]
# Działa na strukturze katalogów:
# 00_repositories/
# 01_firmware/
# 02_openbox/
#

set -e  # zatrzymaj przy błędzie

# Sprawdzenie uprawnień (część skryptów może wymagać root)
if [ "$(id -u)" -ne 0 ]; then
    echo "UWAGA: Skrypt nie jest uruchomiony jako root. Niektóre podskrypty mogą wymagać sudo."
    exit 1
fi

# Upewnienie się, że wszystkie install.sh są wykonywalne
echo "Ustawianie uprawnień wykonywania dla wszystkich plików install.sh..."
find . -type f -name "install.sh" -exec chmod +x {} \;

echo "=== Instalator X553M Debian Openbox ==="
echo

# Wyszukanie podkatalogów w kolejności rosnącej
SUBDIRS=$(ls -d [0-9][0-9]_*/ 2>/dev/null | sort)

if [ -z "$SUBDIRS" ]; then
    echo "Brak katalogów instalacyjnych w bieżącym folderze."
    exit 1
fi

# Pętla po katalogach
for DIR in $SUBDIRS; do
    SCRIPT="${DIR}/install.sh"

    if [ -x "$SCRIPT" ]; then
        read -p "Uruchomić ${SCRIPT}? (t/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[TtYy]$ ]]; then
            (cd "$DIR" && bash "./install.sh")
        else
            echo "Pominięto ${DIR}"
        fi
    else
        echo "Brak pliku lub brak uprawnień do install.sh w katalogu ${DIR}"
    fi

    echo
    read -p "Kontynuować do następnego kroku? (t/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[TtYy]$ ]]; then
        echo "Przerwano instalację na etapie ${DIR}."
        exit 0
    fi
done

echo
echo "Wszystkie wybrane etapy instalacji zakończone."

