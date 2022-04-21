# only uncomment if you want the latest version of CodeQL tools - different from what was used 
#wget https://github.com/github/codeql-cli-binaries/releases/download/v2.8.5/codeql-linux64.zip - current
#unzip codeql-linux64.zip
#mv codeql codeql-cli
#git clone https://github.com/github/codeql.git queries - downloaded 4/19/2022

# uncomment this if you would like `codeql` as a usable command
#export PATH=$PATH:$PWD/codeql-cli/

# CodeQL resolves languages and queries
./codeql-cli/codeql resolve languages
./codeql-cli/codeql resolve qlpacks
