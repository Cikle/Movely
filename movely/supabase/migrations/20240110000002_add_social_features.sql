-- Add following/followers to users table
ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS following UUID[] DEFAULT '{}',
ADD COLUMN IF NOT EXISTS followers UUID[] DEFAULT '{}';

-- Create function to handle following
CREATE OR REPLACE FUNCTION follow_user(follower_id UUID, following_id UUID)
RETURNS void AS $$
BEGIN
    -- Add following_id to follower's following array
    UPDATE public.users 
    SET following = array_append(following, following_id)
    WHERE id = follower_id 
    AND NOT following @> ARRAY[following_id];

    -- Add follower_id to following's followers array
    UPDATE public.users 
    SET followers = array_append(followers, follower_id)
    WHERE id = following_id 
    AND NOT followers @> ARRAY[follower_id];
END;
$$ LANGUAGE plpgsql;

-- Create function to handle unfollowing
CREATE OR REPLACE FUNCTION unfollow_user(follower_id UUID, following_id UUID)
RETURNS void AS $$
BEGIN
    -- Remove following_id from follower's following array
    UPDATE public.users 
    SET following = array_remove(following, following_id)
    WHERE id = follower_id;

    -- Remove follower_id from following's followers array
    UPDATE public.users 
    SET followers = array_remove(followers, follower_id)
    WHERE id = following_id;
END;
$$ LANGUAGE plpgsql;
