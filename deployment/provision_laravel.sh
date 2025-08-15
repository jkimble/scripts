#!/bin/bash
# Run (as root) with:
# chmod +x provision_laravel.sh
# sudo ./provision_laravel.sh

set -e

#------ REQUIRED USER/PROJECT VARIABLES ------
DEPLOY_USER=""
DEPLOY_PASS=""
DOMAIN=""
REPO_SSH=""
DB_NAME=""
DB_USER=""
DB_PASS=""
PHP_VERSION=""

#------ END USER VARIABLES ------

echo "--- System update/upgrade ---"
apt update && apt upgrade -y

# 1. Create the deploy user
if id "$DEPLOY_USER" &>/dev/null; then
    echo "User $DEPLOY_USER exists, skipping useradd."
else
    adduser --disabled-password --gecos "" $DEPLOY_USER
    echo "$DEPLOY_USER:$DEPLOY_PASS" | chpasswd
    usermod -aG sudo $DEPLOY_USER
fi

# 2. Setup SSH for deploy user (copy from root if exists)
if [ -f /root/.ssh/authorized_keys ]; then
    mkdir -p /home/$DEPLOY_USER/.ssh
    cp /root/.ssh/authorized_keys /home/$DEPLOY_USER/.ssh/
    chown -R $DEPLOY_USER:$DEPLOY_USER /home/$DEPLOY_USER/.ssh
    chmod 700 /home/$DEPLOY_USER/.ssh
    chmod 600 /home/$DEPLOY_USER/.ssh/authorized_keys
fi

if [ ! -f /home/deploy/.ssh/id_ed25519 ]; then
  sudo -u deploy mkdir -p /home/deploy/.ssh
  sudo -u deploy ssh-keygen -t ed25519 -N "" -f /home/deploy/.ssh/id_ed25519
  echo "Add the following public key to your Github repo before continuing:"
  cat /home/deploy/.ssh/id_ed25519.pub
  exit 1
fi

# 3. Install core packages
# optionally install: imagemagick
apt install -y software-properties-common curl git ufw nginx mariadb-server redis-server supervisor unzip

# 4. PHP $PHP_VERSION and extensions
# optionally install: php$PHP_VERSION-imagick
add-apt-repository ppa:ondrej/php -y
apt update
apt install -y php$PHP_VERSION php$PHP_VERSION-fpm php$PHP_VERSION-cli php$PHP_VERSION-mysql php$PHP_VERSION-redis php$PHP_VERSION-xml php$PHP_VERSION-mbstring php$PHP_VERSION-curl php$PHP_VERSION-zip php$PHP_VERSION-bcmath

# 5. Composer (global)
if [ ! -f /usr/local/bin/composer ]; then
    curl -sS https://getcomposer.org/installer | php
    mv composer.phar /usr/local/bin/composer
fi

# 6. Install nvm for deploy user and latest Node LTS
su - $DEPLOY_USER -c "\
if [ ! -d \"\$HOME/.nvm\" ]; then \
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash; \
fi \
"
# Load nvm and install latest LTS node as deploy user
su - $DEPLOY_USER -c "
export NVM_DIR=\"\$HOME/.nvm\"
[ -s \"\$NVM_DIR/nvm.sh\" ] && . \"\$NVM_DIR/nvm.sh\"
nvm install --lts
nvm use --lts
"

# 7. Enable firewall: OpenSSH and Nginx Full
ufw allow OpenSSH
ufw allow 'Nginx Full'
ufw --force enable

# 8. Secure MariaDB and create database/user
mysql <<EOF
CREATE DATABASE IF NOT EXISTS $DB_NAME;
CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';
FLUSH PRIVILEGES;
EOF

if ! grep -q github.com /home/deploy/.ssh/known_hosts 2>/dev/null; then
    ssh-keyscan github.com >> /home/deploy/.ssh/known_hosts
fi
chown deploy:deploy /home/deploy/.ssh/known_hosts
chmod 600 /home/deploy/.ssh/known_hosts

# 9. Clone project as deploy user
if [ ! -d "/var/www/$DOMAIN" ]; then
    mkdir -p /var/www/$DOMAIN
    chown $DEPLOY_USER:www-data /var/www/$DOMAIN
    su - $DEPLOY_USER -c "git clone $REPO_SSH /var/www/$DOMAIN"
else
    echo "/var/www/$DOMAIN already exists, skipping clone"
fi

# 10. Set permissions
chown -R $DEPLOY_USER:www-data /var/www/$DOMAIN
chmod -R 775 /var/www/$DOMAIN/storage /var/www/$DOMAIN/bootstrap/cache || true

# 11. Install dependencies (as deploy user)
su - $DEPLOY_USER -c "cd /var/www/$DOMAIN && composer install --no-dev --optimize-autoloader"
su - $DEPLOY_USER -c 'cd /var/www/'$DOMAIN' && export NVM_DIR="$HOME/.nvm" && [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" && npm install && npm run build'

# 12. Generate .env if missing
if [ ! -f /var/www/$DOMAIN/.env ]; then
cat > /var/www/$DOMAIN/.env <<EOF
APP_NAME=Laravel
APP_ENV=production
APP_KEY=
APP_DEBUG=false
APP_URL=https://$DOMAIN

LOG_CHANNEL=stack

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=$DB_NAME
DB_USERNAME=$DB_USER
DB_PASSWORD=$DB_PASS

CACHE_DRIVER=redis
SESSION_DRIVER=redis
QUEUE_CONNECTION=redis
REDIS_HOST=127.0.0.1
EOF
fi
chown $DEPLOY_USER:www-data /var/www/$DOMAIN/.env

# 13. Laravel setup
su - $DEPLOY_USER -c "cd /var/www/$DOMAIN && php artisan key:generate"
su - $DEPLOY_USER -c "cd /var/www/$DOMAIN && php artisan migrate --force"
su - $DEPLOY_USER -c "cd /var/www/$DOMAIN && php artisan config:cache && php artisan route:cache && php artisan view:cache"

# 14. Nginx site config
cat > /etc/nginx/sites-available/$DOMAIN <<EOL
server {
    listen 80;
    server_name $DOMAIN;
    return 301 https://$DOMAIN\$request_uri;
}
server {
    listen 443 ssl http2;
    server_name $DOMAIN;

    root /var/www/$DOMAIN/public;
    index index.php index.html index.htm;

    ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }
    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php$PHP_VERSION-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;
        include fastcgi_params;
    }
    location ~ /\.ht {
        deny all;
    }
}
EOL

ln -sf /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx

# 15. Install certbot and set up SSL
apt install -y certbot python3-certbot-nginx
certbot certonly --nginx --non-interactive --agree-tos --register-unsafely-without-email -d $DOMAIN

nginx -t && systemctl reload nginx


echo "========================================"
echo "Automated install complete for $DOMAIN."
echo "SSH to server as '$DEPLOY_USER' and finish GitHub deploy key configuration as needed."
echo "========================================"
