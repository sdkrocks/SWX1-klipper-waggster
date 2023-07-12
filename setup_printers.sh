#!/bin/bash

main_configs_repo="https://github.com/sdkrocks/SWX1-klipper-waggster.git"
main_configs_path=~/main_configs
printer_folders_path=~/printer_*
gcodes_path="/llabs/gcodes"

# Clone the main_configs repository into the home directory
echo "Cloning main_configs repository..."
git clone -q "$main_configs_repo" "$main_configs_path" 2>/dev/null
if [ $? -eq 0 ]; then
  echo "Cloned main_configs repository successfully."
else
  echo "Main_configs repository already exists. Resetting to match the remote repository..."
  cd "$main_configs_path"
  
  # Fetch the latest changes
  git fetch -q origin
  
  # Reset the local copy to match the remote repository
  git reset --hard origin/main
  
  if [ $? -eq 0 ]; then
    echo "Updated main_configs repository successfully."
  else
    echo "Failed to update the main_configs repository. Please update it manually."
  fi

  cd -
fi

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

# Loop through each printer folder
for printer_folder in "${printer_folders[@]}"; do
  echo ""
  echo "Processing printer folder: $printer_folder"

  # Create gcodes symlink in printer folder
  ln -sf "$gcodes_path" "$printer_folder"

  # Create config folder in printer folder
  config_folder="$printer_folder/config"
  mkdir -p "$config_folder"

  # Remove existing config symlink if it exists
  if [ -L "$config_folder/config" ]; then
    rm "$config_folder/config"
  fi

  # Create config symlink in printer folder
  ln -s "$main_configs_path/config" "$config_folder/config"

  # Remove existing macros symlink if it exists
  if [ -L "$config_folder/macros" ]; then
    rm "$config_folder/macros"
  fi

  # Create macros symlink in printer folder
  ln -s "$main_configs_path/macros" "$config_folder/macros"
  
  # Copy mainsail.cfg to printer folder
  cp "$main_configs_path/mainsail.cfg" "$printer_folder/config"

  # Check if printer.cfg already exists
  if [ -f "$printer_folder/config/printer.cfg" ]; then
    echo "Preserving existing serial port information in printer.cfg..."
    # Preserve existing serial port information
    existing_serial=$(grep -oP '(?<=serial: ).*' "$printer_folder/config/printer.cfg")
    temp_file=$(mktemp)
    cp "$main_configs_path/printer.cfg" "$temp_file"
    sed -i "s|SERIAL_PLACEHOLDER|$existing_serial|" "$temp_file"

    # Get lines from 'SAVE_CONFIG' and below
    save_config=$(awk '/SAVE_CONFIG/{flag=1;next}flag' "$printer_folder/config/printer.cfg")

    # Delete everything from 'SAVE_CONFIG' to the end of the file in temp_file
    sed -i '/SAVE_CONFIG/,$d' "$temp_file"

    # Append save_config lines to the temporary file
    echo "$save_config" >> "$temp_file"

    mv "$temp_file" "$printer_folder/config/printer.cfg"
  else
    cp "$main_configs_path/printer.cfg" "$printer_folder/config"
    echo "Printer.cfg file copied to printer folder."
  fi

  # Edit moonraker.conf file to replace cors_domains section with *:*
  moonraker_conf_file="$printer_folder/config/moonraker.conf"
  sed -i '/cors_domains:/,/^\s*$/{//!d}; /^cors_domains:/a\    *:*' "$moonraker_conf_file"

  echo "Processing of printer folder $printer_folder completed."
  echo ""
done

# Restart each service using the index from the printer_folders array
#for index in "${!printer_folders[@]}"; do
#    service="moonraker-$((index+1)).service"
#    echo -n "Restarting $service ... "
#    if systemctl restart "$service" >/dev/null 2>&1; then
#        sleep 1  # Wait for a moment before checking the service status
#        if systemctl is-active --quiet "$service"; then
#            echo "OK"
#        else
#            echo "FAILED"
#        fi
#    else
#        echo "FAILED"
#    fi
#done

echo ""
echo "Setup completed successfully."
