#!/bin/bash
#
# -------------------------------------------------------------------------------
# Author: epiornis
# Created: 13.10.2025
# Modified: 13.10.2025
# Info: instalacja podstawowych plików systemowych
# -------------------------------------------------------------------------------

# apt install -y xterm lxterminal alacritty

# Kolory dla wyjścia
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Lista dostępnych terminali
declare -A terminals=(
    ["xterm"]="XTerm - podstawowy terminal X"
    ["lxterminal"]="LXTerminal - lekki terminal z LXDE"
    ["alacritty"]="Alacritty - nowoczesny, akcelerowany GPU terminal"
    ["terminator"]="Terminator - zaawansowany terminal z podziałem okna"
    ["sakura"]="Sakura - prosty terminal oparty na VTE"
    ["urxvt"]="RXVT-Unicode - lekki i konfigurowalny terminal"
)

# Funkcja do wyświetlania menu
show_menu() {
    echo -e "${BLUE}Dostępne terminale:${NC}"
    echo "=========================="
    
    local i=1
    for term in "${!terminals[@]}"; do
        echo -e "${YELLOW}$i${NC}. $term - ${terminals[$term]}"
        ((i++))
    done
    
    echo -e "${YELLOW}a${NC}. Wszystkie terminale"
    echo -e "${YELLOW}q${NC}. Wyjście"
    echo "=========================="
    echo -e "${GREEN}Wybierz numery terminali (oddzielone spacją) lub 'a' dla wszystkich:${NC}"
}

# Funkcja do instalacji pakietów
install_packages() {
    local packages=("$@")
    
    echo -e "${BLUE}Aktualizacja listy pakietów...${NC}"
    sudo apt update
    
    for pkg in "${packages[@]}"; do
        if dpkg -l | grep -q "^ii  $pkg "; then
            echo -e "${YELLOW}$pkg jest już zainstalowany.${NC}"
        else
            echo -e "${GREEN}Instalowanie $pkg...${NC}"
            sudo apt install -y "$pkg"
            
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}✓ $pkg został pomyślnie zainstalowany${NC}"
            else
                echo -e "${RED}✗ Błąd podczas instalacji $pkg${NC}"
            fi
        fi
    done
}

# Funkcja główna
main() {
    # Sprawdzenie czy użytkownik ma uprawnienia sudo
    if ! sudo -n true 2>/dev/null; then
        echo -e "${YELLOW}Uwaga: Skrypt wymaga uprawnień sudo${NC}"
        echo "Proszę uruchomić skrypt jako użytkownik z uprawnieniami sudo"
        exit 1
    fi
    
    # Sprawdzenie czy system to Debian
    if ! grep -q "Debian" /etc/os-release; then
        echo -e "${RED}Uwaga: Ten skrypt jest przeznaczony dla systemu Debian${NC}"
        read -p "Kontynuować mimo to? (t/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Tt]$ ]]; then
            exit 1
        fi
    fi
    
    echo -e "${BLUE}Skrypt instalacji terminali dla Debian z Openbox${NC}"
    echo "================================================"
    
    selected_terminals=()
    
    while true; do
        show_menu
        
        read -r -a choices
        
        # Sprawdzenie czy użytkownik chce wyjść
        if [[ "${choices[0]}" == "q" ]]; then
            echo -e "${YELLOW}Wyjście z skryptu.${NC}"
            exit 0
        fi
        
        # Sprawdzenie czy wybrano wszystkie
        if [[ "${choices[0]}" == "a" ]]; then
            selected_terminals=("${!terminals[@]}")
            break
        fi
        
        # Walidacja wyborów
        valid_choices=true
        temp_selected=()
        
        for choice in "${choices[@]}"; do
            if [[ "$choice" =~ ^[0-9]+$ ]]; then
                # Wybór przez numer
                if (( choice >= 1 && choice <= ${#terminals[@]} )); then
                    # Konwersja numeru na nazwę terminala
                    local i=1
                    for term in "${!terminals[@]}"; do
                        if (( i == choice )); then
                            temp_selected+=("$term")
                            break
                        fi
                        ((i++))
                    done
                else
                    echo -e "${RED}Nieprawidłowy numer: $choice${NC}"
                    valid_choices=false
                fi
            else
                # Wybór przez nazwę
                if [[ -n "${terminals[$choice]}" ]]; then
                    temp_selected+=("$choice")
                else
                    echo -e "${RED}Nieprawidłowa nazwa terminala: $choice${NC}"
                    valid_choices=false
                fi
            fi
        done
        
        if $valid_choices; then
            if [ ${#temp_selected[@]} -eq 0 ]; then
                echo -e "${RED}Nie wybrano żadnego terminala.${NC}"
            else
                selected_terminals=("${temp_selected[@]}")
                break
            fi
        fi
        
        echo -e "${YELLOW}Spróbuj ponownie.${NC}"
    done
    
    # Wyświetlenie podsumowania
    echo -e "${BLUE}Wybrane terminale do instalacji:${NC}"
    for term in "${selected_terminals[@]}"; do
        echo -e "  - ${GREEN}$term${NC}: ${terminals[$term]}"
    done
    
    # Potwierdzenie instalacji
    echo
    read -p "Kontynuować instalację? (T/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        echo -e "${YELLOW}Instalacja anulowana.${NC}"
        exit 0
    fi
    
    # Instalacja wybranych terminali
    echo -e "${BLUE}Rozpoczynanie instalacji...${NC}"
    install_packages "${selected_terminals[@]}"
    
    # Informacje dodatkowe
    echo
    echo -e "${GREEN}Instalacja zakończona!${NC}"
    echo -e "${BLUE}Dostępne terminale:${NC}"
    for term in "${selected_terminals[@]}"; do
        if command -v "$term" &> /dev/null; then
            echo -e "  - ${GREEN}$term${NC} ✓"
        else
            echo -e "  - ${RED}$term${NC} ✗ (możliwy problem z instalacją)"
        fi
    done
    
    echo
    echo -e "${YELLOW}Uwaga: Aby używać terminali w Openbox, możesz potrzebować:${NC}"
    echo "1. Dodać je do menu Openbox (~/.config/openbox/menu.xml)"
    echo "2. Przypisać skróty klawiaturowe (~/.config/openbox/rc.xml)"
    echo "3. Uruchomić przez polecenie w konsoli lub menu"
}

# Obsługa sygnałów
trap 'echo -e "\n${RED}Przerwano przez użytkownika.${NC}"; exit 1' INT TERM

# Uruchomienie głównej funkcji
main "$@"
