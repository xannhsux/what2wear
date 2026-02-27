"use client";

import { useCallback, useRef, useState } from "react";
import Image from "next/image";
import { cn } from "@/lib/utils";

interface MultiPhotoUploaderProps {
    photos: File[];
    previewUrls: string[];
    onAddPhotos: (files: File[]) => void;
    onRemovePhoto: (index: number) => void;
    disabled?: boolean;
}

const ACCEPTED_TYPES = ["image/jpeg", "image/png", "image/webp"];
const MAX_SIZE_MB = 10;

export function MultiPhotoUploader({
    photos,
    previewUrls,
    onAddPhotos,
    onRemovePhoto,
    disabled,
}: MultiPhotoUploaderProps) {
    const [isDragging, setIsDragging] = useState(false);
    const [error, setError] = useState<string | null>(null);
    const inputRef = useRef<HTMLInputElement>(null);

    const validateAndAdd = useCallback(
        (files: FileList | File[]) => {
            setError(null);
            const validFiles: File[] = [];

            for (const file of Array.from(files)) {
                if (!ACCEPTED_TYPES.includes(file.type)) {
                    setError("Only JPEG, PNG, or WebP images are accepted.");
                    continue;
                }
                if (file.size > MAX_SIZE_MB * 1024 * 1024) {
                    setError(`Images must be under ${MAX_SIZE_MB}MB each.`);
                    continue;
                }
                validFiles.push(file);
            }

            if (validFiles.length > 0) {
                onAddPhotos(validFiles);
            }
        },
        [onAddPhotos]
    );

    const handleDrop = useCallback(
        (e: React.DragEvent) => {
            e.preventDefault();
            setIsDragging(false);
            if (e.dataTransfer.files.length > 0) {
                validateAndAdd(e.dataTransfer.files);
            }
        },
        [validateAndAdd]
    );

    const handleChange = useCallback(
        (e: React.ChangeEvent<HTMLInputElement>) => {
            if (e.target.files && e.target.files.length > 0) {
                validateAndAdd(e.target.files);
            }
            // Reset input so the same files can be selected again
            if (inputRef.current) inputRef.current.value = "";
        },
        [validateAndAdd]
    );

    return (
        <div className="w-full">
            {/* Photo Grid */}
            {previewUrls.length > 0 && (
                <div className="mb-4 grid grid-cols-4 gap-3 sm:grid-cols-5">
                    {previewUrls.map((url, i) => (
                        <div
                            key={url}
                            className="group relative aspect-square overflow-hidden rounded-xl border border-gray-100 shadow-sm"
                        >
                            <Image
                                src={url}
                                alt={`Training photo ${i + 1}`}
                                fill
                                className="object-cover"
                            />
                            {!disabled && (
                                <button
                                    onClick={() => onRemovePhoto(i)}
                                    className="absolute right-1 top-1 flex h-6 w-6 items-center justify-center rounded-full bg-black/50 text-white opacity-0 transition-opacity group-hover:opacity-100 hover:bg-black/70"
                                    aria-label="Remove photo"
                                >
                                    <svg
                                        className="h-3.5 w-3.5"
                                        fill="none"
                                        viewBox="0 0 24 24"
                                        stroke="currentColor"
                                        strokeWidth={2}
                                    >
                                        <path
                                            strokeLinecap="round"
                                            strokeLinejoin="round"
                                            d="M6 18L18 6M6 6l12 12"
                                        />
                                    </svg>
                                </button>
                            )}
                        </div>
                    ))}

                    {/* Add more button */}
                    {photos.length < 20 && !disabled && (
                        <button
                            onClick={() => inputRef.current?.click()}
                            className="flex aspect-square items-center justify-center rounded-xl border-2 border-dashed border-gray-200 text-gray-400 transition-colors hover:border-accent hover:text-accent"
                        >
                            <svg
                                className="h-6 w-6"
                                fill="none"
                                viewBox="0 0 24 24"
                                stroke="currentColor"
                                strokeWidth={1.5}
                            >
                                <path
                                    strokeLinecap="round"
                                    strokeLinejoin="round"
                                    d="M12 4.5v15m7.5-7.5h-15"
                                />
                            </svg>
                        </button>
                    )}
                </div>
            )}

            {/* Drop zone (shown when no photos or always as fallback) */}
            {previewUrls.length === 0 && (
                <div
                    onClick={() => !disabled && inputRef.current?.click()}
                    onDragEnter={(e) => {
                        e.preventDefault();
                        if (!disabled) setIsDragging(true);
                    }}
                    onDragOver={(e) => {
                        e.preventDefault();
                        if (!disabled) setIsDragging(true);
                    }}
                    onDragLeave={() => setIsDragging(false)}
                    onDrop={handleDrop}
                    className={cn(
                        "flex cursor-pointer flex-col items-center justify-center rounded-2xl border-2 border-dashed px-6 py-16 transition-all duration-200",
                        disabled && "pointer-events-none opacity-50",
                        isDragging
                            ? "border-accent bg-accent-light scale-[1.01]"
                            : "border-gray-200 hover:border-gray-400"
                    )}
                >
                    <div className="mb-4 flex h-16 w-16 items-center justify-center rounded-2xl bg-gradient-to-br from-accent/10 to-accent/5">
                        <svg
                            className="h-7 w-7 text-accent"
                            fill="none"
                            viewBox="0 0 24 24"
                            stroke="currentColor"
                            strokeWidth={1.5}
                        >
                            <path
                                strokeLinecap="round"
                                strokeLinejoin="round"
                                d="M2.25 15.75l5.159-5.159a2.25 2.25 0 013.182 0l5.159 5.159m-1.5-1.5l1.409-1.409a2.25 2.25 0 013.182 0l2.909 2.909M3.75 21h16.5A2.25 2.25 0 0022.5 18.75V5.25A2.25 2.25 0 0020.25 3H3.75A2.25 2.25 0 001.5 5.25v13.5A2.25 2.25 0 003.75 21z"
                            />
                        </svg>
                    </div>
                    <p className="text-sm font-medium text-gray-700">
                        Drop your photos here or click to browse
                    </p>
                    <p className="mt-1.5 text-xs text-gray-400">
                        Upload 4–20 photos · JPEG, PNG, or WebP · Max {MAX_SIZE_MB}MB each
                    </p>
                </div>
            )}

            {/* Photo count & status */}
            {photos.length > 0 && (
                <div className="mt-3 flex items-center justify-between">
                    <p className="text-sm text-gray-500">
                        <span className="font-medium text-gray-700">{photos.length}</span>{" "}
                        photo{photos.length !== 1 ? "s" : ""} selected
                        {photos.length < 4 && (
                            <span className="text-amber-500">
                                {" "}
                                · Need at least {4 - photos.length} more
                            </span>
                        )}
                    </p>
                    {photos.length >= 4 && (
                        <span className="flex items-center gap-1 text-xs font-medium text-green-600">
                            <svg
                                className="h-3.5 w-3.5"
                                fill="none"
                                viewBox="0 0 24 24"
                                stroke="currentColor"
                                strokeWidth={2}
                            >
                                <path
                                    strokeLinecap="round"
                                    strokeLinejoin="round"
                                    d="M4.5 12.75l6 6 9-13.5"
                                />
                            </svg>
                            Ready to train
                        </span>
                    )}
                </div>
            )}

            {error && (
                <p className="mt-3 text-center text-sm text-red-500">{error}</p>
            )}

            <input
                ref={inputRef}
                type="file"
                accept="image/jpeg,image/png,image/webp"
                multiple
                onChange={handleChange}
                className="hidden"
                disabled={disabled}
            />

            {/* Tips */}
            <div className="mt-6 rounded-xl bg-gray-50/80 p-4">
                <p className="mb-2 text-xs font-semibold uppercase tracking-wider text-gray-400">
                    Tips for best results
                </p>
                <ul className="space-y-1.5 text-sm text-gray-500">
                    <li className="flex items-start gap-2">
                        <span className="mt-0.5 text-accent">•</span>
                        Use clear, well-lit photos of yourself
                    </li>
                    <li className="flex items-start gap-2">
                        <span className="mt-0.5 text-accent">•</span>
                        Include different angles: front, side, 3/4 view
                    </li>
                    <li className="flex items-start gap-2">
                        <span className="mt-0.5 text-accent">•</span>
                        Variety in backgrounds and clothing helps
                    </li>
                    <li className="flex items-start gap-2">
                        <span className="mt-0.5 text-accent">•</span>
                        Avoid heavy filters, sunglasses, or face coverings
                    </li>
                </ul>
            </div>
        </div>
    );
}
