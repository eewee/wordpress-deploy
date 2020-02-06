#!/bin/bash
#
# WP Installeur :
# Permettre l'installation en local de Wordpress
#
# Comment lancer le "deploy" ?
# bash deploy.sh sitename themename "Titre de mon site"
# bash deploy.sh "wp_astra" "astra" "Titre de mon site"
# $1 = "nom du dossier" & "nom de la db" & "suffixe login"
# $2 = "nom du theme" (ex: astra)
# $3 = "titre du site" (ex: Lorem ipsum)
# 
# Arbo :
# wp_deploy
#   .gitignore
#   deploy.sh
#   plugins.txt
#   README.md

#---------------------------------------------------------------
# CONFIG WORDPRESS (a editer avec vos propres informations)
#---------------------------------------------------------------

# db 
dbhost="127.0.0.1:8889"
dbname=$1
dbuser="root"
dbpass="root"
dbprefix="wp_"

# admin email
admin_email="contact@eewee.fr"

# admin login
admin_login="admin-$1"

# local url login
# Ex : http://localhost:8888/my-project
url="http://localhost:8888/"$1"/"

# chemin vers votre Wordpress
#path_to_install_wp="~/Documents/sites/personnel/"$1

# chemin vers le fichier contenant la liste des plugins a installer (un par ligne)
#path_plugin_file="~/Documents/sites/personnel/wp_deploy/plugins.txt"
#path_plugin_file="./wp_deploy/plugins.txt"
path_plugin_file="/Applications/MAMP/htdocs/wp_deploy/plugins.txt"

#---------------------------------------------------------------
# SCRIPT CONFIG (ne rien modifier ci-dessous)
#---------------------------------------------------------------

# Stop sur erreur
set -e

# couleur (avec iTerm et activer le mode 256 couleurs)
green='\x1B[0;32m'
cyan='\x1B[1;36m'
blue='\x1B[0;34m'
grey='\x1B[1;30m'
red='\x1B[0;31m'
bold='\033[1m'
normal='\033[0m'

# saut de ligne
function line {
  echo " "
}

# mise en forme du message
function bot {
  line
  echo -e "${blue}${bold}(---- Wordpress ----)${normal} $1"
}

#---------------------------------------------------------------
# SCRIPT EXEC (ne rien modifier ci-dessous)
#---------------------------------------------------------------

# DISPLAY - Afficher le titre du site Wordpress qui sera installe
bot "${blue}${bold}Debut de l'installation.${normal}"
echo -e "Installation Wordpress : ${cyan}$3${normal}"

# CHECK : Directory doesn't exist
# go to wordpress installs folder
# --> Change : to wherever you want
#cd $path_to_install_wp
#cd "~/Documents/sites/personnel/wp_deploy/"

# CHECK - Verifier si le dossier d'installation existe deja
if [ -d $1 ]; then
  bot "${red}Le dossier ${cyan}$1${red}existe deja ${normal}."
  echo "On stop l'installation par securite, pour ne pas ecraser/perdre du contenu."
  line

  # quitter du script
  exit 1
fi

# DOSSIER - Creer le dossier
bot "Creer dossier : ${cyan}$1${normal}"
mkdir $1
cd $1

# DOWNLOAD WP - Download Wordpress en FR
bot "Telecharge WordPress"
wp core download --locale=fr_FR --force

# CHECK - Version du Wordpress telecharge
bot "Version Wordpress :"
wp core version

# DB - Configuration db
bot "Configuration db :"
wp core config --dbhost=$dbhost --dbname=$dbname --dbuser=$dbuser --dbpass=$dbpass --dbprefix=$dbprefix --skip-check --extra-php <<PHP
define( 'WP_DEBUG', true );
define( 'WP_DEBUG_LOG', true );
PHP

# DB - Creer db
bot "Creer db :"
wp db create

# PASSWORD - Generer un mot de passe aleatoire
passgen=`head -c 10 /dev/random | base64`
password=${passgen:0:10}

# INSTALLER WP - Lancer l'installation
bot "Installation Wordpress (en cours) :"
wp core install --url=$url --title="$3" --admin_user=$admin_login --admin_email=$admin_email --admin_password=$password

# PLUGINS - Lancer l'installation des plugins (depuis le fichier .txt contenant un plugin / ligne)
bot "Installation plugin (en cours) :"
while read line || [ -n "$line" ]
do
    wp plugin install $line --activate
    bot "Plugin active : "$line
done < path_plugin_file

# THEME - Telecharger un theme
bot "Installer theme "$2" :"
#cd wp-content/themes/
#git clone https://github.com/brainstormforce/astra.git
#wp theme activate $2
wp theme install $2 --activate

# PAGE - Creer des pages standards
bot "Creer pages (Accueil, Blog, Contact et Mentions Legales)"
wp post create --post_type=page --post_title='Accueil' --post_status=publish
wp post create --post_type=page --post_title='Blog' --post_status=publish
wp post create --post_type=page --post_title='Contact' --post_status=publish
wp post create --post_type=page --post_title='Mentions Legales' --post_status=publish

# ARTICLE - faker
bot "Faker articles"
curl http://loripsum.net/api/5 | wp post generate --post_content --count=5

# SET - Ajuster homepage et page article
bot "Selectionner page Accueil et Article"
wp option update show_on_front page
wp option update page_on_front 3
wp option update page_for_posts 4

# MENU - set
bot "Je cree le menu principal, assigne les pages, et je lie l'emplacement du theme : "
wp menu create "Menu Principal"
wp menu item add-post menu-principal 3
wp menu item add-post menu-principal 4
wp menu item add-post menu-principal 5
#wp menu location assign menu-principal main-menu

# CLEAN - plugin, theme, article d'origine
bot "Supprimer : plugin 'Hello Dolly', theme par defaut, articles exemples"
wp post delete 1 --force # supprime : article + commentaire
wp post delete 2 --force # supprime : article + commentaire
wp plugin delete hello
wp theme delete twentytwelve
wp theme delete twentynineteen
wp theme delete twentyseventeen
wp option update blogdescription ''

# PERMALINKS - /%postname%/
bot "Utiliser permaliens"
wp rewrite structure "/%postname%/" --hard
wp rewrite flush --hard

# CATEG & TAG - update
wp option update category_base theme
wp option update tag_base sujet

# GIT - init
# REQUIRED : download Git at http://git-scm.com/downloads
bot "GIT init + commit :"
#cd ../
git init    # git project
git add -A  # Add all untracked files
git commit -m "Initial commit"   # Commit changes

# Open the stuff
#bot "Je lance le navigateur, Sublime Text et le finder."

# NAVIGATEUR - ouvrir
open $url
open "${url}wp-admin"

# IDE - ouvrir
# REQUIRED : activate subl alias at https://www.sublimetext.com/docs/3/osx_command_line.html
#cd wp-content/themes
#subl $1

# DOSSIER - ouvrir
#cd $1
#open .

# PASSWORD - copier dans presse papier
echo $password | pbcopy

# FIN
bot "${green}Installation terminee !${normal}"
line
echo "URL du site :  $url"
echo "Login admin :  admin-$1"
echo -e "Password :  ${cyan}${bold} $password ${normal}${normal}"
line
echo -e "${grey}(NB : mot de passe dans le presse-papier)${normal}"
line