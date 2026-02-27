"use client";

import { useState } from "react";
import Image from "next/image";
import { Button } from "@/components/ui/Button";

interface AvatarResultProps {
  avatarUrl: string;
  onSave: () => void;
  onRegenerate: () => void;
  onNewPhoto: () => void;
}

export function AvatarResult({
  avatarUrl,
  onSave,
  onRegenerate,
  onNewPhoto,
}: AvatarResultProps) {
  const [saved, setSaved] = useState(false);

  const handleSave = () => {
    onSave();
    setSaved(true);
  };

  return (
    <div className="flex animate-fade-in flex-col items-center">
      <div className="relative h-80 w-80 overflow-hidden rounded-2xl border border-gray-100 shadow-lg">
        <Image
          src={avatarUrl}
          alt="Your generated avatar"
          fill
          className="object-cover"
          unoptimized
        />
      </div>

      {saved && (
        <p className="mt-4 text-sm font-medium text-green-600">
          Avatar saved!
        </p>
      )}

      <div className="mt-6 flex flex-wrap justify-center gap-3">
        {!saved ? (
          <Button variant="primary" onClick={handleSave}>
            Save Avatar
          </Button>
        ) : (
          <Button variant="primary" onClick={onNewPhoto}>
            Done
          </Button>
        )}
        <Button variant="secondary" onClick={onRegenerate}>
          Regenerate
        </Button>
        <Button variant="ghost" onClick={onNewPhoto}>
          Upload New Photo
        </Button>
      </div>
    </div>
  );
}
