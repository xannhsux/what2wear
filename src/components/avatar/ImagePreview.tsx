"use client";

import Image from "next/image";
import { Button } from "@/components/ui/Button";

interface ImagePreviewProps {
  previewUrl: string;
  onRetake: () => void;
  onGenerate: () => void;
  loading?: boolean;
}

export function ImagePreview({
  previewUrl,
  onRetake,
  onGenerate,
  loading,
}: ImagePreviewProps) {
  return (
    <div className="flex flex-col items-center">
      <div className="relative h-72 w-72 overflow-hidden rounded-2xl border border-gray-100 shadow-sm">
        <Image
          src={previewUrl}
          alt="Your selfie"
          fill
          className="object-cover"
        />
      </div>
      <p className="mt-3 text-sm text-gray-400">
        Your face will be swapped onto the avatar body
      </p>
      <div className="mt-6 flex gap-3">
        <Button variant="secondary" onClick={onRetake} disabled={loading}>
          Retake
        </Button>
        <Button variant="primary" onClick={onGenerate} loading={loading}>
          Generate Avatar
        </Button>
      </div>
    </div>
  );
}
