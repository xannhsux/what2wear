// ─── LoRA Training ───

export type TrainingStep =
    | "idle"           // No photos uploaded yet
    | "uploading"      // Uploading photos to Replicate storage
    | "training"       // LoRA training in progress
    | "ready"          // LoRA trained, ready to generate
    | "failed";        // Training failed

export interface LoraTrainingState {
    step: TrainingStep;
    photos: File[];
    photoPreviewUrls: string[];
    requestId: string | null;
    loraUrl: string | null;
    triggerWord: string;
    error: string | null;
    progress: number; // 0-100
}

// ─── Avatar Generation with LoRA ───

export type GenerationStep =
    | "idle"           // Ready to generate
    | "generating"     // Generation in progress
    | "succeeded"      // Image generated
    | "failed";        // Generation failed

export interface LoraGenerationState {
    step: GenerationStep;
    prompt: string;
    requestId: string | null;
    imageUrl: string | null;
    error: string | null;
}

// ─── Saved LoRA Profile ───

export interface SavedLoraProfile {
    loraUrl: string;
    triggerWord: string;
    trainedAt: string;
}

// ─── API Response Types ───
// These match the normalized response shapes returned by our API routes

export interface TrainingResult {
    diffusers_lora_file: {
        url: string;
    };
}

export interface GenerationResult {
    images: Array<{
        url: string;
        width: number;
        height: number;
        content_type: string;
    }>;
}
