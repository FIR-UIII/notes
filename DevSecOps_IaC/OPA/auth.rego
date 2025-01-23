package system.authz


default allow := false          # Reject requests by default.

allow {                         # Allow request if...
    input.identity == "secret"  # Identity is the secret root key.
}
