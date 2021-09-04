#!/bin/bash
#
# WP Installeur :
# Permettre l'installation en local de Wordpress, avec le theme x, plugin(s) x, etc ...
#
# Comment lancer le "deploy" ?
# bash deploy.sh sitename themename "Titre de mon site" "wp" "ewe"
# bash deploy.sh "wp_astra" "astra" "Titre de mon site" "wp" "ewe"
# $1 = "nom du dossier" & "nom de la db" & "suffixe login" (ex: wp_astra)
# $2 = "nom du theme" (ex: astra)
# $3 = "titre du site" (ex: Titre de mon site)
# $4 = project name (in codeanywhere)
#    https://ide.codeanywhere.com/xxx-yyy/#/home/cabox/workspace
#    "xxx" is the name of your project
# $5 = user name (in codeanywhere)
#    https://ide.codeanywhere.com/xxx-yyy/#/home/cabox/workspace
#    "yyy" is the name of your project
# 
# Arbo :
# wp_deploy
#   .gitignore
#   deploy_codeanywhere.sh
#   deploy.sh
#   plugins.txt
#   README.md
# wp-cli.yml
#   
# Command (lancer a la racine de votre htdocs) :
# bash ./wp_deploy/deploy_codeanywhere.sh wp_astra_$(date +'%Y-%m-%d_%H-%m-%s') astra "titre site" "wp" "ewe"

#---------------------------------------------------------------
# CONFIG WORDPRESS (a editer avec vos propres informations)
#---------------------------------------------------------------

# db 
dbhost="localhost"
dbname=$1
dbuser="root"
dbpass=""
dbprefix="wp_"

# admin email
admin_email="contact@eewee.fr"

# admin login
admin_login="admin-$1"

# local url login (ex : http://projectname-user.codeanyapp.com)
codeanywhere_projectname=$4;
codeanywhere_user=$5;
url="http://${codeanywhere_projectname}-${codeanywhere_user}.codeanyapp.com"

# plugins a installer
pluginsList=( 
    "jetpack"
    #"contact-form-7"
    #"wordpress-seo"
)

# idPage
pageAccueil=4
pageBlog=5

# date de publication d'un article
#datePublish=$(date -v-120M '+%Y-%m-%d-%H-%M-%S')
datePublish=$(date --date=' 1 days ago' '+%Y-%m-%d-%H-%M-%S')

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
bot "${blue}${bold}
#----------------------------------------------------------#
#------------------ DEBUT INSTALLATION --------------------#
#----------------------------------------------------------#
${normal}"

# DISPLAY - Afficher le titre du site Wordpress qui sera installe
bot "${blue}${bold}Debut de l'installation.${normal}"
echo -e "Installation Wordpress : ${cyan}$3${normal}"

# CHECK - Verifier si le dossier d'installation existe deja
if [ -d $1 ]; then
  bot "${red}Le dossier ${cyan}$1${red}existe deja ${normal}."
  echo "On stop l'installation par securite, pour ne pas ecraser/perdre du contenu."
  line

  # quitter du script
  exit 1
fi

# POSITION - on se place sur la home d'un projet php sur CodeAnyWhere
bot "POSITION HOME ON CODEANYWHERE : ${cyan}$1${normal}"
cd ~/workspace

# DOWNLOAD WP - Download Wordpress en FR
bot "DOWNLOAD WORDPRESS."
wp core download --locale=fr_FR --force

# CHECK - Version du Wordpress telecharge
bot "VERSION WORDPRESS :"
wp core version

# DB - Configuration db
bot "CONFIG DB :"
wp core config --dbhost=$dbhost --dbname=$dbname --dbuser=$dbuser --dbpass=$dbpass --dbprefix=$dbprefix --skip-check --extra-php <<PHP
define( 'WP_DEBUG', true );
define( 'WP_DEBUG_LOG', true );
PHP

# DB - Creer db
bot "CREATE DB :"
wp db create

# PASSWORD - Generer un mot de passe aleatoire
passgen=`head -c 10 /dev/random | base64`
password=${passgen:0:10}

# INSTALLER WP - Lancer l'installation
bot "INSTALL WORDPRESS :"
wp core install --url=$url --title="$3" --admin_user=$admin_login --admin_email=$admin_email --admin_password=$password

# PLUGINS - Lancer l'installation des plugins (depuis le fichier .txt contenant un plugin / ligne)
bot "INSTALL PLUGINS :"
for vPlugin in "${pluginsList[@]}"
do
  bot "PLUGIN : "$vPlugin
  wp plugin install $vPlugin --activate
done

# THEME - Telecharger un theme
bot "INSTALL THEME "$2" :"
wp theme install $2 --activate

# PAGE - Creer des pages standards
bot "PAGES CREATE : Accueil, Blog, Contact et Mentions Legales"
wp post create --post_type=page --post_title='Accueil' --post_status=publish
wp post create --post_type=page --post_title='Blog' --post_status=publish
wp post create --post_type=page --post_title='Contact' --post_status=publish
wp post create --post_type=page --post_title='Mentions Legales' --post_status=publish

# ARTICLE - faker
bot "ARTICLES CREATE : FAKER"
#wp post generate --count=10 --post_type=page --post_date=$datePublish
curl -N http://loripsum.net/api/5 | wp post generate --post_content --count=5 --post_date=$datePublish

# SET - Ajuster homepage et page article
bot "CONFIG SET PAGE - Selectionner page Accueil et Article"
wp option update show_on_front page
wp option update page_on_front $pageAccueil
wp option update page_for_posts $pageBlog

# MENU - set
bot "CONFIG MENU - Je cree le menu principal, assigne les pages, et je lie l'emplacement du theme : "
wp menu create "Menu Principal"
wp menu item add-post menu-principal 3
wp menu item add-post menu-principal 4
wp menu item add-post menu-principal 5
wp menu item add-post menu-principal 6
#wp menu location assign menu-principal main-menu

# CLEAN - plugin, theme, article d'origine
bot "SUPPRIMER : plugin 'Hello Dolly', theme par defaut, articles exemples"
wp post delete 1 --force # supprime : article + commentaire
wp post delete 2 --force # supprime : article + commentaire
wp plugin delete hello
wp theme delete twentynineteen
wp theme delete twentytwenty
wp theme delete twentytwentyone
wp option update blogdescription ''

# PERMALINKS - /%postname%/
bot "UTILISER PERMALIENS"
#wp rewrite structure "/%postname%/" --hard
#wp rewrite flush --hard
wp option get permalink_structure
wp option update permalink_structure '/%postname%'
wp rewrite flush --hard

# CATEG & TAG - update
wp option update category_base theme
wp option update tag_base sujet

# GIT - init
bot "GIT INIT + COMMIT :"
git init
git add -A
git commit -m "Initial commit" > /dev/null 2>&1

# Open the stuff
#bot "Je lance le navigateur, Sublime Text et le finder."

# NAVIGATEUR - ouvrir
#open $url
#open "${url}wp-admin"

# IDE - ouvrir
# REQUIRED : activate subl alias at https://www.sublimetext.com/docs/3/osx_command_line.html
#cd wp-content/themes
#subl $1

# DOSSIER - ouvrir
#cd $1
#open .

# PASSWORD - copier dans presse papier
#echo $password | pbcopy

# FIN
bot "${green}Installation terminee !${normal}"
echo "URL du site (front): $url"
echo "URL du site (back) : $url/wp-admin"
echo "Login admin        : admin-$1"
echo -e "Password           : ${cyan}${bold} $password ${normal}${normal}"
line
echo -e "${grey}(NB : mot de passe dans le presse-papier)${normal}"
line
echo -e "${grey}(ATTENTION : connectez-vous sur le back de wordpress, reglages/permaliens et enregistrer pour generer le fichier .htaccess)${normal}"
line
line
