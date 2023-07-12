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

  # Create config folder in printer folder
  config_folder="$printer_folder/config"
  mkdir -p "$config_folder"

  # Create gcodes symlink in printer folder
  ln -sf "$gcodes_path" "$printer_folder"
  # Create config symlink in printer folder
  ln -sf "$main_configs_path/config" "$config_folder/config"
  # Create macros symlink in printer folder
  ln -sf "$main_configs_path/macros" "$config_folder/macros"
  # Create defaults symlink in printer folder
  ln -sf "$main_configs_path/defaults" "$config_folder/defaults"

  # Check if printer.cfg already exists
  if ![ -f "$printer_folder/config/printer.cfg" ]; then
    cp "$main_configs_path/printer.cfg" "$printer_folder/config"
    echo "Printer.cfg file copied to printer folder."
  fi

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
