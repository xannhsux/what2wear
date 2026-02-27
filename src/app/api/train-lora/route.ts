import { NextRequest, NextResponse } from "next/server";
import { replicate } from "@/lib/replicate";
import {
    LORA_TRAINER_OWNER,
    LORA_TRAINER_MODEL,
    LORA_TRAINER_VERSION,
    REPLICATE_DESTINATION,
} from "@/lib/constants";

/**
 * POST /api/train-lora
 * Accepts a zip URL containing user photos and submits a LoRA training job.
 *
 * Body: { imagesDataUrl: string, triggerWord?: string, steps?: number }
 * Returns: { requestId: string }
 */
export async function POST(request: NextRequest) {
    try {
        // Validate that REPLICATE_USERNAME is configured
        if (!process.env.REPLICATE_USERNAME) {
            return NextResponse.json(
                {
                    detail:
                        "REPLICATE_USERNAME is not set in your .env.local file. " +
                        "Please set it to your Replicate username (find it at replicate.com/account).",
                },
                { status: 500 }
            );
        }

        const body = await request.json();
        const { imagesDataUrl, triggerWord = "TOK", steps = 1000 } = body;

        if (!imagesDataUrl || typeof imagesDataUrl !== "string") {
            return NextResponse.json(
                { detail: "Missing or invalid 'imagesDataUrl'" },
                { status: 400 }
            );
        }

        // Ensure the destination model exists on Replicate
        try {
            const [destOwner, destName] = REPLICATE_DESTINATION.split("/");
            await replicate.models.create(destOwner, destName, {
                visibility: "private",
                hardware: "gpu-l40s",
                description: "What2Wear personal LoRA model",
            });
            console.log(`Created destination model: ${REPLICATE_DESTINATION}`);
        } catch (modelErr: unknown) {
            // "already exists" is fine — we just want to ensure it's there
            const errMsg =
                modelErr instanceof Error ? modelErr.message : String(modelErr);
            const isAlreadyExists =
                errMsg.includes("already exists") ||
                errMsg.includes("409") ||
                errMsg.includes("Conflict");
            if (!isAlreadyExists) {
                console.error("Failed to create destination model:", errMsg);
                return NextResponse.json(
                    {
                        detail:
                            `Could not create destination model "${REPLICATE_DESTINATION}": ${errMsg}`,
                    },
                    { status: 500 }
                );
            }
            console.log(`Destination model already exists: ${REPLICATE_DESTINATION}`);
        }

        // Submit training job to Replicate
        console.log("Submitting training:", {
            owner: LORA_TRAINER_OWNER,
            model: LORA_TRAINER_MODEL,
            version: LORA_TRAINER_VERSION.slice(0, 12) + "...",
            destination: REPLICATE_DESTINATION,
        });
        const training = await replicate.trainings.create(
            LORA_TRAINER_OWNER,
            LORA_TRAINER_MODEL,
            LORA_TRAINER_VERSION,
            {
                destination: REPLICATE_DESTINATION as `${string}/${string}`,
                input: {
                    input_images: imagesDataUrl,
                    trigger_word: triggerWord,
                    autocaption: true,
                    steps,
                    lora_rank: 16,
                    optimizer: "adamw8bit",
                    batch_size: 1,
                    resolution: "512,768,1024",
                    learning_rate: 0.0004,
                },
            }
        );

        return NextResponse.json({ requestId: training.id }, { status: 202 });
    } catch (err) {
        console.error("LoRA training submit error:", err);
        const message =
            err instanceof Error ? err.message : "Failed to submit training job";
        return NextResponse.json({ detail: message }, { status: 500 });
    }
}
