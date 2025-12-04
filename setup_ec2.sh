#!/bin/bash

# Encerra o script imediatamente se qualquer comando falhar
set -e

# --- Função de Utilidade ---
print_section() {
    echo ""
    echo "================================================="
    echo "=== $1"
    echo "================================================="
}

print_section "INICIANDO SETUP COMPLETO DA EC2"
cd /home/ubuntu

# --- 1. INSTALAÇÃO DE DEPENDÊNCIAS ---
print_section "Atualizando pacotes e instalando dependências"
sudo apt update
sudo apt install -y \
    nginx \
    openjdk-21-jdk \
    python3-pip \
    python3-venv \
    mysql-client \
    pkg-config \
    default-libmysqlclient-dev \
    build-essential

# --- 2. CONFIGURAÇÃO DO BACKEND (SPRING BOOT) ---
print_section "Configurando Backend Spring Boot (Serviço)"
# (Verifica se o .jar copiado existe)
if [ ! -f "/home/ubuntu/backend/target/backend-0.0.1-SNAPSHOT.jar" ]; then
    echo "ERRO: Arquivo backend-0.0.1-SNAPSHOT.jar não encontrado em /home/ubuntu/backend/target/"
    exit 1
fi

# Cria o serviço systemd para o Spring Boot
sudo bash -c 'cat > /etc/systemd/system/optimiza-backend.service' << EOF
[Unit]
Description=Servico Backend Spring Boot Optimiza
After=network.target

[Service]
User=ubuntu
Group=ubuntu
WorkingDirectory=/home/ubuntu/backend/target
ExecStart=/usr/bin/java -jar /home/ubuntu/backend/target/backend-0.0.1-SNAPSHOT.jar
Restart=on-failure
SuccessExitStatus=143

[Install]
WantedBy=multi-user.target
EOF

# --- 3. CONFIGURAÇÃO DO DJANGO (GUNICORN) ---
print_section "Configurando Backend Django (Serviço Gunicorn)"

# (Verifica se o manage.py copiado existe)
if [ ! -f "/home/ubuntu/Poc-atendimento/optimiza/manage.py" ]; then
    echo "ERRO: manage.py não encontrado em /home/ubuntu/Poc-atendimento/optimiza/"
    exit 1
fi

# Navega para a pasta do REPOSITÓRIO (um nível acima do manage.py)
cd /home/ubuntu/Poc-atendimento

# Criação do ambiente virtual (um nível acima, como na EC2-01)
ENV_DIR="ambienteOptimiza"
print_section "Configurando ambiente virtual $ENV_DIR"
python3 -m venv "$ENV_DIR"
source "$ENV_DIR/bin/activate"
echo "Ambiente virtual ativado."

# Instala dependências
print_section "Instalando dependências do Django"
# (Navega para a pasta do manage.py para encontrar o requirements.txt)
cd optimiza
pip install --upgrade pip
pip install -r requirements.txt
pip install gunicorn mysqlclient # Garante que temos tudo para produção

# Coleta os arquivos estáticos (cria a pasta 'staticfiles')
print_section "Coletando arquivos estáticos do Django"
python manage.py collectstatic --no-input
deactivate
echo "Ambiente virtual desativado."

# Cria o serviço systemd para o Gunicorn
sudo bash -c 'cat > /etc/systemd/system/gunicorn.service' << EOF
[Unit]
Description=Servico Gunicorn para Django
After=network.target

[Service]
User=ubuntu
Group=ubuntu
# (O WorkingDirectory deve ser onde o manage.py está)
WorkingDirectory=/home/ubuntu/Poc-atendimento/optimiza
ExecStart=/home/ubuntu/Poc-atendimento/ambienteOptimiza/bin/gunicorn --workers 3 --bind 0.0.0.0:8000 optimiza.wsgi:application
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# --- 4. CONFIGURAÇÃO DO FRONTEND (NGINX) ---
print_section "Configurando Frontend (Nginx)"

# (Verifica se os arquivos do frontend foram copiados)
if [ ! -f "/var/www/optimiza/html/Index.html" ]; then
     echo "AVISO: /var/www/optimiza/html/Index.html não encontrado."
     echo "Certifique-se de ter copiado os arquivos do frontend para este local."
fi

# Dê permissão ao Nginx para ler os arquivos copiados
sudo chown -R www-data:www-data /var/www/optimiza/html

# Cria a configuração do Nginx (servindo front e staticfiles do django)
sudo bash -c 'cat > /etc/nginx/sites-available/default' << EOF
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    # 1. Rota do Frontend
    location / {
        root /var/www/optimiza/html;
        index Index.html;
        try_files $uri $uri/ =404;
    }

    # 2. Rota do Django
    location /chamado/ {
        proxy_pass http://127.0.0.1:8000; # Envia para o Gunicorn
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    # 3. Rota do Spring (Kotlin)
    location /optimiza/ {
        proxy_pass http://127.0.0.1:8080; # Envia para o Spring Boot
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    # 4. Rota dos Estáticos do Django
    location /static/ {
        alias /home/ubuntu/Poc-atendimento/optimiza/staticfiles/;
    }
}
EOF

# --- 5. INICIANDO OS SERVIÇOS ---
print_section "Recarregando daemons e iniciando todos os serviços"
sudo systemctl daemon-reload

sudo systemctl enable optimiza-backend.service
sudo systemctl enable gunicorn.service
sudo systemctl enable nginx

# Inicia os serviços. O 'set -e' vai parar o script se algum falhar.
sudo systemctl start optimiza-backend.service
sudo systemctl start gunicorn.service
sudo systemctl restart nginx # Restart para pegar nova config

print_section "[SETUP COMPLETO CONCLUÍDO!]"
echo "EC2-02 está configurada e os serviços estão rodando."
echo "Verifique o status do ALB no console da AWS. Ambas as instâncias devem ficar 'healthy'."