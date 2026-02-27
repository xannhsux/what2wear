"use client";

import { useState } from "react";
import Image from "next/image";
import { Button } from "@/components/ui/Button";
import { Spinner } from "@/components/ui/Spinner";

const PRESET_PROMPTS = [
    {
        label: "Professional Headshot",
        prompt:
            "wearing a navy blue blazer and white shirt, professional corporate headshot, studio lighting, clean background",
    },
    {
        label: "Casual Everyday",
        prompt:
            "wearing a casual t-shirt and jeans, standing in a sunny park, natural lighting, relaxed pose",
    },
    {
        label: "Street Fashion",
        prompt:
            "wearing trendy streetwear outfit, urban city background, golden hour lighting, fashion photography style",
    },
    {
        label: "Elegant Evening",
        prompt:
            "wearing elegant evening wear, standing in a luxurious setting, dramatic lighting, glamorous style",
    },
    {
        label: "Active Lifestyle",
        prompt:
            "wearing athletic sportswear, outdoors fitness setting, energetic pose, bright natural lighting",
    },
    {
        label: "Winter Cozy",
        prompt:
            "wearing a warm wool coat and scarf, snowy winter scene, cozy atmosphere, soft lighting",
    },
];

interface AvatarGeneratorProps {
    triggerWord: string;
    prompt: string;
    onPromptChange: (prompt: string) => void;
    onGenerate: () => void;
    isGenerating: boolean;
    imageUrl: string | null;
    error: string | null;
    onClear: () => void;
}

export function AvatarGenerator({
    triggerWord,
    prompt,
    onPromptChange,
    onGenerate,
    isGenerating,
    imageUrl,
    error,
    onClear,
}: AvatarGeneratorProps) {
    const [showResult, setShowResult] = useState(false);

    // Show result view when image is ready
    if (imageUrl && !showResult) {
        setShowResult(true);
    }

    if (showResult && imageUrl) {
        return (
            <div className="flex flex-col items-center animate-fade-in">
                <div className="relative overflow-hidden rounded-2xl border border-gray-100 shadow-xl">
                    <Image
                        src={imageUrl}
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
                            // Download image
                            const link = document.createElement("a");
                            link.href = imageUrl;
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
                        onClick={() => {
                            setShowResult(false);
                            onClear();
                        }}
                    >
                        Generate Another
                    </Button>
                </div>
            </div>
        );
    }

    return (
        <div className="w-full">
            {/* Success banner */}
            <div className="mb-6 flex items-center gap-3 rounded-xl bg-green-50 p-4">
                <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-green-100">
                    <svg
                        className="h-5 w-5 text-green-600"
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
                </div>
                <div>
                    <p className="text-sm font-semibold text-green-800">
                        Your personal AI model is ready!
                    </p>
                    <p className="text-xs text-green-600">
                        Describe any outfit or scene to see yourself in it
                    </p>
                </div>
            </div>

            {/* Prompt input */}
            <div className="mb-4">
                <label
                    htmlFor="prompt-input"
                    className="mb-2 block text-sm font-medium text-gray-700"
                >
                    Describe your avatar
                </label>
                <textarea
                    id="prompt-input"
                    value={prompt}
                    onChange={(e) => onPromptChange(e.target.value)}
                    placeholder={`e.g., "wearing a leather jacket, standing on a rooftop at sunset"`}
                    rows={3}
                    disabled={isGenerating}
                    className="w-full resize-none rounded-xl border border-gray-200 bg-white px-4 py-3 text-sm text-gray-900 placeholder:text-gray-400 focus:border-accent focus:outline-none focus:ring-2 focus:ring-accent/20 disabled:opacity-50"
                />
                <p className="mt-1.5 text-xs text-gray-400">
                    The trigger word <code className="rounded bg-gray-100 px-1.5 py-0.5 font-mono text-accent">{triggerWord}</code> will be added automatically
                </p>
            </div>

            {/* Preset prompts */}
            <div className="mb-6">
                <p className="mb-2 text-xs font-semibold uppercase tracking-wider text-gray-400">
                    Quick styles
                </p>
                <div className="flex flex-wrap gap-2">
                    {PRESET_PROMPTS.map((preset) => (
                        <button
                            key={preset.label}
                            onClick={() => onPromptChange(preset.prompt)}
                            disabled={isGenerating}
                            className="rounded-full border border-gray-200 bg-white px-3.5 py-1.5 text-xs font-medium text-gray-600 transition-all hover:border-accent hover:text-accent active:scale-95 disabled:opacity-50"
                        >
                            {preset.label}
                        </button>
                    ))}
                </div>
            </div>

            {error && (
                <div className="mb-4 rounded-lg bg-red-50 p-3 text-center text-sm text-red-600">
                    {error}
                </div>
            )}

            {/* Generate button */}
            <Button
                variant="primary"
                size="lg"
                onClick={onGenerate}
                loading={isGenerating}
                disabled={!prompt.trim() || isGenerating}
                className="w-full"
            >
                {isGenerating ? (
                    <>
                        <Spinner size="sm" className="mr-2" />
                        Generating your avatar…
                    </>
                ) : (
                    <>
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
                    </>
                )}
            </Button>
        </div>
    );
}
