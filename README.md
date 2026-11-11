# Conecta Futuro

## Apresentação

O **Conecta Futuro** é uma plataforma educacional e social para conectar jovens de **18 a 24 anos** de **Canoinhas-SC e municípios próximos** a cursos gratuitos, capacitação profissional, orientação de carreira e oportunidades de primeiro emprego.

O problema social abordado é a dificuldade de encontrar, reunir e acessar formação, orientação e oportunidades de entrada no trabalho, especialmente entre jovens com menos acesso a redes profissionais. O projeto busca reduzir essa barreira organizando informações e caminhos de desenvolvimento. A disponibilidade real depende de ofertas verificadas e de parceiros confirmados.

**Objetivo:** conectar jovens a oportunidades gratuitas de educação e capacitação, orientação de carreira e primeiro emprego, com foco inicial em Canoinhas e expansão regional conforme a disponibilidade de ofertas reais.

**Público-alvo:** jovens de 18 a 24 anos. **Região:** Canoinhas-SC e municípios próximos, conforme a oferta confirmada.

O projeto se alinha ao **ODS 4 — Educação de Qualidade** (principal), **ODS 8 — Trabalho Decente e Crescimento Econômico** e **ODS 10 — Redução das Desigualdades**. Esse alinhamento é um objetivo de projeto; não representa impacto já comprovado.

## Tecnologias

- Next.js 15 e React 19.
- Supabase Auth com sessões seguras por cookie (`@supabase/ssr`).
- Supabase PostgreSQL com Row Level Security (RLS).
- ESLint 8 e TypeScript para qualidade estática.
- Nenhuma chave `service_role` é usada no front-end. O navegador usa somente a chave publicável/anon.

## Configurar Supabase e executar

1. Crie um projeto Supabase e copie `.env.example` para `.env.local`.
2. Preencha `NEXT_PUBLIC_SUPABASE_URL` e `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY` (ou a chave legada `NEXT_PUBLIC_SUPABASE_ANON_KEY`) com os dados de Project Settings → API. Não use `service_role` nessa chave.
3. No SQL Editor do Supabase, execute em ordem `supabase/migrations/202611040001_initial_schema.sql` e `supabase/migrations/202611040002_impact_dashboard.sql` (ou aplique as migrations pela Supabase CLI).
4. Em Authentication → URL Configuration, defina `http://localhost:3000` como Site URL e inclua `http://localhost:3000/**` em Redirect URLs. Adicione também os endereços do ambiente publicado.
5. Instale dependências com `npm install` e rode `npm run dev`.
6. Crie uma conta pela aplicação e confirme o e-mail se a confirmação estiver habilitada no projeto.
7. Para promover o primeiro administrador, execute no SQL Editor, substituindo o e-mail:

   ```sql
   update public.profiles
   set user_type = 'admin'
   where email = 'admin@seudominio.org';
   ```

   O nível de acesso não pode ser alterado pelo formulário ou pelo cliente autenticado. A promoção inicial é uma operação confiável feita no painel do banco.

Sem as variáveis Supabase, as páginas públicas usam conteúdo explicitamente demonstrativo; autenticação, painel e gravação exigem um projeto Supabase configurado e a migration aplicada. Não há seed de cursos/vagas fictícias no banco.

## Publicação para acesso pela internet

O caminho mais simples para este projeto é **GitHub + Vercel + Supabase**:

1. Envie o código para um repositório GitHub. O arquivo `.env.local` está no `.gitignore`; não o remova nem publique suas variáveis locais.
2. Na Vercel, importe o repositório GitHub como um projeto Next.js. A Vercel compila e publica cada atualização do repositório, gerando um endereço HTTPS público `*.vercel.app` que o professor pode abrir em qualquer dispositivo.
3. Em **Settings → Environment Variables** do projeto Vercel, configure `NEXT_PUBLIC_SUPABASE_URL` e `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY`. Use os valores do mesmo projeto Supabase ligado ao `.env.local`. Não configure nem publique a chave `service_role`.
4. Faça o deploy e copie o domínio público criado pela Vercel.
5. No Supabase, acesse **Authentication → URL Configuration**. Defina **Site URL** como o domínio Vercel e inclua `https://SEU-DOMINIO.vercel.app/**` em **Redirect URLs**. Mantenha também `http://localhost:3000/**` para desenvolvimento local.
6. Faça um novo deploy depois de alterar variáveis da Vercel. Teste cadastro, login, redefinição de senha e os catálogos no endereço público.

**GitHub Pages não atende este projeto no formato atual.** Pages publica arquivos estáticos; o Conecta Futuro usa rotas Next.js com renderização no servidor, middleware e sessão de autenticação. O Pages não executa esse servidor. Use o GitHub como repositório de código e a Vercel como hospedagem da aplicação.

Vercel Hobby e Supabase Free permitem uma demonstração sem custo dentro dos limites e termos dos planos. A conta Hobby da Vercel é restrita a uso pessoal/não comercial. O projeto Supabase Free pode ser pausado quando tiver pouca atividade por uma semana; nesse caso, o site continuará publicado, mas os dados/autenticação voltam a responder após reativar o projeto. Antes de usar com jovens reais ou para operação contínua, revise a política de privacidade e as condições dos planos.

### Alternativa Docker

Docker é opcional para executar o projeto localmente ou em um servidor que aceite containers. Ele não é necessário para publicar na Vercel e não substitui o Supabase: Auth, PostgreSQL e RLS continuam hospedados no projeto Supabase.

## Estrutura principal

```text
src/app/                 Rotas públicas, autenticação e painéis
src/components/          Navegação, formulários e dashboards
src/lib/supabase/        Clientes Supabase de navegador e servidor
src/middleware.ts        Atualização de sessão e proteção de rotas
supabase/migrations/     Schema PostgreSQL, RLS e agregações
tests/                   Verificações estáticas de contratos de segurança
```

## Comandos de qualidade

- `npm run lint`: regras Next.js/ESLint no código da aplicação.
- `npm run typecheck`: verificação TypeScript sem emitir arquivos.
- `npm test`: verificações estáticas para o schema e as regras de segurança; não substitui testes contra uma instância Supabase real.
- `npm run build`: compilação de produção.
- `npm audit`: auditoria das dependências do projeto.

## Banco de dados

A migration cria:

- `profiles`: perfil associado 1:1 a `auth.users`; trigger cria o perfil no cadastro. `user_type` é `user` por padrão.
- `courses` e `opportunities`: catálogo moderado por status (`draft`, `published`, `archived`), com cidade e modalidade. Apenas registros publicados são públicos.
- `user_courses` e `user_applications`: tabelas de relacionamento de usuários com cursos e oportunidades, únicas por par usuário/registro.
- `articles`: conteúdo editorial com status de publicação.
- `impact_metrics`: métricas administradas.
- `referrals`: encaminhamentos com estado `pending` ou `confirmed`; confirmação exige referência de comprovação, administrador responsável e data. Somente administradores podem consultar ou registrar encaminhamentos.

IDs usam UUID, referências têm `ON DELETE CASCADE` quando o registro dependente perde seu pai, listas de requisitos são `text[]`, prazos usam `date`, e status/modalidades têm `CHECK` constraints. Restrições únicas evitam inscrições e candidaturas duplicadas. Índices cobrem catálogos publicados e consultas por usuário. A função `get_admin_impact_dashboard()` expõe agregações calculadas somente a administradores; não armazena contagens simuladas.

## Segurança e sessões

- `src/middleware.ts` valida o usuário com `auth.getUser()`, atualiza cookies e protege `/painel` e `/admin`.
- As páginas protegidas também validam usuário e papel no servidor.
- RLS protege todas as tabelas. Perfis são lidos/editados pelo próprio usuário ou por administrador; permissões SQL impedem usuário comum de atualizar `user_type`.
- Usuários só leem e criam suas inscrições/candidaturas; a política exige curso/oportunidade publicada. Administradores podem acompanhar e atualizar status.
- Gerenciamento de cursos, oportunidades, artigos e métricas requer papel `admin` tanto na aplicação quanto nas políticas/RPC do banco.
- Cadastro, login, logout, recuperação e redefinição de senha usam Supabase Auth. Configure o SMTP do Supabase para entrega confiável de e-mails fora do ambiente de desenvolvimento.

## Funcionalidades conectadas

- Catálogos públicos de cursos e oportunidades leem registros publicados no banco quando Supabase está configurado. Detalhes mostram os registros reais; os exemplos locais permanecem marcados como demonstração.
- `/painel`: consulta e edição de dados próprios, inscrições em cursos, candidaturas e respectivos status, além de acesso ao criador de currículo.
- `/admin`: CRUD de cursos, oportunidades e artigos (remoção lógica por arquivamento), consulta de usuários e indicadores agregados.
- As candidaturas/inscrições sem URL externa são registradas internamente pelo usuário autenticado. Os dados e ofertas exibidos devem ser verificados antes da publicação.

## Indicadores calculados

`get_admin_impact_dashboard()` retorna totais, séries mensais de usuários/inscrições/candidaturas e distribuição de oportunidades publicadas por categoria e município. O painel compara os resultados com metas demonstrativas planejadas: 100 jovens cadastrados, 20 cursos, 30 oportunidades publicadas e 15 encaminhamentos comprovados. Metas nunca são adicionadas aos resultados. São contagens operacionais, não prova causal de impacto social. A tabela `impact_metrics` é reservada a métricas adicionais registradas manualmente e administradas.

## Privacidade

A tela atual `/privacidade` ainda tem texto do protótipo e deve ser revisada antes de operar com pessoas reais. Defina finalidade, retenção, canal do controlador, direitos dos titulares e consentimento apropriado antes da publicação. Evite coletar dados que não sejam necessários.
