#!/bin/bash

set -e

echo "Criando usuários convidados do sistema..."

SENHA_CONVIDADO=$(openssl passwd -crypt Senha123)

useradd guest10 -c "Usuário convidado" -s /bin/bash -m -p "$SENHA_CONVIDADO"
passwd guest10 -e

useradd guest11 -c "Usuário convidado" -s /bin/bash -m -p "$SENHA_CONVIDADO"
passwd guest11 -e

useradd guest12 -c "Usuário convidado" -s /bin/bash -m -p "$SENHA_CONVIDADO"
passwd guest12 -e

useradd guest13 -c "Usuário convidado" -s /bin/bash -m -p "$SENHA_CONVIDADO"
passwd guest13 -e

echo "Finalizado!"
