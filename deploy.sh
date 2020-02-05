#!/bin/bash
#
# Wippy (----WP Installeur----)
# Automatize your WordPress installation
#
# How to launch "deploy" ?
# bash deploy.sh sitename "Titre de mon site"
# $1 = folder name & database name
# $2 = Site title


# VARS 
# admin email
email="contact@eewee.fr"

# local url login
# --> Change to fit your server URL model (eg: http://localhost:8888/my-project)
#url="http://"$1":8888/mon_projet/"
url="http://localhost:8888/mon_projet/"

# admin login
admin="admin-$1"

# path to install your WPs
pathtoinstall="~/Documents/sites/personnel/mon_projet"

# path to plugins.txt
pluginfilepath="~/Documents/sites/personnel/wp_deploy/plugins.txt"

# end VARS ---




#  ===============
#  = Fancy Stuff =
#  ===============
# not mandatory at all

# Stop on error
set -e

# colorize and formatting command line
# You need iTerm and activate 256 color mode in order to work : http://kevin.colyar.net/wp-content/uploads/2011/01/Preferences.jpg
green='\x1B[0;32m'
cyan='\x1B[1;36m'
blue='\x1B[0;34m'
grey='\x1B[1;30m'
red='\x1B[0;31m'
bold='\033[1m'
normal='\033[0m'

# Jump a line
function line {
  echo " "
}

# Wippy has something to say
function bot {
  line
  echo -e "${blue}${bold}(----GoGoEtGo----)${normal}  $1"
}


#  ==============================
#  = The show is about to begin =
#  ==============================

# Welcome !
bot "${blue}${bold}Bonjour ! Je suis Wippy.${normal}"
echo -e "         Je vais installer WordPress pour votre site : ${cyan}$2${normal}"

# CHECK :  Directory doesn't exist
# go to wordpress installs folder
# --> Change : to wherever you want
#cd installpath
#cd "~/Documents/sites/personnel/wp_deploy"

# check if provided folder name already exists
if [ -d $1 ]; then
  bot "${red}Le dossier ${cyan}$1${red}existe deja ${normal}."
  echo "         Par securite, je ne vais pas plus loin pour ne rien ecraser."
  line

  # quit script
  exit 1
fi

# create directory
bot "Je cree le dossier : ${cyan}$1${normal}"
mkdir $1
cd $1

# Download WP
bot "Je telecharge WordPress..."
wp core download --locale=fr_FR --force

# check version
bot "J'ai recupere cette version :"
wp core version

# create base configuration
bot "Je lance la configuration :"
wp core config --dbhost=127.0.0.1:8889 --dbname=$1 --dbuser=root --dbpass=root --dbprefix=wp_ --skip-check --extra-php <<PHP
define( 'WP_DEBUG', true );
PHP

# Create database
bot "Je cree la base de donnees :"
wp db create

# Generate random password
passgen=`head -c 10 /dev/random | base64`
password=${passgen:0:10}

# launch install
bot "et j'installe !"
wp core install --url=$url --title="$2" --admin_user=$admin --admin_email=$email --admin_password=$password

# Plugins install
bot "J'installe les plugins a partir de la liste des plugins :"
while read line || [ -n "$line" ]
do
    wp plugin install $line --activate
done < pluginfilepath

# Download from private git repository
bot "Je telecharge le theme Astra theme :"
cd wp-content/themes/
#git clone git@github.com:brainstormforce/astra.git
git clone https://github.com/brainstormforce/astra.git
wp theme activate $1

# Create standard pages
bot "Je cree les pages habituelles (Accueil, blog, contact...)"
wp post create --post_type=page --post_title='Accueil' --post_status=publish
wp post create --post_type=page --post_title='Blog' --post_status=publish
wp post create --post_type=page --post_title='Contact' --post_status=publish
wp post create --post_type=page --post_title='Mentions Legales' --post_status=publish

# Create fake posts
bot "Je cree quelques faux articles"
curl http://loripsum.net/api/5 | wp post generate --post_content --count=5

# Change Homepage
bot "Je change la page d'accueil et la page des articles"
wp option update show_on_front page
wp option update page_on_front 3
wp option update page_for_posts 4

# Menu stuff
bot "Je cree le menu principal, assigne les pages, et je lie l'emplacement du theme : "
wp menu create "Menu Principal"
wp menu item add-post menu-principal 3
wp menu item add-post menu-principal 4
wp menu item add-post menu-principal 5
#wp menu location assign menu-principal main-menu

# Misc cleanup
bot "Je supprime Hello Dolly, les themes de base et les articles exemples"
wp post delete 1 --force # Article exemple - no trash. Comment is also deleted
wp post delete 2 --force # page exemple
wp plugin delete hello
wp theme delete twentytwelve
wp theme delete twentynineteen
wp theme delete twentyseventeen
wp theme delete twentyfourteen
wp theme delete twentythirteen
wp option update blogdescription ''

# Permalinks to /%postname%/
bot "J'active la structure des permaliens"
wp rewrite structure "/%postname%/" --hard
wp rewrite flush --hard

# cat and tag base update
wp option update category_base theme
wp option update tag_base sujet

# Git project
# REQUIRED : download Git at http://git-scm.com/downloads
bot "Je Git le projet :"
cd ../..
git init    # git project
git add -A  # Add all untracked files
git commit -m "Initial commit"   # Commit changes

# Open the stuff
#bot "Je lance le navigateur, Sublime Text et le finder."

# Open in browser
open $url
open "${url}wp-admin"

# Open in Sublime text
# REQUIRED : activate subl alias at https://www.sublimetext.com/docs/3/osx_command_line.html
#cd wp-content/themes
#subl $1

# Open in finder
#cd $1
#open .

# Copy password in clipboard
echo $password | pbcopy

# That's all ! Install summary
bot "${green}L'installation est terminee !${normal}"
line
echo "URL du site:   $url"
echo "Login admin :  admin$1"
echo -e "Password :  ${cyan}${bold} $password ${normal}${normal}"
line
echo -e "${grey}(N'oubliez pas le mot de passe ! Je l'ai copie dans le presse-papier)${normal}"

line
bot "A Bientot !"
line
line
