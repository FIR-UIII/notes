package OPA
import rego.v1

default output := false

output := true if {
    100 > 0
}