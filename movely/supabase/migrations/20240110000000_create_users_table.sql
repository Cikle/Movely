-- Create users table
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id),
    username TEXT UNIQUE NOT NULL,
    display_name TEXT NOT NULL,
    favorite_activities TEXT[] NOT NULL DEFAULT '{}',
    discovery_source TEXT,
    onboarding_completed BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    daily_steps INTEGER DEFAULT 0,
    total_steps INTEGER DEFAULT 0,
    step_history JSONB DEFAULT '{"days": []}'::jsonb
);

-- Create RLS policies
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

DO $$ 
BEGIN
    -- Drop existing policies if they exist
    DROP POLICY IF EXISTS "Users can read their own data" ON public.users;
    DROP POLICY IF EXISTS "Users can update their own data" ON public.users;
    DROP POLICY IF EXISTS "Users can insert their own data" ON public.users;
    
    -- Create new policies
    CREATE POLICY "Users can read their own data"
        ON public.users
        FOR SELECT
        USING (auth.uid() = id);

    CREATE POLICY "Users can update their own data"
        ON public.users
        FOR UPDATE
        USING (auth.uid() = id);

    CREATE POLICY "Users can insert their own data"
        ON public.users
        FOR INSERT
        WITH CHECK (auth.uid() = id);
END $$;

-- Notify PostgREST to reload schema cache
NOTIFY pgrst, 'reload schema';

-- Create updated_at trigger
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DO $$
BEGIN
    DROP TRIGGER IF EXISTS handle_users_updated_at ON public.users;
    CREATE TRIGGER handle_users_updated_at
        BEFORE UPDATE ON public.users
        FOR EACH ROW
        EXECUTE FUNCTION public.handle_updated_at();
END $$;
