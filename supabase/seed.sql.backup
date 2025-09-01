-- Seed data for powerlifting rep max tracker
-- This creates test users and lift entries for development

-- Insert test users into auth.users first
-- NOTE: In production, users are created via Supabase Auth, but for testing we create them directly
INSERT INTO auth.users (
  instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, 
  invited_at, confirmation_token, confirmation_sent_at, recovery_token, recovery_sent_at, 
  email_change_token_new, email_change, email_change_sent_at, last_sign_in_at, 
  raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at, 
  phone, phone_confirmed_at, phone_change, phone_change_token, phone_change_sent_at, 
  email_change_token_current, email_change_confirm_status, banned_until, reauthentication_token, 
  reauthentication_sent_at, is_sso_user, deleted_at
) VALUES 
  ('00000000-0000-0000-0000-000000000000', '550e8400-e29b-41d4-a716-446655440001', 'authenticated', 'authenticated', 'john@example.com', crypt('password123', gen_salt('bf')), now(), NULL, '', NULL, '', NULL, '', '', NULL, NULL, '{"provider":"email","providers":["email"]}', '{}', FALSE, now(), now(), NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, FALSE, NULL),
  ('00000000-0000-0000-0000-000000000000', '550e8400-e29b-41d4-a716-446655440002', 'authenticated', 'authenticated', 'jane@example.com', crypt('password123', gen_salt('bf')), now(), NULL, '', NULL, '', NULL, '', '', NULL, NULL, '{"provider":"email","providers":["email"]}', '{}', FALSE, now(), now(), NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, FALSE, NULL);

-- Insert corresponding entries into auth.identities
INSERT INTO auth.identities (
  provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at
) VALUES 
  ('john@example.com', '550e8400-e29b-41d4-a716-446655440001', '{"sub":"550e8400-e29b-41d4-a716-446655440001","email":"john@example.com"}', 'email', now(), now(), now()),
  ('jane@example.com', '550e8400-e29b-41d4-a716-446655440002', '{"sub":"550e8400-e29b-41d4-a716-446655440002","email":"jane@example.com"}', 'email', now(), now(), now());

-- Test user 1: john@example.com
INSERT INTO public.lift_entries (user_id, lift, reps, weight_kg, performed_at) VALUES
  -- Squat progression
  ('550e8400-e29b-41d4-a716-446655440001', 'squat', 1, 180.0, '2024-01-15'),
  ('550e8400-e29b-41d4-a716-446655440001', 'squat', 2, 170.0, '2024-01-10'),
  ('550e8400-e29b-41d4-a716-446655440001', 'squat', 3, 160.0, '2024-01-08'),
  ('550e8400-e29b-41d4-a716-446655440001', 'squat', 5, 140.0, '2024-01-05'),
  ('550e8400-e29b-41d4-a716-446655440001', 'squat', 8, 120.0, '2024-01-03'),
  ('550e8400-e29b-41d4-a716-446655440001', 'squat', 10, 100.0, '2024-01-01'),
  
  -- Bench progression  
  ('550e8400-e29b-41d4-a716-446655440001', 'bench', 1, 120.0, '2024-01-12'),
  ('550e8400-e29b-41d4-a716-446655440001', 'bench', 2, 115.0, '2024-01-09'),
  ('550e8400-e29b-41d4-a716-446655440001', 'bench', 3, 110.0, '2024-01-07'),
  ('550e8400-e29b-41d4-a716-446655440001', 'bench', 5, 95.0, '2024-01-04'),
  ('550e8400-e29b-41d4-a716-446655440001', 'bench', 8, 80.0, '2024-01-02'),
  
  -- Deadlift progression
  ('550e8400-e29b-41d4-a716-446655440001', 'deadlift', 1, 220.0, '2024-01-14'),
  ('550e8400-e29b-41d4-a716-446655440001', 'deadlift', 2, 210.0, '2024-01-11'),
  ('550e8400-e29b-41d4-a716-446655440001', 'deadlift', 3, 200.0, '2024-01-08'),
  ('550e8400-e29b-41d4-a716-446655440001', 'deadlift', 5, 180.0, '2024-01-06'),
  ('550e8400-e29b-41d4-a716-446655440001', 'deadlift', 8, 160.0, '2024-01-03');

-- Test user 2: jane@example.com  
INSERT INTO public.lift_entries (user_id, lift, reps, weight_kg, performed_at) VALUES
  -- Squat progression
  ('550e8400-e29b-41d4-a716-446655440002', 'squat', 1, 140.0, '2024-01-16'),
  ('550e8400-e29b-41d4-a716-446655440002', 'squat', 3, 125.0, '2024-01-12'),
  ('550e8400-e29b-41d4-a716-446655440002', 'squat', 5, 110.0, '2024-01-08'),
  ('550e8400-e29b-41d4-a716-446655440002', 'squat', 8, 95.0, '2024-01-05'),
  ('550e8400-e29b-41d4-a716-446655440002', 'squat', 10, 85.0, '2024-01-02'),
  
  -- Bench progression
  ('550e8400-e29b-41d4-a716-446655440002', 'bench', 1, 80.0, '2024-01-15'),
  ('550e8400-e29b-41d4-a716-446655440002', 'bench', 2, 75.0, '2024-01-10'),
  ('550e8400-e29b-41d4-a716-446655440002', 'bench', 5, 65.0, '2024-01-07'),
  ('550e8400-e29b-41d4-a716-446655440002', 'bench', 8, 55.0, '2024-01-04'),
  
  -- Deadlift progression
  ('550e8400-e29b-41d4-a716-446655440002', 'deadlift', 1, 160.0, '2024-01-13'),
  ('550e8400-e29b-41d4-a716-446655440002', 'deadlift', 3, 145.0, '2024-01-09'),
  ('550e8400-e29b-41d4-a716-446655440002', 'deadlift', 5, 130.0, '2024-01-06'),
  ('550e8400-e29b-41d4-a716-446655440002', 'deadlift', 8, 115.0, '2024-01-03');

-- Add some duplicate entries with lower weights to test the "best weight" logic
INSERT INTO public.lift_entries (user_id, lift, reps, weight_kg, performed_at) VALUES
  -- Earlier, weaker squat 1RM for user 1 (should not appear in rep_maxes)
  ('550e8400-e29b-41d4-a716-446655440001', 'squat', 1, 175.0, '2023-12-01'),
  -- Same weight but earlier date (should not appear in rep_maxes due to date tiebreaker)
  ('550e8400-e29b-41d4-a716-446655440001', 'squat', 1, 180.0, '2024-01-10');