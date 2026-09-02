-- =====================================================================
-- Sistema de Cadastro do Cidadão — UBS
-- Schema para o Supabase (SQL Editor → New query → cole tudo e rode)
-- =====================================================================

-- ---------- Agentes Comunitários de Saúde (ACS) ----------
create table if not exists public.agentes (
  id         text primary key,
  nome       text not null,
  area       text,
  microarea  text,
  criado_em  timestamptz not null default now()
);

-- ---------- Logradouros cadastrados ----------
create table if not exists public.logradouros (
  id         text primary key,
  logradouro text not null,
  bairro     text,
  cep        text,
  cidade     text,
  uf         text,
  estado     text,
  acs_id     text references public.agentes(id),
  criado_em  timestamptz not null default now()
);

-- ---------- Cidadãos (registro único por CPF) ----------
create table if not exists public.cidadaos (
  id            text primary key,
  nome          text not null,
  cpf           text not null unique,
  logradouro    text,
  numero        text,
  complemento   text,
  bairro        text,
  cidade        text,
  uf            text,
  estado        text,
  cep           text,
  acs           text,
  area          text,
  microarea     text,
  logradouro_id text references public.logradouros(id),
  atualizado_em timestamptz not null default now()
);

-- ---------- Histórico de declarações de residência emitidas ----------
create table if not exists public.declaracoes (
  id            text primary key,
  nome          text not null,
  cpf           text not null,
  logradouro    text,
  numero        text,
  complemento   text,
  bairro        text,
  cidade        text,
  uf            text,
  estado        text,
  cep           text,
  acs           text,
  area          text,
  microarea     text,
  logradouro_id text,
  data          timestamptz not null default now(),
  emissor_nome    text,
  emissor_funcao  text,
  emissor_cpf     text
);

-- Caso a tabela 'declaracoes' já exista em um banco publicado anteriormente,
-- rode também o alter abaixo para adicionar os campos do emissor:
alter table public.declaracoes add column if not exists emissor_nome text;
alter table public.declaracoes add column if not exists emissor_funcao text;
alter table public.declaracoes add column if not exists emissor_cpf text;

-- ---------- Catálogo de medicamentos (autocompletar) ----------
create table if not exists public.medicamentos (
  id        text primary key,
  nome      text not null unique,
  criado_em timestamptz not null default now()
);

-- ---------- Histórico de renovações de receita (prontuário por medicamento) ----------
create table if not exists public.renovacoes (
  id              text primary key,
  nome            text not null,
  cpf             text not null,
  acs_id          text,
  acs_nome        text,
  medicamento     text not null,
  quantidade      text,
  dose            text,
  posologia       text,
  data_renovacao  date,
  data_registro   timestamptz not null default now()
);
create index if not exists renovacoes_cpf_idx on public.renovacoes (cpf);

-- ---------- Configuração da unidade (uma única linha, id = 1) ----------
create table if not exists public.configuracao (
  id           int primary key default 1,
  nome_unidade text,
  cnes         text,
  logradouro   text,
  numero       text,
  complemento  text,
  bairro       text,
  cidade       text,
  uf           text,
  responsavel  text,
  registro     text,
  assinatura   text,
  constraint configuracao_singleton check (id = 1)
);

-- =====================================================================
-- Segurança: exige login (RLS) — só usuários autenticados leem/gravam
-- =====================================================================
alter table public.agentes      enable row level security;
alter table public.logradouros  enable row level security;
alter table public.cidadaos     enable row level security;
alter table public.declaracoes  enable row level security;
alter table public.medicamentos enable row level security;
alter table public.renovacoes   enable row level security;
alter table public.configuracao enable row level security;

create policy "acesso_autenticado" on public.agentes      for all to authenticated using (true) with check (true);
create policy "acesso_autenticado" on public.logradouros  for all to authenticated using (true) with check (true);
create policy "acesso_autenticado" on public.cidadaos     for all to authenticated using (true) with check (true);
create policy "acesso_autenticado" on public.declaracoes  for all to authenticated using (true) with check (true);
create policy "acesso_autenticado" on public.medicamentos for all to authenticated using (true) with check (true);
create policy "acesso_autenticado" on public.renovacoes   for all to authenticated using (true) with check (true);
create policy "acesso_autenticado" on public.configuracao for all to authenticated using (true) with check (true);
