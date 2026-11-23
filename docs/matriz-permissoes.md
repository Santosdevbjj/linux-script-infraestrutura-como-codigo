# Matriz de Controle de Acesso e Diretórios

## Diretórios Provisionados

| Diretório | Dono (`owner`) | Grupo (`group`) | Permissão (`octal`) | Permissão Simbólica | Regra de Acesso |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `/publico` | `root` | `root` | `777` | `drwxrwxrwx` | Acesso total (leitura, escrita e execução) para todos os usuários do sistema. |
| `/adm` | `root` | `GRP_ADM` | `770` | `drwxrwx---` | Acesso total para `root` e membros de `GRP_ADM`; sem acesso para demais usuários. |
| `/ven` | `root` | `GRP_VEN` | `770` | `drwxrwx---` | Acesso total para `root` e membros de `GRP_VEN`; sem acesso para demais usuários. |
| `/sec` | `root` | `GRP_SEC` | `770` | `drwxrwx---` | Acesso total para `root` e membros de `GRP_SEC`; sem acesso para demais usuários. |

## Grupos e Usuários

| Grupo | Usuários Alocados | Shell Padrão | Diretório Home |
| :--- | :--- | :--- | :--- |
| `GRP_ADM` | `carlos`, `maria`, `joao` | `/bin/bash` | `/home/<usuario>` |
| `GRP_VEN` | `debora`, `sebastiana`, `roberto` | `/bin/bash` | `/home/<usuario>` |
| `GRP_SEC` | `josefina`, `amanda`, `rogerio` | `/bin/bash` | `/home/<usuario>` |
| *(Grupo primário padrão)* | `guest10`, `guest11`, `guest12`, `guest13` | `/bin/bash` | `/home/<usuario>` (troca de senha forçada no 1º login) |
