import { Response } from 'express';
import { AuthenticatedRequest } from '../middleware/auth';
import { supabaseAdmin } from '../services/supabase';

export const getWardrobeItems = async (req: AuthenticatedRequest, res: Response) => {
    try {
        const userId = req.user!.id;
        const { data, error } = await supabaseAdmin
            .from('clothing_items')
            .select('*')
            .eq('user_id', userId)
            .order('created_at', { ascending: false });

        if (error) throw error;
        res.json(data);
    } catch (err: any) {
        res.status(500).json({ error: err.message });
    }
};

export const addWardrobeItem = async (req: AuthenticatedRequest, res: Response) => {
    try {
        const userId = req.user!.id;
        const { name, category, imageUrl } = req.body;

        if (!name || !category) {
            return res.status(400).json({ error: 'Name and category are required' });
        }

        const { data, error } = await supabaseAdmin
            .from('clothing_items')
            .insert([
                { user_id: userId, name, category, image_url: imageUrl }
            ])
            .select()
            .single();

        if (error) throw error;
        res.status(201).json(data);
    } catch (err: any) {
        res.status(500).json({ error: err.message });
    }
};

export const deleteWardrobeItem = async (req: AuthenticatedRequest, res: Response) => {
    try {
        const userId = req.user!.id;
        const { id } = req.params;

        const { error } = await supabaseAdmin
            .from('clothing_items')
            .delete()
            .eq('id', id)
            .eq('user_id', userId);

        if (error) throw error;
        res.status(204).send();
    } catch (err: any) {
        res.status(500).json({ error: err.message });
    }
};
