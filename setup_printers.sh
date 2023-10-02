#!/bin/bash

main_configs_repo="https://github.com/sdkrocks/SWX1-klipper-waggster.git"
main_configs_path=~/main_configs
printer_folders_path=~/printer_*
gcodes_path="/llabs/gcodes"

kamp_repo="https://github.com/kyleisah/Klipper-Adaptive-Meshing-Purging.git"
kamp_path=~/KAMP

# Clone the main_configs repository into the home directory
echo "Cloning main_configs repository"
if [ -d "$main_configs_path" ]; then
    rm -rf "$main_configs_path"
fi
git clone "$main_configs_repo" "$main_configs_path"

# Clone KAMP repository into the home directory
echo "Cloning main_configs repository"
if [ -d "$kamp_path" ]; then
    rm -rf "$kamp_path"
fi
git clone "$kamp_repo" "$kamp_path"

cd ~/

sleep 1

# Get a list of printer folders
printer_folders=($printer_folders_path)

if [ ${#printer_folders[@]} -eq 0 ]; then
  echo "No printer folders found."
  exit 1
fi

echo ""
echo "Found printer folders:"
for printer_folder in "${printer_folders[@]}"; do
  echo "  - $printer_folder"
done
sleep 1

read -p "Do you want to override the printer.cfg files to default? (y/N): " response
response=${response:-n}  # Set default value to "n" if the input is empty

# Loop through each printer folder
for printer_folder in "${printer_folders[@]}"; do
  echo ""
  echo "Processing printer folder: $printer_folder"

  # Create config folder in printer folder
  config_folder="$printer_folder/config"
  mkdir -p "$config_folder"

  # Create necessary symlinks
  find "$printer_folder" -type l -delete
  rmdir "$printer_folder/gcodes"
  ln -sf "$gcodes_path" "$printer_folder"
  ln -sf "$main_configs_path/config" "$config_folder/config"
  ln -sf "$main_configs_path/macros" "$config_folder/macros"
  ln -sf "$main_configs_path/defaults" "$config_folder/defaults"
  ln -sf ~/KAMP/Configuration "$config_folder/KAMP"

  cp "$main_configs_path/KAMP_Settings.cfg" "$config_folder"  
  cp "$main_configs_path/mainsail.cfg" "$config_folder"

  # Check if printer.cfg already exists
  if [ ! -f "$config_folder/printer.cfg" ] || [[ $response =~ ^[Yy]$ ]]; then
    cp "$main_configs_path/printer.cfg" "$config_folder"
    echo "printer.cfg file copied to printer folder."
  fi

  # Edit moonraker.conf file to replace cors_domains section with *:*
  moonraker_conf_file="$config_folder/moonraker.conf"
  sed -i '/cors_domains:/,/^\s*$/{//!d}; /^cors_domains:/a\    *:*' "$moonraker_conf_file"

  echo "Processing of printer folder $printer_folder completed."
  echo ""
done

echo ""
echo "Setup completed successfully."
