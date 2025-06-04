https://owasp.org/www-community/Source_Code_Analysis_Tools

SAST (Static Application Security Testing) — статический анализ кода: проверка библиотек, поступающих в контур разработки. 
    Semgrep
    SonarQube
    Checkmarx
    CodeQL
    Svace 
OSA (Open Source Analysis) — анализ компонентов с открытым исходным кодом. 
SCA (Software Composition Analysis) — анализ состава программного кода (из чего состоят программные системы). 
DAST (Dynamic Application Security Testing) — динамический анализ кода. IAST (Interactive Application Security Testing) — интерактивный анализ кода. 
    OWASP ZAP (Zed Attack Proxy). Бесплатный и мощный инструмент от проекта OWASP, предназначенный для тестирования веб-приложений. ZAP обнаруживает различные виды атак, включая XSS и SQL-инъекции, и позволяет протестировать надежность приложения.
    Burp Suite.
BAST (Business Application Security Testing или Behavioral Application Security Testing) — анализ кода бизнес-программ или поведенческий анализ кода.

### Разметка по статусам
```
True negative | False positive
--------------|----------------
False negative| True positive

TN - анализатор верно не нашел проблему, ее нет на самом деле
FP - анализатор нашел проблему, но ее нет на самом деле
FN - анализатор не нашел проблему, но она была в коде на самом деле
TP - анализатор верно нашел проблему, она была в коде на самом деле
```

Статичный анализ кода
https://exploit-notes.hdks.org/exploit/linux/privilege-escalation/python-eval-code-execution/

### Static Taint Analysis 
![Taint](..\Media\taint_analysis.png)

### Data and control flow analysis 
Abstract Syntax Tree (AST), Control Flow Graph (CFG),


CodeQL - нужно учить синтаксис

IaC monitor

trivy

https://checkmarx.com/product/opensource/kics-open-source-infrastructure-as-code-project/?utm_source=PR&utm_medium=referral&utm_campaign=checkmarx+zap
HCL AppScan


### Software Composition Analysis (SCA) tool to generate SBOMs
