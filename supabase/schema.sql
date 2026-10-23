-- CSI Meetpar Yesu Alayam — WhatsApp Automation Centre
-- Run this file in Supabase Dashboard > SQL Editor > New query.
-- This creates tables for the WhatsApp Centre only; it does not alter the Birthday Register project.

create extension if not exists pgcrypto;

create table if not exists public.church_contacts (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(trim(name)) between 1 and 120),
  phone text not null check (phone ~ '^[0-9]{8,15}$'),
  birthday date,
  anniversary date,
  language text not null default 'ta' check (language in ('ta','en')),
  whatsapp_consent boolean not null default false,
  consent_updated_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.message_logs (
  id uuid primary key default gen_random_uuid(),
  recipient_name text,
  recipient_phone text,
  message_type text not null default 'manual_draft',
  status text not null default 'draft_created',
  details text,
  created_at timestamptz not null default now(),
  created_by uuid references auth.users(id) on delete set null
);

create index if not exists church_contacts_name_idx on public.church_contacts (name);
create index if not exists church_contacts_phone_idx on public.church_contacts (phone);
create index if not exists message_logs_created_at_idx on public.message_logs (created_at desc);

alter table public.church_contacts enable row level security;
alter table public.message_logs enable row level security;

-- Starter policies: authenticated project users share this church register.
-- Only create accounts for trusted church users. Restrict policies further before wider rollout.
drop policy if exists "Authenticated users can read church contacts" on public.church_contacts;
create policy "Authenticated users can read church contacts"
  on public.church_contacts for select to authenticated using (true);
drop policy if exists "Authenticated users can add church contacts" on public.church_contacts;
create policy "Authenticated users can add church contacts"
  on public.church_contacts for insert to authenticated with check (true);
drop policy if exists "Authenticated users can update church contacts" on public.church_contacts;
create policy "Authenticated users can update church contacts"
  on public.church_contacts for update to authenticated using (true) with check (true);
drop policy if exists "Authenticated users can delete church contacts" on public.church_contacts;
create policy "Authenticated users can delete church contacts"
  on public.church_contacts for delete to authenticated using (true);

drop policy if exists "Authenticated users can read message logs" on public.message_logs;
create policy "Authenticated users can read message logs"
  on public.message_logs for select to authenticated using (true);
drop policy if exists "Authenticated users can add message logs" on public.message_logs;
create policy "Authenticated users can add message logs"
  on public.message_logs for insert to authenticated with check (true);
drop policy if exists "Authenticated users can update message logs" on public.message_logs;
create policy "Authenticated users can update message logs"
  on public.message_logs for update to authenticated using (true) with check (true);
drop policy if exists "Authenticated users can delete message logs" on public.message_logs;
create policy "Authenticated users can delete message logs"
  on public.message_logs for delete to authenticated using (true);

grant usage on schema public to authenticated;
grant select, insert, update, delete on public.church_contacts to authenticated;
grant select, insert, update, delete on public.message_logs to authenticated;
