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

# 🚀 Despliegue de Aplicación Node.js + Redis en EKS (Parte 2)

Como desplegar una aplicación Node.js + Redis sobre Kubernetes en AWS, utilizando:

- Helm para empaquetar y desplegar la app
- GitHub Actions para automatizar CI/CD
- Redis (ElastiCache) como base de datos
- DNS privado para acceso desde tu máquina

La infraestructura (EKS, Redis, S3, etc.) ya debe haber sido creada con Terraform previamente (ver "1. Infraestructura como Código (IaC)" ).

---

## ✅ ¿Qué hace esta aplicación?

- Ejecuta un contenedor Node.js que:
  - Sirve un archivo HTML con `Hello World`
  - Lee y escribe valores en Redis
- Se despliega con 1 a 3 réplicas en Kubernetes (EKS)
- Se accede desde tu máquina usando un DNS privado (`nginx.hello.local`)

## 📁 Estructura del Proyecto

challenger-mindfactory/
├── app/ # Código Node.js (Dockerizado)
│ ├── redis.js
│ ├── Dockerfile
│ └── package.json
│
├── helm/app/ #
│ ├── values.yaml
│ ├── Chart.yaml
│ └── templates/
│ ├── deployment.yaml
│ ├── service.yaml
│ 
│
└── .github/workflows/
└── deploy.yaml # CI/CD con GitHub Actions

## 🧩 Requisitos Previos

Antes de continuar, asegurate de tener:

- El clúster EKS funcionando (ver README-parte-1)
- Redis desplegado en ElastiCache
- Terraform ya ejecutado
- Docker habilitado en GitHub Actions
- Secretos configurados en GitHub:
 `AWS_ACCESS_KEY_ID` Para autenticarse con AWS
 `AWS_SECRET_ACCESS_KEY` Para autenticarse con AWS

## 🚦 Paso 1: Clonar el Repositorio

git clone https://github.com/joacofurlan/challenger-mindfactory.git
cd challenger-mindfactory

⚙️ Paso 2: Revisar el archivo values.yaml
Ubicado en helm/app/values.yaml. Asegurate de tener el host Redis correcto:

replicaCount: 3

image:
  repository: ghcr.io/joacofurlan/challenger-mindfactory
  tag: latest

service:
  type: ClusterIP
  port: 80

redis:
  host: clustercfg.test-redis-devops.fvaym2.use1.cache.amazonaws.com
  port: 6379
  
⚙️ Paso 3: Configurar tu entorno local para probar luego
Para simular un DNS privado desde tu PC:

Abrí el bloc de notas como administrador (click derecho → Ejecutar como administrador)

Abrí el archivo:

C:\Windows\System32\drivers\etc\hosts
Agregá esta línea al final:
127.0.0.1 nginx.hello.local
Guardá y cerrá.

Esto permitirá que al hacer curl http://nginx.hello.local:8080 tu máquina redirija a localhost (útil para testing).

🚀 Paso 4: GitHub Actions - Deploy Automático
Cada vez que se hace git push a la rama main, GitHub va a:

Construir la imagen Docker a partir de app/Dockerfile

Subirla a GitHub Container Registry (GHCR)

Actualizar tu clúster EKS usando Helm

No necesitás hacer nada más. El archivo .github/workflows/deploy.yaml ya contiene todo:

helm upgrade --install nginx-hello ./helm/app \
  --namespace default \
  --values ./helm/app/values.yaml \
  --set image.repository=ghcr.io/joacofurlan/challenger-mindfactory \
  --set image.tag=latest \
  --wait \
  --debug
  
🧪 Paso 5: Validar el Despliegue
Verificar pods:
kubectl get pods
Todos deben aparecer en estado Running.

Probar internamente:
kubectl exec -it <nombre-del-pod> -- sh
curl localhost/
# Debe mostrar:
Hello from Redis: world
Probar desde tu PC (DNS simulado):
bash
Copiar
Editar
curl http://nginx.hello.local:8080
# También debe mostrar:
Hello from Redis: world
Si no funciona, asegurate de tener configurado correctamente el archivo hosts de Windows y que estés redirigiendo al puerto correcto con port-forward si es necesario.

🧹 Rollbacks (si algo sale mal)
Si un deploy falla (por ejemplo: error en Helm o falla de pull de imagen):

bash
Copiar
Editar
helm rollback nginx-hello <número-de-revision>
Para ver el historial:

bash
Copiar
Editar
helm history nginx-hello
🧼 Limpieza Manual
Para eliminar el despliegue:

bash
Copiar
Editar
helm uninstall nginx-hello

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
