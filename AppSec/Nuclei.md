### Usage
```
nuclei -u https://my.target.site
```

### Templates


### Install
```sh
git clone https://github.com/projectdiscovery/nuclei.git
cd nuclei/cmd/nuclei
go build .
cp nuclei /usr/local/bin/
nuclei -version

### Go
rm -rf /usr/local/go 
wget https://go.dev/dl/go1.23.2.linux-arm64.tar.gz
tar -C /usr/local -xzf go1.23.2.linux-arm64.tar.gz
export PATH=$PATH:/usr/local/go/bin
go version
```