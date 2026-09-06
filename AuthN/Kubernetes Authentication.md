Every request to the Kubernetes API passes through three stages in the API server: authentication, authorisation, and admission control:
https://learnkube.com/microservices-authentication-kubernetes

API server has identities:
1. Kubernetes  managed identities: Service Accounts created by the Kubernetes cluster itself and used by in-cluster apps.
2. Non-Kubernetes managed users: users that are external to the Kubernetes cluster, such as:
* Users with static tokens or certificates provided by cluster administrators.
* Users authenticated through external identity providers using OIDC, webhook token authentication, or an authenticating proxy.

### Service Account
```
# test Service Account in the authn-demo namespace
kubectl create namespace authn-demo
kubectl -n authn-demo apply -f - <<'EOF'
    apiVersion: v1
    kind: ServiceAccount
    metadata:
    name: test
    EOF
    serviceaccount/test created

kubectl -n authn-demo get serviceaccount test -o yaml


# или можно сделать запрос
export APISERVER=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')
export CACERT=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.certificate-authority}')
export TOKEN=$(kubectl -n authn-demo create token test --duration=10m)
curl -sS --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -X GET ${APISERVER}/api
{
  "kind": "APIVersions",
  "versions": [
    "v1"
  ],
  "serverAddressByClientCIDRs": [
    {
      "clientCIDR": "0.0.0.0/0",
      "serverAddress": "192.168.49.2:8443"
    }
  ]
}
```

### ClusterRoleBinding
```
kubectl apply -f - <<'EOF'
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin
subjects:
- kind: User
  name: arthur
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
EOF
clusterrolebinding.rbac.authorization.k8s.io/admin created

export APISERVER=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')
export CACERT=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.certificate-authority}')
curl -sS --cacert ${CACERT} -X GET ${APISERVER}/api/v1/namespaces
```

### External Identities
Kubernetes offers several other mechanisms to authenticate external users:
* X.509 client certificates.
* JWT/OpenID Connect.
* Authenticating proxy.
* Webhook token authentication.


### RBAC in Kubernetes
A Service Account: this is the identity of who is accessing the resources.
A Role which includes the permission to access the resources.
A RoleBinding that links the identity (Service Account) to the permissions (Role).
```
kubectl create namespace demo-namespace

kubectl apply -f - <<'EOF'
apiVersion: v1
kind: ServiceAccount
metadata:
  name: app1
  namespace: demo-namespace
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: viewer
  namespace: demo-namespace
rules:
  - apiGroups:
      - ''
    resources:
      - services
      - pods
    verbs:
      - get
      - list
  - apiGroups:
      - apps
    resources:
      - deployments
    verbs:
      - get
      - list
  - apiGroups:
      - stable.example.com
    resources:
      - crontabs
    verbs:
      - get
      - list
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: app1-viewer
  namespace: demo-namespace
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: viewer
subjects:
  - kind: ServiceAccount
    name: app1
    namespace: demo-namespace
EOF

namespace/demo-namespace created
serviceaccount/app1 created
role.rbac.authorization.k8s.io/viewer created
rolebinding.rbac.authorization.k8s.io/app1-viewer created
```