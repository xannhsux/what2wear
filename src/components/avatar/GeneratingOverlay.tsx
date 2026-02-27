"use client";

import { useState, useEffect } from "react";
import { Spinner } from "@/components/ui/Spinner";

const STATUS_MESSAGES = [
  "Swapping your face onto the avatar...",
  "Blending features...",
  "Adding finishing touches...",
  "Almost there...",
];

interface GeneratingOverlayProps {
  pollCount: number;
}

export function GeneratingOverlay({ pollCount }: GeneratingOverlayProps) {
  const [messageIndex, setMessageIndex] = useState(0);

  useEffect(() => {
    const interval = setInterval(() => {
      setMessageIndex((i) => (i + 1) % STATUS_MESSAGES.length);
    }, 4000);
    return () => clearInterval(interval);
  }, []);

  return (
    <div className="flex flex-col items-center py-12">
      <Spinner size="lg" className="text-accent" />
      <p className="mt-6 text-lg font-medium transition-opacity duration-300">
        {STATUS_MESSAGES[messageIndex]}
      </p>
      <p className="mt-2 text-sm text-gray-400">
        This usually takes 30&ndash;60 seconds
      </p>

      {/* Progress bar */}
      <div className="mt-8 h-1 w-64 overflow-hidden rounded-full bg-gray-100">
        <div
          className="h-full rounded-full bg-accent transition-all duration-500 ease-out"
          style={{
            width: `${Math.min((pollCount / 60) * 100, 95)}%`,
          }}
        />
      </div>
      <p className="mt-2 text-xs text-gray-300">{pollCount}s elapsed</p>
    </div>
  );
}
