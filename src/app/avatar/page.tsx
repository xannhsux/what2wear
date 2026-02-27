"use client";

import { useCallback, useRef, useState } from "react";
import Image from "next/image";
import { useFaceSwap } from "@/hooks/useFaceSwap";
import { Button } from "@/components/ui/Button";
import { Spinner } from "@/components/ui/Spinner";
import { cn } from "@/lib/utils";

const ACCEPTED_TYPES = ["image/jpeg", "image/png", "image/webp"];
const MAX_SIZE_MB = 10;

export default function AvatarPage() {
  const { state, setPhoto, clearPhoto, generate, reset } = useFaceSwap();
  const fileInputRef = useRef<HTMLInputElement>(null);
  const [dragOver, setDragOver] = useState(false);

  const handleFiles = useCallback(
    (files: FileList | File[]) => {
      const file = Array.from(files).find((f) =>
        ACCEPTED_TYPES.includes(f.type)
      );
      if (!file) return;
      if (file.size > MAX_SIZE_MB * 1024 * 1024) return;
      setPhoto(file);
    },
    [setPhoto]
  );

  const handleDrop = useCallback(
    (e: React.DragEvent) => {
      e.preventDefault();
      setDragOver(false);
      if (e.dataTransfer.files.length) {
        handleFiles(e.dataTransfer.files);
      }
    },
    [handleFiles]
  );

  const isProcessing =
    state.step === "uploading" || state.step === "processing";

  return (
    <div className="mx-auto max-w-2xl px-6 pb-24 pt-28">
      <h1 className="mb-2 text-center text-3xl font-bold tracking-tight">
        Create Your Avatar
      </h1>
      <p className="mb-10 text-center text-gray-500">
        Upload a clear photo of your face and we&apos;ll create your
        personalized avatar
      </p>

      {/* ─── Result View ─── */}
      {state.step === "succeeded" && state.resultUrl && (
        <div className="flex flex-col items-center animate-fade-in">
          <div className="relative overflow-hidden rounded-2xl border border-gray-100 shadow-xl">
            <Image
              src={state.resultUrl}
              alt="Your generated avatar"
              width={512}
              height={680}
              className="h-auto w-full max-w-sm"
              unoptimized
            />
          </div>

          <div className="mt-6 flex flex-wrap justify-center gap-3">
            <Button
              variant="primary"
              onClick={() => {
                const link = document.createElement("a");
                link.href = state.resultUrl!;
                link.download = `avatar-${Date.now()}.png`;
                link.click();
              }}
            >
              <svg
                className="mr-1.5 h-4 w-4"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
                strokeWidth={2}
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  d="M3 16.5v2.25A2.25 2.25 0 005.25 21h13.5A2.25 2.25 0 0021 18.75V16.5M16.5 12L12 16.5m0 0L7.5 12m4.5 4.5V3"
                />
              </svg>
              Download
            </Button>
            <Button
              variant="secondary"
              onClick={reset}
            >
              Try Another Photo
            </Button>
          </div>
        </div>
      )}

      {/* ─── Processing View ─── */}
      {isProcessing && (
        <div className="flex flex-col items-center py-12 animate-fade-in">
          {/* Show the user's uploaded photo with pulsing overlay */}
          <div className="relative mb-8">
            <div className="relative h-64 w-52 overflow-hidden rounded-2xl border border-gray-100 shadow-lg">
              {state.photoPreviewUrl ? (
                <Image
                  src={state.photoPreviewUrl}
                  alt="Your photo"
                  fill
                  className="object-cover opacity-50"
                />
              ) : (
                <div className="h-full w-full bg-gray-100" />
              )}
              <div className="absolute inset-0 bg-gradient-to-b from-accent/10 to-accent/5 animate-pulse" />
              <div className="absolute inset-0 flex items-center justify-center">
                <Spinner size="lg" className="text-accent" />
              </div>
            </div>
          </div>

          <p className="text-lg font-medium text-gray-900">
            {state.step === "uploading"
              ? "Uploading your photo…"
              : "Creating your avatar…"}
          </p>
          <p className="mt-2 text-sm text-gray-400">
            {state.step === "uploading"
              ? "Preparing your image for processing"
              : "This may take 1–3 minutes on first run"}
          </p>

          {/* Animated progress dots */}
          <div className="mt-6 flex gap-1.5">
            {[0, 1, 2].map((i) => (
              <div
                key={i}
                className="h-2 w-2 rounded-full bg-accent/60 animate-bounce"
                style={{
                  animationDelay: `${i * 0.15}s`,
                  animationDuration: "0.8s",
                }}
              />
            ))}
          </div>
        </div>
      )}

      {/* ─── Upload + Preview View ─── */}
      {state.step !== "succeeded" && !isProcessing && (
        <div className="w-full">
          {/* Avatar preview area */}
          <div className="mb-8 flex justify-center">
            <div className="relative">
              <div className="relative flex h-72 w-56 items-center justify-center overflow-hidden rounded-2xl border border-gray-100 bg-gradient-to-b from-gray-50 to-gray-100 shadow-lg">
                <svg className="h-32 w-32 text-gray-300" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z" />
                </svg>
              </div>
              <div className="absolute -bottom-3 left-1/2 -translate-x-1/2 rounded-full bg-white px-3 py-1 shadow-md border border-gray-100">
                <p className="text-xs font-medium text-gray-500 whitespace-nowrap">
                  Upload a photo to create your avatar
                </p>
              </div>
            </div>
          </div>

          {/* Upload area */}
          <div
            className={cn(
              "relative mt-6 flex cursor-pointer flex-col items-center justify-center rounded-2xl border-2 border-dashed p-8 transition-all",
              dragOver
                ? "border-accent bg-accent/5 scale-[1.02]"
                : state.photoPreviewUrl
                  ? "border-green-300 bg-green-50/50"
                  : "border-gray-200 bg-gray-50/50 hover:border-gray-300 hover:bg-gray-50",
              isProcessing && "pointer-events-none opacity-50"
            )}
            onClick={() => fileInputRef.current?.click()}
            onDragOver={(e) => {
              e.preventDefault();
              setDragOver(true);
            }}
            onDragLeave={() => setDragOver(false)}
            onDrop={handleDrop}
          >
            <input
              ref={fileInputRef}
              type="file"
              accept={ACCEPTED_TYPES.join(",")}
              className="hidden"
              onChange={(e) => {
                if (e.target.files?.length) {
                  handleFiles(e.target.files);
                }
              }}
            />

            {state.photoPreviewUrl ? (
              <div className="flex items-center gap-4">
                <div className="relative h-20 w-20 overflow-hidden rounded-full border-2 border-green-300 shadow-md">
                  <Image
                    src={state.photoPreviewUrl}
                    alt="Your face"
                    fill
                    className="object-cover"
                  />
                </div>
                <div className="text-left">
                  <p className="text-sm font-medium text-green-700">
                    Photo ready!
                  </p>
                  <p className="text-xs text-gray-400">
                    Click to change or tap Generate below
                  </p>
                </div>
              </div>
            ) : (
              <>
                <div className="mb-3 flex h-12 w-12 items-center justify-center rounded-full bg-gray-100">
                  <svg
                    className="h-6 w-6 text-gray-400"
                    fill="none"
                    viewBox="0 0 24 24"
                    stroke="currentColor"
                    strokeWidth={1.5}
                  >
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      d="M15.75 6a3.75 3.75 0 11-7.5 0 3.75 3.75 0 017.5 0zM4.501 20.118a7.5 7.5 0 0114.998 0A17.933 17.933 0 0112 21.75c-2.676 0-5.216-.584-7.499-1.632z"
                    />
                  </svg>
                </div>
                <p className="text-sm font-medium text-gray-700">
                  Upload a clear face photo
                </p>
                <p className="mt-1 text-xs text-gray-400">
                  Drag & drop or click to browse · JPG, PNG, WEBP · Max{" "}
                  {MAX_SIZE_MB}MB
                </p>
              </>
            )}
          </div>

          {/* Tips */}
          <div className="mt-4 rounded-xl bg-blue-50/70 p-4">
            <p className="text-xs font-semibold text-blue-700 mb-1.5">
              📸 Tips for best results:
            </p>
            <ul className="text-xs text-blue-600/80 space-y-0.5">
              <li>• Use a front-facing photo with clear lighting</li>
              <li>• Make sure your full face and hairstyle are visible</li>
              <li>• Avoid sunglasses or heavy face obstructions</li>
            </ul>
          </div>

          {/* Error */}
          {state.error && (
            <div className="mt-4 rounded-lg bg-red-50 p-3 text-center text-sm text-red-600">
              {state.error}
            </div>
          )}

          {/* Actions */}
          <div className="mt-6 flex flex-col gap-3 sm:flex-row">
            <Button
              variant="primary"
              size="lg"
              onClick={generate}
              disabled={!state.photo || isProcessing}
              className="w-full sm:flex-1"
            >
              <svg
                className="mr-2 h-4 w-4"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
                strokeWidth={2}
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  d="M9.813 15.904L9 18.75l-.813-2.846a4.5 4.5 0 00-3.09-3.09L2.25 12l2.846-.813a4.5 4.5 0 003.09-3.09L9 5.25l.813 2.846a4.5 4.5 0 003.09 3.09L15.75 12l-2.846.813a4.5 4.5 0 00-3.09 3.09zM18.259 8.715L18 9.75l-.259-1.035a3.375 3.375 0 00-2.455-2.456L14.25 6l1.036-.259a3.375 3.375 0 002.455-2.456L18 2.25l.259 1.035a3.375 3.375 0 002.455 2.456L21.75 6l-1.036.259a3.375 3.375 0 00-2.455 2.456zM16.894 20.567L16.5 21.75l-.394-1.183a2.25 2.25 0 00-1.423-1.423L13.5 18.75l1.183-.394a2.25 2.25 0 001.423-1.423l.394-1.183.394 1.183a2.25 2.25 0 001.423 1.423l1.183.394-1.183.394a2.25 2.25 0 00-1.423 1.423z"
                />
              </svg>
              Generate Avatar
            </Button>
            {state.photo && (
              <Button variant="ghost" onClick={clearPhoto}>
                Clear
              </Button>
            )}
          </div>
        </div>
      )}

      {/* ─── Failed State ─── */}
      {state.step === "failed" && !state.photo && (
        <div className="flex flex-col items-center py-12">
          <div className="mb-4 flex h-14 w-14 items-center justify-center rounded-full bg-red-50">
            <svg
              className="h-6 w-6 text-red-500"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
              strokeWidth={1.5}
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                d="M12 9v3.75m9-.75a9 9 0 11-18 0 9 9 0 0118 0zm-9 3.75h.008v.008H12v-.008z"
              />
            </svg>
          </div>
          <p className="text-lg font-medium">Avatar Generation Failed</p>
          <p className="mt-2 text-center text-sm text-gray-500">
            {state.error}
          </p>
          <div className="mt-6">
            <Button variant="primary" onClick={reset}>
              Try Again
            </Button>
          </div>
        </div>
      )}
    </div>
  );
}
