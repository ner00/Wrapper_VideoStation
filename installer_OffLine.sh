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
vs_path=/var/packages/VideoStation/target
ms_path=/var/packages/MediaServer/target
vs_libsynovte_file="$vs_path/lib/libsynovte.so"
ms_libsynovte_file="$ms_path/lib/libsynovte.so"
cp_path=/var/packages/CodecPack/target
cp_bin_path="$cp_path/bin"
declare -i control=0
logfile="/tmp/wrapper_ffmpeg.log"
LANG="0"
cpu_model=$(cat /proc/cpuinfo | grep "model name")

values=('669066909066906690' 'B801000000' '30')
hex_values=('1F28' '48F5' '4921' '4953' '4975' '9AC8')
indices=(0 1 1 1 1 2)
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
  echo -e  "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')] $1: $2"
}
function info() {
  log "${BLUE}INFO" "${YELLOW}$1"
}
function error() {
  log "${RED}ERROR" "${RED}$1"
}

function restart_packages() {
  text_restart_1=("Restarting CodecPack..." "Reiniciando CodecPack..." "Reiniciando o CodecPack..." "Redémarrage de CodecPack..." "CodecPack wird neu gestartet..." "Riavvio CodecPack...")

  info "${GREEN}${text_restart_1[$LANG]}"
  info "${GREEN}Restarting CodecPack..." >> $logfile
  synopkg restart CodecPack 2>> $logfile
}

function check_dependencias() {
text_ckck_depen1=("You have ALL necessary packages Installed, GOOD." "Tienes TODOS los paquetes necesarios ya instalados, BIEN." "Você tem TODOS os pacotes necessários já instalados, BOM." "Vous avez TOUS les packages nécessaires déjà installés, BON." "Sie haben ALLE notwendigen Pakete bereits installiert, GUT." "Hai già installato TUTTI i pacchetti necessari, BUONO.")

for dependencia in "${dependencias[@]}"; do
    if [[ ! -d "/var/packages/${dependencia[@]}" ]]; then
      error "MISSING $dependencia Package." 
      error "MISSING $dependencia Package." >> $logfile
    let "npacks=npacks+1"

    fi
done

if [[ npacks -eq control ]]; then
echo -e  "${GREEN}${text_ckck_depen1[$LANG]}"
fi

if [[ npacks -ne control ]]; then
echo -e  "At least you need $npacks package/s to Install, please Install the dependencies and RE-RUN the Installer again."
exit 1
fi

}

function titulo() {
   clear
text_titulo_1=("====================FFMPEG WRAPPER INSTALLER FOR DSM 7.0 and above by Dark Nebular.====================" "====================INSTALADOR DE WRAPPER FFMPEG PARA DSM 7.0 y superior de Dark Nebular.====================" "==================== INSTALADOR DO FFMPEG WRAPPER PARA DSM 7.0 e superior de Dark Nebular.======================" "==================== FFMPEG WRAPPER INSTALLER POUR DSM 7.0 et supérieur de Dark Nebular.====================" "==================== FFMPEG WRAPPER INSTALLER FÜR DSM 7.0 und höher von Dark Nebular.=====================" "==================== INSTALLER FFMPEG WRAPPER PER DSM 7.0 e versioni successive da Dark Nebular.=======================")
text_titulo_2=("====================This Wrapper Installer is only avalaible for DSM 7.0 and above only====================" "====================Este Instalador de Wrapper sólo está disponible para DSM 7.0 y superiores====================" "====================Este Instalador do Wrapper está disponível apenas para DSM 7.0 e superior======================" "====================Ce Wrapper Installer est uniquement disponible pour DSM 7.0 et supérieur=====================" "====================Dieser Wrapper-Installer ist nur für DSM 7.0 und höher verfügbar=====================" "=====================Questo programma di installazione wrapper è disponibile solo per DSM 7.0 e versioni successive=====================")

echo -e "${BLUE}${text_titulo_1[$LANG]}"
echo -e "${BLUE}${text_titulo_2[$LANG]}"
echo ""
echo ""
}

function check_root() {
# NO SE TRADUCE
   if [[ $EUID -ne 0 ]]; then
  error "YOU MUST BE ROOT FOR EXECUTE THIS INSTALLER. Please write ("${PURPLE}" sudo -i "${RED}") and try again with the Installer."
  exit 1
fi
}

function check_licence_AME() {
# NO SE TRADUCE
if [[ ! -f /usr/syno/etc/codec/activation.conf ]]; then
error "YOU HAVEN'T THE LICENCE LOADED in Advanced Media Extension package. Please, LOAD this licence and try again with the Installer."
error "YOU HAVEN'T THE LICENCE LOADED in Advanced Media Extension package. Please, LOAD this licence and try again with the Installer." >> $logfile
exit 1
fi
if grep "false" /usr/syno/etc/codec/activation.conf >> $logfile; then
error "YOU HAVEN'T THE LICENCE ACTIVATED in Advanced Media Extension package. Please, try to transcode something in VideoStation for activate It and try again with the Installer."
error "YOU HAVEN'T THE LICENCE ACTIVATED in Advanced Media Extension package. Please, try to transcode something in VideoStation for activate It and try again with the Installer." >> $logfile
exit 1
fi
}

function check_versions() {
# NO SE TRADUCE

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
error "Your DSM Version $dsm_version is NOT SUPPORTED using this Installer. Please use the MANUAL Procedure."
error "Your DSM Version $dsm_version is NOT SUPPORTED using this Installer. Please use the MANUAL Procedure." >> $logfile
exit 1
fi
}

function crackmenu() {
 clear
 text_crackmenu_1=("THIS IS THE LICENSE CRACK MENU, PLEASE CHOOSE YOUR SELECTION:" "ESTE ES EL MENU DEL CRACK DE LICENCIAS, POR FAVOR ELIJA SU SELECCIÓN:" "ESTE É O MENU DE CRACK DE LICENÇA, POR FAVOR, ESCOLHA SUA SELEÇÃO:" "VOICI LE MENU DE CRACK DE LICENCE, VEUILLEZ CHOISIR VOTRE SÉLECTION :" "DIES IST DAS LIZENZ-Crack-MENÜ, BITTE WÄHLEN SIE IHRE AUSWAHL:" "QUESTO È IL MENU CRACK DELLA LICENZA, PER FAVORE SCEGLI LA TUA SELEZIONE:")
 text_crackmenu_2=("RETURN to MAIN menu." "VOLVER al MENU Principal." "VOLTAR ao MENU Principal." "RETOUR au MENU Principal." "ZURÜCK zum Hauptmenü." "INDIETRO al menù principale.")
 text_crackmenu_3=("Do you want to install the crack for the AME license?" "¿Deseas instalar el crack para la licencia del AME?" "Deseja instalar o crack para a licença AME?" "Voulez-vous installer le crack pour la licence AME ?" "Möchten Sie den Crack für die AME-Lizenz installieren?" "Vuoi installare la crack per la licenza AME?")
 text_crackmenu_4=("Please answer with the correct option writing: P (Patch the AME's license) or U (Unpatch the AME's license). Write Z (to QUIT)." "Por favor, responda con la opción correcta escribiendo: P (parchea la licencia de AME) o U (desparchea la licencia de AME). Escribe Z (para volver al menú PRINCIPAL)." "Por favor, responda com a opção correta digitando: P (patches de licença AME) ou U (unpatches de licença AME). Digite Z (para retornar ao menu PRINCIPAL)." "Veuillez répondre avec l'option correcte en tapant : P (corrige la licence AME) ou U (élimine la licence AME). Tapez Z (pour revenir au menu PRINCIPAL)." "Bitte antworten Sie mit der richtigen Option, indem Sie Folgendes eingeben: P (Patches der AME-Lizenz) oder U (Patches der AME-Lizenz aufheben). Geben Sie Z ein (um zum HAUPTMENÜ zurückzukehren)." "Si prega di rispondere con l'opzione corretta digitando: P (patch della licenza AME) o U (unpatch della licenza AME). Digitare Z (per tornare al menu PRINCIPALE).")
 text_crackmenu_5=("==================== Installation of the AME's License Crack ====================" "==================== Instalación del Crack de Licencia de AME ====================" "==================== Instalando o crack da licença AME =====================" "==================== Installation du crack de licence AME ====================" "==================== Installieren des AME-Lizenz-Cracks ====================" "===================== Installazione della licenza AME Crack ====================")	
 text_crackmenu_6=("INSTALL the AME's License Crack" "INSTALAR el crack de licencia de AME" "INSTALE o crack da licença AME" "INSTALLER le crack de la licence AME" "INSTALLIEREN Sie den AME-Lizenz-Crack" "INSTALLA il crack della licenza AME")
 text_crackmenu_7=("UNINSTALL the AME's License Crack" "DESINSTALAR el crack de licencia de AME" "DESINSTALAR crack de licença AME" "DÉSINSTALLER le crack de la licence AME" "AME-Lizenz-Crack DEINSTALLIEREN" "DISINSTALLA il crack della licenza AME")	
 text_crackmenu_8=("This patcher enables Advanced Media Extensions 3.0 for you, without having to login account." "Este parche habilita Advanced Media Extensions 3.0 para usted, sin tener que iniciar sesión en la cuenta." "Este patch habilita o Advanced Media Extensions 3.0 para você, sem ter que entrar em sua conta." "Ce correctif active Advanced Media Extensions 3.0 pour vous, sans avoir à vous connecter à votre compte." "Dieser Patch aktiviert Advanced Media Extensions 3.0 für Sie, ohne dass Sie sich bei Ihrem Konto anmelden müssen." "Questa patch abilita Advanced Media Extensions 3.0 per te, senza dover accedere al tuo account.")	
 text_crackmenu_9=("This enables the AAC and HEVC codecs and its license in the AME package, until DSM 7.2." "Esto habilita los códecs AAC y HEVC y su licencia en el paquete AME, hasta DSM 7.2." "Isso habilita os codecs AAC e HEVC e suas licenças no pacote AME, até DSM 7.2." "Cela active les codecs AAC et HEVC et leur licence dans le package AME, jusqu'à DSM 7.2." "Dadurch werden die AAC- und HEVC-Codecs und deren Lizenz im AME-Paket bis DSM 7.2 aktiviert." "Ciò abilita i codec AAC e HEVC e la relativa licenza nel pacchetto AME, fino a DSM 7.2.")	
 text_crackmenu_10=("When you install this License crack, the Wrapper will be deleted and you must to re-install it again." "Cuando instale este crack de licencia, el Wrapper se eliminará y deberá volver a instalarlo." "Ao instalar este crack de licença, o contêiner será removido e você precisará reinstalá-lo." "Lorsque vous installez ce crack de licence, le conteneur sera supprimé et vous devrez le réinstaller." "Wenn Sie diesen Lizenz-Crack installieren, wird der Container entfernt und Sie müssen ihn neu installieren." "Quando installi questo crack della licenza, il contenitore verrà rimosso e dovrai reinstallarlo.")
 text_crackmenu_11=("Note that in order to use this, you will have to use a valid SN (but doesn't have to login synology account with that SN)." "Tenga en cuenta que para usar esto, deberá usar un SN válido (pero no tiene que iniciar sesión en una cuenta de Synology con ese SN)." "Observe que, para usá-lo, você precisará usar um SN válido (mas não precisa entrar em uma conta Synology com esse SN)." "Veuillez noter que pour l'utiliser, vous devrez utiliser un SN valide (mais vous n'avez pas besoin de vous connecter à un compte Synology avec ce SN)." "Bitte beachten Sie, dass Sie zur Nutzung eine gültige SN verwenden müssen (Sie müssen sich jedoch nicht mit dieser SN bei einem Synology-Konto anmelden)." "Si noti che per utilizzare questo, sarà necessario utilizzare un SN valido (ma non è necessario accedere a un account Synology con quel SN).")	
 text_crackmenu_12=("DISCLAIMER:" "DESCARGO DE RESPONSABILIDAD:" "ISENÇÃO DE RESPONSABILIDADE:" "CLAUSE DE NON-RESPONSABILITÉ:" "HAFTUNGSAUSSCHLUSS:" "DISCLAIMER:")	
 text_crackmenu_13=("Use at your own risk, although it has been done to be as safe as possible, there could be errors. (Crack for XPenelogy and Synology without AME's license)." "Úsalo bajo tu propia responsabilidad, aunque se ha hecho para ser lo más seguro posible, podría haber errores. (Crack para XPenology y Synology sin licencia de AME)." "Use-o por sua conta e risco, embora tenha sido feito para ser o mais seguro possível, pode haver erros. (Crack para XPenology e Synology sem licença AME)." "Utilisez-le à vos propres risques, bien qu'il ait été fait pour être aussi sûr que possible, il pourrait y avoir des erreurs. (Crack pour XPenology et Synology sans licence AME)." "Die Verwendung erfolgt auf eigene Gefahr. Obwohl dies so sicher wie möglich ist, kann es dennoch zu Fehlern kommen. (Crack für XPenology und Synology ohne AME-Lizenz)." "Usalo a tuo rischio e pericolo, anche se è stato fatto per essere il più sicuro possibile, potrebbero esserci degli errori. (Crack per XPenology e Synology senza licenza AME).")	
  
	echo ""
        echo -e "${BLUE}${text_crackmenu_5[$LANG]}"
	info "${BLUE}==================== Installation of the AME's License Crack ====================" >> $logfile
	echo ""
	echo -e "${GREEN}${text_crackmenu_8[$LANG]}"
	echo -e "${GREEN}${text_crackmenu_9[$LANG]}"
	echo -e "${GREEN}${text_crackmenu_10[$LANG]}"
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
        echo -e "${PURPLE} ( Z ) ${text_crackmenu_2[$LANG]}"
   	while true; do
	echo -e "${GREEN}"
    read -p "${text_crackmenu_3[$LANG]}" puz
        case $puz in
        	[Pp]* ) patch_ame_license; break;;
		[Uu]* ) unpatch_ame_license; break;;
		[Zz]* ) exit 0;;
		* ) echo -e "${YELLOW}${text_crackmenu_4[$LANG]}";;  
        esac
	done
}
patch_ame_license() {

touch "$logfile"

text_patchame_1=("The backup file $so_backup already exists. A new backup will not be created." "El archivo de respaldo $so_backup ya existe. No se creará una nueva copia de seguridad." "O arquivo de backup $so_backup já existe. Um novo backup não será criado." "Le fichier de sauvegarde $so_backup existe déjà. Une nouvelle sauvegarde ne sera pas créée." "Die Sicherungsdatei $so_backup existiert bereits. Es wird kein neues Backup erstellt." "Il file di backup $so_backup esiste già. Non verrà creato un nuovo backup.")
text_patchame_2=("$so backup created as $so_backup." "Copia de seguridad de $so creada como $so_backup." "$so backup criado como $so_backup." "Sauvegarde $so créée en tant que $so_backup." "$so-Backup erstellt als $so_backup." "$so backup creato come $so_backup.")
text_patchame_3=("The backup file $lic_backup already exists. A new backup will not be created." "El archivo de respaldo $lic_backup ya existe. No se creará una nueva copia de seguridad." "O arquivo de backup $lic_backup já existe. Um novo backup não será criado." "Le fichier de sauvegarde $lic_backup existe déjà. Une nouvelle sauvegarde ne sera pas créée." "Die Sicherungsdatei $lic_backup existiert bereits. Es wird kein neues Backup erstellt." "Il file di backup $lic_backup esiste già. Non verrà creato un nuovo backup.")
text_patchame_4=("$lic backup created as $lic_backup." "Copia de seguridad de $lic creada como $lic_backup." "$lic backup criado como $lic_backup." "Sauvegarde $lic créée en tant que $lic_backup." "$lic-Backup erstellt als $lic_backup." "$lic backup creato come $lic_backup.")
text_patchame_5=("The backup file $licsig_backup already exists. A new backup will not be created." "El archivo de respaldo $licsig_backup ya existe. No se creará una nueva copia de seguridad." "O arquivo de backup $licsig_backup já existe. Um novo backup não será criado." "Le fichier de sauvegarde $licsig_backup existe déjà. Une nouvelle sauvegarde ne sera pas créée." "Die Sicherungsdatei $licsig_backup existiert bereits. Es wird kein neues Backup erstellt." "Il file di backup $licsig_backup esiste già. Non verrà creato un nuovo backup.")
text_patchame_6=("$licsig backup created as $licsig_backup." "Copia de seguridad de $licsig creada como $licsig_backup." "$licsig backup criado como $licsig_backup." "Sauvegarde $licsig créée en tant que $licsig_backup." "$licsig-Backup erstellt als $licsig_backup." "$licsig backup creato come $licsig_backup.")
text_patchame_7=("Applying the patch." "Aplicando el patch." "Aplicando o remendo." "Application du patch." "Anbringen des Patches." "Applicazione del cerotto.")	
text_patchame_8=("Checking whether patch is successful..." "Comprobando si el parche es exitoso..." "Verificando se o patch foi bem-sucedido..." "Vérification du succès du correctif..." "Überprüfen, ob der Patch erfolgreich ist..." "Verifica se la patch ha esito positivo...")	
text_patchame_9=("Successful, updating codecs." "Correcto, actualizando códecs." "Certo, atualizando codecs." "Bon, mise à jour des codecs." "Richtig, Codecs aktualisieren." "Giusto, aggiornando i codec.")	
text_patchame_10=("Crack installed correctly." "Crack instalado correctamente." "Crack instalado com sucesso." "Crack installé avec succès." "Crack erfolgreich installiert." "Crack installato con successo.")	
text_patchame_11=("Patched but unsuccessful." "Parcheado pero sin éxito." "Parcheado, mas sem sucesso." "Patché mais sans succès." "Gepatcht, aber ohne Erfolg." "Patched ma senza successo.")	
text_patchame_12=("Please do an uninstallation of the Wrapper first." "Por favor, primero desinstale el Wrapper." "Faça uma desinstalação do Wrapper primeiro." "Veuillez d'abord désinstaller le Wrapper." "Bitte deinstallieren Sie zunächst den Wrapper." "Eseguire prima una disinstallazione del Wrapper.")	
text_patchame_13=("Error occurred while writing to the file." "Se produjo un error al escribir en el archivo." "Ocorreu um erro ao escrever no arquivo." "Une erreur s'est produite lors de l'écriture dans le fichier." "Beim Schreiben in die Datei ist ein Fehler aufgetreten." "Si è verificato un errore durante la scrittura nel file.")

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
    echo "MD5 mismatch"
    unpatch_ame_license
    exit 1
fi

for ((i = 0; i < ${#hex_values[@]}; i++)); do
    offset=$(( 0x${hex_values[i]} + 0x8000 ))
    value=${values[indices[i]]}
    printf '%s' "$value" | xxd -r -p | dd of="$so" bs=1 seek="$offset" conv=notrunc 2>> "$logfile"
    if [[ $? -ne 0 ]]; then
        info "${RED}${text_patchame_13[$LANG]}"
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
  	info "${YELLOW}Successful, updating codecs." >> $logfile
        "$cp_usr_path/bin/synoame-bin-auto-install-needed-codec" 2>> "$logfile"
	info "${GREEN}${text_patchame_10[$LANG]}"
        info "${GREEN}Crack installed correctly." >> $logfile
		sleep 4
		reloadstart
    	else
	info "${YELLOW}${text_patchame_11[$LANG]}"
        info "${YELLOW}Patched but unsuccessful." >> $logfile

        exit 1
   	fi
}
unpatch_ame_license() {

touch "$logfile"

text_unpatchame_1=("$so file restored from $so_backup." "Archivo $so restaurado desde $so_backup." "$so arquivo restaurado de $so_backup." "Fichier $so restauré à partir de $so_backup." "$so-Datei aus $so_backup wiederhergestellt." "$so file ripristinato da $so_backup.")	
text_unpatchame_2=("Backup file $so_backup does not exist. No restore action will be performed." "El archivo de respaldo $so_backup no existe. No se realizará ninguna acción de restauración." "O arquivo de backup $so_backup não existe. Nenhuma ação de restauração será executada." "Le fichier de sauvegarde $so_backup n'existe pas. Aucune action de restauration ne sera effectuée." "Die Sicherungsdatei $so_backup existiert nicht. Es wird keine Wiederherstellungsaktion durchgeführt." "Il file di backup $so_backup non esiste. Non verrà eseguita alcuna azione di ripristino.")	
text_unpatchame_3=("$lic file restored from $lic_backup." "Archivo $lic restaurado desde $lic_backup." "$lic arquivo restaurado de $lic_backup." "Fichier $lic restauré à partir de $lic_backup." "$lic-Datei aus $lic_backup wiederhergestellt." "$lic file ripristinato da $lic_backup.")	
text_unpatchame_4=("Backup file $lic_backup does not exist. No restore action will be performed." "El archivo de respaldo $lic_backup no existe. No se realizará ninguna acción de restauración." "O arquivo de backup $lic_backup não existe. Nenhuma ação de restauração será executada." "Le fichier de sauvegarde $lic_backup n'existe pas. Aucune action de restauration ne sera effectuée." "Die Sicherungsdatei $lic_backup existiert nicht. Es wird keine Wiederherstellungsaktion durchgeführt." "Il file di backup $lic_backup non esiste. Non verrà eseguita alcuna azione di ripristino.")	
text_unpatchame_5=("$licsig file restored from $licsig_backup." "Archivo $licsig restaurado desde $licsig_backup." "$licsig arquivo restaurado de $licsig_backup." "Fichier $licsig restauré à partir de $licsig_backup." "$licsig-Datei aus $licsig_backup wiederhergestellt." "$licsig file ripristinato da $licsig_backup.")	
text_unpatchame_6=("Backup file $licsig_backup does not exist. No restore action will be performed." "El archivo de respaldo $licsig_backup no existe. No se realizará ninguna acción de restauración." "O arquivo de backup $licsig_backup não existe. Nenhuma ação de restauração será executada." "Le fichier de sauvegarde $licsig_backup n'existe pas. Aucune action de restauration ne sera effectuée." "Die Sicherungsdatei $licsig_backup existiert nicht. Es wird keine Wiederherstellungsaktion durchgeführt." "Il file di backup $licsig_backup non esiste. Non verrà eseguita alcuna azione di ripristino.")	
text_unpatchame_7=("Crack uninstalled correctly." "Crack desinstalado correctamente." "Crack desinstalado com sucesso." "Crack désinstallé avec succès." "Crack wurde erfolgreich deinstalliert." "Crack disinstallato con successo.")
	
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
info "${GREEN}Crack uninstalled correctly." >> $logfile
	
sleep 4
reloadstart
}


function reloadstart() {
clear
titulo
check_dependencias
check_licence_AME
check_versions
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
  info) exit 0;;
esac
