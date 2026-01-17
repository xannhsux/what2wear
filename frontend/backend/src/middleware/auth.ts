import { Request, Response, NextFunction } from 'express';
import { supabaseAdmin } from '../services/supabase';

export interface AuthenticatedRequest extends Request {
    user?: {
        id: string;
        email?: string;
    };
}

export const requireAuth = async (req: AuthenticatedRequest, res: Response, next: NextFunction) => {
    const authHeader = req.headers.authorization;

    if (!authHeader) {
        return res.status(401).json({ error: 'Missing authorization header' });
    }

    const token = authHeader.replace('Bearer ', '');

    try {
        const { data: { user }, error } = await supabaseAdmin.auth.getUser(token);

        if (error || !user) {
            return res.status(401).json({ error: 'Invalid token' });
        }

        req.user = {
            id: user.id,
            email: user.email,
        };

        next();
    } catch (err) {
        console.error('Auth error:', err);
        res.status(500).json({ error: 'Internal server error during authentication' });
    }
};
