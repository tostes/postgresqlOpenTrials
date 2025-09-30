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

### Exemplo de uso

```bash
python scripts/create_tables.py
python scripts/create_procedures.py
python scripts/populate_data.py
python scripts/schema_versioning.py database/tables database/procedures database/populate --record
```

## Dump original

O arquivo `dump_com_inserts.sql` permanece disponível como referência integral do estado inicial do banco.
