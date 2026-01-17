import { Response } from 'express';
import { AuthenticatedRequest } from '../middleware/auth';
import { supabaseAdmin } from '../services/supabase';

export const getOutfits = async (req: AuthenticatedRequest, res: Response) => {
    try {
        // In a real app we'd use the user's profile and event type to filter
        // For now we return all templates or filter by query param 'event'
        const event = req.query.event as string;

        let query = supabaseAdmin
            .from('outfit_templates')
            .select('*');

        if (event) {
            query = query.eq('event_type', event);
        }

        const { data, error } = await query;

        if (error) throw error;
        res.json(data);
    } catch (err: any) {
        res.status(500).json({ error: err.message });
    }
};
