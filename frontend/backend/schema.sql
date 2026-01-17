-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- PROFILES Table
-- Extends the built-in auth.users table
create table profiles (
  id uuid references auth.users not null primary key,
  email text,
  height numeric, -- stored in cm
  weight numeric, -- stored in kg
  shoe_size numeric, -- EU size
  chest numeric, -- cm
  waist numeric, -- cm
  hips numeric, -- cm
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- RLS for Profiles
alter table profiles enable row level security;

create policy "Users can view own profile" on profiles
  for select using (auth.uid() = id);

create policy "Users can update own profile" on profiles
  for update using (auth.uid() = id);

-- WARDROBE ITEMS Table
create table clothing_items (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references auth.users not null,
  name text not null,
  category text not null,
  image_url text, -- Store the base64 string or a URL if uploaded to storage
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- RLS for Wardrobe
alter table clothing_items enable row level security;

create policy "Users can view own wardrobe" on clothing_items
  for select using (auth.uid() = user_id);

create policy "Users can insert own wardrobe items" on clothing_items
  for insert with check (auth.uid() = user_id);

create policy "Users can delete own wardrobe items" on clothing_items
  for delete using (auth.uid() = user_id);

-- OUTFIT TEMPLATES Table
-- Stores the hardcoded data from outfitData.ts for persistence
create table outfit_templates (
  id serial primary key,
  style text not null,
  event_type text not null, -- 'Work Day – Office', 'Weekend – Leisure', etc.
  image_url text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- RLS for Outfit Templates (Read-only for public/authenticated, write for admin/none)
alter table outfit_templates enable row level security;

create policy "Everyone can view outfit templates" on outfit_templates
  for select using (true);


-- Trigger to create profile on signup
create or replace function public.handle_new_user() 
returns trigger as $$
begin
  insert into public.profiles (id, email)
  values (new.id, new.email);
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
