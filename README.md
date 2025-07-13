# Challenger MindFactory - (NGINX + Redis + AWS + GitHub Actions)

Este proyecto resuelve un desafío técnico de DevOps, incluyendo:
- Infraestructura como código con Terraform.
- Despliegue en Kubernetes (EKS).
- Redis en AWS ElastiCache.
- Escalado automático de aplicación con NGINX + Redis.
- Automatización de CI/CD con GitHub Actions.
- Acceso vía DNS privado (`/etc/hosts`) desde entorno local.
- 
## 📌 Requisitos del desafío

### 1. Infraestructura como Código (IaC)

* Utilizar Terraform o Pulumi.
* Provisionar en AWS:

  * VPC, subredes públicas y privadas.
  * Bucket S3.
  * Clúster EKS.
  * Instancia de Redis (ElastiCache).

### 2. Aplicación

* Contenedor con NGINX sirviendo archivo HTML.
* Capacidad de lectura y escritura en Redis.
* Deployment escalable (entre 1 y 3 réplicas).
* Expuesto por un **DNS privado** mapeado en `/etc/hosts`.

### 3. Automatización

* Uso de Helm para definir y desplegar la app.
* Uso de GitHub Actions para el CI/CD completo.

---

## 🛠 Infraestructura - Terraform (IaC)
El proyecto está compuesto por módulos y configuraciones para:

* Crear un `cluster EKS` con `node groups` autoscalables.
* Crear `Redis` en ElastiCache dentro de subredes privadas con TLS habilitado.
* Crear `Bucket S3` como almacenamiento general.
* Definir VPC con rutas, internet gateway, NAT gateway, tablas de ruteo.

## Contenido del Módulo Terraform: 
- terraform/main.tf: recursos principales (VPC, EKS, Redis, S3, SGs)
- terraform/variables.tf: definición de variables reutilizables
- terraform/outputs.tf: exporta datos útiles para otros módulos o para debugging
- 
## Requisitos Previos
Terraform >= 1.0
AWS CLI configurado: https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html

## Exportar las credenciales de AWS:
export AWS_ACCESS_KEY_ID=AKIA...
export AWS_SECRET_ACCESS_KEY=...
export AWS_DEFAULT_REGION=us-east-1

## Variables necesarias
Las variables ya vienen con valores por defecto definidos en variables.tf:
aws_region      = "us-east-1"
cluster_name    = "test-eks-devops"
s3_bucket_name  = "test-bucket-devops-120725"
redis_node_type = "cache.t3.micro"


## PASO A PASO
1. Clonar el repo y posicionarse en la carpeta:
git clone https://github.com/joacofurlan/challenger-mindfactory.git
cd challenger-mindfactory/terraform

2. Inicializar Terraform:
terraform init

3. Revisar el plan:
terraform plan -out=tfplan

4. Aplicar cambios:
terraform apply tfplan

Esto creara automáticamente:
VPC con subredes públicas y privadas
EKS cluster y nodos (1-3 instancias t3.small)
Redis en ElastiCache (privado y con seguridad aplicada)
Bucket S3 privado y encriptado
IAM policies para acceso desde EKS a S3

## Seguridad y Networking
Este proyecto ya incluye reglas de seguridad que seran utilizadas en la activida numero dos de crear una aplicacion:

Reglas de entrada Redis:
Permite el puerto TCP 6379 desde la red interna 10.0.0.0/16
Permite puertos 6379-6390 desde los nodos del EKS (source_security_group_id = SG del node group)

Reglas de salida Redis:
Acceso total hacia 0.0.0.0/0

## Validacion:
aws eks update-kubeconfig --region us-east-1 --name test-eks-devops
kubectl get no|des
kubectl get svc -n default

## Eliminacion:
terraform destroy

## 🚀 Aplicación (NGINX + Node.js + Redis)

### Estructura de la app

La app consiste en un servidor `Node.js` (`redis.js`) que:

1. Se conecta a Redis vía `TLS`.
2. Setea el valor `hello = world`.
3. Lo recupera y lo muestra vía HTTP (`/`).

```js
const client = redis.createClient({
  socket: {
    host: process.env.REDIS_HOST,
    port: process.env.REDIS_PORT,
    tls: true,
    servername: process.env.REDIS_HOST
  }
});
```

### Dockerfile

```Dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN apk add --no-cache curl ca-certificates
EXPOSE 80
CMD ["node", "redis.js"]
```

---

## 📦 Helm Chart personalizado

El Helm chart (`helm/app`) permite parametrizar:

* Imagen Docker (`repository`, `tag`).
* `replicaCount`.
* Host y puerto de Redis desde `values.yaml`:

```yaml
image:
  repository: ghcr.io/joacofurlan/challenger-mindfactory
  tag: latest
  pullPolicy: Always

replicaCount: 3

redis:
  host: test-redis-devops.cluster-xxxxxxx.usw2.cache.amazonaws.com
  port: 6379
```

---

## ⚙️ CI/CD - GitHub Actions

Workflow `.github/workflows/deploy.yaml`:

* Construye imagen y la sube a `GitHub Container Registry (GHCR)`.
* Luego ejecuta `helm upgrade --install` contra el clúster `EKS`.

### Variables importantes:

```yaml
env:
  REGISTRY: ghcr.io
  IMAGE_NAME: joacofurlan/challenger-mindfactory
  CLUSTER_NAME: test-eks-devops
  AWS_REGION: us-east-1
```

### Comando Helm ejecutado

```bash
helm upgrade --install nginx-hello ./helm/app \
  --namespace default \
  --values ./helm/app/values.yaml \
  --set image.repository=ghcr.io/joacofurlan/challenger-mindfactory \
  --set image.tag=latest \
  --wait --debug
```

> ⚠️ En caso de error de `another operation in progress`, se resolvió con:
>
> ```bash
> helm rollback nginx-hello <última_revision_estable>
> ```

---

## 🌐 DNS privado con `/etc/hosts`

### Paso a paso:

1. Ejecutar port-forward para exponer localmente:

```bash
kubectl port-forward svc/nginx-hello 8080:80
```

2. Abrir como **Administrador** el archivo:

```plaintext
C:\Windows\System32\drivers\etc\hosts
```

3. Agregar esta línea (importante guardar con permisos de administrador):

```plaintext
127.0.0.1 nginx.hello.local
```

4. Acceder desde el navegador o terminal:

```bash
curl http://nginx.hello.local:8080
```

---

## 🧪 Verificación funcional

✔️ `kubectl get pods` muestra los 3 pods de la app `Running`.
✔️ `kubectl exec` + `curl localhost` muestra `Hello from Redis: world`.
✔️ Acceso desde Windows vía DNS privado simulado funciona correctamente.

---

## ✅ Resultado final

Todos los requerimientos del desafío están **completamente cumplidos**, de forma profesional, reproducible y automatizada.

---

## 📎 Extras

* Se utilizaron prácticas de debugging y troubleshooting (Redis TLS, logs, rollback Helm).
* Se corrigieron errores de imagen (ImagePullBackOff) y conflictos de upgrade (`pending-upgrade`).
* Validación de `/etc/hosts` fue crítica: se resolvió editando el archivo como **Administrador**.

---

## 🧠 Autor

**Joaquín Furlan**
Proyecto técnico resuelto con enfoque DevOps extremo.

---

¿Preguntas? ¿Feedback? Abierto a mejoras 💬
