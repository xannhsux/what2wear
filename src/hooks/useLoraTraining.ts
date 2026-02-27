"use client";

import { useState, useCallback, useRef } from "react";
import type {
    LoraTrainingState,
    SavedLoraProfile,
    TrainingResult,
} from "@/types/lora";
import { compressImage, sleep } from "@/lib/utils";
import { useLocalStorage } from "./useLocalStorage";

const POLL_INTERVAL_MS = 3000;
const MAX_POLL_ATTEMPTS = 300; // ~15 minutes max

const initialState: LoraTrainingState = {
    step: "idle",
    photos: [],
    photoPreviewUrls: [],
    requestId: null,
    loraUrl: null,
    triggerWord: "TOK",
    error: null,
    progress: 0,
};

export function useLoraTraining() {
    const [state, setState] = useState<LoraTrainingState>(initialState);
    const [savedProfile, setSavedProfile] =
        useLocalStorage<SavedLoraProfile | null>("what2wear_lora_profile", null);
    const abortRef = useRef(false);

    // Add photos to the training set
    const addPhotos = useCallback((files: File[]) => {
        setState((prev) => {
            const newPhotos = [...prev.photos, ...files].slice(0, 20); // max 20
            const newPreviews = [
                ...prev.photoPreviewUrls,
                ...files.map((f) => URL.createObjectURL(f)),
            ].slice(0, 20);
            return {
                ...prev,
                photos: newPhotos,
                photoPreviewUrls: newPreviews,
                error: null,
            };
        });
    }, []);

    // Remove a photo by index
    const removePhoto = useCallback((index: number) => {
        setState((prev) => {
            URL.revokeObjectURL(prev.photoPreviewUrls[index]);
            const newPhotos = prev.photos.filter((_, i) => i !== index);
            const newPreviews = prev.photoPreviewUrls.filter((_, i) => i !== index);
            return {
                ...prev,
                photos: newPhotos,
                photoPreviewUrls: newPreviews,
            };
        });
    }, []);

    // Clear all photos and reset
    const clearAll = useCallback(() => {
        setState((prev) => {
            prev.photoPreviewUrls.forEach((url) => URL.revokeObjectURL(url));
            return { ...initialState };
        });
    }, []);

    // Start LoRA training
    const startTraining = useCallback(async () => {
        if (state.photos.length < 4) {
            setState((prev) => ({
                ...prev,
                error: "Please upload at least 4 photos for training.",
            }));
            return;
        }

        abortRef.current = false;
        setState((prev) => ({
            ...prev,
            step: "uploading",
            error: null,
            progress: 0,
        }));

        try {
            // Step 1: Compress all images to base64
            const base64Images = await Promise.all(
                state.photos.map((photo) => compressImage(photo, 1024, 0.9))
            );

            if (abortRef.current) return;

            setState((prev) => ({ ...prev, progress: 10 }));

            // Step 2: Upload images (creates a zip and uploads to Replicate storage)
            const uploadRes = await fetch("/api/upload-images", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ images: base64Images }),
            });

            if (!uploadRes.ok) {
                const err = await uploadRes.json();
                throw new Error(err.detail || "Failed to upload images");
            }

            const { imagesDataUrl } = await uploadRes.json();

            if (abortRef.current) return;

            setState((prev) => ({ ...prev, step: "training", progress: 20 }));

            // Step 3: Submit training job
            const trainRes = await fetch("/api/train-lora", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({
                    imagesDataUrl,
                    triggerWord: state.triggerWord,
                    steps: 1000,
                }),
            });

            if (!trainRes.ok) {
                const err = await trainRes.json();
                throw new Error(err.detail || "Failed to start training");
            }

            const { requestId } = await trainRes.json();
            setState((prev) => ({ ...prev, requestId }));

            // Step 4: Poll for training completion
            let attempts = 0;
            while (attempts < MAX_POLL_ATTEMPTS && !abortRef.current) {
                await sleep(POLL_INTERVAL_MS);
                attempts++;

                const pollRes = await fetch(`/api/train-lora/${requestId}`);
                if (!pollRes.ok) {
                    throw new Error("Failed to check training status");
                }

                const result = await pollRes.json();

                // Update progress (20% -> 95% during training)
                const trainingProgress = Math.min(
                    20 + (attempts / 200) * 75,
                    95
                );
                setState((prev) => ({ ...prev, progress: trainingProgress }));

                if (result.status === "COMPLETED" && result.data) {
                    const data = result.data as TrainingResult;
                    const loraUrl = data.diffusers_lora_file.url;

                    // Save to localStorage
                    setSavedProfile({
                        loraUrl,
                        triggerWord: state.triggerWord,
                        trainedAt: new Date().toISOString(),
                    });

                    setState((prev) => ({
                        ...prev,
                        step: "ready",
                        loraUrl,
                        progress: 100,
                    }));
                    return;
                }

                if (result.status === "FAILED") {
                    throw new Error("Training failed. Please try again.");
                }
            }

            if (!abortRef.current) {
                throw new Error("Training timed out. Please try again.");
            }
        } catch (err) {
            if (!abortRef.current) {
                setState((prev) => ({
                    ...prev,
                    step: "failed",
                    error: err instanceof Error ? err.message : "Something went wrong",
                }));
            }
        }
    }, [state.photos, state.triggerWord, setSavedProfile]);

    // Reset everything
    const reset = useCallback(() => {
        abortRef.current = true;
        setState((prev) => {
            prev.photoPreviewUrls.forEach((url) => URL.revokeObjectURL(url));
            return { ...initialState };
        });
    }, []);

    // Load existing LoRA profile (skip training)
    const loadExistingProfile = useCallback(() => {
        if (savedProfile) {
            setState((prev) => ({
                ...prev,
                step: "ready",
                loraUrl: savedProfile.loraUrl,
                triggerWord: savedProfile.triggerWord,
                progress: 100,
            }));
        }
    }, [savedProfile]);

    return {
        state,
        savedProfile,
        addPhotos,
        removePhoto,
        clearAll,
        startTraining,
        reset,
        loadExistingProfile,
    };
}
