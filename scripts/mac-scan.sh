#!/bin/sh
clear

echo =================================
echo \*\*\* MACOS SCAN FOLDER CREATOR \*\*\*
echo =================================
echo Description: Script de création
echo et partage d\'un dossier de scan.
echo
echo APPUYEZ SUR \'ENTER\' POUR EXECUTER
read

s_user=scan
s_folder=/Users/Shared/scan

echo ---
echo Création du dossier \'$s_folder\'...
mkdir -p $s_folder

echo Création de l\'utilisateur $s_user...
dscl . create /Users/$s_user
dscl . create /Users/$s_user RealName $s_user
dscl . create /Users/$s_user UniqueID 550
dscl . create /Users/$s_user PrimaryGroupID 20
dscl . create /Users/$s_user UserShell /usr/bin/false
dscl . create /Users/$s_user NFSHomeDirectory /dev/null
dscl . passwd /Users/$s_user $s_user

echo Activation du partage SMB...
launchctl load -w /System/Library/LaunchDaemons/com.apple.smbd.plist 2>/dev/null
defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server.plist EnabledServices -array disk 2>/dev/null
pwpolicy -u $s_user -sethashtypes SMB-NT on 1>/dev/null 2>/dev/null

echo Partage du dossier...
sharing -a $s_folder -S scan 1>/dev/null 2>/dev/null

echo Application des droits et ACLs sur le dossier...
chmod ugo+rwx $s_folder
chmod +a "group:everyone allow list,add_file,search,add_subdirectory,delete_child,readattr,writeattr,readextattr,writeextattr,readsecurity,file_inherit,directory_inherit" $s_folder

echo Création des raccourcis sur les bureaux...
cd /Users
for user in * ; do
   ln -s $s_folder /Users/$user/Desktop/Scan 2>/dev/null
done
rm $s_folder/scan 2>/dev/null

`sudo dscl . passwd /Users/$s_user $s_user`
echo ---
echo
echo Exécution terminée.
echo
echo

echo =[INFOS INTERFACE DU MULTIFONCTION]======
ip=`ifconfig | grep "inet " | grep -Fv "127." | awk '{print $2}'`
netbios_name=`scutil --get LocalHostName`
f_path=\\\\\\\\$netbios_name\\s_folder
echo $f_path | pbcopy
echo Répertoire partagé \(copié dans presse-papiers\):
echo $f_path ou \\\\\\\\$ip\\s_folder
echo Utilisateur et pass \(respecter la casse\):
echo \'$s_user\'
echo =========================================
echo
echo UNE FOIS LES INFORMATIONS ENREGISTREES DANS
echo LE MULTIFONCTION, ENREGISTREZ VOTRE TRAVAIL
echo ET APPUYEZ SUR \'ENTER\' POUR REDEMARRER.
read
reboot
