# **Documentação Negocial e Técnica \- Radar Civil**

**Instituição:** Centro Universitário de Brasília (CEUB) \- Faculdade de Tecnologia e Ciências Sociais Aplicadas  

24 de junho de 2026  
 

## 1\. Visão Geral do Negócio (Documentação Negocial)

### 1.1 Objetivo do Projeto

O **Radar Civil** é um aplicativo que tem como objetivo trazer mais consciência política para o dia a dia do cidadão brasileiro. A plataforma consiste em um feed de notícias focado em apresentar os projetos de lei propostos pela Câmara dos Deputados de maneira acessível, transparente e organizada.

### 1.2 Problema e Oportunidade

Conforme destacado pelo Tribunal Superior Eleitoral (TSE), o voto consciente depende diretamente do acesso a informações confiáveis sobre o funcionamento do sistema político, propostas e candidatos. A ausência ou a dificuldade de acesso a esse conhecimento pode resultar em escolhas eleitorais pouco fundamentadas, prejudicando a qualidade da representação política. O Radar Civil surge como uma ferramenta essencial para combater a desinformação e facilitar o acesso a dados governamentais oficiais.

### 1.3 Público-Alvo

O aplicativo é destinado a todos os cidadãos brasileiros. 

### 1.4 Benefícios Esperados

* Fortalecimento da consciência eleitoral através do acesso facilitado a informações oficiais e atualizadas da Câmara.  
* Redução da dependência de fontes informais, opiniões de terceiros ou redes sociais potencialmente desinformativas.  
* Incentivo a uma postura crítica e informada, resultando em decisões eleitorais muito mais conscientes.  
* Maior transparência sobre o alinhamento entre os representantes eleitos e os interesses práticos da população.

## 2\. Escopo e Requisitos do Produto

### 2.1 Funcionalidades Principais:

O aplicativo Radar Civil deve garantir que o usuário seja capaz de realizar as seguintes interações em sua interface baseada em "feed":

* **Visualização de Autoria:** Identificar instantaneamente o(a) autor(a) do projeto de lei e o seu respectivo partido político no cabeçalho do card.  
* **Identificação do Projeto e Tema:** Visualizar o título oficial do projeto e a área temática/setor da sociedade que ele afeta (dados classificados e extraídos diretamente da API).  
* **Acompanhamento de Status:** Verificar a situação atual de tramitação (status) do projeto de lei de forma simplificada.  
* **Resumo Informativo:** Ler um resumo claro, objetivo e de rápido consumo do texto do projeto de lei diretamente na tela principal do feed.  
* **Leitura na Íntegra:** Abrir uma página ou modal interno contendo o texto completo e a redação original da proposição para análises mais profundas.  
* **Redirecionamento Oficial:** Acessar um link de saída seguro para a página oficial do projeto no portal web da Câmara dos Deputados.

## 3\. Documentação Técnica

### 3.1 Arquitetura e Tecnologias:e

* **Frontend/Mobile App:** O aplicativo será desenvolvido utilizando o framework **Flutter** (Dart). A escolha garante alta performance, uma interface de usuário rica, fluida, reativa e alinhada ao design visual idealizado nos protótipos.  
* **Plataforma Alvo Inicial:** O sistema tem como foco primário o lançamento para o sistema operacional **Android**.  
* **Fonte de Dados (Backend via API de Terceiros):** O aplicativo não possuirá um banco de dados próprio para a listagem das leis. Ele operará consumindo informações em tempo real por meio da **API RESTful de Dados Abertos**, mantida e disponibilizada pela própria Câmara dos Deputados do Brasil.

### 3.2 Mapeamento de Integração de Dados

A tabela abaixo detalha como os requisitos funcionais da interface mapeiam diretamente para o consumo da API:

| Requisito do Aplicativo | Origem Sugerida (API Câmara dos Deputados) | Descrição da Integração Técnica |
| :---- | :---- | :---- |
| Autor(a) e Partido | Endpoint /proposicoes/{id}/autores | Busca do nome parlamentar, URI da foto do deputado, sigla do partido e UF associada à proposição específica. |
| Título e Área Afetada | Endpoint /proposicoes/{id}/temas | Extração da ementa (título resumo) e das tags/áreas temáticas indexadas pelos sistemas legislativos. |
| Status do Projeto | Endpoint /proposicoes/{id}/tramitacoes | Captura do último evento no array de andamentos para exibir a situação atual (ex: "Aguardando Parecer", "Pronto para Pauta"). |
| Resumo do Texto | Endpoint /proposicoes | Utilização do campo ementaDetalhada para compor o bloco principal de texto do card no feed. |
| Texto Completo | Endpoint /proposicoes/{id} (Inteiro Teor) | Requisição da URL do documento de inteiro teor (geralmente em formato PDF ou RTF) para renderização no app. |
| Link Oficial | Endpoint /proposicoes/{id} | Uso do campo url retornado no payload principal para uso em um widget de WebView ou navegador externo. |

## 4\. Informações do Projeto Acadêmico

* **Integrantes:**  
  - Satie Kumeda Chirico      - Designer
  - Miguel Sant'Ana Menezes   - Desenvolvedor Fullstack
  - Pedro L. R. Greco         - Revisão e Documentação 

* **Orientação Acadêmica:** Prof. Dr. Tiago Leite Pereira