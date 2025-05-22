SCA have the following capabilities:
* Manifest analysis: Analyzes the application's manifest file to identify used open-source components, offering a basic view of dependencies but has no insight into how the application utilizes them.
* Lockfile analysis: Examines the lockfile for a detailed snapshot of specific versions of dependencies used, providing accurate version tracking but not insight into their actual execution or reachability in the application.
* Static analysis: Reviews the source code without execution to determine how dependencies are integrated, revealing which parts of third-party libraries are referenced and potentially vulnerable.
* Dynamic analysis: Observes the application during runtime to capture real-time data on dependency interaction and usage, offering the most precise insights into reachability and runtime vulnerabilities.

### Reachability
- наличие в package.json версии в поле dependencies (не dev)
-  наличие вызова уязвимой функции


### Transitive reachability analysis
indirect dependency, is a dependency of a dependency

### Go
https://github.com/ondrajz/go-callvis

### Java, JS, PHP
https://depscan.readthedocs.io/reachability-analysis/