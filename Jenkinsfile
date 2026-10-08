pipeline {
  agent {
    kubernetes {
      yamlFile 'agent.yaml'
      defaultContainer 'node'
    }
  }

  environment {
    IMAGE_TAG = 'gsp-lab3'
    APP_VERSION = '3.0.0'
    IMAGE_NAME = 'tarea-final'
    NAMESPACE = 'ns-gsp-lab3'
    DEPLOYMENT = 'app-gsp-lab3'
  }

  stages {
    stage('install') {
      steps {
        container('node') {
          sh 'corepack enable && corepack prepare pnpm@12.10.1 --activate && pnpm install --frozen-lockfile'
        }
      }
    }

    stage('test') {
      steps {
        container('node') {
          sh 'pnpm test --runInBand'
          sh 'pnpm run test:e2e --runInBand'
        }
      }
    }

    stage('build') {
      steps {
        container('node') {
          sh 'pnpm run build'
        }
        container('docker') {
          sh 'until docker info >/dev/null 2>&1; do sleep 2; done'
          sh 'docker build --build-arg APP_VERSION="$APP_VERSION" --tag "$IMAGE_NAME:$IMAGE_TAG" .'
          sh 'docker tag "$IMAGE_NAME:$IMAGE_TAG" "$IMAGE_NAME:$APP_VERSION"'
        }
      }
    }

    stage('push') {
      steps {
        container('docker') {
          withCredentials([
            usernamePassword(
              credentialsId: 'dockerhub-credentials',
              usernameVariable: 'DOCKERHUB_USER',
              passwordVariable: 'DOCKERHUB_TOKEN'
            ),
            usernamePassword(
              credentialsId: 'ghcr-credentials',
              usernameVariable: 'GHCR_USER',
              passwordVariable: 'GHCR_TOKEN'
            )
          ]) {
            sh '''
              set +x
              DOCKERHUB_USER="$(printf '%s' "$DOCKERHUB_USER" | tr '[:upper:]' '[:lower:]')"
              GHCR_USER="$(printf '%s' "$GHCR_USER" | tr '[:upper:]' '[:lower:]')"
              DOCKERHUB_IMAGE="$DOCKERHUB_USER/$IMAGE_NAME"
              GHCR_IMAGE="ghcr.io/$GHCR_USER/$IMAGE_NAME"

              printf '%s' "$DOCKERHUB_TOKEN" | docker login --username "$DOCKERHUB_USER" --password-stdin
              printf '%s' "$GHCR_TOKEN" | docker login ghcr.io --username "$GHCR_USER" --password-stdin

              for tag in "$IMAGE_TAG" "$APP_VERSION"; do
                docker tag "$IMAGE_NAME:$IMAGE_TAG" "$DOCKERHUB_IMAGE:$tag"
                docker tag "$IMAGE_NAME:$IMAGE_TAG" "$GHCR_IMAGE:$tag"
                docker push "$DOCKERHUB_IMAGE:$tag"
                docker push "$GHCR_IMAGE:$tag"
              done

              docker logout
              docker logout ghcr.io
            '''
          }
        }
      }
    }

    stage('deploy') {
      steps {
        container('kubectl') {
          withCredentials([
            usernamePassword(
              credentialsId: 'dockerhub-credentials',
              usernameVariable: 'DOCKERHUB_USER',
              passwordVariable: 'DOCKERHUB_TOKEN'
            ),
            string(
              credentialsId: 'api-key-lab3',
              variable: 'API_KEY'
            )
          ]) {
            sh '''
              set +x
              export KUBECONFIG="$(mktemp)"
              trap 'rm -f "$KUBECONFIG"' EXIT
              cat > "$KUBECONFIG" <<EOF
apiVersion: v1
kind: Config
clusters:
- name: in-cluster
  cluster:
    certificate-authority: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
    server: https://${KUBERNETES_SERVICE_HOST}:${KUBERNETES_SERVICE_PORT}
contexts:
- name: in-cluster
  context:
    cluster: in-cluster
    user: deployer
    namespace: $NAMESPACE
current-context: in-cluster
users:
- name: deployer
  user:
    tokenFile: /var/run/secrets/kubernetes.io/serviceaccount/token
EOF
              DOCKERHUB_USER="$(printf '%s' "$DOCKERHUB_USER" | tr '[:upper:]' '[:lower:]')"
              sed "s|docker.io/odonatafly/tarea-final:gsp-lab3|docker.io/$DOCKERHUB_USER/$IMAGE_NAME:$IMAGE_TAG|" entrega.yaml \
                | kubectl apply -f -
              encoded_api_key="$(printf '%s' "$API_KEY" | base64 | tr -d '\n')"
              printf '{"apiVersion":"v1","kind":"Secret","metadata":{"name":"secret-gsp-lab3","namespace":"%s"},"type":"Opaque","data":{"API_KEY":"%s"}}\n' \
                "$NAMESPACE" "$encoded_api_key" | kubectl apply -f -
              kubectl rollout restart "deployment/$DEPLOYMENT" --namespace "$NAMESPACE"
              kubectl rollout status "deployment/$DEPLOYMENT" --namespace "$NAMESPACE" --timeout=180s
            '''
          }
        }
      }
    }
  }
}
