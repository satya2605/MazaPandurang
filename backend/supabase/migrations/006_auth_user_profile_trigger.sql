-- ========================================================
-- MAZA PANDURANG — DATABASE SCHEMA MIGRATION 006
-- Automatic Profile Provisioning Trigger for auth.users
-- ========================================================

-- Create or replace trigger function to create profile on auth signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
DECLARE
  user_role_val public.user_role := 'pilgrim'::public.user_role;
  input_role text;
BEGIN
  input_role := new.raw_user_meta_data->>'role';
  IF input_role IS NOT NULL AND input_role IN ('pilgrim', 'dindi_leader', 'police_authority', 'ngo_volunteer', 'palkhi_operator', 'local_citizen', 'admin') THEN
    user_role_val := input_role::public.user_role;
  END IF;

  -- Check if profile already exists (e.g. seeded/provisioned privileged roles)
  IF NOT EXISTS (SELECT 1 FROM public.profiles WHERE id = new.id) THEN
    INSERT INTO public.profiles (id, email, display_name, role, status)
    VALUES (
      new.id,
      new.email,
      COALESCE(
        new.raw_user_meta_data->>'full_name',
        new.raw_user_meta_data->>'display_name',
        split_part(new.email, '@', 1)
      ),
      user_role_val,
      'active'
    );
  END IF;
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to invoke on auth.users insert
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();
