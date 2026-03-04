-- Enable pgvector extension
CREATE EXTENSION IF NOT EXISTS vector;

-- Assumed wardrobe_items table (as per user specifications)
CREATE TABLE IF NOT EXISTS wardrobe_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL, -- link to your users table
  category text NOT NULL, -- 'tops', 'bottoms', 'shoes', 'accessories'
  formality int DEFAULT 1, -- 1: casual, 5: formal
  season text[] DEFAULT '{}', -- {'summer', 'spring'}
  style_tags text[] DEFAULT '{}', -- {'vintage', 'streetwear'}
  image_url text,
  embedding vector(1536), -- CLIP embeddings (1536-dim)
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Outfits table: groups items into a curated set
CREATE TABLE IF NOT EXISTS outfits (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  name text,
  item_ids uuid[] DEFAULT '{}', -- Stores references to wardrobe_items
  style_tags text[] DEFAULT '{}',
  average_formality float,
  is_curated boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Daily recommendations table
CREATE TABLE IF NOT EXISTS daily_recommendations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  recommend_date date NOT NULL,
  outfit_id uuid REFERENCES outfits(id),
  source text NOT NULL DEFAULT 'generated', -- 'generated' vs 'curated'
  score float,
  context JSONB, -- store weather/occasion context for reference
  created_at timestamptz DEFAULT now(),
  UNIQUE(user_id, recommend_date, outfit_id)
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_wardrobe_user ON wardrobe_items (user_id);
CREATE INDEX IF NOT EXISTS idx_wardrobe_category ON wardrobe_items (category);
CREATE INDEX IF NOT EXISTS idx_daily_user_date ON daily_recommendations (user_id, recommend_date);
CREATE INDEX IF NOT EXISTS idx_outfits_user ON outfits (user_id);

-- Vector Index for similarity search
-- Adjust 'lists' based on your anticipated scale; 100 is solid for small-to-medium datasets
CREATE INDEX IF NOT EXISTS idx_wardrobe_embedding ON wardrobe_items
USING ivfflat (embedding vector_cosine_ops)
WITH (lists = 100);

-- Enable RLS for privacyFirst
ALTER TABLE wardrobe_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE outfits ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_recommendations ENABLE ROW LEVEL SECURITY;

-- Basic RLS Policies (Assuming users have auth.uid())
-- These may need tuning based on your specific Supabase setup
DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Users can access own items') THEN
    CREATE POLICY "Users can access own items" ON wardrobe_items FOR ALL USING (auth.uid() = user_id);
    CREATE POLICY "Users can access own outfits" ON outfits FOR ALL USING (auth.uid() = user_id);
    CREATE POLICY "Users can access own recs" ON daily_recommendations FOR ALL USING (auth.uid() = user_id);
  END IF;
END $$;
