/*
  # Initial Schema Setup for Bazam Platform

  1. New Tables
    - users
      - Extended user profile information
      - Seller-specific fields
    - products
      - Product listings
      - Connected to sellers
    - orders
      - Order tracking
      - Payment and shipping status
    - disputes
      - Order disputes
      - Evidence tracking
    
  2. Security
    - RLS policies for all tables
    - Secure access patterns
*/

-- Users table extension
CREATE TABLE IF NOT EXISTS public.users (
  id UUID REFERENCES auth.users PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  full_name TEXT,
  business_name TEXT,
  is_seller BOOLEAN DEFAULT false,
  stripe_account_id TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Products table
CREATE TABLE IF NOT EXISTS public.products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  seller_id UUID REFERENCES public.users NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  price INTEGER NOT NULL,
  images TEXT[],
  active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Orders table
CREATE TABLE IF NOT EXISTS public.orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id UUID REFERENCES public.products NOT NULL,
  buyer_id UUID REFERENCES public.users NOT NULL,
  seller_id UUID REFERENCES public.users NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending',
  tracking_number TEXT,
  shipping_address TEXT NOT NULL,
  payment_intent_id TEXT,
  delivery_confirmation_date TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Disputes table
CREATE TABLE IF NOT EXISTS public.disputes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID REFERENCES public.orders NOT NULL,
  created_by UUID REFERENCES public.users NOT NULL,
  reason TEXT NOT NULL,
  evidence TEXT[],
  status TEXT NOT NULL DEFAULT 'open',
  resolution TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Enable RLS
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.disputes ENABLE ROW LEVEL SECURITY;

-- Users policies
CREATE POLICY "Users can read their own data"
  ON public.users
  FOR SELECT
  USING (auth.uid() = id);

-- Products policies
CREATE POLICY "Anyone can view active products"
  ON public.products
  FOR SELECT
  USING (active = true);

CREATE POLICY "Sellers can manage their products"
  ON public.products
  FOR ALL
  USING (auth.uid() = seller_id);

-- Orders policies
CREATE POLICY "Users can view their orders"
  ON public.orders
  FOR SELECT
  USING (
    auth.uid() = buyer_id OR 
    auth.uid() = seller_id
  );

CREATE POLICY "Buyers can create orders"
  ON public.orders
  FOR INSERT
  WITH CHECK (auth.uid() = buyer_id);

-- Disputes policies
CREATE POLICY "Users can view their disputes"
  ON public.disputes
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.orders
      WHERE orders.id = disputes.order_id
      AND (orders.buyer_id = auth.uid() OR orders.seller_id = auth.uid())
    )
  );

CREATE POLICY "Users can create disputes for their orders"
  ON public.disputes
  FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.orders
      WHERE orders.id = order_id
      AND (orders.buyer_id = auth.uid() OR orders.seller_id = auth.uid())
    )
  );