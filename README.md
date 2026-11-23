# Infraestrutura como Código (IaC) no Linux: Provisionamento Automatizado de Usuários, Grupos, Diretórios e Permissões

<img width="120" height="120" alt="Formação Linux Fundamentals" src="https://github.com/user-attachments/assets/5bb3cd93-d51b-493e-9af3-e613f0574ead" />

> **Formação Linux Fundamentals**: projeto de automação em **Bash** que transforma uma VM Linux recém-criada em um ambiente departamental pronto para uso, com um único comando.

---

## 1. Visão Geral

Todo novo servidor ou máquina virtual Linux precisa, antes de ser útil, de usuários, grupos, diretórios e permissões configurados. Fazer isso manualmente é lento e propenso a erros.

Este projeto resolve o problema com **scripts Bash versionados no GitHub**: ao executar o script, a estrutura de acesso departamental (`/publico`, `/adm`, `/ven`, `/sec`), os grupos (`GRP_ADM`, `GRP_VEN`, `GRP_SEC`) e as contas de usuários são criados de forma automática, padronizada e reaplicável em qualquer nova VM.

---

## 2. Problema de Negócio

Em ambientes corporativos e laboratórios, configurar usuários, grupos e permissões a cada nova instância gera:

- **Risco de erro humano:** nomes, grupos ou permissões (`chmod`/`chown`) digitados incorretamente.
- **Inconsistência entre ambientes (drift):** VMs configuradas em momentos diferentes acabam com regras diferentes.
- **Baixa velocidade de entrega:** tempo perdido repetindo os mesmos comandos a cada provisionamento.
- **Risco de segurança:** uma permissão errada num diretório departamental pode expor dados de um setor a outro.

---

## 3. Contexto

A empresa-modelo do projeto possui três departamentos, cada um com seu diretório restrito, além de uma área comum:

| Departamento | Grupo | Diretório |
| :--- | :--- | :--- |
| Administração | `GRP_ADM` | `/adm` |
| Vendas | `GRP_VEN` | `/ven` |
| Segurança | `GRP_SEC` | `/sec` |
| Todos | *(sem grupo dedicado)* | `/publico` |

Além dos nove usuários departamentais, o projeto cria quatro **usuários convidados** (`guest10` a `guest13`) com troca de senha obrigatória no primeiro login.

O detalhamento completo de donos, grupos e permissões está em [`docs/matriz-permissoes.md`](docs/matriz-permissoes.md).

---

## 4. Baseline: Como é Feito Hoje

**Cenário atual (manual):** o administrador acessa cada VM e digita os comandos um a um.

Para reproduzir a estrutura deste projeto manualmente, são necessários cerca de **32 comandos** por máquina:

| Tarefa | Comandos manuais |
| :--- | :---: |
| Criar diretórios (`mkdir`) | 4 |
| Criar grupos (`groupadd`) | 3 |
| Criar usuários (`useradd`) | 13 |
| Forçar troca de senha dos convidados (`passwd -e`) | 4 |
| Definir dono e grupo (`chown`) | 4 |
| Definir permissões (`chmod`) | 4 |
| **Total** | **32** |

**Meta da solução:** substituir esses 32 comandos por **2 execuções de script**, com o mesmo resultado em toda VM.

---

## 5. Objetivo do Projeto

Desenvolver uma solução prática de **Infraestrutura como Código (IaC)** aplicada à administração de sistemas Linux, consolidando:

- **Bash Script** para automação;
- gerenciamento de contas (`useradd`, `groupadd`, `passwd`);
- controle de permissões (`chown` e `chmod`);
- versionamento no GitHub para reutilização em novas máquinas virtuais.

---

## 6. Premissas e Limitações

- O provisionamento é executado em **Linux** com privilégios administrativos (`root` ou `sudo`).
- Os usuários, grupos e diretórios seguem o modelo definido para o projeto.
- A senha inicial (`Senha123`) é **temporária, de laboratório**, e não deve ser usada em produção.
- O script principal deve rodar em uma **VM limpa**: usuários, grupos ou diretórios conflitantes criados manualmente antes devem ser removidos. Reexecutar o `iac1.sh` na mesma máquina falha, porque o `useradd` não aceita usuários já existentes e o `set -e` interrompe a execução.
- O comando `openssl passwd -crypt` é um método legado e **não é suportado em versões recentes do OpenSSL (3.x)**. Em distribuições mais novas, é preciso trocá-lo por `openssl passwd -6` (SHA-512).
- Os diretórios `/publico` com `777` não usam *sticky bit*, ou seja, qualquer usuário pode apagar arquivos de outro nessa pasta.

---

## 7. Estratégia da Solução e Decisões Técnicas

### Estrutura de Pastas

```
linux-script-infraestrutura-como-codigo/
├── README.md
├── LICENSE
├── .gitignore
├── scripts/
│   ├── iac1.sh            # Diretórios, grupos, usuários departamentais e permissões
│   └── criar_user.sh      # Usuários convidados com troca de senha no 1º login
└── docs/
    └── matriz-permissoes.md
```

### Fluxo de execução

1. **`iac1.sh`**: cria os diretórios (`mkdir -p`), os grupos (`groupadd -f`), os nove usuários departamentais já associados aos grupos (`useradd -G`), e aplica donos e permissões (`chown` / `chmod`).
2. **`criar_user.sh`** *(opcional)*: cria `guest10` a `guest13` e força a troca de senha no primeiro acesso (`passwd -e`).

### Decisões e trade-offs

1. **Bash puro em vez de Ansible ou Terraform:** usa apenas utilitários nativos (`useradd`, `groupadd`, `chown`, `chmod`, `openssl`), sem dependências externas e com inicialização rápida em VMs. O custo é perder recursos como idempotência nativa e gerenciamento de estado, aceitável para o escopo inicial.

2. **Isolamento por grupo com `chown` e `chmod 770`:** cada grupo (`GRP_ADM`, `GRP_VEN`, `GRP_SEC`) tem acesso total (`rwx`) apenas ao seu diretório; os demais usuários ficam sem nenhuma permissão (`---`).

3. **Área compartilhada com `777` em `/publico`:** facilita a troca de arquivos entre todos, enquanto os diretórios departamentais continuam restritos. O custo é menos controle sobre quem altera ou apaga o quê.

4. **Senha com hash gerado por script em vez de chave SSH/IAM:** atende ao fluxo do laboratório, com geração automatizada de hash. Em produção, exigiria troca de credenciais ou autenticação mais forte.

5. **`set -e` nos scripts:** interrompe a execução no primeiro erro, evitando um provisionamento parcialmente configurado sem aviso.

---

## 8. Tecnologias Utilizadas

- **Linux**: ambiente de execução e administração de sistemas
- **Bash / Shell Script**: automação do provisionamento
- **OpenSSL**: geração do hash da senha inicial dos usuários
- **Git e GitHub**: versionamento, documentação e reutilização do código

---

## 9. Como Executar o Projeto

### Pré-requisitos

- Sistema operacional **Linux** (preferencialmente uma VM limpa)
- Acesso como `root` ou usuário com `sudo`
- `bash` e `openssl` instalados
- **Git** para clonar o repositório

### Passo a passo

1. Clone o repositório:

   ```bash
   git clone https://github.com/Santosdevbjj/linux-script-infraestrutura-como-codigo.git
   cd linux-script-infraestrutura-como-codigo
   ```

2. Conceda permissão de execução aos scripts:

   ```bash
   chmod +x scripts/iac1.sh scripts/criar_user.sh
   ```

3. Execute o script principal de infraestrutura:

   ```bash
   sudo ./scripts/iac1.sh
   ```

4. *(Opcional)* Crie os usuários convidados, que terão de trocar a senha no primeiro login:

   ```bash
   sudo ./scripts/criar_user.sh
   ```

### Validação

Confirme diretórios, donos e permissões:

```bash
ls -ld /publico /adm /ven /sec
```

Resultado esperado:

```
drwxrwxrwx root root    /publico
drwxrwx--- root GRP_ADM /adm
drwxrwx--- root GRP_VEN /ven
drwxrwx--- root GRP_SEC /sec
```

Confirme os grupos dos usuários:

```bash
id carlos debora josefina
```

---

## 10. Insights e Resultados

- **Resultado obtido:** estrutura completa de diretórios, grupos, usuários e permissões provisionada de forma automática e documentada, pronta para ser reaplicada em novas instâncias Linux.
- **Ganho operacional:** 32 comandos manuais substituídos por 2 execuções de script.
- **Ganho de padronização:** toda VM nasce com as mesmas regras, o que elimina o drift entre ambientes.
- **Ganho de segurança:** o isolamento departamental é imposto pelo sistema operacional (`770`), sem depender da disciplina de cada usuário.

---

## 11. Aprendizados

- **Permissões na prática:** entendi como `chown` (`usuário:grupo`) combinado com máscaras octais (`770` e `777`) impõe isolamento entre departamentos.
- **Documentação como parte da entrega:** um repositório com contexto, decisões e matriz de permissões é legível tanto para quem opera quanto para quem avalia.
- **Limites do Bash puro:** na prática, a falta de idempotência e o uso do `openssl passwd -crypt` (legado) mostraram onde o script precisa evoluir.
- **O que faria diferente hoje:** validar se usuários e grupos já existem antes de criá-los, parametrizar os nomes e registrar logs estruturados da execução.

---

## 12. Próximos Passos

- [ ] Tornar o script **idempotente**, verificando a existência de usuários e grupos antes de criá-los (`id`, `getent`), para permitir reexecuções seguras.
- [ ] Substituir `openssl passwd -crypt` por `openssl passwd -6` (SHA-512), compatível com versões atuais do OpenSSL.
- [ ] Criar um script de limpeza/rollback (`cleanup.sh`) para testes repetidos em VMs descartáveis.
- [ ] Parametrizar usuários, grupos e diretórios em um arquivo de configuração externo.
- [ ] Adicionar *sticky bit* em `/publico` (`chmod 1777`) para impedir que um usuário apague arquivos de outro.
- [ ] Gerar logs estruturados da execução.
- [ ] Avaliar a migração para Ansible quando o número de servidores justificar.

---

## Licença

Distribuído sob a licença **MIT**. Consulte o arquivo [`LICENSE`](LICENSE).

---

**Autor:** Sérgio Santos: Cientista de Dados | Ambientes Críticos e Governança de Dados

[![Portfólio Sérgio Santos](https://img.shields.io/badge/Portfólio-Sérgio_Santos-111827?style=for-the-badge&logo=githubpages&logoColor=00eaff)](https://portfoliosantossergio.vercel.app)
[![LinkedIn Sérgio Santos](https://img.shields.io/badge/LinkedIn-Sérgio_Santos-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white)](https://linkedin.com/in/santossergioluiz)
