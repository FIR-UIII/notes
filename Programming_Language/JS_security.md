### Защита функционала фронтэнда от пользователя

Защита от программных кликов - например капча
```js
// получить все обработчики событий
getEventListeners($0) или указываем в аргументе название если оно известно
{} пустой массив - значит нет

// выполнить программный клик (эмуляция клика пользователя в браузере
button.dispatcherEvent(new PointerEvent("mousedown", {bubbles: true}))
```

Защита от подобный использование функций вызывающих только 

### React-Related Exploits
```js
React.createElement(): // If user-controlled data is passed as a prop without proper sanitization, it could lead to XSS attacks.
dangerouslySetInnerHTML: // As the name implies, this can potentially open up to XSS attacks if the input isn't sanitized.
setState(): // If user-controlled input is passed to setState and then rendered without proper sanitization, it could lead to XSS attacks.
componentDidMount(), componentDidUpdate(): // React lifecycle methods that run after the initial render and after every update, respectively. If these methods include user-controlled data that isn't properly sanitized, they can potentially lead to XSS attacks.
props.children: // If not sanitized and user-controlled, could potentially open up to XSS attacks when rendered.
```

### Angular-Related Exploits
```js
http.get(), http.post(): // If the URL or parameters are not properly validated, they could potentially be used for SSRF or even RCE attacks.
.subscribe(): // If the data received via the subscription isn't properly sanitized, it could lead to Code Injection or XSS attacks.
.toPromise(): // If not properly sanitized, could lead to similar exploits as .subscribe().
ng-bind-html: // Angular directive that binds innerHTML to the result of an expression. If not properly sanitized, it can lead to XSS attacks.
{{ }} interpolation: // Angular's double curly braces are used for data binding. If the data isn't sanitized properly, it could lead to XSS attacks.
```

### Vue.js-Related Exploits
```js
v-html: // This directive can lead to XSS attacks if the bound input isn't sanitized.
v-bind: // If the bound expression isn't properly sanitized, it could lead to XSS attacks.
v-on: // If the bound handler code isn't properly sanitized, it could potentially lead to Code Injection attacks.
v-model: // Two-way data binding directive. If user-controlled input is bound and used without proper sanitization, it could lead to XSS attacks.
```

### Express.js-Related Exploits
```js
app.get(), app.post(): // If user input is processed without proper sanitization in the callback functions, they could potentially lead to Code Injection or Command Injection attacks.
res.send(): // If user input is included without proper sanitization, it could potentially lead to HTTP Response Splitting attacks.
req.query, req.body, req.params: // These properties could potentially be used for SQL Injection or NoSQL Injection attacks if they aren't properly sanitized.
```

### Node.js Built-in Modules
Node.js is a JavaScript runtime built on Chrome's V8 JavaScript engine.
```js
fs.readFile(), fs.writeFile(): // These methods read from and write to files, respectively. If file names or content are user-controlled and not properly sanitized, this could lead to Path Traversal or Arbitrary File Overwrite vulnerabilities.
child_process.exec(): // Executes a shell command. If the command or arguments are user-controlled, this could lead to Command Injection attacks.
crypto.createCipher(): // Creates a Cipher object, with the specified algorithm and password. If algorithm or password are user-controlled, this could lead to weak encryption and the exposure of sensitive data.
http.createServer(): // Creates a new instance of http.Server. If request handlers aren't properly set up, it can potentially lead to security issues like open access to sensitive resources.
```

### jQuery-Related Exploits
jQuery is a fast, small, and feature-rich JavaScript library.
```js
jQuery.ajax()://  Makes an HTTP request. If the URL or data are not properly validated or sanitized, it could potentially be used for SSRF or XSS.
.html(): // Sets or returns the content of selected elements. If not properly sanitized, it can lead to XSS attacks.
.append(), .prepend(), .before(), .after(): // Insert content, specified by the parameter, to the end/beginning of each element in the set of matched elements. If the content is user-controlled and not sanitized, it can lead to XSS attacks.
.load(): // Loads data from a server and places the returned HTML into the matched elements. If the server isn't trusted, it can lead to Code Injection or XSS attacks.
```

### Socket.io-Related Exploits
Socket.IO is a library for real-time web applications. It enables real-time, bidirectional, and event-based communication between the browser and the server.
```js
socket.emit(), socket.on(): // These methods send and handle custom events. If event names or data are user-controlled and not sanitized, they could potentially lead to Code Injection attacks.
```

### Mongoose-Related Exploits
Mongoose provides a straightforward, schema-based solution to model your application data for MongoDB.
```js
.find(), .findOne(), .update(): // These Mongoose methods can potentially be used for NoSQL Injection attacks if the filter or update objects contain user-controlled input and are not properly sanitized.
mongoose.connect(): // Connects to a MongoDB database. If the connection string is user-controlled, this could potentially lead to SSRF or unauthorized access to the database.
```

### Electron-Related Exploits
Electron is a framework for creating native applications with web technologies like JavaScript, HTML, and CSS.
```js
webContents.executeJavaScript(): // This method can be used to run JavaScript on the renderer process (web page). If user-controlled input is injected into this function without proper sanitization, it could lead to Remote Code Execution.
webContents.loadURL(): // This method loads the URL in the window. If the URL is user-controlled and not validated, it could lead to Universal Cross-site Scripting (UXSS) or Remote Code Execution.
shell.openExternal(): // This method opens the given external protocol URL in the desktop's default manner. If the URL is user-controlled and not validated, it could be used for URL Scheme Hijacking attacks.
new BrowserWindow(): // If the nodeIntegration or contextIsolation options are not set correctly when creating new windows, it could lead to Remote Code Execution.
```

### D3.js-Related Exploits
D3.js is a JavaScript library for producing dynamic, interactive data visualizations in web browsers.
```js
d3.json(), d3.csv(), d3.xml(): // These methods load external JSON, CSV, or XML data. If the URL or the way the data is used is user-controlled and not properly validated or sanitized, it could lead to Data Injection attacks or Cross-Site Scripting.
d3.select(), d3.selectAll(): // These methods select an element or elements from the document. If the selector is user-controlled and not properly sanitized, it could potentially be used for DOM-Based Cross-Site Scripting attacks.
```

### Lodash-Related Exploits
Lodash is a modern JavaScript utility library delivering modularity, performance, and extras.
```js
_.template(): // This method compiles JavaScript templates into functions that can interpolate values. If user-controlled data is used as a template without proper sanitization, it could lead to Template Injection attacks.
_.merge(), _.extend(): // These methods are used to merge two or more objects. If a user-controlled object is merged without validation, it could potentially lead to Prototype Pollution, which in turn can lead to more severe vulnerabilities like Remote Code Execution.
_.set(): // This method sets the value at a path of an object. If the path is user-controlled and not validated, it could lead to Prototype Pollution.
```

### Three.js-Related Exploits
Three.js is a cross-browser JavaScript library and API used to create and display animated 3D computer graphics in a web browser.
```js
THREE.ObjectLoader.parse(): // This function parses a JSON structure and creates objects. If the JSON input is user-controlled and not validated, it could potentially be used for JSON Injection attacks.
THREE.FileLoader.load(): // This function loads a file at the specified URL. If the URL is user-controlled and not validated, it could potentially be used for SSRF attacks.
```

### axios-Related Exploits
Axios is a Promise-based HTTP client for the browser and Node.js.
```js
axios.get(), axios.post(): // Similar to http.get/post from Angular. If the URL or parameters are not properly validated, they could potentially be used for SSRF or even RCE attacks.
axios.create(): // Creates a new Axios instance. If the configuration is user-controlled and not validated, it could potentially be used for Misconfiguration attacks.
```

### Redux-Related Exploits
Redux is an open-source JavaScript library for managing application state.
```js
store.dispatch(): // This function dispatches an action to the Redux store. If the action or its payload is user-controlled and not validated, it could potentially be used for State Manipulation attacks.
createStore(): // This function creates a Redux store. If the reducer is user-controlled and not validated, it could potentially lead to State Manipulation or even Code Injection attacks.
```

### Knex.js-Related Exploits
Knex.js is a "batteries included" SQL query builder for Postgres, MSSQL, MySQL, MariaDB, SQLite3, Oracle, and Amazon Redshift.
```js
knex.raw(): // This function allows raw SQL to be executed. If the raw SQL includes user-controlled input, it could potentially lead to SQL Injection attacks.
knex.select(), knex.where(): // These methods are used to build queries. If the column names or values are user-controlled and not validated, they could potentially lead to SQL Injection attacks.
```

### Moment.js-Related Exploits
Moment.js is a free and open-source JavaScript library that removes the need to use the native JavaScript Date object directly.
```js
moment.parseZone(): // This method parses a string and converts it into a moment object in a specified timezone. If the input string is user-controlled and not validated, it could potentially lead to Parsing Manipulation attacks.
moment.tz(): // This function allows for converting dates between timezones. If the timezone parameter is user-controlled and not validated, it could potentially lead to Timezone Manipulation attacks.
```

### Passport.js-Related Exploits
Passport.js is authentication middleware for Node.js, extremely flexible and modular, that can be unobtrusively dropped into any Express-based web application.
```js
passport.authenticate(): //  This function authenticates requests. If the strategy or options are user-controlled and not validated, they could potentially lead to Authentication Bypass attacks.
```