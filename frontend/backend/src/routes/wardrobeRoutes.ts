import { Router } from 'express';
import { getWardrobeItems, addWardrobeItem, deleteWardrobeItem } from '../controllers/wardrobeController';
import { requireAuth } from '../middleware/auth';

const router = Router();

router.use(requireAuth);

router.get('/', getWardrobeItems);
router.post('/', addWardrobeItem);
router.delete('/:id', deleteWardrobeItem);

export default router;
