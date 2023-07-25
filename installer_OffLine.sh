#!/bin/bash

##############################################################
version="SCPT_3.9.1"
# Changes:
# SCPT_1.X: See these changes in the releases notes in my Repository in Github. (Deprecated)
# SCPT_2.X: See these changes in the releases notes in my Repository in Github. (Deprecated)
# SCPT_3.0: Initial new major Release. Clean the code from last versions. (Deprecated migrated to SCPT_3.1)
# SCPT_3.1: Add compatibility to DSXXX-Play appliances using ffmpeg27. Change the name of the injectors. (Deprecated migrated to SCPT_3.2)
# SCPT_3.2: Reflect the new Wrapper change in the installation script. (Deprecated migrated to SCPT_3.3)
# SCPT_3.3: Support for the new versions of FFMPEG 6.0.X and deprecate the use of ffmpeg 4.X.X. (Deprecated migrated to SCPT_3.4)
# SCPT_3.4: Improvements in checking for future releases of DSM's versions. Creation of installer_OffLine to avoid the 128KB limit and to be able to create more logic in the script and new fuctions. (Deprecated migrated to SCPT_3.5)
# SCPT_3.5: Added an Installer for the License's CRACK for the AME 3.0. Improvements in autoinstall, now the autoinstall will installs the type of Wrapper that you had installed. (Deprecated migrated to SCPT_3.6)
# SCPT_3.6: Added full support for DS21X-Play devices with ARMv8 using a GStreamer's Wrapper. Now the installer recommends to you the Simplest or the Advanced in function of the performance of your system. (Deprecated migrated to SCPT_3.7)
# SCPT_3.7: Fixed a bug in the GStreamer's Wrapper installer that doesn't clear the plugin's cache in AME. (Deprecated migrated to SCPT_3.8)
# SCPT_3.8: Fixed a bug in declaration of the variables for the licenses fix for AME. (Deprecated migrated to SCPT_3.9)
# SCPT_3.9: Added the possibility to transcode AAC codec in Video Station and Media Server. Added new libraries for GStreamer 1.6.3. for this AAC decoding. Added the word BETA for the cracker of the AME's license. (Deprecated migrated to SCPT_3.9.1)
# SCPT_3.9.1: Added in the license's crack the patch for the DSM 7.2.

##############################################################


###############################
# VARIABLES GLOBALES
###############################

dsm_version=$(cat /etc.defaults/VERSION | grep productversion | sed 's/productversion=//' | tr -d '"')
majorversion=$(cat /etc.defaults/VERSION | grep majorversion | sed 's/majorversion=//' | tr -d '"')
minorversion=$(cat /etc.defaults/VERSION | grep minorversion | sed 's/minorversion=//' | tr -d '"')
repo_url="https://raw.githubusercontent.com/ner00/Wrapper_VideoStation"
setup="crackmenu"
dependencias=("CodecPack")
RED="\u001b[31m"
BLUE="\u001b[36m"
BLUEGSLP="\u001b[36m"
PURPLE="\u001B[35m"
GREEN="\u001b[32m"
YELLOW="\u001b[33m"
cp_path=/var/packages/CodecPack/target
cp_bin_path="$cp_path/bin"
declare -i control=0
logfile="/tmp/amepatch.log"
LANG="0"
cpu_model=$(cat /proc/cpuinfo | grep "model name")

values=('669066909066906690' 'B801000000' '30')
hex_values=('1F28' '48F5' '4921' '4953' '4975' '9AC8')
indexes=(0 1 1 1 1 2)
cp_usr_path='/var/packages/CodecPack/target/usr'
so="$cp_usr_path/lib/libsynoame-license.so"
so_backup="$cp_usr_path/lib/libsynoame-license.so.orig"
lic="/usr/syno/etc/license/data/ame/offline_license.json"
lic_backup="/usr/syno/etc/license/data/ame/offline_license.json.orig"
licsig="/usr/syno/etc/license/data/ame/offline_license.sig"
licsig_backup="/usr/syno/etc/license/data/ame/offline_license.sig.orig"


###############################
# FUNCIONES
###############################

function log() {
  echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')] $1: $2"
}

function info() {
  log "${BLUE}INFO" "${YELLOW}$1"
}

function error() {
  log "${RED}ERROR" "${RED}$1"
}

function check_dependencias() {
  text_ckck_depen1=("GOOD! You have ALL the necessary packages installed.")
  
  for dependencia in "${dependencias[@]}"; do
    if [[ ! -d "/var/packages/${dependencia[@]}" ]]; then
      error "MISSING $dependencia package." 
      error "MISSING $dependencia package." >> $logfile
      let "npacks=npacks+1"
    fi
  done
  
  if [[ npacks -eq control ]]; then
    echo -e "${GREEN}${text_ckck_depen1[$LANG]}"
  fi
  
  if [[ npacks -ne control ]]; then
    echo -e "You need to install at least $npacks package(s), please install those dependencies and run this patcher again."
    exit 1
  fi
}

function titulo() {
  clear
  text_titulo_1=("==================== AME License Patcher for DSM 7.0 and above ====================")
  text_titulo_2=("==================== This patcher is only compatible with DSM 7.0 and above ====================")

  echo -e "${BLUE}${text_titulo_1[$LANG]}"
  echo -e "${BLUE}${text_titulo_2[$LANG]}"
  echo ""
  echo ""
}

function check_root() {
  if [[ $EUID -ne 0 ]]; then
    error "YOU MUST BE ROOT TO EXECUTE THIS PATCHER. Please type ("${PURPLE}" sudo -i "${RED}") and try again."
    exit 1
  fi
}

function check_licence_AME() {
  if [[ ! -f /usr/syno/etc/codec/activation.conf ]]; then
    error "NO LICENSE LOADED in Advanced Media Extension package. Please LOAD a license and try again."
    error "NO LICENSE LOADED in Advanced Media Extension package. Please LOAD a license and try again." >> $logfile
    exit 1
  fi
  if grep "false" /usr/syno/etc/codec/activation.conf >> $logfile; then
    error "NO LICENSE ACTIVATED in Advanced Media Extension package. Please transcode a video in VideoStation to activate it and try again."
    error "NO LICENSE ACTIVATED in Advanced Media Extension package. Please transcode a video in VideoStation to activate it and try again." >> $logfile
    exit 1
  fi
}

function check_versions() {
  # Contemplando la posibilidad de que las sucesivas versiones 0 de DSM 8 y futuras sigan con las variables correctas.
  if [[ "$majorversion" -ge "8" ]]; then
    cp_path="/var/packages/CodecPack/target/pack"
    cp_bin_path="$cp_path/bin"
  elif [[ "$majorversion" -eq "7" && "$minorversion" -ge "1" ]]; then
    cp_path="/var/packages/CodecPack/target/pack"
    cp_bin_path="$cp_path/bin"
  elif [[ "$majorversion" -eq "7" && "$minorversion" -eq "0" ]]; then
    cp_path="/var/packages/CodecPack/target"
    cp_bin_path="$cp_path/bin"
  else
    error "This patcher does not support your DSM version $dsm_version"
    error "This patcher does not support your DSM version $dsm_version" >> $logfile
    exit 1
  fi
}

function crackmenu() {
  clear
  text_crackmenu_1=("Please type an option:")
  text_crackmenu_2=("Quit")
  text_crackmenu_3=("What do you want to do? ")
  text_crackmenu_4=("Please type the corresponding letter: P to Patch the AME License or U to Unpatch the AME License. Type Q to Quit.")
  text_crackmenu_5=("==================== AME License Patcher ====================")
  text_crackmenu_6=("Patch AME License")
  text_crackmenu_7=("Unpatch AME License")
  text_crackmenu_8=("This patcher enables Advanced Media Extensions 3.0 for you, without needing a Synology account.")
  text_crackmenu_9=("This enables the HEVC and AAC codecs and its license in the AME package, up to DSM 7.2.")
  text_crackmenu_11=("Note that in order to use this, your Synology DSM needs to use a valid S/N, even if generated.")
  text_crackmenu_12=("DISCLAIMER:")
  text_crackmenu_13=("Use at your own risk! Although it has been tested, there could be errors.")
  
  echo ""
  echo -e "${BLUE}${text_crackmenu_5[$LANG]}"
  info "${BLUE}==================== AME License Patcher ====================" >> $logfile
  echo ""
  echo -e "${GREEN}${text_crackmenu_8[$LANG]}"
  echo -e "${GREEN}${text_crackmenu_9[$LANG]}"
  echo -e "${GREEN}${text_crackmenu_11[$LANG]}"
  echo ""
  echo ""
  echo -e "${RED}${text_crackmenu_12[$LANG]} ${YELLOW}${text_crackmenu_13[$LANG]}"
  echo ""
  echo -e "${YELLOW}${text_crackmenu_1[$LANG]}"
  echo ""
  echo -e "${BLUE} ( P ) ${text_crackmenu_6[$LANG]}"
  echo -e "${BLUE} ( U ) ${text_crackmenu_7[$LANG]}"       
  echo -e ""
  echo -e "${PURPLE} ( Q ) ${text_crackmenu_2[$LANG]}"
  while true; do
    echo -e "${GREEN}"
    read -p "${text_crackmenu_3[$LANG]}" puq
    case $puq in
      [Pp]* ) patch_ame_license; break;;
      [Uu]* ) unpatch_ame_license; break;;
      [Qq]* ) exit 0;;
      * ) echo -e "${YELLOW}${text_crackmenu_4[$LANG]}";;  
    esac
  done
}

patch_ame_license() {
  touch "$logfile"
  
  text_patchame_1=("The backup file $so_backup already exists. A new backup will not be created.")
  text_patchame_2=("$so backup created as $so_backup.")
  text_patchame_3=("The backup file $lic_backup already exists. A new backup will not be created.")
  text_patchame_4=("$lic backup created as $lic_backup.")
  text_patchame_5=("The backup file $licsig_backup already exists. A new backup will not be created.")
  text_patchame_6=("$licsig backup created as $licsig_backup.")
  text_patchame_7=("Applying the patch.")
  text_patchame_8=("Checking whether patch is successful...")
  text_patchame_9=("Successful, updating codecs...")
  text_patchame_10=("Done.")
  text_patchame_11=("Patch was unsuccessful.")
  text_patchame_12=("Error occurred while writing to the file.")
  
  # Verificar si ya existen los archivos de respaldo
  if [ -f "$so_backup" ]; then
    info "${GREEN}${text_patchame_1[$LANG]}"
    info "${GREEN}The backup file $so_backup already exists. A new backup will not be created." >> $logfile
  else
    # Crear copia de seguridad de libsynoame-license.so
    cp -p "$so" "$so_backup"
    info "${GREEN}${text_patchame_2[$LANG]}"
    info "${GREEN}$so backup created as $so_backup." >> $logfile
  fi
  
  if [ -f "$lic_backup" ]; then
    info "${GREEN}${text_patchame_3[$LANG]}"
    info "${GREEN}The backup file $lic_backup already exists. A new backup will not be created." >> $logfile
  else
    # Crear copia de seguridad de offline_license.json
    cp -p "$lic" "$lic_backup"
    info "${GREEN}${text_patchame_4[$LANG]}"
    info "${GREEN}$lic backup created as $lic_backup." >> $logfile
  fi
  
  if [ -f "$licsig_backup" ]; then
    info "${GREEN}${text_patchame_5[$LANG]}"
    info "${GREEN}The backup file $licsig_backup already exists. A new backup will not be created." >> $logfile
  else
    # Crear copia de seguridad de offline_license.sig
    cp -p "$licsig" "$licsig_backup"
    info "${GREEN}${text_patchame_6[$LANG]}"
    info "${GREEN}$licsig backup created as $licsig_backup." >> $logfile
  fi
  
   info "${YELLOW}${text_patchame_7[$LANG]}"
   info "${YELLOW}Applying the patch." >> $logfile
  
  # Comprobar que el fichero a parchear sea exactamente la misma versión que se estudió. 
  if [[ "$majorversion" -eq "7" && "$minorversion" -le "1" ]]; then
    expected_checksum='fcc1084f4eadcf5855e6e8494fb79e23'
    hex_values=('1F28' '48F5' '4921' '4953' '4975' '9AC8')
    content= '[{"appType": 14, "appName": "ame", "follow": ["device"], "server_time": 1666000000, "registered_at": 1651000000, "expireTime": 0, "status": "valid", "firstActTime": 1651000001, "extension_gid": null, "licenseCode": "0", "duration": 1576800000, "attribute": {"codec": "hevc", "type": "free"}, "licenseContent": 1}, {"appType": 14, "appName": "ame", "follow": ["device"], "server_time": 1666000000, "registered_at": 1651000000, "expireTime": 0, "status": "valid", "firstActTime": 1651000001, "extension_gid": null, "licenseCode": "0", "duration": 1576800000, "attribute": {"codec": "aac", "type": "free"}, "licenseContent": 1}]'
  elif [[ "$majorversion" -eq "7" && "$minorversion" -eq "2" ]]; then
    expected_checksum='09e3adeafe85b353c9427d93ef0185e9'
    hex_values=('3718' '60A5' '60D1' '6111' '6137' 'B5F0')
    content='[{"attribute": {"codec": "hevc", "type": "free"}, "status": "valid", "extension_gid": null, "expireTime": 0, "appName": "ame", "follow": ["device"], "duration": 1576800000, "appType": 14, "licenseContent": 1, "registered_at": 1649315995, "server_time": 1685421618, "firstActTime": 1649315995, "licenseCode": "0"}, {"attribute": {"codec": "aac", "type": "free"}, "status": "valid", "extension_gid": null, "expireTime": 0, "appName": "ame", "follow": ["device"], "duration": 1576800000, "appType": 14, "licenseContent": 1, "registered_at": 1649315995, "server_time": 1685421618, "firstActTime": 1649315995, "licenseCode": "0"}]'
  fi
  
  if [ "$(md5sum -b "$so" | awk '{print $1}')" != "$expected_checksum" ]; then
    echo "MD5 mismatch, not matching any version of AME"
    unpatch_ame_license
    exit 1
  fi
  
  for ((i = 0; i < ${#hex_values[@]}; i++)); do
    offset=$(( 0x${hex_values[i]} + 0x8000 ))
    value=${values[indexes[i]]}
    printf '%s' "$value" | xxd -r -p | dd of="$so" bs=1 seek="$offset" conv=notrunc 2>> "$logfile"
    if [[ $? -ne 0 ]]; then
      info "${RED}${text_patchame_12[$LANG]}"
      # Llama a la función unpatch_ame_license en caso de error
      unpatch_ame_license  
      exit 1
    fi
  done

  mkdir -p "$(dirname "$lic")"
  echo "$content" > "$lic"

  info "${YELLOW}${text_patchame_8[$LANG]}"
  info "${YELLOW}Checking whether patch is successful..." >> $logfile
    
if "$cp_usr_path/bin/synoame-bin-check-license"; then
  	info "${YELLOW}${text_patchame_9[$LANG]}"
    info "${YELLOW}Successful, updating codecs..." >> $logfile
    "$cp_usr_path/bin/synoame-bin-auto-install-needed-codec" 2>> "$logfile"
  	info "${GREEN}${text_patchame_10[$LANG]}"
    info "${GREEN}Done." >> $logfile
  	sleep 4
  	reloadstart
  else
	  info "${YELLOW}${text_patchame_11[$LANG]}"
    info "${YELLOW}Patch was unsuccessful." >> $logfile
    exit 1
  fi
}

function unpatch_ame_license() {
  touch "$logfile"
  
  text_unpatchame_1=("$so file restored from $so_backup.")
  text_unpatchame_2=("Backup file $so_backup does not exist. No restore action will be performed.")
  text_unpatchame_3=("$lic file restored from $lic_backup.")
  text_unpatchame_4=("Backup file $lic_backup does not exist. No restore action will be performed.")
  text_unpatchame_5=("$licsig file restored from $licsig_backup.")
  text_unpatchame_6=("Backup file $licsig_backup does not exist. No restore action will be performed.")
  text_unpatchame_7=("Patch removed successfully.")
	
  if [ -f "$so_backup" ]; then
    mv "$so_backup" "$so"
    info "${GREEN}${text_unpatchame_1[$LANG]}"
    info "${GREEN}$so file restored from $so_backup." >> $logfile
  else
    info "${GREEN}${text_unpatchame_2[$LANG]}"
    info "${GREEN}Backup file $so_backup does not exist. No restore action will be performed." >> $logfile
  fi

  if [ -f "$lic_backup" ]; then
    mv "$lic_backup" "$lic"
	  info "${GREEN}${text_unpatchame_3[$LANG]}"
    info "${GREEN}$lic file restored from $lic_backup." >> $logfile
  else
    info "${GREEN}${text_unpatchame_4[$LANG]}"
    info "${GREEN}Backup file $lic_backup does not exist. No restore action will be performed." >> $logfile
  fi
  
  if [ -f "$licsig_backup" ]; then
    mv "$licsig_backup" "$licsig"
  	info "${GREEN}${text_unpatchame_5[$LANG]}"
    info "${GREEN}$licsig file restored from $licsig_backup." >> $logfile
  else
    info "${GREEN}${text_unpatchame_6[$LANG]}"
    info "${GREEN}Backup file $licsig_backup does not exist. No restore action will be performed." >> $logfile
  fi
  
  info "${GREEN}${text_unpatchame_7[$LANG]}"
  info "${GREEN}Patch removed successfully." >> $logfile
  
  sleep 4
  reloadstart
}

function reloadstart() {
  clear
  titulo
  check_dependencias
  check_licence_AME
  check_versions
  crackmenu
}


################################
# EJECUCIÓN
################################
titulo

check_root

check_dependencias

check_licence_AME

check_versions

case "$setup" in
  crackmenu) crackmenu;;
esac
