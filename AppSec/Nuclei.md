### Usage
```bash
nuclei -l [targets_list.txt] -t [template_name OR directory/] -u https[:]//[target] -rate-limit 10

### For Burp extension
In settings (windows) Path to nuclei - NULL
In template tab change
nuclei.exe -v -t C:\Users\artpa\AppData\Local\Temp\ [nucleiID].yaml -u [HOST] >>>
D:/nuclei/nuclei.exe -v -t C:/Users/artpa/AppData/Local/Temp/ [nucleiID].yaml -u [HOST]

### AI
nuclei -auth # provide API key https://cloud.projectdiscovery.io/templates
nuclei -u [url_target] -ai "Find admin_api_key in response"
nuclei -u [url_target] -ai "Extract page titles"
```

### Templates

<span style="color:red">!!! WARNING</span>
Важно проверить шаблон на безопасность перед использованием 
https://github.com/projectdiscovery/nuclei-templates/issues/11635 <br>

Примеры: 
* удаление информации 
* изменение конфигурации сервера
* загрузка веб-шелла
* дозагрузка в шаблон информации со сторонних ресурсов для тестирования

https://docs.projectdiscovery.io/templates
https://github.com/projectdiscovery/nuclei-docs/blob/main/docs/templating-guide/operators/matchers.md
https://github.com/projectdiscovery/nuclei/blob/dev/SYNTAX-REFERENCE.md 
```bash
### Debugging
nuclei -debug -svd -proxy http://127.0.0.1:8080 -stats
  -debug # print all requests that are being sent by nuclei to the target as well as the response received from the target.
  -svd flag # print all variables pre and post execution of a request for a template
  -proxy http://127.0.0.1:8080 # use proxy for showing requests
  -stats # show stats like [0:00:01] | Templates: 1 | Hosts: 1 | RPS: 1 | Matched: 1 | Errors: 0 | Requests: 1/1 (100%)
```

### Xpath
Chrome / Ctrl+I / Elements / Ctrl+F / SelectElement by element / Right click / Copy / Xopy full Xpath / Paste it in Find by Xpath in order to verify

### Install
```bash
git clone https://github.com/projectdiscovery/nuclei.git
cd nuclei/cmd/nuclei
go build .git
cp nuclei /usr/local/bin/
nuclei -version

### Go install (optional if installed before)
rm -rf /usr/local/go 
wget https://go.dev/dl/go1.23.2.linux-arm64.tar.gz
tar -C /usr/local -xzf go1.23.2.linux-arm64.tar.gz
export PATH=$PATH:/usr/local/go/bin
go version
```
