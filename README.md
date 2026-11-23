## Formação Linux Fundamentals.

<img width="120" height="120" alt="1000136618" src="https://github.com/user-attachments/assets/5bb3cd93-d51b-493e-9af3-e613f0574ead" />



---


## Estrutura de Pastas e Arquivos no GitHub:

```

linux-script-infraestrutura-como-codigo/
├── README.md
├── .gitignore
├── scripts/
│   ├── iac1.sh
│   └── criar_user.sh
└── docs/
    └── matriz-permissoes.md

```

---

# Infraestrutura como Código (IaC): Provisionamento de Usuários, Diretórios e Permissões no Linux

Projeto de automação em **Shell Script (Bash)** para provisionar de forma padronizada, repetível e versionada a estrutura inicial de usuários, grupos, diretórios departamentais e permissões em ambientes Linux.

---

## Visão Geral

Este projeto resolve o problema de configuração manual e inconsistente de ambientes Linux ao iniciar novas máquinas virtuais ou servidores. Por meio de scripts versionados no GitHub, toda a estrutura de acesso departamental (`/publico`, `/adm`, `/ven`, `/sec`), grupos (`GRP_ADM`, `GRP_VEN`, `GRP_SEC`) e contas de usuários é criada de forma automatizada e reprodutível.

---

## Problema e Contexto

Em ambientes corporativos ou laboratórios de sistemas operacionais, configurar manualmente usuários, grupos e permissões a cada nova instância gera:

- **Risco de erro humano:** digitação incorreta de nomes, grupos ou permissões (`chmod`/`chown`).
- **Inconsistência entre ambientes (drift):** servidores ou VMs configurados em momentos diferentes acabam com regras distintas.
- **Baixa velocidade de entrega:** perda de tempo repetindo comandos manuais em cada novo provisionamento.

### Premissas do Ambiente

- O provisionamento é executado em sistema operacional **Linux** com privilégios administrativos (`root` ou via `sudo`).
- A base de usuários e grupos departamentais segue o modelo definido para o projeto (`GRP_ADM`, `GRP_VEN`, `GRP_SEC` e diretórios `/publico`, `/adm`, `/ven`, `/sec`).
- As senhas iniciais geradas via `openssl passwd` são temporárias e devem ser alteradas em ambientes produtivos.
- Antes de executar o script principal em uma máquina já utilizada anteriormente, eventuais diretórios, arquivos, grupos e usuários conflitantes criados manualmente devem ser removidos ou tratados conforme o estado da VM.

---

## Objetivo do Projeto

Desenvolver uma solução prática de **Infraestrutura como Código (IaC)** aplicada à administração de sistemas Linux, consolidando o uso de **Bash Script**, controle de permissões (`chown` e `chmod`), gerenciamento de contas (`useradd`, `groupadd`, `passwd`) e versionamento no GitHub para reutilização em novas máquinas virtuais.

---

## Estratégia e Decisões Técnicas

1. **Automação via Bash Script em vez de execução manual:** centraliza os comandos em arquivos `.sh` executáveis e versionados, garantindo repetibilidade e rastreabilidade via Git.

2. **Isolamento por grupo com `chown` e `chmod 770`:** cada departamento (`GRP_ADM`, `GRP_VEN`, `GRP_SEC`) recebe permissão total (`rwx`) apenas no seu respectivo diretório (`/adm`, `/ven`, `/sec`), enquanto outros usuários e grupos ficam sem permissão (`---`).


3. **Área compartilhada controlada (`/publico` com `777`):** permite troca de arquivos ampla entre os usuários do sistema no diretório público, mantendo a separação restrita nos diretórios departamentais.

4. **Trade-offs considerados:**
   - *Simplicidade e portabilidade vs. ferramentas externas de IaC:* optou-se por **Bash puro** com utilitários nativos do Linux (`useradd`, `groupadd`, `chown`, `chmod`, `openssl`) pela zero dependência externa e rapidez na inicialização de VMs, em vez de introduzir ferramentas como Ansible ou Terraform neste escopo inicial.
     
   - *Senha criptografada via script vs. autenticação por chave SSH/IAM:* atende ao fluxo do laboratório com geração automatizada de hash de senha, assumindo o trade-off de exigir troca/reforço de credenciais em cenários reais de produção.

---

## Tecnologias Utilizadas

- **Linux** (ambiente de sistema operacional e administração)
- **Bash / Shell Script** (automação e provisionamento)
- **OpenSSL** (geração de hash de senha para criação de usuários)
- **Git e GitHub** (versionamento, documentação e reutilização do código)

---

## Como Executar o Projeto

### Pré-requisitos

- Sistema operacional **Linux**
- Acesso como `root` ou usuário com permissão `sudo`
- Utilitários `bash` e `openssl` instalados
- **Git** instalado para clonar o repositório

### Passos para execução

1. Clone o repositório:

   ```bash
   git clone [https://github.com/Santosdevbjj/linux-script-infraestrutura-como-codigo.git](https://github.com/Santosdevbjj/linux-script-infraestrutura-como-codigo.git)
   cd linux-script-infraestrutura-como-codigo

 * Conceda permissão de execução aos scripts:
   chmod +x scripts/iac1.sh scripts/criar_user.sh

 * Execute o script principal de infraestrutura como root:
   sudo ./scripts/iac1.sh

 * (Opcional) Execute o script de criação de usuários convidados com expiração de senha no primeiro login:
   sudo ./scripts/criar_user.sh

 * Valide a criação de diretórios e permissões:
   ls -ld /publico /adm /ven /sec
id carlos debora josefina


## Resultados e Aprendizados

 * Resultado obtido: infraestrutura de diretórios, grupos, usuários e permissões provisionada de forma automatizada e documentada, pronta para ser reaplicada em novas instâncias Linux.
 * Principais aprendizados:
   * Compreensão prática de como chown (usuário:grupo) e máscaras octais (770 e 777) impõem isolamento entre departamentos no Linux.
   * Importância de estruturar o repositório com clareza de contexto, decisões técnicas e documentação legível tanto para operação quanto para avaliação técnica.
   * O que faria diferente hoje: adicionar validações prévias de existência de usuários/grupos, parâmetros configuráveis e logs estruturados de execução.


## Próximos Passos:

 * Implementar validações de idempotência mais robustas para reexecuções seguras em ambientes já provisionados.
 * Criar um script de limpeza/rollback (cleanup.sh) para testes repetidos em máquinas virtuais descartáveis.
 * Parametrizar usuários, grupos e diretórios em arquivo de configuração externo para facilitar adaptações a novos cenários.

---

### Comandos Git para Subir no Repositório

Depois de criar os arquivos nas respectivas pastas dentro do diretório local do projeto, execute:

```bash
git init
git branch -M main
git remote add origin https://github.com/Santosdevbjj/linux-script-infraestrutura-como-codigo.git
git add .
git commit -m "feat: adiciona scripts de IaC para usuários, diretórios e permissões no Linux"
git push -u origin main

---


