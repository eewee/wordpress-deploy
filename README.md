bash deploy.sh "nom_de_votre_dossier_et_db" "nom_du_theme" "Titre de mon site"

# WP-CLI :

## PLUGIN

// Uninstall le plugin "hello" :
wp plugin uninstall hello

// Afficher la liste des plugins :
wp plugin list

// Recherche un plugin (ici on recherche "jetpack" dans le nom du plugin) :
wp plugin search jetpack

// Installer le plugin "jetpack" :
wp plugin install jetpack

// Activer le plugin "jetpack" :
wp plugin active jetpack

// Desactiver plugin nomme "jetpack" :
wp plugin install jetpack --activate

// Desactiver plugin nomme "jetpack" :
wp plugin install jetpack --version=8.1.1 --activate

// Mise à jour du plugin "jetpack" :
wp plugin update jetpack

// Desactiver plugin nomme "jetpack" :
wp plugin deactivate jetpack

// Desactiver tous les plugins :
wp plugin deactivate --all

## THEME

// Afficher la liste des theme :
wp theme list

// Recherche un theme (ici on recherche "generate" dans le nom du theme) :
wp theme search generate

// Installer le theme "generatepress" :
wp theme install generatepress

// Activer le theme "generatepress" :
wp theme active generatepress

## CORE

// Changer l'url de Wordpress :
wp option update home 'http://monSite.com'
wp option update siteurl 'http://monSite.com'

## SEARCH-REPLACE
### deserialise puis remplace la chaine et serialise
### ideal pour pouvoir changer 1 ndd lors d'1 migration db

// Remplace une chaine par une autre :
wp search-replace oldstring newstring

## HELP

// Commande "help" pour afficher la doc :
wp help media
