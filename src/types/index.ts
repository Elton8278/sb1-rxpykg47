export interface User {
  id: string;
  email: string;
  full_name: string;
  business_name?: string;
  is_seller: boolean;
  created_at: string;
}

export interface Product {
  id: string;
  seller_id: string;
  title: string;
  description: string;
  price: number;
  images: string[];
  created_at: string;
}

export interface Order {
  id: string;
  product_id: string;
  buyer_id: string;
  seller_id: string;
  status: 'pending' | 'paid' | 'shipped' | 'delivered' | 'disputed' | 'completed';
  tracking_number?: string;
  shipping_address: string;
  payment_intent_id: string;
  created_at: string;
  delivery_confirmation_date?: string;
}