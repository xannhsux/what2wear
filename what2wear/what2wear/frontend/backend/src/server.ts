
import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import wardrobeRoutes from './routes/wardrobeRoutes';
import profileRoutes from './routes/profileRoutes';
import outfitRoutes from './routes/outfitRoutes';



dotenv.config();

const app = express();
const port = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

app.use('/api/wardrobe', wardrobeRoutes);
app.use('/api/profile', profileRoutes);
app.use('/api/outfits', outfitRoutes);



app.get('/', (req, res) => {
    res.send('Fashion Helper Backend is running');
});

app.listen(port, () => {
    console.log(`Server is running on port ${port}`);
});
