#!/bin/bash

set -e

echo "Iniciando o provisionamento da infraestrutura (IaC)..."

echo "Criando diretórios..."
mkdir -p /publico /adm /ven /sec

echo "Criando grupos de usuários..."
groupadd -f GRP_ADM
groupadd -f GRP_VEN
groupadd -f GRP_SEC

echo "Criando usuários e associando aos grupos..."
SENHA_PADRAO=$(openssl passwd -crypt Senha123)

useradd carlos -m -s /bin/bash -p "$SENHA_PADRAO" -G GRP_ADM
useradd maria -m -s /bin/bash -p "$SENHA_PADRAO" -G GRP_ADM
useradd joao -m -s /bin/bash -p "$SENHA_PADRAO" -G GRP_ADM

useradd debora -m -s /bin/bash -p "$SENHA_PADRAO" -G GRP_VEN
useradd sebastiana -m -s /bin/bash -p "$SENHA_PADRAO" -G GRP_VEN
useradd roberto -m -s /bin/bash -p "$SENHA_PADRAO" -G GRP_VEN

useradd josefina -m -s /bin/bash -p "$SENHA_PADRAO" -G GRP_SEC
useradd amanda -m -s /bin/bash -p "$SENHA_PADRAO" -G GRP_SEC
useradd rogerio -m -s /bin/bash -p "$SENHA_PADRAO" -G GRP_SEC

echo "Especificando proprietários e permissões dos diretórios..."
chown root:GRP_ADM /adm
chown root:GRP_VEN /ven
chown root:GRP_SEC /sec
chown root:root /publico

chmod 770 /adm
chmod 770 /ven
chmod 770 /sec
chmod 777 /publico

echo "Provisionamento concluído com sucesso!"
