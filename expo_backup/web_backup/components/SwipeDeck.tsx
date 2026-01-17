'use client'; // Client component for interaction

import React, { useState } from 'react';
import OutfitCard from './OutfitCard';

export default function SwipeDeck() {
    // Mock data for now
    const cards = [
        { id: 1, style: 'Business Professional' },
        { id: 2, style: 'Smart Casual' },
        { id: 3, style: 'Evening Chill' },
    ];

    const [currentIndex, setCurrentIndex] = useState(0);

    // In a real app, we'd use a gesture library like react-use-gesture or framer-motion
    // For MVP/Mock, we'll just show the top card and a "stack" effect visually.

    const currentCard = cards[currentIndex % cards.length];
    const nextCard = cards[(currentIndex + 1) % cards.length];

    return (
        <div style={{
            position: 'relative',
            width: '100%',
            maxWidth: '360px',
            aspectRatio: '3/4',
            margin: '0 auto',
            perspective: '1000px'
        }}>
            {/* Background Card (Next) */}
            <div style={{
                position: 'absolute',
                top: '10px',
                left: '10px',
                right: '-10px',
                bottom: '-10px',
                transform: 'scale(0.95) translateY(10px)',
                opacity: 0.6,
                zIndex: 0,
                transition: 'all 0.3s ease'
            }}>
                <OutfitCard styleName={nextCard.style} />
            </div>

            {/* Foreground Card (Current) */}
            <div style={{
                position: 'absolute',
                inset: 0,
                zIndex: 10,
                cursor: 'grab',
                transition: 'transform 0.3s ease',
            }}
                // Simple click to cycle for demo purposes
                onClick={() => setCurrentIndex(prev => prev + 1)}
            >
                <OutfitCard styleName={currentCard.style} />
            </div>

            {/* Swipe Hints (Visual only) */}
            <div style={{
                position: 'absolute',
                bottom: '-40px',
                left: 0,
                right: 0,
                display: 'flex',
                justifyContent: 'space-between',
                padding: '0 20px',
                opacity: 0.5,
                fontSize: '0.875rem',
                color: 'var(--text-secondary)'
            }}>
                <span>← Dislike</span>
                <span>Like →</span>
            </div>
        </div>
    );
}
