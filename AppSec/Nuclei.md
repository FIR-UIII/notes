### Usage
```
nuclei -l [targets_list.txt] -t [template_name OR directory/] -u https[:]//[target]

### For Burp extension
In settings (windows) Path to nuclei - NULL
In template tab change
nuclei.exe -v -t C:\Users\artpa\AppData\Local\Temp\ [nucleiID].yaml -u [HOST] >>>
D:/nuclei/nuclei.exe -v -t C:/Users/artpa/AppData/Local/Temp/ [nucleiID].yaml -u [HOST]
```

### Templates
https://docs.projectdiscovery.io/templates

### Install
```sh
git clone https://github.com/projectdiscovery/nuclei.git
cd nuclei/cmd/nuclei
go build .git
cp nuclei /usr/local/bin/
nuclei -version

### Go
rm -rf /usr/local/go 
wget https://go.dev/dl/go1.23.2.linux-arm64.tar.gz
tar -C /usr/local -xzf go1.23.2.linux-arm64.tar.gz
export PATH=$PATH:/usr/local/go/bin
go version
```
