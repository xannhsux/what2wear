import { Briefcase } from 'lucide-react';

export default function DateSelector() {
    return (
        <div style={{
            width: '100%',
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            gap: '1rem',
            padding: '1.5rem 0',
            paddingTop: '3rem' // Extra space for status bar
        }}>
            {/* Date Pill */}
            <button style={{
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'space-between',
                background: 'var(--accent-primary)', /* Black */
                color: 'var(--text-inverse)', /* White */
                padding: '1rem 2rem',
                borderRadius: '9999px',
                width: '90%',
                maxWidth: '380px',
                border: 'none',
                boxShadow: 'var(--shadow-md)',
                cursor: 'pointer',
                transform: 'scale(1)',
                transition: 'transform 0.2s ease'
            }}>
                <span style={{ fontSize: '2rem', fontWeight: 600, letterSpacing: '-0.04em' }}>Friday</span>
                <span style={{ fontSize: '1rem', opacity: 0.8, fontWeight: 400 }}>Jan 16</span>
            </button>

            {/* Event Label */}
            <div style={{
                display: 'flex',
                alignItems: 'center',
                gap: '0.6rem',
                fontSize: '0.9rem',
                fontWeight: 600,
                color: 'var(--text-primary)', /* Dark text */
                background: '#fff',
                padding: '0.6rem 1.25rem',
                borderRadius: '9999px',
                boxShadow: '0 4px 12px rgba(0,0,0,0.05)',
                border: '1px solid rgba(0,0,0,0.05)'
            }}>
                <Briefcase size={18} />
                <span>Work Day – Office</span>
            </div>
        </div>
    );
}
