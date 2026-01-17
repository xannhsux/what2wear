import React from 'react';

interface OutfitCardProps {
    styleName: string;
    image?: string; // Optional for now, using placeholder svg
    onViewDetails?: () => void;
}

export default function OutfitCard({ styleName, onViewDetails }: OutfitCardProps) {
    return (
        <div style={{
            background: '#fff',
            borderRadius: '24px',
            padding: '24px',
            width: '100%',
            height: '100%',
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            justifyContent: 'space-between',
            boxShadow: '0 20px 40px rgba(0,0,0,0.1)',
            position: 'relative',
            overflow: 'hidden'
        }}>
            <h2 style={{
                fontSize: '1.25rem',
                fontWeight: 600,
                color: '#000',
                alignSelf: 'flex-start',
                marginBottom: '1rem'
            }}>Today's Recommendation</h2>

            {/* Illustration Placeholder */}
            <div style={{
                flex: 1,
                width: '100%',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                marginBottom: '1rem'
            }}>
                {/* Minimal Human Silhouette Line Art */}
                <svg width="200" height="300" viewBox="0 0 100 200" fill="none" stroke="#000" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
                    <circle cx="50" cy="30" r="15" /> {/* Head */}
                    <path d="M50 45 V 90" /> {/* Body */}
                    <path d="M50 90 L 30 180" /> {/* Left Leg */}
                    <path d="M50 90 L 70 180" /> {/* Right Leg */}
                    <path d="M50 55 L 20 80" /> {/* Left Arm */}
                    <path d="M50 55 L 80 80" /> {/* Right Arm */}
                    {/* Simple Shirt */}
                    <path d="M35 45 L 65 45 L 70 90 L 30 90 Z" strokeDasharray="2 2" />
                </svg>
            </div>

            <div style={{
                width: '100%',
                display: 'flex',
                flexDirection: 'column',
                alignItems: 'center',
                gap: '1rem'
            }}>
                <span style={{
                    fontSize: '1rem',
                    fontWeight: 500,
                    color: '#666'
                }}>{styleName}</span>

                <button
                    onClick={onViewDetails}
                    style={{
                        background: '#000',
                        color: '#fff',
                        border: 'none',
                        padding: '1rem 2rem',
                        borderRadius: '9999px',
                        fontSize: '1rem',
                        fontWeight: 500,
                        cursor: 'pointer',
                        width: '100%'
                    }}
                >
                    View Details
                </button>
            </div>
        </div>
    );
}
