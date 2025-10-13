#!/bin/bash

set -e  # zatrzymuje skrypt w przypadku błędu (z wyjątkiem bloków || {...})

# --- Sprawdzenie uprawnień ---
if [ "$(id -u)" -ne 0 ]; then
    echo "Skrypt należy uruchomić jako root" >&2
    exit 1
fi

## --- Intel Celeron N2840 ---
echo "Instalacja mikrokodu Intel..."
apt install -y intel-microcode || { 
	echo "Błąd instalacji intel-microcode" >&2; 
	exit 1; 
}

# Dodanie firmware-misc-nonfree (może być przydatne dla niektórych urządzeń) ?
echo "Instalacja dodatkowego firmware..."
apt install -y firmware-misc-nonfree 2>/dev/null || echo "Uwaga: firmware-misc-nonfree niedostępny (może wymagać non-free repo)"

## --- Broadcom BCM43142 802.11b/g/n ---
echo "Instalacja sterowników WiFi Broadcom..."

KERNEL_VERSION=$(uname -r)
apt install -y linux-image-${KERNEL_VERSION} linux-headers-${KERNEL_VERSION} broadcom-sta-dkms || {
    echo "BŁĄD: Instalacja sterowników WiFi" >&2
    exit 1
}

echo "Usuwanie konfliktujących modułów..."
modprobe -r b44 b43 b43legacy ssb brcmsmac bcma 2>/dev/null || true

echo "Instalacja modułów wl..."
apt install -y wl || { 
	echo "Błąd instalacji wl" >&2; 
	exit 1; 
}

echo "Ładowanie modułu wl..."
modprobe wl

# --> wymagany reboot

## --- Lite-On Broadcom BCM43142A0 ---
echo "Konfiguracja Bluetooth..."

FIRMWARE_FILE="BCM43142A0-04ca-2006.hcd"
FIRMWARE_DEST="/lib/firmware/brcm/"

# Sprawdzenie czy plik źródłowy istnieje
if [ ! -f "${FIRMWARE_FILE}" ]; then
    echo "BŁĄD: Nie znaleziono pliku ${FIRMWARE_FILE} w bieżącym katalogu" >&2
    echo "Skrypt kontynuuje, ale Bluetooth może nie działać"
else
    # Utworzenie katalogu jeśli nie istnieje
    mkdir -p "${FIRMWARE_DEST}"
    
    # Kopiowanie firmware
    cp "${FIRMWARE_FILE}" "${FIRMWARE_DEST}" || {
        echo "BŁĄD: Nie udało się skopiować firmware Bluetooth" >&2
    }
    
    # Ustawienie uprawnień
    chmod 644 "${FIRMWARE_DEST}"*.hcd
    chown root:root "${FIRMWARE_DEST}"*.hcd
    
    echo "Firmware Bluetooth zainstalowany pomyślnie"
fi

## --- potencjalny restart systemu ---
read -p "Wymagany jest restart systemu. Czy chcesz teraz zrestartować system? (t/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[TtYy]$ ]]; then
    echo "Ponowne uruchamianie systemu..."
    reboot
fi
