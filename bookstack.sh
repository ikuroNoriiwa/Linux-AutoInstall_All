#!/usr/bin/bash


requirements_bookstack_mariadb_php(){
yum -y upgrade
yum -y install epel-release
yum -y install git unzip mariadb-server nginx php php-cli php-fpm php-json php-gd php-mysqlnd php-xml php-openssl php-tokenizer php-mbstring php-mysqlnd

dnf -y install https://rpms.remirepo.net/enterprise/remi-release-8.rpm

dnf -y module reset php
dnf -y module install php:remi-7.3
dnf -y --enablerepo=remi install -y php73-php-tidy php73-php-json php73-php-pecl-zip 

ln -s /opt/remi/php73/root/usr/lib64/php/modules/tidy.so /usr/lib64/php/modules/tidy.so
echo "extension=tidy" >> /etc/php.ini
#OK
}

ssl_keys(){

cd /root 
mkdir ssl-key && cd ssl-key/

echo "Géneration de CA keys en cours ..."
openssl genrsa -des3 -out rootCA.key 4096
openssl req -x509 -new -nodes -key rootCA.key -sha256 -days 1024 -out rootCA.crt -subj '/CN='
openssl genrsa -out esgi.local.key 2048


echo "Géneration de SSL key pour le site wiki.esgi.local  en cours ..."
openssl req -new -key esgi.local.key -out wiki.esgi.local.csr '/CN='
openssl x509 -req -in wiki.esgi.local.csr -CA rootCA.crt -CAkey rootCA.key -CAcreateserial -out wiki.esgi.local.crt -days 500 -sha256

echo "Géneration de SSL key pour le site sso.esgi.local  en cours ..."
openssl req -new -key esgi.local.key -out sso.esgi.local.csr
openssl x509 -req -in sso.esgi.local.csr -CA rootCA.crt -CAkey rootCA.key -CAcreateserial -out sso.esgi.local.crt -days 500 -sha256

}



conf_mariadb(){
systemctl enable --now mariadb.service
printf "\n n\n n\n n\n y\n y\n y\n" | mysql_secure_installation

mysql --execute="
CREATE DATABASE IF NOT EXISTS bookstackdb DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
GRANT ALL PRIVILEGES ON bookstackdb.* TO 'bookstackuser'@'localhost' IDENTIFIED BY 'bookstackpass' WITH GRANT OPTION;
FLUSH PRIVILEGES;
quit"

fpmconf=/etc/php-fpm.d/www.conf
# sed -i "s|^listen =.*$|listen = /var/run/php-fpm.sock|" $fpmconf
# sed -i "s|^;listen.owner =.*$|listen.owner = nginx|" $fpmconf
# sed -i "s|^;listen.group =.*$|listen.group = nginx|" $fpmconf
sed -i "s|^user =.*$|user = nginx ; PHP-FPM running user|" $fpmconf
sed -i "s|^group =.*$|group = nginx ; PHP-FPM running group|" $fpmconf
# sed -i "s|^php_value\[session.save_path\].*$|php_value[session.save_path] = /var/www/sessions|" $fpmconf
}

conf_nginx(){
mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.BAK 

cat << '_EOF_' > /etc/nginx/nginx.conf
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;
include /usr/share/nginx/modules/*.conf;
events {
    worker_connections 1024;
}
http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';
    access_log  /var/log/nginx/access.log  main;
    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 2048;
    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;
    include /etc/nginx/conf.d/*.conf;
}
_EOF_

cat << '_EOF_' > /etc/nginx/conf.d/bookstack.conf

server {
   listen 80;
   server_name wiki.esgi.local;
   root /var/www/bookstack/public;

   access_log  /var/log/nginx/bookstack_access.log;
   error_log  /var/log/nginx/bookstack_error.log;

   client_max_body_size 1G;
   fastcgi_buffers 64 4K;

   index  index.php;

   location / {
     try_files $uri $uri/ /index.php?$query_string;
   }

   location ~ ^/(?:\.htaccess|data|config|db_structure\.xml|README) {
     deny all;
   }

   location ~ \.php(?:$|/) {
     fastcgi_split_path_info ^(.+\.php)(/.+)$;
     include fastcgi_params;
     fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
     fastcgi_param PATH_INFO $fastcgi_path_info;
     fastcgi_pass unix:/run/php-fpm/www.sock;
   }

   location ~* \.(?:jpg|jpeg|gif|bmp|ico|png|css|js|swf)$ {
     expires 30d;
     access_log off;
   }
 }


server {
   listen 443 ssl;
  listen [::]:443 ssl;
  server_name wiki.esgi.local;
  ssl_certificate /root/ssl-key/wiki.esgi.local.crt;
  ssl_certificate_key /root/ssl-key/esgi.local.key;
  ssl_protocols TLSv1.2;
  ssl_prefer_server_ciphers on;

  root /var/www/bookstack/public;

  access_log  /var/log/nginx/bookstack_access.log;
  error_log  /var/log/nginx/bookstack_error.log;

  client_max_body_size 1G;
  fastcgi_buffers 64 4K;

  index  index.php;

  location / {
    try_files $uri $uri/ /index.php?$query_string;
  }

  location ~ ^/(?:\.htaccess|data|config|db_structure\.xml|README) {
    deny all;
  }

  location ~ \.php(?:$|/) {
    fastcgi_split_path_info ^(.+\.php)(/.+)$;
    include fastcgi_params;
    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    fastcgi_param PATH_INFO $fastcgi_path_info;
    fastcgi_pass unix:/run/php-fpm/www.sock;
  }

  location ~* \.(?:jpg|jpeg|gif|bmp|ico|png|css|js|swf)$ {
    expires 30d;
    access_log off;
  }
}
_EOF_


systemctl enable --now nginx.service
systemctl enable --now php-fpm.service

}


bookstack_env(){
# mkdir -p /var/www/sessions
git clone https://github.com/BookStackApp/BookStack.git --branch release --single-branch /var/www/bookstack


echo "###################################"
echo "Installing composer..."
BAR='############################################################'


cd /usr/local/bin
export HOME=/root/

curl -sS https://getcomposer.org/installer | php
wait $!

mv /usr/local/bin/composer.phar /usr/local/bin/composer
cd /var/www/bookstack

php /usr/local/bin/composer install

echo "###################################"
echo "Configuring bookstack env..."
BAR='############################################################'


cp .env.example .env
sed -i "s/https:\/\/example.com/https:\/\/wiki.esgi.local/" .env
sed -i "s|^DB_DATABASE=.*$|DB_DATABASE=bookstackdb|" .env
sed -i "s|^DB_USERNAME=.*$|DB_USERNAME=bookstackuser|" .env
sed -i "s|^DB_PASSWORD=.*$|DB_PASSWORD=bookstackpass|" .env
sed -i "s|^MAIL_PORT=.*$|MAIL_PORT=25|" .env

php artisan key:generate --force
php artisan migrate --force
php artisan bookstack:create-admin --email="nimda@esgi.local" --name="Nimda" --password="P@ssW0rD"
php artisan bookstack:create-admin --email="esgi@esgi.local" --name="esgi" --password="P@ssW0rD"

chown -R nginx:nginx /var/www/{bookstack,sessions}
chmod -R 750 /var/www/bookstack/{bootstrap/cache,public/uploads,storage}
}

conf_bookstack_for_SSO(){
cat >> /var/www/bookstack/.env << EOF

AUTH_METHOD=saml2
SAML2_NAME=keycloak
SAML2_EMAIL_ATTRIBUTE=urn:oid:1.2.840.113549.1.9.1
SAML2_EXTERNAL_ID_ATTRIBUTE=sub
SAML2_DISPLAY_NAME_ATTRIBUTES=urn:oid:2.5.4.42|urn:oid:2.5.4.4
SAML2_IDP_ENTITYID:https://sso.esgi.local/auth/realms/KOLLAB/protocol/saml/descriptor
SAML2_AUTOLOAD_METADATA=true

EOF
}

#bookstack(){
#    ssl_keys
#    requirements_bookstack_mariadb_php
#    conf_mariadb
#    conf_nginx
#    bookstack_env
#    conf_bookstack_for_SSO
#}
