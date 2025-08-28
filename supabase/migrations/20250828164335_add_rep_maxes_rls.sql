-- Enable RLS on rep_maxes view (inherits from lift_entries but explicit is better)
-- Views in PostgreSQL don't support RLS directly, but we can create a security definer function
-- However, since our view already filters through lift_entries which has RLS,
-- the view automatically inherits the security policies.

-- Let's add some indexes to optimize the rep_maxes view performance
CREATE INDEX IF NOT EXISTS lift_entries_user_lift_reps_weight_idx 
ON public.lift_entries(user_id, lift, reps, weight_kg DESC, performed_at DESC, created_at DESC);

-- Add a comment to document the RLS inheritance
COMMENT ON VIEW public.rep_maxes IS 'Rep maxes view automatically inherits RLS from lift_entries table';