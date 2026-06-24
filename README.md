# Radar Civil
Radar Cívil se trata de uma plataforma feita com o intuito de aumentar a consiência do cidadão sobre governantes eleitos.
Se trata de um feed de projetos propostos pela câmara dos deputados adiquiridos através da API "dados abertos" disponibilizada pela própria câmara no link: https://dadosabertos.camara.leg.br/swagger/api.html?tab=api
Design inicial presente no link: https://www.figma.com/design/gaD3C9uVO5pUTnsKC0u16Y/Projeto-Consci%C3%AAncia

# Integrantes
- Satie Kumeda Chirico - Design
- Miguel Sant'Ana Menezes - Desenvolvimento
- Pedro L. R. Greco - Revisão/Desenvolvimento
  
# Arquitetura e técnologias:
O projeto foi desenvolvido em Flutter e segue arquitetura definida em camadas, contendo uma camada de servidor e uma camada de aplicação conectadas pela API dados abertos

# Escopo
Projeto consiste no desenvolvimento do aplicativo Dados Abertos que possui o intuito de promover a consciência eleitoral, servindo como um *display* de projetos propostos por parlamentares;
O aplicativo tem como *landing page* a página principal consistindo em um feed de projetos composta por cards contendo informações essenciais sobre projetos propostos na câmara;

### Requisitos preliminares
**Página principal:**
- Feed com cards contendo foto do(s) parlamentar(es) autor(es) do projeto e nome do partido ao lado de seu nome, além de informaçõpes sobre a proposição
- Botão para uma página dedicada ao projeto

**Projeto:**
- Título do projeto de lei
- Nome do autor do projeto
- Partido do autor do projeto
- Botão "ver mais" que leva a uma página contendo as informações do projeto
- Botão para ver a página original do projeto no site da câmara dos deputados
