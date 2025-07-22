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
