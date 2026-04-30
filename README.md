# Radar Civil
Radar Cívil se trata de uma plataforma feita com o intuito de aumentar a consiência do cidadão sobre aqueles que nos regem.
Se trata de um feed de projetos propostos pela câmara dos deputados adiquiridos através da API "dados abertos" disponibilizada pela própria câmara no link: https://dadosabertos.camara.leg.br/swagger/api.html?tab=api

# Arquitetura e técnologias:
O aplicativo será desenvolvido em React e será públicado na Android Play Store.
...
Não encontramos uma API para um banco de imagens, mas existe uma página de banco de imagens no Link: https://www.camara.leg.br/banco-imagens
...
Será construido em camadas, uma camada visual, uma camada de domínio e uma camada de dados. A camada de dados consiste na própria api "Dados abertos" Refêrenciada acima.

# Escopo

Projeto para desenvolvimento de um aplicativo com intuito de aumentar a consciência dos eleitores sobre os projetos propostos por seus parlamentares;

O projeto consiste em uma página, estilo feed de notícias, com cards contendo informações essenciais sobre projetos propostos na câmara;

O projeto depende da API RESTFUL “Dados abertos” do governo federal;

### Requisitos preliminares

**Página principal:**

- Feed com card contendo foto da pessoa que fez o projeto e foto do partido ao lado, embaixo o texto e as informações
- Ao clicar entra no link do projeto oficial
- Projetos dos últimos 4 anos ou desde a última eleição

**Projeto:**

- Título do projeto de lei
- Nome do autor do projeto
- Partido do autor do projeto
- Botão "ver mais" que leva a uma página contendo as informações do projeto
- Botão de compartilhar
- Botão de salvar
- Notificação push quando for proposto um novo projeto

### Afazeres relativos a páginas:

- MVP (primeiro semestre):
    - Design
    - Landing page com feed de projetos organizados por data de publicação:
        - ligação com API;
        - Definição de como coletar imagens;
        - Criação de templates para cards;
        - Rederização em lista;
    - Página de projetos sendo acompanhados pelo usuário:
        - Definir como serão armazenadas as referências do projeto salvo;
    - Página do projeto com informações e texto completo do projeto:
        - Template com base no design definido;
