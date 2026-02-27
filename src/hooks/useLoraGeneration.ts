"use client";

import { useState, useCallback, useRef } from "react";
import type {
    LoraGenerationState,
    GenerationResult,
} from "@/types/lora";
import { sleep } from "@/lib/utils";

const POLL_INTERVAL_MS = 2000;
const MAX_POLL_ATTEMPTS = 120; // ~4 minutes max

const initialState: LoraGenerationState = {
    step: "idle",
    prompt: "",
    requestId: null,
    imageUrl: null,
    error: null,
};

export function useLoraGeneration() {
    const [state, setState] = useState<LoraGenerationState>(initialState);
    const abortRef = useRef(false);

    const setPrompt = useCallback((prompt: string) => {
        setState((prev) => ({ ...prev, prompt }));
    }, []);

    // Generate avatar from prompt + LoRA
    const generate = useCallback(
        async (loraUrl: string, triggerWord: string) => {
            if (!state.prompt.trim()) {
                setState((prev) => ({
                    ...prev,
                    error: "Please enter a description for your avatar.",
                }));
                return;
            }

            abortRef.current = false;
            setState((prev) => ({
                ...prev,
                step: "generating",
                error: null,
                imageUrl: null,
            }));

            try {
                // Ensure the prompt contains the trigger word
                const promptWithTrigger = state.prompt.includes(triggerWord)
                    ? state.prompt
                    : `A photo of ${triggerWord}, ${state.prompt}`;

                // Submit generation
                const genRes = await fetch("/api/generate-avatar", {
                    method: "POST",
                    headers: { "Content-Type": "application/json" },
                    body: JSON.stringify({
                        prompt: promptWithTrigger,
                        loraUrl,
                        loraScale: 1,
                        imageSize: "portrait_4_3",
                    }),
                });

                if (!genRes.ok) {
                    const err = await genRes.json();
                    throw new Error(err.detail || "Failed to start generation");
                }

                const { requestId } = await genRes.json();
                setState((prev) => ({ ...prev, requestId }));

                // Poll for completion
                let attempts = 0;
                while (attempts < MAX_POLL_ATTEMPTS && !abortRef.current) {
                    await sleep(POLL_INTERVAL_MS);
                    attempts++;

                    const pollRes = await fetch(`/api/generate-avatar/${requestId}`);
                    if (!pollRes.ok) {
                        throw new Error("Failed to check generation status");
                    }

                    const result = await pollRes.json();

                    if (result.status === "COMPLETED" && result.data) {
                        const data = result.data as GenerationResult;
                        if (data.images && data.images.length > 0) {
                            setState((prev) => ({
                                ...prev,
                                step: "succeeded",
                                imageUrl: data.images[0].url,
                            }));
                            return;
                        }
                    }

                    if (result.status === "FAILED") {
                        throw new Error("Generation failed. Please try again.");
                    }
                }

                if (!abortRef.current) {
                    throw new Error("Generation timed out. Please try again.");
                }
            } catch (err) {
                if (!abortRef.current) {
                    setState((prev) => ({
                        ...prev,
                        step: "failed",
                        error:
                            err instanceof Error ? err.message : "Something went wrong",
                    }));
                }
            }
        },
        [state.prompt]
    );

    const reset = useCallback(() => {
        abortRef.current = true;
        setState({ ...initialState });
    }, []);

    const clearResult = useCallback(() => {
        setState((prev) => ({
            ...prev,
            step: "idle",
            imageUrl: null,
            error: null,
        }));
    }, []);

    return {
        state,
        setPrompt,
        generate,
        reset,
        clearResult,
    };
}
