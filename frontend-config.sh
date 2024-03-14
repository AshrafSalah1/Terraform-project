#!/bin/bash

# Stop ubuntu pop-up "Daemons using outdated libraries"
sed -i "/#\$nrconf{restart} = 'i';/s/.*/\$nrconf{restart} = 'a';/" /etc/needrestart/needrestart.conf

# Update system packages
sudo apt-get update -y

# Install Cloud Monitor Agent
ARGUS_VERSION=3.5.10 /bin/bash -c "$(curl -s https://cms-agent-us-east-1.oss-us-east-1-internal.aliyuncs.com/Argus/agent_install_ecs-1.7.sh)"

# Install docker
wget -O - https://gist.githubusercontent.com/fredhsu/f3d927d765727181767b3b13a3a23704/raw/3c2c55f185e23268f7fce399539cb6f1f3c45146/ubuntudocker.sh | bash

# Install Git
sudo apt-get install git -y

# Install Node.js 18.x
curl -s https://deb.nodesource.com/setup_18.x | sudo bash -
sudo apt-get install nodejs -y

# Clone Uptime Kuma repository
git clone https://github.com/louislam/uptime-kuma.git && cd uptime-kuma

# Setup Uptime Kuma
npm run setup

# Install PM2 globally and PM2 log rotate plugin
sudo npm install pm2 -g && pm2 install pm2-logrotate

# Start Uptime Kuma server using PM2
pm2 start server/server.js --name uptime-kuma

# add it to startup
pm2 save && pm2 startup

# Install and configure self hosted runner agent
# mkdir actions-runner && cd actions-runner
# curl -o actions-runner-linux-x64-2.314.1.tar.gz -L https://github.com/actions/runner/releases/download/v2.314.1/actions-runner-linux-x64-2.314.1.tar.gz
# echo "6c726a118bbe02cd32e222f890e1e476567bf299353a96886ba75b423c1137b5  actions-runner-linux-x64-2.314.1.tar.gz" | shasum -a 256 -c
# tar xzf ./actions-runner-linux-x64-2.314.1.tar.gz
# export RUNNER_ALLOW_RUNASROOT="1"
# RUNNER_ALLOW_RUNASROOT="1" ./config.sh --url https://github.com/AshrafSalah1/uptime-kuma --token AOEMNYL277KENOG63VWUOQDF6MS44
# nohup ./run.sh &