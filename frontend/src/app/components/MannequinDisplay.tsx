interface Measurements {
  height: number;
  weight: number;
  shoeSize: number;
  chest?: number;
  waist?: number;
  hips?: number;
}

interface MannequinDisplayProps {
  measurements: Measurements;
  userImage?: string;
}

export function MannequinDisplay({ measurements }: MannequinDisplayProps) {
  // Calculate proportions based on measurements
  // Height affects overall scale, weight affects width
  const baseHeight = 400;
  const heightScale = measurements.height / 170; // 170cm as baseline
  const weightScale = measurements.weight / 65; // 65kg as baseline
  
  const mannequinHeight = baseHeight * heightScale;
  const shoulderWidth = 80 * weightScale;
  const waistWidth = 60 * weightScale;
  const hipWidth = 85 * weightScale;
  
  const headHeight = mannequinHeight * 0.13;
  const torsoHeight = mannequinHeight * 0.45;
  const legHeight = mannequinHeight * 0.42;

  return (
    <div className="flex items-center justify-center py-12">
      <svg
        width="200"
        height={mannequinHeight}
        viewBox={`0 0 200 ${mannequinHeight}`}
        className="transition-all duration-500"
      >
        {/* Head */}
        <ellipse
          cx="100"
          cy={headHeight / 2}
          rx={headHeight * 0.6}
          ry={headHeight * 0.7}
          fill="none"
          stroke="black"
          strokeWidth="1.5"
        />
        
        {/* Neck */}
        <line
          x1="100"
          y1={headHeight}
          x2="100"
          y2={headHeight + 20}
          stroke="black"
          strokeWidth="1.5"
        />
        
        {/* Shoulders */}
        <line
          x1={100 - shoulderWidth / 2}
          y1={headHeight + 20}
          x2={100 + shoulderWidth / 2}
          y2={headHeight + 20}
          stroke="black"
          strokeWidth="1.5"
        />
        
        {/* Torso - narrowing to waist */}
        <path
          d={`
            M ${100 - shoulderWidth / 2} ${headHeight + 20}
            L ${100 - waistWidth / 2} ${headHeight + torsoHeight * 0.6}
            L ${100 - hipWidth / 2} ${headHeight + torsoHeight}
          `}
          fill="none"
          stroke="black"
          strokeWidth="1.5"
        />
        <path
          d={`
            M ${100 + shoulderWidth / 2} ${headHeight + 20}
            L ${100 + waistWidth / 2} ${headHeight + torsoHeight * 0.6}
            L ${100 + hipWidth / 2} ${headHeight + torsoHeight}
          `}
          fill="none"
          stroke="black"
          strokeWidth="1.5"
        />
        
        {/* Hips/Bottom of torso */}
        <line
          x1={100 - hipWidth / 2}
          y1={headHeight + torsoHeight}
          x2={100 + hipWidth / 2}
          y2={headHeight + torsoHeight}
          stroke="black"
          strokeWidth="1.5"
        />
        
        {/* Arms */}
        <line
          x1={100 - shoulderWidth / 2}
          y1={headHeight + 20}
          x2={100 - shoulderWidth / 2 - 15}
          y2={headHeight + torsoHeight * 0.7}
          stroke="black"
          strokeWidth="1.5"
        />
        <line
          x1={100 + shoulderWidth / 2}
          y1={headHeight + 20}
          x2={100 + shoulderWidth / 2 + 15}
          y2={headHeight + torsoHeight * 0.7}
          stroke="black"
          strokeWidth="1.5"
        />
        
        {/* Legs */}
        <line
          x1={100 - hipWidth / 2 + 10}
          y1={headHeight + torsoHeight}
          x2={100 - 15}
          y2={headHeight + torsoHeight + legHeight}
          stroke="black"
          strokeWidth="1.5"
        />
        <line
          x1={100 + hipWidth / 2 - 10}
          y1={headHeight + torsoHeight}
          x2={100 + 15}
          y2={headHeight + torsoHeight + legHeight}
          stroke="black"
          strokeWidth="1.5"
        />
      </svg>
    </div>
  );
}
