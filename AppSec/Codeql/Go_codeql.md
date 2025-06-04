# Go

# Audit

### Find all dependencies
```sql
import go
import semmle.go.dependencies.Dependencies
from Dependency d, int nimports, string name
where
  nimports = strictsum(ImportSpec is | is = d.getAnImport() | 1) and
  exists(string p, string v | d.info(p, v) and name = p + v)
select name, nimports order by nimports desc
```

### Find Remote Flow Sources
```sql
import semmle.go.security.FlowSources
from RemoteFlowSource::Range source
where not source.getFile().getRelativePath().matches("%/test/%") // исключает тестовые файлы из показа
select source, "remote", source.getFile().getRelativePath(), source.getStartLine(),
  source.getEndLine(), source.getStartColumn(), source.getEndColumn()
```

### Function calls
```sql
from Function osOpen, CallExpr call
where
  osOpen.hasQualifiedName("os", "Open") and
  call.getTarget() = osOpen
select call.getArgument(0)
```

### Local data flow - в рамках одной функции/метода
```sql
from Function osOpen, CallExpr call, Parameter p
where
  osOpen.hasQualifiedName("os", "Open") and
  call.getTarget() = osOpen and
  DataFlow::localFlow(DataFlow::parameterNode(p), DataFlow::exprNode(call.getArgument(0)))
select p
```
 
### TaintTracking
```sql
from Function osOpen, CallExpr call, Parameter p
where
  osOpen.hasQualifiedName("os", "Open") and
  call.getTarget() = osOpen and
  TaintTracking::localTaint(DataFlow::parameterNode(p), DataFlow::exprNode(call.getArgument(0)))
select p
```
     
### Global data flow
```sql
import go
import semmle.go.dataflow.TaintTracking
import MyFlow::PathGraph

private module MyConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) {
    // Define your source nodes here. eg:
    // exists(DataFlow::CallNode call |
    //   call.getTarget().hasQualifiedName(_, "source") and
    //   call = source
    // )
    none()
  }

  predicate isSink(DataFlow::Node sink) {
    // Define your sink nodes here. eg:
    // exists(DataFlow::CallNode call |
    //   call.getTarget().hasQualifiedName(_, "sink") and
    //   call.getArgument(0) = sink
    //   )
    none()
  }
}

module MyFlow = TaintTracking::Global<MyConfig>; // or DataFlow::Global<..>

from MyFlow::PathNode source, MyFlow::PathNode sink
where MyFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Sample TaintTracking query"
```
