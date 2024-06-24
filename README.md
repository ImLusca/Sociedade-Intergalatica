# Projeto Final - Laboratório de Bases de Dados

## Descrição do Projeto

Projeto com fins educativos para a matéria de Laborátorio de Base de Dados - SCC0241 ministrado na USP - ICMC.<br>
Nesse projeto foi desenvolvido um sistema de gerenciamento para a Sociedade Galáctica, esse sistema se baseia em uma interface gráfica onde os usuários podem gerenciar e gerar relatórios sobre as informações da Sociedade Galáctica que são armazenados em uma base de dados que foi projetada com base no material passado em aula.

## Como rodar?

Back-End
1. cd back-end
2. cd Sociedade
3. ./Scripts/activate (no windows para entrar na venv)
4. cd ../sociedadeInter
5. pip install requirements
6. python run.py

Front-End
1. cd back-end
2. npm install
3. npm run dev

## Ferramentas Utilizadas

- **SGBD:** Oracle 19C
- **Linguagem de Programação:** Python e React
- **Integração com Base de Dados:** API para Oracle (ex: `python-oracledb`, `OCCI`)

## Estrutura do Banco de Dados

A base de dados contém informações sobre corpos celestes, espécies, comunidades, nações, federações, facções, e líderes.

![image](https://github.com/ImLusca/Sociedade-Intergalatica/assets/80288516/26c34919-e976-4d0f-ba6f-b602c05b0c5a)

## Funcionalidades

### Gerenciamento

1. **Líder de Facção:**
   - Gerenciar a própria facção (alterar nome, indicar novo líder, credenciar comunidades novas).
   - Remover facção de Nação.

2. **Oficial:**
   - Não pode alterar nada na base.

3. **Comandante:**
   - Alterar aspectos da própria nação (incluir/excluir federação, criar nova federação).
   - Inserir nova dominância de um planeta.

4. **Cientista:**
   - Gerenciar (CRUD) estrelas, planetas e sistemas.

### Relatórios

1. **Líder de Facção:**
   - Informações sobre comunidades da própria facção (agrupamento por nação, espécie, planeta, sistema).

2. **Oficial:**
   - Informações de habitantes da própria nação (monitoramento de crescimento e deslocamento populacional).

3. **Comandante:**
   - Informações de planetas dominados e de potencial dominação (informações estratégicas, filtros de distância).

4. **Cientista:**
   - Informações de estrelas, planetas e sistemas (análise de grupos de sistemas, prevalência ou correlação de características específicas).
   - Monitoramento de informações de planetas ao longo do tempo
   - Análise de grupos de sistemas próximos e otimização do cálculo de distâncias entre estrelas

## Comentários para a correção
1. Foi considerado que nos campos onde temos data de início e data de fim a data de fim tem que estar como Null para ser entendida que o evento ainda está ocorrendo.

## Estrutura de Interfaces

1. **Interface de Login:**
   - Autenticação do usuário.

2. **Interface de Overview:**
   - Apresentação do nome de usuário autenticado e informações de overview.

3. **Interface de Relatórios:**
   - Exibição de relatórios de acordo com o usuário logado.

## Arquivos
   - back-end - Arquivos do backend da aplicação onde se tem a comunicação do front com o banco de dados
   - front-end - Arquivos do frontend para gerar intarface da aplicação
   - banco-end/pacotes/app_user_security.sql - Scripts para gerenciamento de login dos usuários, como checagem, criação de hash para as senhas...
   - banco-end/pacotes/gerenciamento_cientista.sql - Scripts para funcionalidades de gerenciamento para os cientistas
   - banco-end/pacotes/gerenciamento_comandante.sql - Scripts para funcionalidades de gerenciamento para os comandantes
   - banco-end/pacotes/gerenciamento_lider.sql - Scripts para funcionalidades de gerenciamento para os lideres
   - banco-end/pacotes/relatorio_cientista.sql - Scripts para funcionalidades gerar relatórios para os cientistas
   - banco-end/pacotes/relatorio_comandante.sql - Scripts para funcionalidades gerar relatórios para os comandantes
   - banco-end/pacotes/relatorio_lider.sql - Scripts para funcionalidades gerar relatórios para os lideres
   - banco-end/pacotes/relatorio_oficial.sql - Scripts para funcionalidades gerar relatórios para os oficiais
   - banco-end/view/view.sql - Script de geração das views utilizadas
   - banco-end/indices/index.sql - Script de indices utilizados
   - banco-end/tabelas/tabelas.sql - Scripts das tabelas adicionais criadas para administrar usuário
   - banco-end/triggers/triggers.sql - Scripts dos scripts dos triggers utilizados no projeto

## Contribuidores

- Théo Bruno Frey Riffel - 12547812
- lucas pereira pacheco - 12543930
- Pedro Dias Batista - 10769809


---

**Professora:** Elaine Parros Machado de Sousa  
**Estagiários PAE:** Afonso Matheus Sousa Lima / André Moreira Souza
