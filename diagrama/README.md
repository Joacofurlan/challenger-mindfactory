🧩 Componentes del Diagrama

🟦 Amazon EKS (Elastic Kubernetes Service)
Dentro de una subred privada de la VPC.

Ejecuta 3 réplicas de pods con la aplicacion nginx que sirve HTML y se conecta a Redis.

Se despliega con Helm, usando nodos EC2 (t3.medium) en EKS.

🟥 Amazon ElastiCache for Redis
Servicio gestionado de Redis, fuera del clúster de Kubernetes, pero accesible desde la misma VPC.

Pods nginx hacen operaciones de lectura/escritura sobre esta instancia.

Tiene TLS habilitado.

🟥 Amazon S3
Usado como almacenamiento general.

Está dentro de la misma VPC y accesible desde la app en EKS.

🟣 Private DNS
Simula un DNS privado definido manualmente en /etc/hosts.

Permite resolver el dominio interno de la app desplegada, sin necesidad de Route 53.

Ideal para entornos de tests.

🔁 Flujo de Comunicación
Los pods nginx en EKS se escalan de 1 a 3 réplicas automáticamente.

Estos pods se comunican con Redis (ElastiCache) mediante el endpoint configurado.

También pueden interactuar con el bucket S3 si lo necesitan (lectura/escritura).

Todo sucede dentro de una misma VPC sin tráfico saliente ni exposición pública.

El acceso a la app se hace mediante DNS privado configurado en /etc/hosts, no por Load Balancer.
