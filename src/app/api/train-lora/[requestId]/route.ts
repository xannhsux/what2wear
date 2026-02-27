import { NextRequest, NextResponse } from "next/server";
import { replicate } from "@/lib/replicate";

/**
 * GET /api/train-lora/[requestId]
 * Polls the status of a LoRA training job on Replicate.
 *
 * Normalizes Replicate status values to match the frontend expectations:
 *   Replicate "starting"/"processing" → "IN_PROGRESS"
 *   Replicate "succeeded" → "COMPLETED"
 *   Replicate "failed"/"canceled" → "FAILED"
 *
 * When COMPLETED, returns the LoRA weights URL in a normalized format
 * that matches what the frontend hooks expect.
 */
export async function GET(
    _request: NextRequest,
    { params }: { params: { requestId: string } }
) {
    try {
        const { requestId } = params;

        const training = await replicate.trainings.get(requestId);

        if (training.status === "succeeded") {
            // Normalize to the format the hook expects:
            // result.data.diffusers_lora_file.url
            const weightsUrl =
                training.output?.weights ||
                training.output?.version ||
                null;

            return NextResponse.json({
                status: "COMPLETED",
                data: {
                    diffusers_lora_file: {
                        url: weightsUrl,
                    },
                },
            });
        }

        if (training.status === "failed" || training.status === "canceled") {
            return NextResponse.json({
                status: "FAILED",
                error: training.error || "Training failed",
            });
        }

        // "starting" or "processing"
        return NextResponse.json({
            status: "IN_PROGRESS",
            logs: training.logs,
        });
    } catch (err) {
        console.error("LoRA training status error:", err);
        const message =
            err instanceof Error ? err.message : "Failed to check training status";
        return NextResponse.json({ detail: message }, { status: 500 });
    }
}
