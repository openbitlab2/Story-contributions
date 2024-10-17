#!/bin/bash
sudo apt update
sudo apt-get update
sudo apt install curl git make jq build-essential gcc unzip wget lz4 aria2 -y

wget https://story-geth-binaries.s3.us-west-1.amazonaws.com/geth-public/geth-linux-amd64-0.9.2-ea9f0d2.tar.gz
tar -xzf geth-linux-amd64-0.9.2-ea9f0d2.tar.gz
mv geth-linux-amd64-0.9.2-ea9f0d2/geth /usr/local/bin/geth
rm -rf geth-linux-amd64*
wget https://story-geth-binaries.s3.us-west-1.amazonaws.com/story-public/story-linux-amd64-0.11.0-aac4bfe.tar.gz
tar -xzf story-linux-amd64-0.11.0-aac4bfe.tar.gz
mv story-linux-amd64-0.11.0-aac4bfe/story /usr/local/bin/story
rm -rf story-linux-amd64*

story init --network iliad --moniker $1
sed -i -e "s|^seeds *=.*|seeds = \"3f472746f46493309650e5a033076689996c8881@story-testnet.rpc.kjnodes.com:26659\"|" $HOME/.story/story/config/config.toml
mkdir -p $HOME/.story/geth
curl -L https://story-testnet-snapshot.openbitlab.com/geth_pruned_latest.tar.lz4 | tar -Ilz4 -xf - -C $HOME/.story/geth
curl -L https://story-testnet-snapshot.openbitlab.com/story_pruned_latest.tar.lz4 | tar -Ilz4 -xf - -C $HOME/.story/story

sudo tee /etc/systemd/system/gethd.service > /dev/null <<EOF
[Unit]
Description=Story Geth Client
After=network.target

[Service]
User=$USER
ExecStart=/usr/local/bin/geth --iliad --syncmode full --http
Restart=always
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF
sudo tee /etc/systemd/system/storyd.service > /dev/null <<EOF
[Unit]
Description=Story Consensus Client
After=network.target

[Service]
User=$USER
ExecStart=/usr/local/bin/story run
Restart=always
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
sudo systemctl start gethd
sudo systemctl start storyd
sudo systemctl enable gethd
sudo systemctl enable storyd
