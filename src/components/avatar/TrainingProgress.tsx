"use client";

import { useEffect, useState } from "react";
import { Spinner } from "@/components/ui/Spinner";

const TRAINING_MESSAGES = [
    "Uploading your photos…",
    "Preparing training data…",
    "AI is learning your features…",
    "Refining facial details…",
    "Learning your unique style…",
    "Building your personal model…",
    "Optimizing quality…",
    "Almost ready…",
];

interface TrainingProgressProps {
    step: "uploading" | "training";
    progress: number;
}

export function TrainingProgress({ step, progress }: TrainingProgressProps) {
    const [messageIndex, setMessageIndex] = useState(0);

    useEffect(() => {
        const interval = setInterval(() => {
            setMessageIndex((i) => (i + 1) % TRAINING_MESSAGES.length);
        }, 5000);
        return () => clearInterval(interval);
    }, []);

    // Adjust message based on step
    const message =
        step === "uploading"
            ? TRAINING_MESSAGES[0]
            : TRAINING_MESSAGES[messageIndex];

    return (
        <div className="flex flex-col items-center py-12">
            {/* Animated orb */}
            <div className="relative mb-8">
                <div className="h-24 w-24 rounded-full bg-gradient-to-br from-accent/20 to-accent/5 animate-pulse" />
                <div className="absolute inset-0 flex items-center justify-center">
                    <Spinner size="lg" className="text-accent" />
                </div>
            </div>

            {/* Message */}
            <p className="text-lg font-medium text-gray-900 transition-opacity duration-500">
                {message}
            </p>
            <p className="mt-2 text-sm text-gray-400">
                {step === "uploading"
                    ? "Preparing your images for training…"
                    : "This typically takes 10–15 minutes"}
            </p>

            {/* Progress bar */}
            <div className="mt-8 w-72">
                <div className="h-1.5 w-full overflow-hidden rounded-full bg-gray-100">
                    <div
                        className="h-full rounded-full bg-gradient-to-r from-accent to-accent/70 transition-all duration-700 ease-out"
                        style={{ width: `${Math.min(progress, 98)}%` }}
                    />
                </div>
                <div className="mt-2 flex justify-between text-xs text-gray-400">
                    <span>{Math.round(progress)}%</span>
                    <span>
                        {step === "uploading"
                            ? "Uploading"
                            : progress < 30
                                ? "Starting"
                                : progress < 70
                                    ? "Training"
                                    : "Finalizing"}
                    </span>
                </div>
            </div>

            {/* Estimated time */}
            {step === "training" && (
                <div className="mt-6 rounded-lg bg-amber-50 px-4 py-2.5 text-center">
                    <p className="text-xs font-medium text-amber-700">
                        💡 You can leave this page open — training continues on our servers
                    </p>
                </div>
            )}
        </div>
    );
}
