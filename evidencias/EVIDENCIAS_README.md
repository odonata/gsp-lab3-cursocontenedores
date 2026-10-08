# Evidencias de Kubernetes

Comando `kubectl cluster-info` evidencia:

```text
Kubernetes control plane is running at https://127.0.0.1:51643
CoreDNS is running at https://127.0.0.1:51643/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
```

Comando `kubectl get nodes` evidencia:

```text
NAME                               STATUS   ROLES           AGE   VERSION
curso-contenedores-control-plane   Ready    control-plane   28d   v1.37.0
```

Comando `kubectl get pods -n ns-gsp-lab3` evidencia:

```text
NAME                           READY   STATUS    RESTARTS   AGE
app-gsp-lab3-ff69d5887-8xq4j   1/1     Running   0          21m
app-gsp-lab3-ff69d5887-zgbff   1/1     Running   0          21m
```

Comando `kubectl get deployment -n ns-gsp-lab3` evidencia:

```text
NAME           READY   UP-TO-DATE   AVAILABLE   AGE
app-gsp-lab3   2/2     2            2           21m
```

Comando `kubectl get svc -n ns-gsp-lab3` evidencia:

```text
NAME           TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
svc-gsp-lab3   ClusterIP   10.96.179.167   <none>        80/TCP    21m
```

Comando `kubectl logs deployment/app-gsp-lab3 -n ns-gsp-lab3` evidencia:

```text
Found 2 pods, using pod/app-gsp-lab3-ff69d5887-zgbff
[Nest] 1  - 10/08/2026, 9:04:52 PM     LOG [NestFactory] Starting Nest application...
[Nest] 1  - 10/08/2026, 9:04:52 PM     LOG [InstanceLoader] AppModule dependencies initialized +58ms
[Nest] 1  - 10/08/2026, 9:04:52 PM     LOG [RoutesResolver] AppController {/}: +16ms
[Nest] 1  - 10/08/2026, 9:04:52 PM     LOG [RouterExplorer] Mapped {/, GET} route +3ms
[Nest] 1  - 10/08/2026, 9:04:52 PM     LOG [RouterExplorer] Mapped {/lab, GET} route +0ms
[Nest] 1  - 10/08/2026, 9:04:52 PM     LOG [NestApplication] Nest application successfully started +3ms
```

Comando `kubectl exec deployment/app-gsp-lab3 -n ns-gsp-lab3 -- printenv` evidencia:

```text
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
HOSTNAME=app-gsp-lab3-ff69d5887-zgbff
NODE_VERSION=24.21.0
YARN_VERSION=1.22.22
NODE_ENV=production
AMBIENTE=desarrollo
API_KEY=[REDACTED]
SVC_GSP_LAB3_SERVICE_HOST=10.96.179.167
SVC_GSP_LAB3_PORT_80_TCP=tcp://10.96.179.167:80
SVC_GSP_LAB3_PORT_80_TCP_PROTO=tcp
SVC_GSP_LAB3_PORT_80_TCP_ADDR=10.96.179.167
KUBERNETES_SERVICE_PORT=443
SVC_GSP_LAB3_SERVICE_PORT=80
SVC_GSP_LAB3_SERVICE_PORT_HTTP=80
SVC_GSP_LAB3_PORT=tcp://10.96.179.167:80
SVC_GSP_LAB3_PORT_80_TCP_PORT=80
KUBERNETES_SERVICE_HOST=10.96.0.1
KUBERNETES_PORT=tcp://10.96.0.1:443
KUBERNETES_PORT_443_TCP_PROTO=tcp
KUBERNETES_PORT_443_TCP_ADDR=10.96.0.1
KUBERNETES_SERVICE_PORT_HTTPS=443
KUBERNETES_PORT_443_TCP=tcp://10.96.0.1:443
HOME=/home/node
```

Comando `kubectl get configmap config-gsp-lab3 -n ns-gsp-lab3` evidencia:

```text
NAME              DATA   AGE
config-gsp-lab3   1      21m
```

Comando `kubectl get secret secret-gsp-lab3 -n ns-gsp-lab3` evidencia:

```text
NAME              TYPE     DATA   AGE
secret-gsp-lab3   Opaque   1      21m
```
