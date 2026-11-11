# Documentação do uso de IA — Conecta Futuro

## Ferramenta

- OpenAI Codex no aplicativo desktop, usado como assistente de desenvolvimento para ler, editar e validar o código deste repositório.
- Ferramentas locais usadas na validação: Node.js/npm, Next.js, TypeScript, ESLint e `node:test`. Não foi usada uma ferramenta externa de geração de imagens nem outro assistente de IA neste trabalho registrado.

## Prompts e instruções recebidos

Esta documentação registra somente instruções que aparecem nesta conversa. Os itens abaixo são descrições fiéis do escopo solicitado; não são transcrições literais completas.

1. **Diretrizes do projeto Conecta Futuro:** Canoinhas-SC e municípios próximos; público de 18 a 24 anos; desenvolvimento educacional/social; ODS 4 principal, ODS 8 e 10 secundários; conectar jovens a cursos, capacitação, orientação profissional e primeiro emprego; meta de MVP navegável com dados, autenticação e indicadores.
2. **“PROMPT 3 — BACK-END, SUPABASE, BANCO DE DADOS E FUNCIONALIDADES”:** implementar Supabase Auth, PostgreSQL, RLS, controle de sessão, proteção de rotas, painéis de usuário e administrador, inscrições/candidaturas e documentação técnica, sem expor `service_role`.
3. **“PROMPT 4 — INDICADORES DE IMPACTO, ACESSIBILIDADE E RESPONSIVIDADE”:** calcular indicadores com dados reais, distinguir metas planejadas de resultados, criar gráficos, revisar acessibilidade e responsividade e relatar limitações.
4. **“PROMPT 5 — AUDITORIA FINAL, TESTES, DOCUMENTAÇÃO E PREPARAÇÃO PARA APRESENTAÇÃO”:** auditar fluxos, segurança e qualidade; atualizar README; documentar uso de IA; preparar pitch de aproximadamente três minutos; entregar matriz de status e limitações.

Não há registro, no contexto consultado, de prompts numerados 1 ou 2; portanto, não foram inventados nem incluídos.

## Etapas auxiliadas por IA

- Organização da implementação Next.js/Supabase e criação/revisão das migrations, tabelas, relacionamentos, políticas RLS, sessões e rotas administrativas.
- Implementação dos fluxos de cadastro, login, recuperação de senha, perfil, catálogo, inscrições e candidaturas.
- Implementação do painel administrativo, indicadores agregados, metas planejadas, distribuição por categoria/localidade e cadastro de encaminhamentos com referência de comprovação.
- Revisão de acessibilidade e responsividade no código, ajustes de estados de erro/sucesso e prevenção de redirecionamento externo após login.
- Configuração de lint/typecheck/testes estáticos e atualização da documentação técnica e acadêmica.

## Alterações e decisões manuais

- A pessoa usuária definiu o nome, a região, o público, os ODS, as metas acadêmicas e os requisitos funcionais por meio das mensagens acima.
- Não há registro de edição manual de código pelo autor do projeto nesta conversa. As alterações de código foram aplicadas pelo Codex em resposta às instruções da pessoa usuária.
- O Codex tomou decisões de implementação como manter as metas separadas dos resultados, contar somente encaminhamentos confirmados com referência e restringir esses registros à administração. Essas decisões estão refletidas no código e nas migrations.

## Problemas encontrados e resposta

- O comando inicial de lint chamava `next lint`, que abria um assistente interativo por falta de configuração. Foi substituído por ESLint configurado para Next.js, com comando não interativo.
- A auditoria de dependências apontou inicialmente vulnerabilidades moderadas em `minimatch`, incluído pela configuração de lint. A dependência transitiva foi fixada por override na versão corrigida; a auditoria final reportou zero vulnerabilidades.
- O ambiente não contém `.env.local` nem credenciais Supabase. As migrations não foram aplicadas a um banco remoto e os fluxos de autenticação, RLS e gravação não puderam ser testados contra uma instância real.
- As solicitações HTTP locais foram bloqueadas pelas permissões de socket do ambiente, mesmo com o servidor Next.js iniciado. Não foi possível confirmar respostas HTTP, erros de console ou fluxo visual real.
- A inspeção visual automatizada do navegador também foi interrompida pelo controle de segurança da ferramenta, que não conseguiu identificar com confiança a URL ativa. Foram revisados os estilos e breakpoints no código, mas não há validação visual manual registrada.

## Validações realizadas

- `npm run lint`: passou sem avisos na auditoria final.
- `npm run typecheck`: passou.
- `npm test`: passou com 5 testes estáticos de contrato do schema, RLS, prevenção de autopromoção, agregação administrativa, ambiente público e comportamento de rotas protegidas sem configuração.
- `npm run build`: compilação de produção passou.
- `npm audit`: reportou zero vulnerabilidades após o override.

Os testes de contrato leem os scripts SQL e o middleware; eles não executam PostgreSQL nem comprovam a aplicação efetiva de RLS. Não foi registrada validação humana navegando nas telas ou conferindo dados no Supabase.

## Limitações

- As funcionalidades que dependem do Supabase só podem ser consideradas ponta a ponta após configurar as variáveis, aplicar ambas as migrations e executar uma sessão de teste no projeto Supabase.
- Cadastro, login, e-mail de confirmação, redefinição de senha, permissões reais, CRUD, inscrições, candidaturas, indicadores e encaminhamentos não foram validados com uma conta real.
- Não foram realizados testes Lighthouse, testes de leitor de tela, avaliação manual de contraste, viewport visual, desempenho de rede ou publicação.
