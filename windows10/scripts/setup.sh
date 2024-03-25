#!/bin/bash

# Function to validate product key format
isValidProductKey() {
    local key="$1"
    [[ "$key" =~ ^[A-Z0-9]{5}-[A-Z0-9]{5}-[A-Z0-9]{5}-[A-Z0-9]{5}-[A-Z0-9]{5}$ ]]
    return $?
}

# Check for required ISO path
if [[ -z "$1" ]]; then
    echo "Error: You must provide the path to an ISO."
    exit 1
fi

# Assign command-line arguments to variables
ISO_PATH=$1
WINDOWS_IMAGE=${2:-"Not Provided"}
PRODUCT_KEY=${3:-"XXXXX-XXXXX-XXXXX-XXXXX-XXXXX"}

# Extract the actual value if it is in the format WINDOWS_IMAGE=value
if [[ "$WINDOWS_IMAGE" == WINDOWS_IMAGE=* ]]; then
    WINDOWS_IMAGE=$(echo "$WINDOWS_IMAGE" | sed 's/WINDOWS_IMAGE=//')
fi

# Extract the actual value if it is in the format PRODUCT_KEY=value
if [[ "$PRODUCT_KEY" == PRODUCT_KEY=* ]]; then
    PRODUCT_KEY=$(echo "$PRODUCT_KEY" | sed 's/PRODUCT_KEY=//')
fi

# Validate product key
if ! isValidProductKey "$PRODUCT_KEY"; then
    echo "Invalid product key: $PRODUCT_KEY"
    exit 1
fi

# Define the XML file location
XML_FILE="./http/Autounattend.xml"
[ ! -f "$XML_FILE" ] && echo "$XML_FILE not found!" && exit 1

# Mount the ISO
MOUNT_DIR="/tmp/mount_iso_$(date +%s)"
mkdir -p "$MOUNT_DIR"
sudo mount -o loop "$ISO_PATH" "$MOUNT_DIR"


WIM_PATH="$MOUNT_DIR/sources/install.wim"
declare -a IMAGES

if [ -f "$WIM_PATH" ]; then
    # Extract the names into the array
    while IFS= read -r name; do
        IMAGES+=("$name")
    done < <(wimlib-imagex info "$WIM_PATH" | awk -F': ' '/Index/ {flag=1; next} flag && /Name/ {gsub(/^ +| +$/, "", $2); print $2; flag=0}')
else
    echo "install.wim not found in the ISO."
    sudo umount "$MOUNT_DIR"
    rmdir "$MOUNT_DIR"
    exit 1
fi


# Check if provided WINDOWS_IMAGE is valid
VALID_IMAGE=false
if [[ "$WINDOWS_IMAGE" != "Not Provided" ]]; then
    for image in "${IMAGES[@]}"; do
        if [[ "$WINDOWS_IMAGE" == "$image" ]]; then
            VALID_IMAGE=true
            break
        fi
        echo "Provided windows image not found on iso!"
    done
fi

# If WINDOWS_IMAGE is not valid or not provided, display the options and ask for user's choice
if [[ "$WINDOWS_IMAGE" == "Not Provided" || "$VALID_IMAGE" == false ]]; then
    echo "Available Windows Images:"
    for index in "${!IMAGES[@]}"; do
        echo "[$((index+1))] - ${IMAGES[$index]}"
    done

    read -p "Please select an image index: " CHOICE
    if [[ "$CHOICE" -ge 1 && "$CHOICE" -le "${#IMAGES[@]}" ]]; then
        WINDOWS_IMAGE="${IMAGES[$((CHOICE-1))]}"
    else
        echo "Invalid choice. Exiting."
        sudo umount "$MOUNT_DIR"
        rmdir "$MOUNT_DIR"
        exit 1
    fi
fi

# Unmount the ISO
sudo umount "$MOUNT_DIR"
rmdir "$MOUNT_DIR"

# Update XML with the specific WINDOWS_IMAGE is provided
sed -i "/<InstallFrom>/,/<\/InstallFrom>/s/\(<Value>\).*\(<\/Value>\)/\1$WINDOWS_IMAGE\2/" "$XML_FILE"

# Update the product key in XML
if [[ "$PRODUCT_KEY" == "XXXXX-XXXXX-XXXXX-XXXXX-XXXXX" ]]; then
    # If default key, check if section is commented
    grep -q "<!--ProductKey>" "$XML_FILE" && grep -q "</ProductKey>-->" "$XML_FILE" && sed -i "/<!--ProductKey>/,/<\/ProductKey>-->/s/\(<Key>\).*\(<\/Key>\)/\1$PRODUCT_KEY\2/" "$XML_FILE" || {
        sed -i "/<\/ProductKey>-->/!s/<\/ProductKey>/<\/ProductKey>-->/;s/<ProductKey>/<!--ProductKey>/" "$XML_FILE"
        sed -i "/<!--ProductKey>/,/<\/ProductKey>-->/s/\(<Key>\).*\(<\/Key>\)/\1$PRODUCT_KEY\2/" "$XML_FILE"
    }
else
    # If custom key, update section and ensure it's uncommented
    grep -q "<!--ProductKey>" "$XML_FILE" && grep -q "</ProductKey>-->" "$XML_FILE" && {
        sed -i "s/<!--ProductKey>/<ProductKey>/;s/<\/ProductKey>-->/<\/ProductKey>/" "$XML_FILE"
        sed -i "/<ProductKey>/,/<\/ProductKey>/s/\(<Key>\).*\(<\/Key>\)/\1$PRODUCT_KEY\2/" "$XML_FILE"
    } || sed -i "/<ProductKey>/,/<\/ProductKey>/s/\(<Key>\).*\(<\/Key>\)/\1$PRODUCT_KEY\2/" "$XML_FILE"
fi
