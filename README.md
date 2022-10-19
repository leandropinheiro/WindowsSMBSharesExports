# WindowsSMBSharesExports

<h1>Porque?</h1>

Precisei fazer uma migração de Storage em um cliente.

Após fazer a migração dos dados do Volume do Storage antigo para o Novo, desmontar os Volumes angtigos, e montar os novos Volumes com as mesmas letras, o pessoal do SAP nos informou que alguns SMB Shares utilizados pelo SAP haviam sumido.

Criei este script para exportar a informação atual dos SMB Shares, e criar dois arquivos, um com a evidÊncia da configuração atual, e um script PS1 para recriar os Shares.
