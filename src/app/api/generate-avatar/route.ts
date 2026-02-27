import { NextRequest, NextResponse } from "next/server";
import { replicate } from "@/lib/replicate";
import { FLUX_LORA_VERSION } from "@/lib/constants";

/**
 * POST /api/generate-avatar
 * Generates an avatar image using a trained LoRA model on Replicate.
 *
 * Body: { prompt: string, loraUrl: string, loraScale?: number, imageSize?: string }
 * Returns: { requestId: string }
 */
export async function POST(request: NextRequest) {
    try {
        const body = await request.json();
        const {
            prompt,
            loraUrl,
            loraScale = 1,
            imageSize = "3:4",
        } = body;

        if (!prompt || typeof prompt !== "string") {
            return NextResponse.json(
                { detail: "Missing or invalid 'prompt'" },
                { status: 400 }
            );
        }

        if (!loraUrl || typeof loraUrl !== "string") {
            return NextResponse.json(
                { detail: "Missing or invalid 'loraUrl' — train your LoRA first" },
                { status: 400 }
            );
        }

        // Submit generation job to Replicate
        const prediction = await replicate.predictions.create({
            version: FLUX_LORA_VERSION,
            input: {
                prompt,
                hf_lora: loraUrl,
                lora_scale: loraScale,
                aspect_ratio: imageSize,
                num_inference_steps: 28,
                guidance_scale: 3.5,
                num_outputs: 1,
                output_format: "png",
                output_quality: 90,
            },
        });

        return NextResponse.json({ requestId: prediction.id }, { status: 202 });
    } catch (err) {
        console.error("Avatar generation submit error:", err);
        const message =
            err instanceof Error ? err.message : "Failed to submit generation job";
        return NextResponse.json({ detail: message }, { status: 500 });
    }
}
