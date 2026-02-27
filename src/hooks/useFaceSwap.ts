"use client";

import { useState, useCallback, useRef } from "react";
import { compressImage, sleep } from "@/lib/utils";

const POLL_INTERVAL_MS = 4000;
const MAX_POLL_ATTEMPTS = 150; // ~10 minutes max (handles cold starts)

export type FaceSwapStep =
    | "idle"         // Ready to upload a photo
    | "uploading"    // Sending face image to API
    | "processing"   // Face swap in progress
    | "succeeded"    // Done — avatar ready
    | "failed";      // Error

export interface FaceSwapState {
    step: FaceSwapStep;
    photo: File | null;
    photoPreviewUrl: string | null;
    resultUrl: string | null;
    error: string | null;
}

const initialState: FaceSwapState = {
    step: "idle",
    photo: null,
    photoPreviewUrl: null,
    resultUrl: null,
    error: null,
};

export function useFaceSwap() {
    const [state, setState] = useState<FaceSwapState>(initialState);
    const abortRef = useRef(false);

    /** Set the user's face photo */
    const setPhoto = useCallback((file: File) => {
        setState((prev) => {
            // Revoke old preview URL
            if (prev.photoPreviewUrl) {
                URL.revokeObjectURL(prev.photoPreviewUrl);
            }
            return {
                ...prev,
                photo: file,
                photoPreviewUrl: URL.createObjectURL(file),
                error: null,
                resultUrl: null,
                step: "idle",
            };
        });
    }, []);

    /** Clear the photo */
    const clearPhoto = useCallback(() => {
        setState((prev) => {
            if (prev.photoPreviewUrl) {
                URL.revokeObjectURL(prev.photoPreviewUrl);
            }
            return { ...initialState };
        });
    }, []);

    /** Run face swap */
    const generate = useCallback(async () => {
        if (!state.photo) {
            setState((prev) => ({
                ...prev,
                error: "Please upload a photo first.",
            }));
            return;
        }

        abortRef.current = false;
        setState((prev) => ({
            ...prev,
            step: "uploading",
            error: null,
            resultUrl: null,
        }));

        try {
            // Step 1: Compress the photo to base64
            const base64Image = await compressImage(state.photo, 1024, 0.9);

            if (abortRef.current) return;

            setState((prev) => ({ ...prev, step: "processing" }));

            // Step 2: Submit face swap
            const swapRes = await fetch("/api/face-swap", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ faceImage: base64Image }),
            });

            if (!swapRes.ok) {
                const err = await swapRes.json();
                throw new Error(err.detail || "Failed to start face swap");
            }

            const { requestId } = await swapRes.json();

            if (abortRef.current) return;

            // Step 3: Poll for completion
            let attempts = 0;
            while (attempts < MAX_POLL_ATTEMPTS && !abortRef.current) {
                await sleep(POLL_INTERVAL_MS);
                attempts++;

                const pollRes = await fetch(`/api/face-swap/${requestId}`);
                if (!pollRes.ok) {
                    throw new Error("Failed to check face swap status");
                }

                const result = await pollRes.json();

                if (result.status === "COMPLETED" && result.imageUrl) {
                    setState((prev) => ({
                        ...prev,
                        step: "succeeded",
                        resultUrl: result.imageUrl,
                    }));
                    return;
                }

                if (result.status === "FAILED") {
                    throw new Error(
                        result.error || "Face swap failed. Please try again."
                    );
                }
            }

            if (!abortRef.current) {
                throw new Error("Face swap timed out. Please try again.");
            }
        } catch (err) {
            if (!abortRef.current) {
                setState((prev) => ({
                    ...prev,
                    step: "failed",
                    error:
                        err instanceof Error
                            ? err.message
                            : "Something went wrong",
                }));
            }
        }
    }, [state.photo]);

    /** Reset to initial state */
    const reset = useCallback(() => {
        abortRef.current = true;
        setState((prev) => {
            if (prev.photoPreviewUrl) {
                URL.revokeObjectURL(prev.photoPreviewUrl);
            }
            return { ...initialState };
        });
    }, []);

    return {
        state,
        setPhoto,
        clearPhoto,
        generate,
        reset,
    };
}
