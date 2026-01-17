import { Response } from 'express';
import { AuthenticatedRequest } from '../middleware/auth';
import { supabaseAdmin } from '../services/supabase';

export const getProfile = async (req: AuthenticatedRequest, res: Response) => {
    try {
        const userId = req.user!.id;
        const { data, error } = await supabaseAdmin
            .from('profiles')
            .select('*')
            .eq('id', userId)
            .single();

        if (error) {
            // If profile doesn't exist yet but user does (rare due to trigger, but possible), return basic info or 404
            return res.status(404).json({ error: 'Profile not found' });
        }
        res.json(data);
    } catch (err: any) {
        res.status(500).json({ error: err.message });
    }
};

export const updateProfile = async (req: AuthenticatedRequest, res: Response) => {
    try {
        const userId = req.user!.id;
        const updates = req.body;

        // Filter allowed fields
        const allowed = ['height', 'weight', 'shoe_size', 'chest', 'waist', 'hips'];
        const filteredUpdates: any = {};
        allowed.forEach(field => {
            if (updates[field] !== undefined) filteredUpdates[field] = updates[field];
        });

        const { data, error } = await supabaseAdmin
            .from('profiles')
            .update(filteredUpdates)
            .eq('id', userId)
            .select()
            .single();

        if (error) throw error;
        res.json(data);
    } catch (err: any) {
        res.status(500).json({ error: err.message });
    }
};
