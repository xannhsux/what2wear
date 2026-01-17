import DateSelector from '@/components/DateSelector';
import SwipeDeck from '@/components/SwipeDeck';
import BottomNav from '@/components/BottomNav';

export default function Home() {
  return (
    <main style={{
      display: 'flex',
      flexDirection: 'column',
      height: '100vh',
      paddingBottom: '100px', // Space for bottom nav
      background: 'var(--bg-app)',
      color: 'var(--text-primary)',
      position: 'relative',
      overflow: 'hidden' // Prevent scrolling for app-like feel
    }}>
      <DateSelector />

      <div style={{
        flex: 1,
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        padding: '20px',
        marginTop: '-20px' // Slight optical adjustment
      }}>
        <SwipeDeck />
      </div>

      <BottomNav />
    </main>
  );
}
