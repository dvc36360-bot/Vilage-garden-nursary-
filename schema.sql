-- JACT MOTORCYCLE - SUPABASE DATABASE SETUP
-- Safe to run on the existing JACT project. This script does NOT delete table data.
-- Run the ENTIRE file once in Supabase Dashboard -> SQL Editor -> New query.

create extension if not exists pgcrypto;

-- 1) TABLES
create table if not exists public.admin_users (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text,
  price numeric(10,2) not null default 0,
  stock integer not null default 0,
  image_url text,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.bookings (
  id uuid primary key default gen_random_uuid(),
  customer_name text not null,
  phone text not null,
  email text,
  service_type text not null,
  bike_make text not null,
  bike_model text,
  preferred_date date not null,
  preferred_time text,
  location text,
  details text not null,
  status text not null default 'pending',
  created_at timestamptz not null default now()
);

create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  customer_name text not null,
  customer_phone text not null,
  notes text,
  total numeric(10,2) not null default 0,
  status text not null default 'new',
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete cascade,
  product_id uuid references public.products(id) on delete set null,
  product_name text not null,
  quantity integer not null,
  unit_price numeric(10,2) not null,
  created_at timestamptz not null default now()
);

-- 2) ADD ANY MISSING COLUMNS TO TABLES THAT ALREADY EXIST
-- IF NOT EXISTS means existing data/columns are kept.
alter table public.admin_users add column if not exists created_at timestamptz not null default now();

alter table public.products add column if not exists name text;
alter table public.products add column if not exists description text;
alter table public.products add column if not exists price numeric(10,2) not null default 0;
alter table public.products add column if not exists stock integer not null default 0;
alter table public.products add column if not exists image_url text;
alter table public.products add column if not exists active boolean not null default true;
alter table public.products add column if not exists created_at timestamptz not null default now();
alter table public.products add column if not exists updated_at timestamptz not null default now();

alter table public.bookings add column if not exists customer_name text;
alter table public.bookings add column if not exists phone text;
alter table public.bookings add column if not exists email text;
alter table public.bookings add column if not exists service_type text;
alter table public.bookings add column if not exists bike_make text;
alter table public.bookings add column if not exists bike_model text;
alter table public.bookings add column if not exists preferred_date date;
alter table public.bookings add column if not exists preferred_time text;
alter table public.bookings add column if not exists location text;
alter table public.bookings add column if not exists details text;
alter table public.bookings add column if not exists status text not null default 'pending';
alter table public.bookings add column if not exists created_at timestamptz not null default now();

alter table public.orders add column if not exists customer_name text;
alter table public.orders add column if not exists customer_phone text;
alter table public.orders add column if not exists notes text;
alter table public.orders add column if not exists total numeric(10,2) not null default 0;
alter table public.orders add column if not exists status text not null default 'new';
alter table public.orders add column if not exists created_at timestamptz not null default now();

alter table public.order_items add column if not exists order_id uuid references public.orders(id) on delete cascade;
alter table public.order_items add column if not exists product_id uuid references public.products(id) on delete set null;
alter table public.order_items add column if not exists product_name text;
alter table public.order_items add column if not exists quantity integer;
alter table public.order_items add column if not exists unit_price numeric(10,2);
alter table public.order_items add column if not exists created_at timestamptz not null default now();

-- 3) ENABLE ROW LEVEL SECURITY
alter table public.admin_users enable row level security;
alter table public.products enable row level security;
alter table public.bookings enable row level security;
alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- 4) REMOVE THIS PROJECT'S OLD POLICIES BEFORE RECREATING THEM
drop policy if exists "Admins can read own membership" on public.admin_users;
drop policy if exists "Public can read active products" on public.products;
drop policy if exists "Admins insert products" on public.products;
drop policy if exists "Admins update products" on public.products;
drop policy if exists "Admins delete products" on public.products;
drop policy if exists "Public can submit bookings" on public.bookings;
drop policy if exists "Admins manage bookings" on public.bookings;
drop policy if exists "Public can create orders" on public.orders;
drop policy if exists "Admins manage orders" on public.orders;
drop policy if exists "Public can add order items" on public.order_items;
drop policy if exists "Admins manage order items" on public.order_items;

-- 5) ADMIN MEMBERSHIP
create policy "Admins can read own membership" on public.admin_users
for select to authenticated
using (user_id = (select auth.uid()));

-- 6) PRODUCTS: everyone can view active products; admins manage products
create policy "Public can read active products" on public.products
for select to anon, authenticated
using (
  active = true
  or exists (select 1 from public.admin_users a where a.user_id = (select auth.uid()))
);

create policy "Admins insert products" on public.products
for insert to authenticated
with check (exists (select 1 from public.admin_users a where a.user_id = (select auth.uid())));

create policy "Admins update products" on public.products
for update to authenticated
using (exists (select 1 from public.admin_users a where a.user_id = (select auth.uid())))
with check (exists (select 1 from public.admin_users a where a.user_id = (select auth.uid())));

create policy "Admins delete products" on public.products
for delete to authenticated
using (exists (select 1 from public.admin_users a where a.user_id = (select auth.uid())));

-- 7) BOOKINGS: visitors may submit; only admins may view/manage them
create policy "Public can submit bookings" on public.bookings
for insert to anon, authenticated
with check (
  char_length(trim(customer_name)) between 1 and 100
  and char_length(trim(phone)) between 5 and 30
  and char_length(trim(details)) between 1 and 1500
  and status = 'pending'
);

create policy "Admins manage bookings" on public.bookings
for all to authenticated
using (exists (select 1 from public.admin_users a where a.user_id = (select auth.uid())))
with check (exists (select 1 from public.admin_users a where a.user_id = (select auth.uid())));

-- 8) ORDERS: visitors submit orders through the secure RPC function below.
-- Direct public SELECT/INSERT policies are intentionally NOT enabled, so customers
-- cannot read other customers' orders or choose their own prices/totals.
create policy "Admins manage orders" on public.orders
for all to authenticated
using (exists (select 1 from public.admin_users a where a.user_id = (select auth.uid())))
with check (exists (select 1 from public.admin_users a where a.user_id = (select auth.uid())));

create policy "Admins manage order items" on public.order_items
for all to authenticated
using (exists (select 1 from public.admin_users a where a.user_id = (select auth.uid())))
with check (exists (select 1 from public.admin_users a where a.user_id = (select auth.uid())));

-- 9) SECURE ORDER SUBMISSION FUNCTION
-- The website sends product IDs + quantities. Supabase looks up the real prices
-- and calculates the total itself. Customers cannot set fake prices or read orders.
create or replace function public.submit_jact_order(
  p_customer_name text,
  p_customer_phone text,
  p_notes text,
  p_items jsonb
)
returns uuid
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_order_id uuid;
  v_item jsonb;
  v_product_id uuid;
  v_quantity integer;
  v_product_name text;
  v_price numeric(10,2);
  v_total numeric(10,2) := 0;
begin
  if p_customer_name is null or char_length(trim(p_customer_name)) not between 1 and 100 then
    raise exception 'Please enter a valid customer name.';
  end if;
  if p_customer_phone is null or char_length(trim(p_customer_phone)) not between 5 and 30 then
    raise exception 'Please enter a valid phone number.';
  end if;
  if p_items is null or jsonb_typeof(p_items) <> 'array' or jsonb_array_length(p_items) = 0 then
    raise exception 'Your basket is empty.';
  end if;
  if jsonb_array_length(p_items) > 30 then
    raise exception 'Too many different products in one enquiry.';
  end if;

  -- Validate every item and calculate the total before creating the order.
  for v_item in select value from jsonb_array_elements(p_items)
  loop
    v_product_id := (v_item->>'product_id')::uuid;
    v_quantity := (v_item->>'quantity')::integer;
    if v_quantity is null or v_quantity < 1 or v_quantity > 99 then
      raise exception 'Each product quantity must be between 1 and 99.';
    end if;
    select name, price into v_product_name, v_price
      from public.products
      where id = v_product_id and active = true;
    if not found then
      raise exception 'A selected product is no longer available. Please refresh the shop.';
    end if;
    v_total := v_total + (v_price * v_quantity);
  end loop;

  insert into public.orders (customer_name, customer_phone, notes, total, status)
  values (trim(p_customer_name), trim(p_customer_phone), nullif(trim(coalesce(p_notes, '')), ''), v_total, 'new')
  returning id into v_order_id;

  for v_item in select value from jsonb_array_elements(p_items)
  loop
    v_product_id := (v_item->>'product_id')::uuid;
    v_quantity := (v_item->>'quantity')::integer;
    select name, price into v_product_name, v_price
      from public.products
      where id = v_product_id and active = true;
    insert into public.order_items (order_id, product_id, product_name, quantity, unit_price)
    values (v_order_id, v_product_id, v_product_name, v_quantity, v_price);
  end loop;

  return v_order_id;
end;
$$;

revoke all on function public.submit_jact_order(text, text, text, jsonb) from public;
grant execute on function public.submit_jact_order(text, text, text, jsonb) to anon, authenticated;

-- 10) TABLE PERMISSIONS
revoke all on public.admin_users, public.products, public.bookings, public.orders, public.order_items from anon, authenticated;
grant select on public.products to anon, authenticated;
grant insert on public.bookings to anon, authenticated;
grant select on public.admin_users to authenticated;
grant select, insert, update, delete on public.products to authenticated;
grant select, update on public.bookings to authenticated;
grant select, update, delete on public.orders to authenticated;
grant select, insert, update, delete on public.order_items to authenticated;

-- 11) ADD THE AUTHORISED JACT ADMIN AFTER CREATING THEIR AUTH USER.
-- Replace the email below with the actual JACT admin email and run separately:
-- insert into public.admin_users (user_id)
-- select id from auth.users where lower(email) = lower('JACT_ADMIN_EMAIL@example.com')
-- on conflict (user_id) do nothing;

-- Done. Existing table data is not deleted by this script.
