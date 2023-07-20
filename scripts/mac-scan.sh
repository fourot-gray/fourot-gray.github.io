#!/bin/sh
clear

echo =========================
echo MACOS SCAN FOLDER CREATOR
echo =========================
echo

s_user=scan
s_folder=/Users/Shared/SCAN

echo Création du dossier \'$s_folder\'...
mkdir -p $s_folder

echo Création de l\'utilisateur $s_user...
dscl . create /Users/$s_user
dscl . create /Users/$s_user RealName $s_user
dscl . passwd /Users/$s_user $s_user
dscl . create /Users/$s_user UniqueID 550
dscl . create /Users/$s_user PrimaryGroupID 20
dscl . create /Users/$s_user UserShell /usr/bin/false
dscl . create /Users/$s_user NFSHomeDirectory /dev/null

echo Activation du partage SMB...
launchctl load -w /System/Library/LaunchDaemons/com.apple.smbd.plist 2>/dev/null
defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server.plist EnabledServices -array disk 2>/dev/null
pwpolicy -u $s_user -sethashtypes SMB-NT on 1>/dev/null 2>/dev/null

echo Partage du dossier...
sharing -a $s_folder

echo Application des droits et ACLs sur le dossier...
chmod ugo+rwx $s_folder
chmod +a "group:everyone allow list,add_file,search,add_subdirectory,delete_child,readattr,writeattr,readextattr,writeextattr,readsecurity,file_inherit,directory_inherit" $s_folder

echo Création des raccourcis sur les bureaux...
cd /Users
for user in * ; do
   ln -s $s_folder /Users/$user/Desktop/Scan 2>/dev/null
done
