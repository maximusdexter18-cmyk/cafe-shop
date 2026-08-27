-- ============================================================
-- AMBER & ASH — CAFE ORDERING SCHEMA (Supabase / Postgres)
-- Run this once in your Supabase project: SQL Editor -> New query -> paste -> Run
-- ============================================================

-- 1. Physical tables in the cafe
create table tables (
  id uuid primary key default gen_random_uuid(),
  table_number int not null unique,
  seats int default 2
);

-- 2. Menu, editable anytime from Supabase's Table Editor — no code changes needed
create table menu_items (
  id uuid primary key default gen_random_uuid(),
  category text not null,          -- e.g. 'Coffee', 'Bakery', 'Food'
  name text not null,
  description text,
  price numeric(10,2) not null,
  is_available boolean default true,
  sort_order int default 0,
  image_url text
);

-- 2b. Optional add-ons per menu item (e.g. "Extra shot", "Oat milk"), configured by admin.
-- Run this in Supabase SQL Editor:
create table if not exists menu_addons (
  id uuid primary key default gen_random_uuid(),
  menu_item_id uuid references menu_items(id) on delete cascade not null,
  name text not null,
  price numeric(10,2) not null default 0,
  is_available boolean default true
);

alter table menu_addons enable row level security;

drop policy if exists "public read addons" on menu_addons;
create policy "public read addons"
  on menu_addons for select
  using (true);

-- Only admins should be able to manage add-ons, matching your admin-gated menu editing
drop policy if exists "admin write addons" on menu_addons;
create policy "admin write addons"
  on menu_addons for all
  using (auth.uid() in (select id from admins))
  with check (auth.uid() in (select id from admins));

-- 3. One row per customer "session" created the moment a QR is scanned.
--    This is what makes the link expire after 10 minutes.
create table table_sessions (
  id uuid primary key default gen_random_uuid(),
  table_id uuid references tables(id) not null,
  created_at timestamptz default now(),
  expires_at timestamptz default (now() + interval '10 minutes')
);

-- 4. Orders — one row per submitted order
create table orders (
  id uuid primary key default gen_random_uuid(),
  table_id uuid references tables(id) not null,
  session_id uuid references table_sessions(id),
  status text default 'pending',   -- 'pending' -> 'completed'
  notes text,
  created_at timestamptz default now(),
  completed_at timestamptz
);

-- 5. Order line items
create table order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid references orders(id) on delete cascade not null,
  menu_item_id uuid references menu_items(id) not null,
  item_name text not null,   -- snapshot of name/price at order time,
  item_price numeric(10,2) not null, -- so later menu edits don't rewrite history
  quantity int not null default 1,
  addons jsonb default '[]'::jsonb   -- customer-selected add-ons at order time
);

-- ============================================================
-- ROW LEVEL SECURITY
-- Customers (anon key) can: read menu, create sessions/orders, read their own order status.
-- Staff dashboard also uses the anon key here for simplicity — lock this down with
-- Supabase Auth (staff login) before going live so only logged-in staff can update orders.
-- ============================================================
alter table tables enable row level security;
alter table menu_items enable row level security;
alter table table_sessions enable row level security;
alter table orders enable row level security;
alter table order_items enable row level security;

create policy "public read tables" on tables for select using (true);
create policy "public read menu" on menu_items for select using (true);

-- Admin access control: only signed-in admins may change the menu / cancel bookings.
-- The cafe owner adds their own Supabase Auth user id to this table (see notes below).
create table admins (
  id uuid primary key references auth.users(id),
  email text,
  created_at timestamptz default now()
);
alter table admins enable row level security;
create policy "admin self read" on admins for select using (auth.uid() = id);

-- Staff access control (mirrors admins): signed-in staff may update orders.
create table staff (
  id uuid primary key references auth.users(id),
  email text,
  name text,
  created_at timestamptz default now()
);
alter table staff enable row level security;
create policy "staff self read" on staff for select using (auth.uid() = id);

create policy "admin insert menu" on menu_items
  for insert with check (exists (select 1 from admins where admins.id = auth.uid()));
create policy "admin update menu" on menu_items
  for update using (exists (select 1 from admins where admins.id = auth.uid()));
create policy "admin delete menu" on menu_items
  for delete using (exists (select 1 from admins where admins.id = auth.uid()));

-- (add-ons table, RLS, and admin-only policies are defined in section 2b above)

create policy "public create session" on table_sessions for insert with check (true);
create policy "public read own session" on table_sessions for select using (true);

create policy "public create order" on orders for insert with check (true);
create policy "public read orders" on orders for select using (true);
create policy "staff update orders" on orders
  for update using (exists (select 1 from staff where staff.id = auth.uid()));

create policy "public create order items" on order_items for insert with check (true);
create policy "public read order items" on order_items for select using (true);

-- ============================================================
-- REALTIME — lets the staff dashboard see new orders instantly
-- ============================================================
alter publication supabase_realtime add table orders;
alter publication supabase_realtime add table order_items;
alter publication supabase_realtime add table menu_addons;

-- 6. Table bookings — reservations with hard conflict prevention at the DB level
create extension if not exists btree_gist;

create table bookings (
  id uuid primary key default gen_random_uuid(),
  table_id uuid references tables(id) not null,
  customer_name text not null,
  phone text,
  party_size int not null default 2,
  arrival_at timestamptz not null,
  leaving_at timestamptz not null,
  status text default 'confirmed',   -- 'confirmed' or 'cancelled'
  created_at timestamptz default now(),
  constraint valid_time_range check (leaving_at > arrival_at)
);

-- This is what makes double-booking impossible, even with two people booking at the
-- exact same second: Postgres itself will reject an overlapping insert.
alter table bookings add constraint no_overlapping_bookings
  exclude using gist (
    table_id with =,
    tstzrange(arrival_at, leaving_at) with &&
  ) where (status = 'confirmed');

alter table bookings enable row level security;
create policy "public read bookings" on bookings for select using (true);
create policy "public create bookings" on bookings for insert with check (true);
create policy "staff update bookings" on bookings
  for update using (exists (select 1 from admins where admins.id = auth.uid()));

-- ============================================================
-- SEED DATA — replace/add rows anytime from Table Editor
-- ============================================================
insert into tables (table_number, seats) values
  (1, 2), (2, 2), (3, 4), (4, 4), (5, 6);

insert into menu_items (category, name, description, price, sort_order) values
  ('Coffee', 'Amber Latte', 'House espresso, oat milk, brown-butter caramel', 220, 1),
  ('Coffee', 'Ash Cold Brew', '18-hour steep, served over one large cube', 190, 2),
  ('Bakery', 'Burnt-Honey Croissant', 'Laminated fresh each morning', 160, 3),
  ('Food', 'Saffron Rice Bowl', 'Slow-cooked lentils, charred vegetables, herb oil', 340, 4);

-- Example add-ons (admin can add/remove these in the menu manager)
insert into menu_addons (menu_item_id, name, price, is_available)
select id, 'Extra shot', 30, true from menu_items where name = 'Amber Latte';
insert into menu_addons (menu_item_id, name, price, is_available)
select id, 'Oat milk', 20, true from menu_items where name = 'Amber Latte';
insert into menu_addons (menu_item_id, name, price, is_available)
select id, 'Warmed', 0, true from menu_items where name = 'Burnt-Honey Croissant';
