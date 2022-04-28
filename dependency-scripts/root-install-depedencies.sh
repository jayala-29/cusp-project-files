apt update
apt-get install wget
apt-get install jq
apt install vim
apt install gnupg
apt install unzip

apt-key adv --keyserver keyserver.ubuntu.com --recv-key C99B11DEB97541F0
apt-get install software-properties-common
apt-add-repository https://cli.github.com/packages
apt update
apt install gh
apt-get install parallel
apt install python2

#wget https://github.com/github/codeql-cli-binaries/releases/download/v2.8.5/codeql-linux64.zip - current
#unzip codeql-linux64.zip
#mv codeql codeql-cli
#git clone https://github.com/github/codeql.git queries - 4/19/2022

gh auth login
