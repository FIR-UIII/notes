# Безопасность JDK
### Какие инструменты есть:
* Усиление целостности JDK: JEP 403 — Strongly Encapsulate JDK Internals
* JAR Signing
* Управление криптографией (keytool, JCA/JCE)
* Serialization Filters – JEP 290, JEP 415
* Java Platform Module System – JEP 261

Ключевая идея: CVE живут в модулях JDK. Неиспользуемый модуль → удаляем → CVE не эксплуатируемы
```sh
# проверяем образ на уязвимости
osv-scanner scan image --serve eclipse-temurin:25-jre

# jdeps как инструмент для определения зависимостей для самого приложения
$ jdeps --ignore-missing-deps –q
--recursive
--multi-release 25
--print-module-deps
--class-path 'BOOT-INF/lib/*’
app.jar > deps.info

$ cat deps.info
java.base

# c использованием jlink собираем кастомный минимальный JRE, включающий только те модули, которые нужны для работы конкретного приложения
$ jlink --add-modules java.base \ # Список корневых модулей
  --compress=zip-9 \ # Уровни сжатия
  --strip-debug \ # Удаляет отладочную информацию
  --no-man-pages \ # Удаляет справочные страницы
  --no-header-files \ # Исключает заголовочные файлы
  --output /jre

# Удаляем неиспользуемые модули
$ java --list-modules
  java.base@21.0.10
  java.compiler@21.0.10
  java.datatransfer@21.0.10
  java.desktop@21.0.10
  …

$ cat module-info.java
module java.base {
  exports java.io;
  exports java.lang;
  requires java.sql;
}

# Итоговый Dokerfile (multistage)
# ЭТАП 1: СБОРКА (build)
FROM maven:3.9.16-eclipse-temurin-25 AS build
RUN mkdir /usr/src/project # Создаем рабочую директорию внутри контейнера для исходников
COPY . /usr/src/project # Копируем все файлы проекта (кроме того, что в .dockerignore) в контейнер
WORKDIR /usr/src/project # Делаем созданную директорию текущей рабочей
RUN mvn package -DskipTests # Собираем Maven-проект в JAR-файл, пропуская тесты (ускоряем сборку)

# Анализируем зависимости JAR-файла, чтобы узнать, какие модули Java ему нужны сохраняем в файл deps.info
RUN jdeps --ignore-missing-deps -q \ 
  --recursive \ # рекурсивно анализируем все зависимости
  --multi-release 25 \ # учитываем multi-release JAR'ы для Java 25
  --print-module-deps \ #  выводим список необходимых модулей
  --class-path 'BOOT-INF/lib/*' \ # указываем, где искать библиотеки (Spring Boot структура)
  target/app.jar > deps.info # анализируемый JAR-файл app.jar

# Создаем минимальную JRE (Java Runtime Environment) только с нужными модулями
RUN jlink \
--add-modules $(cat deps.info) \ # добавляем только те модули, которые нужны приложению
--strip-debug \
--compress zip-9 \
--no-header-files \
--no-man-pages \
--output /myjre

# ЭТАП 2: ФИНАЛЬНЫЙ ОБРАЗ
FROM axiom-linux-base:25-musl # Используем минимальный образ Axiom Linux (мускул-версия) для запуска
ENV JAVA_HOME /user/java/jdk25 # Указываем, где лежит наша кастомная JRE
ENV PATH $JAVA_HOME/bin:$PATH # Добавляем Java в PATH, чтобы можно было вызывать java без полного пути
COPY --from=build /myjre $JAVA_HOME # Копируем собранную JRE с первого этапа (build) в финальный образ
RUN mkdir /app # Создаем директорию для приложения
COPY --from=build /usr/src/project/target/app.jar /app/ # Копируем собранный JAR-файл с первого этапа в финальный образ
WORKDIR /app # Переключаемся в директорию приложения
ENTRYPOINT ["java", "-jar", "app.jar"] # Запуск приложения

$ docker build -t my_app_custom:v1 .

# Дальнейший харденинг образа
Удалить shell (/bin/sh) - Атака невозможна без интерактивного доступа. Но оставить отдельный debug-образ с shell только для разработки
Удалить package manager (apk, apt) - Нет возможности установить вредоносный пакет
Запускать от non-root - Ограничение привилегий по умолчанию
Read-only rootfs - Запись в ФС заблокирована на уровне ОС или Смонтировать tmpfs в /tmp
Drop capabilities - Можно оставить NET_BIND_SERVICE при необходимости
AOT + jlink - Максимальный харденинг
```

# Транзитивные зависимости
```
$ mvn install
...
Downloaded from central:
https://repo1.maven.org/.../log4j-api-2.25.3.jar
...
[INFO] Installing .../target/spring-petclinic-4.0.0-SNAPSHOT.jar to ...
[INFO] Installing .../target/classes/META-INF/sbom/application.cdx.json to
...spring-petclinic-4.0.0-SNAPSHOT-cyclonedx.json # мавен сразу готовит SBOM
[INFO] BUILD SUCCESS

ИЛИ
$ mvn org.cyclonedx:cyclonedx-maven-plugin:makeBom
$ docker buildx build ––sbom=true

$ osv-scanner --sbom=sbom.cdx.json
Total 9 packages affected by 32 known vulnerabilities
(10 Critical, 14 High, 5 Medium, 2 Low)
ИЛИ
$ trivy --vex trivy.vex.json # VEX даёт возможность явно указать, эксплуатируема ли уязвимость в конкретном контексте https://trivy.dev/docs/v0.51/guide/supply-chain/vex

Верификация библиотек (проверка подписи)
$ mvn org.simplify4u.plugins:pgpverify-maven-plugin:show \
  -Dartifact=org.apache.logging.log4j:log4j-api:2.25.2
  Artifact:
      groupId: org.apache.logging.log4j
      artifactId: log4j-api
      type: jar
      version: 2.25.2
  PGP signature:
      version: 4
      algorithm: SHA512 with RSA (Encrypt or Sign)
      keyId: 0x077E8893A6DCC33DD4A4D5B256E73BA9A0B592D0
      create date: Thu Sep 18 21:35:37 MSK 2025
      status: valid
  PGP key:
      version: 4
      algorithm: RSA (Encrypt or Sign)
      bits: 4096
      fingerprint: 0x077E8893A6DCC33DD4A4D5B256E73BA9A0B592D0
      create date: Tue Jan 10 11:25:28 MSK 2023
      uids: [ASF Logging Services RM <private@logging.apache.org>]

$ cosign verify --key cosign-axiom.key 25-trusted-axiom-runtime-container-pro:jdk-all-25-musl
Verification for 25-trusted-axiom-runtime-container-pro:jdk-all-25-musl @sha256:bf4691b25802...
The following checks were performed:
- The cosign claims were validated
- Existence of the claims in the transparency log was verified offline
- The signatures were verified against the specified public key
[{"critical":{"identity":{...},"image":{...},"type":“..."},"optional":null}]
```

# Уязвимости в коде
# Common info
https://docs.oracle.com/en/java/javase/13/security/security-api-specification1.html
https://www.oracle.com/java/technologies/javase/seccodeguide.html
https://cheatsheetseries.owasp.org/cheatsheets/Java_Security_Cheat_Sheet.html
https://rules.sonarsource.com/java/impact/security

### XXE (обработка XML контента)
```java
// Ниже описаны безопасные способы обработки информации с XML
// Disabling DOCTYPE
factory.setFeature("http://apache.org/xml/features/disallow-doctype-decl", true);

// Disabling external entities declarations
factory.setFeature("http://xml.org/sax/features/external-general-entities", false);
factory.setFeature("http://xml.org/sax/features/external-parameter-entities", false);

// PHP's libxml library is safe by default because external entities are disabled unless the LIBXML_NOENT parameter is explicitly set
$doc = simplexml_load_string($xml, "SimpleXMLElement", LIBXML_NOENT); // !XXE enabled!
$doc = simplexml_load_string($xml, "SimpleXMLElement"); // XXE disabled

// Enabling secure processing (Функция безопасной обработки парсера XML внутри Java)
actory.setFeature(XMLConstants.FEATURE_SECURE_PROCESSING, true);

// Disabling entities references expansion (&entityname;)
DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
factory.setExpandEntityReferences(false);

```
