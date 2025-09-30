# OpenTrials PostgreSQL Structure

Este repositório organiza os artefatos do banco de dados utilizado no futuro Registro Brasileiro de Ensaios Clínicos. O conteúdo foi estruturado para facilitar a manutenção de tabelas, procedures e dados de apoio.

## Organização de diretórios

- `database/tables/`: arquivos SQL contendo as definições de todas as tabelas, sequências e restrições.
- `database/procedures/`: funções PL/pgSQL extraídas do dump original.
- `database/populate/`: inserts e ajustes de sequência que povoam as tabelas.
- `scripts/`: utilitários Python (comentados em inglês) para aplicar as alterações e controlar versionamento.

## Scripts Python

Todos os scripts foram escritos por **Diego Tostes** e aceitam parâmetros via linha de comando:

- `scripts/create_tables.py`: executa os arquivos de `database/tables/` em ordem alfabética.
- `scripts/create_procedures.py`: aplica as funções definidas em `database/procedures/`.
- `scripts/populate_data.py`: insere os dados definidos em `database/populate/`.
- `scripts/schema_versioning.py`: calcula hashes dos arquivos SQL para detectar alterações e persistir metadados na tabela `schema_version`.

Os scripts utilizam `psycopg2` para conexão com PostgreSQL e carregam a configuração do banco por variáveis de ambiente (`DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASSWORD`, `DB_NAME`) ou por um arquivo JSON informado via `--config`.

### `scripts/schema_versioning.py`

O script percorre os diretórios informados, ordena os arquivos SQL encontrados e calcula, para cada um, um hash SHA-256 baseado no conteúdo do arquivo. Esses hashes são comparados com o histórico registrado na tabela `schema_version` para identificar arquivos novos ou modificados.

- Execução padrão: sem `--record`, o script apenas exibe quais alterações seriam aplicadas, permitindo uma revisão prévia.
- Execução com `--record`: além de exibir as alterações, grava o novo hash e metadados (arquivo, caminho, timestamp) na tabela `schema_version`.

Para configurar a conexão, utilize as variáveis de ambiente `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASSWORD` e `DB_NAME` ou passe um arquivo JSON com as chaves equivalentes via `--config caminho/para/config.json`.

### `scripts/create_tables.py`

Aceita o argumento opcional `--priority-prefix`, cujo padrão é `vocabulary_`, para garantir que os arquivos cujos nomes começam com o prefixo informado sejam executados antes dos demais. Isso assegura que tabelas de vocabulário sejam criadas antes das tabelas que dependem delas.

### Exemplos

```bash
python scripts/create_tables.py --priority-prefix vocabulary_
python scripts/create_procedures.py
python scripts/populate_data.py
python scripts/schema_versioning.py database/tables database/procedures database/populate
python scripts/schema_versioning.py database/tables database/procedures database/populate --record
```

## Dump original

O arquivo `dump_com_inserts.sql` permanece disponível como referência integral do estado inicial do banco.
