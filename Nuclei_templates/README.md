nuclei -v -t \XSS\5_lab-javascript-template-literal-angle-brackets.yaml -u https://0acd00cf03a8f36180bc8fc800bb00cb.web-security-academy.net -headless

nuclei -v -t .\HTTP_smuggling\4_lab-confirming-cl-te-via-differential-responses.yaml -u https://0acd00cf03a8f36180bc8fc800bb00cb.web-security-academy.net

nuclei -list targets.txt -ai "Find exposed AI/ML model files (.pkl, .h5, .pt) that may leak proprietary algorithms or sensitive training data"

nuclei -list targets.txt -ai "Find exposed automation scripts (.sh, .ps1, .bat) revealing internal tooling or credentials"

nuclei -list targets.txt -ai "Identify misconfigured CSP headers allowing 'unsafe-inline' or wildcard sources"

nuclei -list targets.txt -ai "Detect pages leaking JWT tokens in URLs or cookies"

nuclei -list targets.txt -ai "Identify overly verbose error messages revealing framework or library details"

nuclei -list targets.txt -ai "Find application endpoints with verbose stack traces or source code exposure"

nuclei -list targets.txt -ai "Find sensitive information in HTML comments (debug notes, API keys, credentials)"

nuclei -list targets.txt -ai "Find exposed .env files leaking credentials, API keys, and database passwords"

nuclei -list targets.txt -ai "Find exposed configuration files such as config.json, config.yaml, config.php, application.properties containing API keys and database credentials."

nuclei -list targets.txt -ai "Find exposed configuration files containing sensitive information such as credentials, API keys, database passwords, and cloud service secrets." 

nuclei -list targets.txt -ai "Find database configuration files such as database.yml, db_config.php, .pgpass, .my.cnf leaking credentials."  

nuclei -list targets.txt -ai "Find exposed Docker and Kubernetes configuration files such as docker-compose.yml, kubeconfig, .dockercfg, .docker/config.json containing cloud credentials and secrets."  

nuclei -list targets.txt -ai "Find exposed SSH keys and configuration files such as id_rsa, authorized_keys, and ssh_config."  

nuclei -list targets.txt -ai "Find exposed WordPress configuration files (wp-config.php) containing database credentials and authentication secrets."  

nuclei -list targets.txt -ai "Identify exposed .npmrc and .yarnrc files leaking NPM authentication tokens"

nuclei -list targets.txt -ai "Identify open directory listings exposing sensitive files"  

nuclei -list targets.txt -ai "Find exposed .git directories allowing full repo download"

nuclei -list targets.txt -ai "Find exposed .svn and .hg repositories leaking source code"  

nuclei -list targets.txt -ai "Identify open FTP servers allowing anonymous access"  

nuclei -list targets.txt -ai "Find GraphQL endpoints with introspection enabled"  

nuclei -list targets.txt -ai "Identify exposed .well-known directories revealing sensitive data"  

nuclei -list targets.txt -ai "Find publicly accessible phpinfo() pages leaking environment details"  

nuclei -list targets.txt -ai "Find exposed Swagger, Redocly, GraphiQL, and API Blueprint documentation"
  
nuclei -list targets.txt -ai "Identify exposed .vscode and .idea directories leaking developer configs"  

nuclei -list targets.txt -ai "Detect internal IP addresses (10.x.x.x, 192.168.x.x, etc.) in HTTP responses"  

nuclei -list targets.txt -ai "Find exposed WordPress debug.log files leaking credentials and error messages"  

nuclei -list targets.txt -ai "Detect misconfigured CORS allowing wildcard origins ('*')"  

nuclei -list targets.txt -ai "Find publicly accessible backup and log files (.log, .bak, .sql, .zip, .dump)" 

nuclei -list targets.txt -ai "Find exposed admin panels with default credentials"

nuclei -list targets.txt -ai "Identify commonly used API endpoints that expose sensitive user data, returning HTTP status 200 OK."

nuclei -list targets.txt -ai "Detect web applications running in debug mode, potentially exposing sensitive system information."
