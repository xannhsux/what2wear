import { Router } from 'express';
import { getOutfits } from '../controllers/outfitController';
import { requireAuth } from '../middleware/auth';

const router = Router();

// Outfits can be public or protected. Let's make them protected to ensure valid user context.
router.use(requireAuth);

router.get('/', getOutfits);

export default router;
