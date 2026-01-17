import { motion, useMotionValue, useTransform } from "motion/react";

interface OutfitCardProps {
  style: string;
  imageUrl?: string;
  onSwipe: (direction: "left" | "right") => void;
  index: number;
}

export function OutfitCard({ style, imageUrl, onSwipe, index }: OutfitCardProps) {
  const x = useMotionValue(0);
  const rotate = useTransform(x, [-200, 200], [-25, 25]);
  const opacity = useTransform(x, [-200, -100, 0, 100, 200], [0, 1, 1, 1, 0]);

  const handleDragEnd = () => {
    const threshold = 100;
    if (x.get() > threshold) {
      onSwipe("right");
    } else if (x.get() < -threshold) {
      onSwipe("left");
    }
  };

  return (
    <motion.div
      className="absolute w-full max-w-[300px]"
      style={{
        x,
        rotate,
        opacity,
        zIndex: 10 - index,
      }}
      drag="x"
      dragConstraints={{ left: 0, right: 0 }}
      onDragEnd={handleDragEnd}
      animate={{
        scale: 1 - index * 0.05,
        y: index * 10,
      }}
      transition={{
        type: "spring",
        stiffness: 300,
        damping: 30,
      }}
    >
      <div className="bg-white rounded-[32px] shadow-[0_8px_32px_rgba(0,0,0,0.08)] overflow-hidden">
        <div className="p-6 pb-5">
          {/* Outfit Illustration */}
          <div className="flex justify-center items-center h-[280px] mb-6">
            {imageUrl ? (
              <img
                src={imageUrl}
                alt={style}
                className="w-full h-full object-cover rounded-2xl"
              />
            ) : (
              <svg
                width="200"
                height="300"
                viewBox="0 0 200 300"
                fill="none"
                xmlns="http://www.w3.org/2000/svg"
                className="stroke-black"
              >
                {/* Head */}
                <circle cx="100" cy="40" r="25" strokeWidth="1.5" />
                
                {/* Body - Shirt/Top */}
                <path
                  d="M 75 65 L 75 140 L 125 140 L 125 65 Z"
                  strokeWidth="1.5"
                  fill="none"
                />
                
                {/* Collar */}
                <path
                  d="M 90 65 L 100 75 L 110 65"
                  strokeWidth="1.5"
                  fill="none"
                />
                
                {/* Arms */}
                <circle cx="75" cy="110" r="8" strokeWidth="1.5" />
                <circle cx="125" cy="110" r="8" strokeWidth="1.5" />
                
                {/* Pants/Bottom */}
                <path
                  d="M 80 140 L 85 240 M 85 240 L 95 240"
                  strokeWidth="1.5"
                />
                <path
                  d="M 120 140 L 115 240 M 115 240 L 105 240"
                  strokeWidth="1.5"
                />
                
                {/* Feet */}
                <ellipse cx="90" cy="245" rx="10" ry="5" strokeWidth="1.5" />
                <ellipse cx="110" cy="245" rx="10" ry="5" strokeWidth="1.5" />
              </svg>
            )}
          </div>

          {/* Style Label */}
          <p className="text-center text-gray-500 mb-5 tracking-wide text-sm">
            {style}
          </p>

          {/* View Details Button */}
          <button className="w-full bg-black text-white py-3 rounded-full hover:bg-gray-800 transition-colors text-sm">
            View Details
          </button>
        </div>
      </div>
    </motion.div>
  );
}