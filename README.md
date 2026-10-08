# GSP-Laboratorio 3: CI/CD en Kubernetes

## Ejecucion local

Instalar las dependencias, ejecuta las pruebas y construir la imagen:

```bash
pnpm install --frozen-lockfile
pnpm test --runInBand
pnpm run test:e2e --runInBand
pnpm run build
docker build -t tarea-final:gsp-lab3 .
```

Iniciar la aplicacion con valores locales :

```bash
docker run --rm -p 3000:3000 \
  -e AMBIENTE=desarrollo \
  -e API_KEY=clave-local \
  tarea-final:gsp-lab3
```


`clave-local` es solo un valor de ejemplo para pruebas locales.

## Pipeline Jenkins

1. Se usa la rama `main` del repositorio [gsp-lab3-cursocontenedores](https://github.com/odonata/gsp-lab3-cursocontenedores).
2. En Jenkins, se crean estas credenciales globales con losIDs indicados: `dockerhub-credentials` y `ghcr-credentials` como **Username with password**; `api-key-lab3` como **Secret text**. Los tokens y la clave se guardan en Jenkins, no en el repositorio.
3. Antes de ejecutar el pipeline, se da acceso al namespace de la aplicación. En el clúster Kubernetes de destino, se debe ejecutar:

```bash
kubectl create namespace ns-gsp-lab3 --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f jenkins-rbac.yaml
```

4. En Jenkins, se selecciona **New Item**, se escribe `gsp-lab3-cursocontenedores`, se elige **Pipeline** y se pulsa **OK**.
5. En la configuraciòn del trabajo, en **Pipeline**, se seleccionan **Pipeline script from SCM** y **Git**. Se introduce `https://github.com/odonata/gsp-lab3-cursocontenedores.git`, se indica `*/main` como rama y `Jenkinsfile` como **Script Path**. Se guardan los cambios.
6. Para ejecutar el trabajo, se abre y se selecciona **Build Now**. En la ejecución, se comprueba que terminen correctamente las etapas `install`, `test`, `build`, `push` y `deploy`.

El pipeline publica las etiquetas `gsp-lab3` y `3.0.0` en Docker Hub y GHCR, y despliega la imagen de Docker Hub en el clúster configurado.

Si Jenkins todavía no está instalado en el clúster de destino, instalarlo

## Despliegue manual

La imagen ya está configurada en `entrega.yaml` como [`odonatafly/tarea-final:gsp-lab3`](https://hub.docker.com/r/odonatafly/tarea-final). No es necesario editarla. Aplica los manifiestos:

```bash
kubectl create namespace ns-gsp-lab3 --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f entrega.yaml
```

Actualizar el Secret con la clave que se use en el entorno destino:

```bash
read -s -p "API_KEY: " API_KEY
echo
kubectl create secret generic secret-gsp-lab3 \
  -n ns-gsp-lab3 \
  --from-literal="API_KEY=$API_KEY" \
  --dry-run=client -o yaml | kubectl apply -f -
unset API_KEY
kubectl rollout restart deployment/app-gsp-lab3 -n ns-gsp-lab3
kubectl rollout status deployment/app-gsp-lab3 -n ns-gsp-lab3
kubectl get pods -n ns-gsp-lab3
```

Para consulta la aplicaciòn, hacer el port-forward:

```bash
kubectl port-forward svc/svc-gsp-lab3 8080:80 -n ns-gsp-lab3
```

Y en otra ventana de terminal ejecutar :

```bash
curl http://localhost:8080/lab
```

## Evidencias

Las `evidencias` estan en el archivo evidencias\EVIDENCIAS_README.md

```bash
kubectl cluster-info
kubectl get nodes
kubectl get pods -n ns-gsp-lab3
kubectl get deployment -n ns-gsp-lab3
kubectl get svc -n ns-gsp-lab3
kubectl logs deployment/app-gsp-lab3 -n ns-gsp-lab3
kubectl exec deployment/app-gsp-lab3 -n ns-gsp-lab3 -- printenv
kubectl get configmap config-gsp-lab3 -n ns-gsp-lab3
kubectl get secret secret-gsp-lab3 -n ns-gsp-lab3
```

