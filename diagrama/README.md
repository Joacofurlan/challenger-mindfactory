## 🧩 Componentes del Diagrama de Red

🟦 **Amazon EKS (Elastic Kubernetes Service)**

Ejecuta 3 réplicas de pods en una subred privada de la VPC.  
Cada pod corre una aplicación Node.js que:
- Sirve HTML estático (como si fuera un NGINX)
- Se conecta a Redis para leer y escribir datos (contador de visitas)

El despliegue se realiza con Helm sobre nodos EC2 `t3.medium`.


🟥 **Amazon ElastiCache for Redis**  

Servicio Redis gestionado por AWS, accesible desde la misma VPC pero fuera del clúster de Kubernetes.  
- Los pods se conectan a esta instancia mediante endpoint TLS.
- Redis se usa como backend de estado para `/api`.


🟥 **Amazon S3**  

Disponible como almacenamiento general (no usado activamente por esta app pero provisto por la infraestructura).  
Está dentro de la misma VPC y accesible si se necesitara desde los pods.


🟣 **DNS Privado (simulado)**  

En lugar de usar Route 53, se simula un DNS privado manualmente modificando el archivo `/etc/hosts`.  
Esto permite acceder a la app desde tu máquina usando:
http://nginx.hello.local:8080

