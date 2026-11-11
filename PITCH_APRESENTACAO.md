# Pitch acadêmico — Conecta Futuro (aprox. 3 minutos)

Olá. Este é o **Conecta Futuro**, uma proposta de plataforma educacional e social que aproxima jovens de oportunidades para estudar, se desenvolver e iniciar a vida profissional.

O problema que queremos enfrentar é a dificuldade de encontrar, em um só lugar, cursos gratuitos, capacitação, orientação de carreira e oportunidades de primeiro emprego. Essa fragmentação pode pesar ainda mais para jovens que têm menos acesso a redes de contato e informação profissional.

Nosso público são jovens de 18 a 24 anos. O foco inicial é Canoinhas, em Santa Catarina, com possibilidade de incluir municípios próximos conforme existam cursos, instituições, projetos sociais e oportunidades que possam ser verificados.

O projeto tem como referência principal o **ODS 4, Educação de Qualidade**, e também se relaciona ao **ODS 8, Trabalho Decente e Crescimento Econômico**, e ao **ODS 10, Redução das Desigualdades**. Esses objetivos orientam o projeto; ainda não são resultados de impacto comprovados.

Na demonstração, a pessoa pode explorar cursos e oportunidades, acessar conteúdos de orientação, criar um currículo e preparar uma versão para impressão em PDF. Com o Supabase configurado, o fluxo inclui criação de conta, login, recuperação de senha, edição de perfil, inscrição em cursos e registro de candidaturas. A administração pode gerenciar cursos, oportunidades e artigos, acompanhar candidaturas e registrar encaminhamentos profissionais somente quando houver referência de comprovação.

O sistema foi construído com Next.js, React, TypeScript, Supabase Auth e PostgreSQL. As tabelas usam relacionamentos e políticas RLS; as rotas do usuário e da administração verificam sessão e permissão. O painel calcula resultados a partir dos registros do banco e os compara com metas de planejamento: 100 jovens, 20 cursos, 30 oportunidades e 15 encaminhamentos. As metas não são contadas como resultados, e o protótipo não apresenta números fictícios como impacto real.

Na validação técnica realizada, lint, verificação TypeScript, cinco testes estáticos de segurança/schema, auditoria de dependências e compilação de produção passaram. Porém, ainda não conectamos esta cópia a um projeto Supabase real. Portanto, cadastro, gravação, RLS e indicadores precisam de validação ponta a ponta. Também faltam testes visuais em dispositivos, avaliação com leitores de tela e validação de conteúdo com jovens e parceiros locais.

Os próximos passos são configurar o Supabase e aplicar as migrations, testar os fluxos com contas de usuário e administrador, cadastrar apenas ofertas verificadas, conduzir testes de acessibilidade e usabilidade com o público-alvo e, então, acompanhar inscrições, candidaturas e encaminhamentos confirmados. O Conecta Futuro está preparado como MVP demonstrável, com essas limitações declaradas e um caminho claro para validação em campo.
