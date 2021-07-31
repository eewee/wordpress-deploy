# Comment lancer une installation ?

Ce placer à la racine de votre projet, avec un dossier wp_deploy contenant ce repository :

`bash ./wp_deploy/deploy.sh "nom_de_votre_dossier_et_db" "nom_du_theme" "Titre de mon site"`

Ex : 
`bash ./wp_deploy/deploy.sh wp_astra_$(date +'%Y-%m-%d_%H-%m-%s') astra "Titre site"`

# CodeAnyWhere :

Si vous utilisez [CodeAnyWhere.com](https://codeanywhere.com), vous pouvez déployer un site Wordpress avec le script `deploy_codeanywhere.sh`

1. Pour cela créer un projet PHP sur CodeAnyWhere.
1. Installer wp-cli
   1. `curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar`
   1. `chmod +x wp-cli.phar`
   1. `sudo mv wp-cli.phar /usr/local/bin/wp`
   1. `wp --info`
1. `mkdir deploy`
1. `cd deploy`
1. Clonez ce projet
1. `bash deploy_codeanywhere.sh wp_astra_$(date +'%Y-%m-%d_%H-%m-%s') astra "Titre site"`
1. Connectez-vous à l'admin Wordpress.
1. Réglages / Permaliens
1. Sauvegarder (cela va generer le fichier `.htaccess`)

# Config SSH :

Serveur distant :
1. A la racine du serveur (ex: ionos), créer un dossier .ssh (chmod 700)
1. Dans le dossier .ssh (créé ci-dessus), ajouter un fichier authorized_keys (chmod600)

Machine locale (Créer une key SSH) :
1. `cd ~/.ssh`
1. `ssh-keygen -t rsa -C “your_email@tld.com” -b 4096`
1. Copier le contenu de la key public (ex: ionos.pub)

Serveur distant :
1. Coller le contenu de la key public de votre machine local, dans /.ssh/authorized_keys

Machine locale (Créer une key SSH) :
1. `cd /votre_projet`
1. `ssh-add ~/.ssh/ionos`
1. Tester le bon fonctionnement (toujours depuis /votre_projet) : 
    * ssh u12341234@home123456789.1and1-data.host ls 
    * (On doit avoir le rendu sans devoir indiquer le mot de passe ssh)

NB : 
* Dans notre exemple, je suppose que le "key SSH" porte le nom de "ionos.pub" (pour la key public) et "ionos" (pour la key privée). Car j'ai réalisé cette exemple sur un serveur de chez IONOS.fr

# Config VHOST + MAMP :

Fichier "hosts", ajoutez :
1. `127.0.0.1 votre_projet.dev`

Fichier "/Applications/MAMP/conf/apache/extra/httpd-vhosts.conf", ajoutez :
1. En haut du fichier (Une seule fois) :
`NameVirtualHost *:8888`
1. Pour chaque vhost à rajouter :
```
<VirtualHost *:8888>
    DocumentRoot "/Applications/MAMP/htdocs/votre_projet"
    ServerName votre_projet.dev

    <directory "/Applications/MAMP/htdocs/votre_projet">
        Options Indexes FollowSymLinks Includes
        AllowOverride All
        Order allow,deny
        Allow from all
    </directory>
</VirtualHost>
```

# .htaccess

Supposant que votre_projet se trouve dans le dossier htdocs de MAMP.

Lorsque vous allez récupérer le projet distant via un "make import" et "make dbimport", alors vous devrez ajuster le .htaccess.

Pour cela changez le "RewriteBase /" par "RewriteBase /votre_projet/"

# WP-CLI (exemple de commande) :

## MAINTENANCE

// Activer le mode maintenance :
wp maintenance-mode activate

// Desactiver le mode maintenance :
wp maintenance-mode deactivate

// Voir le statut du mode maintenance :
wp maintenance-mode status

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
