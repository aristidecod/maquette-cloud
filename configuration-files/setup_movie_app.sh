#!/bin/bash

set -e  # Stoppe en cas d’erreur

echo "➡️  Création de l’arborescence..."
mkdir -p ~/movies-app/{web,proxy}
cd ~/movies-app

echo "➡️  Téléchargement de l’application Spring Boot..."
wget -O web/spring-app.war http://tinyurl.com/jlmassat2/cca/spring-app.war

echo "➡️  Dockerfile Java (my-java:latest)"
mkdir -p web/java-docker
cat > web/java-docker/Dockerfile <<EOF
FROM almalinux
LABEL desc="My Java 17"
RUN dnf -y update && dnf -y install java-17-openjdk && dnf clean all
EOF

echo "➡️  Build image Java"
sudo docker build -t my-java:latest web/java-docker

echo "➡️  Script de démarrage Spring Boot"
cat > web/start.sh <<'EOF'
exec &> $MYAPP_LOG-$(uname -n)
echo "DB_URL      is $MYAPP_DB_URL"
echo "DB_DRIVER   is $MYAPP_DB_DRIVER"
echo "DB_USER     is $MYAPP_DB_USER"
echo "DB_PASSWORD is $MYAPP_DB_PASSWORD"
java \
    -Dspring.datasource.driver-class-name=$MYAPP_DB_DRIVER \
    -Dspring.datasource.url=$MYAPP_DB_URL \
    -Dspring.jpa.generate-ddl=true \
    -Dspring.jpa.hibernate.ddl-auto=update \
    -Dspring.datasource.username=$MYAPP_DB_USER \
    -Dspring.datasource.password=$MYAPP_DB_PASSWORD \
    -jar spring-app.war
EOF
chmod +x web/start.sh

echo "➡️  Dockerfile Web"
cat > web/Dockerfile <<EOF
FROM my-java:latest
LABEL desc="My SpringBoot App with MySQL"
WORKDIR /app
ENV MYAPP_DB_DRIVER="com.mysql.jdbc.Driver"
ENV MYAPP_DB_URL="jdbc:mysql://movies-app-database-1:3306/moviesdb"
ENV MYAPP_DB_USER="moviesuser"
ENV MYAPP_DB_PASSWORD="moviespass"
ENV MYAPP_LOG="/var/tmp/myapp.log"
ENV MYAPP_NAME="myapp"
COPY spring-app.war /app/spring-app.war
COPY start.sh /app/start.sh
EXPOSE 8081
ENTRYPOINT ["/bin/bash", "/app/start.sh"]
HEALTHCHECK --interval=4s --timeout=3s --retries=100 \
  CMD curl -f http://localhost:8081/movies/ || exit 1
EOF

echo "➡️  Config Docker Compose - compose.yaml"
cat > compose.yaml <<EOF
name: movies-app
include:
  - database.yaml
  - web.yaml
  - front.yaml
networks:
  mynet:
    driver: bridge
EOF

echo "➡️  Config database.yaml"
mkdir -p /var/movies/db
cat > database.yaml <<EOF
services:
  database:
    image: mysql
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: rootpasswd
      MYSQL_USER: moviesuser
      MYSQL_PASSWORD: moviespass
      MYSQL_DATABASE: moviesdb
    volumes:
      - /var/movies/db:/var/lib/mysql
    networks:
      - mynet
    healthcheck:
      test: /usr/bin/mysql --user=root --password=rootpasswd --execute "SHOW DATABASES;"
      interval: 2s
      timeout: 20s
      retries: 100
EOF

echo "➡️  Config web.yaml"
mkdir -p /var/movies/logs
cat > web.yaml <<EOF
services:
  web:
    build: web
    deploy:
      replicas: 2
    expose:
      - "8081"
    restart: always
    depends_on:
      database:
        condition: service_healthy
    networks:
      - mynet
    volumes:
      - /var/movies/logs/:/var/tmp
EOF

echo "➡️  Téléchargement du proxy (HAProxy)"
wget -O proxy.zip http://tinyurl.com/jlmassat2/cca/proxy.zip
unzip -o proxy.zip -d proxy/
rm proxy.zip

echo "➡️  Config front.yaml"
cat > front.yaml <<EOF
services:
  proxy:
    build: proxy/
    ports:
      - "8888:80"
    restart: always
    networks:
      - mynet
    environment:
      DOMAIN_NAME: idl.xfr
      EMAIL_ADDRESS: root@idl.xfr
      BACKEND1_URL: movies-app-web-1:8081
      BACKEND2_URL: movies-app-web-2:8081
    depends_on:
      web:
        condition: service_healthy
EOF

echo "✅ Préparation terminée ! Tu peux maintenant lancer le déploiement avec :"
echo ""
echo "    cd ~/movies-app"
echo "    sudo docker compose up -d --wait --build"
