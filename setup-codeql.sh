# log in to github
gh auth login

# retrieve used version of CodeQL
wget https://github.com/github/codeql-cli-binaries/releases/download/v2.8.5/codeql-linux64.zip
unzip codeql-linux64.zip
mv codeql codeql-cli

# queries repo, already included in directory
#git clone https://github.com/github/codeql.git queries - downloaded 4/19/2022

# uncomment this if you would like `codeql` as a usable command
#export PATH=$PATH:$PWD/codeql-cli/

# CodeQL resolves languages and queries
./codeql-cli/codeql resolve languages
./codeql-cli/codeql resolve qlpacks
