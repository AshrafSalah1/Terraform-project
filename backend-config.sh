#!/bin/bash

# Stop ubuntu pop-up "Daemons using outdated libraries"
sed -i "/#\$nrconf{restart} = 'i';/s/.*/\$nrconf{restart} = 'a';/" /etc/needrestart/needrestart.conf

# Update system packages
sudo apt-get update -y

# Install Cloud Monitor Agent
ARGUS_VERSION=3.5.10 /bin/bash -c "$(curl -s https://cms-agent-us-east-1.oss-us-east-1-internal.aliyuncs.com/Argus/agent_install_ecs-1.7.sh)"

# Install docker
wget -O - https://gist.githubusercontent.com/fredhsu/f3d927d765727181767b3b13a3a23704/raw/3c2c55f185e23268f7fce399539cb6f1f3c45146/ubuntudocker.sh | bash


# Configure laravel project
sudo apt install software-properties-common -y
sudo add-apt-repository ppa:ondrej/php -y
sudo apt install php8.1 php8.1-mbstring php8.1-gettext php8.1-zip php8.1-fpm php8.1-curl php8.1-mysql php8.1-gd php8.1-cgi php8.1-soap php8.1-sqlite3 php8.1-xml php8.1-redis php8.1-bcmath php8.1-imagick php8.1-intl -y
sudo apt install git composer -y
sudo apt install nginx -y
cd /var/www/html
sudo rm -rf *
sudo git clone https://github.com/AshrafSalah1/laravel.git
cd laravel/
sudo composer install -n
sudo chown -R www-data:www-data /var/www/html
sudo cp .env.example .env
php artisan key:generate
sed -i "s/'charset' => 'utf8mb4',/'charset' => 'utf8',/; s/'collation' => 'utf8mb4_unicode_ci',/'collation' => 'utf8_unicode_ci',/" config/database.php
sudo touch /etc/nginx/sites-available/laravel.conf
sudo ln -s /etc/nginx/sites-available/laravel.conf /etc/nginx/sites-enabled/laravel.conf

# Install and configure self hosted runner agent
# mkdir actions-runner && cd actions-runner
# curl -o actions-runner-linux-x64-2.314.1.tar.gz -L https://github.com/actions/runner/releases/download/v2.314.1/actions-runner-linux-x64-2.314.1.tar.gz
# echo "6c726a118bbe02cd32e222f890e1e476567bf299353a96886ba75b423c1137b5  actions-runner-linux-x64-2.314.1.tar.gz" | shasum -a 256 -c
# tar xzf ./actions-runner-linux-x64-2.314.1.tar.gz
# export RUNNER_ALLOW_RUNASROOT="1"
# RUNNER_ALLOW_RUNASROOT="1" ./config.sh --url https://github.com/AshrafSalah1/laravel --token AOEMNYKRIKYKIT66HUERUS3F6MPPQ
# nohup ./run.sh &