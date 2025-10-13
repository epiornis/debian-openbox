#!/bin/bash
#
# -------------------------------------------------------------------------------
# Author: epiornis
# Created: 13.10.2025
# Modified: 13.10.2025
# Info: instalacja podstawowych plików systemowych
# -------------------------------------------------------------------------------

# instalacja podstawowego środowiska graficznego
apt install -y xorg openbox lxappearance


# Menedżer wyświetlania
apt install -y lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings


# Zarządzanie energią i ACPI
apt install -y acpi acpid xfce4-power-manager


# NetworkManager
apt install -y network-manager network-manager-gnome



