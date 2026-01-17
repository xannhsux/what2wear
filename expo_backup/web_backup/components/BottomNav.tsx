import { Home, DoorOpen, Plus, Search, User } from 'lucide-react';

export default function BottomNav() {
  const iconSize = 24;
  const strokeWidth = 1.5;

  return (
    <nav style={{
      position: 'fixed',
      bottom: 0,
      left: 0,
      right: 0,
      height: '84px',
      background: 'rgba(255, 255, 255, 0.9)',
      backdropFilter: 'blur(20px)',
      WebkitBackdropFilter: 'blur(20px)',
      borderTop: '1px solid rgba(0,0,0,0.05)',
      display: 'flex',
      justifyContent: 'space-evenly',
      alignItems: 'center',
      zIndex: 100,
      paddingBottom: '24px'
    }}>
      <button className="nav-item active" style={{ color: 'var(--text-primary)', border: 'none', background: 'none' }}>
        <Home size={iconSize} strokeWidth={strokeWidth} />
      </button>
      <button className="nav-item" style={{ color: 'var(--text-muted)', border: 'none', background: 'none' }}>
        <DoorOpen size={iconSize} strokeWidth={strokeWidth} />
      </button>

      {/* Plus Button - Main Action */}
      <button className="nav-item" style={{
        background: 'var(--accent-primary)', /* Black */
        color: 'var(--text-inverse)',      /* White */
        width: '56px',
        height: '56px',
        borderRadius: '50%',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        marginTop: '-24px',
        boxShadow: '0 8px 16px rgba(0,0,0,0.15)',
        border: 'none',
        cursor: 'pointer'
      }}>
        <Plus size={28} strokeWidth={strokeWidth} />
      </button>

      <button className="nav-item" style={{ color: 'var(--text-muted)', border: 'none', background: 'none' }}>
        <Search size={iconSize} strokeWidth={strokeWidth} />
      </button>
      <button className="nav-item" style={{ color: 'var(--text-muted)', border: 'none', background: 'none' }}>
        <User size={iconSize} strokeWidth={strokeWidth} />
      </button>
    </nav >
  );
}
