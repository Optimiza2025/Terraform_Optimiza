#!/bin/bash

# Atualiza pacotes
sudo apt update && sudo apt upgrade -y

# Instala MySQL Server
sudo apt install mysql-server -y

# Ativa e inicia o serviço MySQL
sudo systemctl enable mysql
sudo systemctl start mysql

# Altera configuração para permitir conexões externas
sudo sed -i "s/^bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf

# Reinicia o MySQL para aplicar mudanças
sudo systemctl restart mysql

# Cria o banco e a tabela com permissões remotas para o usuário root
sudo mysql -e "
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '1234';
CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '1234';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;

DROP DATABASE IF EXISTS poc_optimiza;
CREATE DATABASE IF NOT EXISTS poc_optimiza;
USE poc_optimiza;

CREATE TABLE poc_optimiza.poc_optimiza_chamado (
    id_chamado INT PRIMARY KEY,
    titulo_chamado VARCHAR(255) NOT NULL,
    code_retorno_pipefy VARCHAR(100) NOT NULL,
    data_solicitacao_chamado DATETIME NOT NULL, 
    log_envio VARCHAR(200)
);
"

echo "MySQL instalado e configurado. Acesso remoto liberado para o usuário root."