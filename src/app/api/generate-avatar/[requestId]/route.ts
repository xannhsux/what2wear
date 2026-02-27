import { NextRequest, NextResponse } from "next/server";
import { replicate } from "@/lib/replicate";

/**
 * GET /api/generate-avatar/[requestId]
 * Polls the status of an avatar generation job on Replicate.
 *
 * Normalizes Replicate status/output to match the frontend expectations:
 *   Replicate "starting"/"processing" → "IN_PROGRESS"
 *   Replicate "succeeded" → "COMPLETED" with data.images[{url}]
 *   Replicate "failed"/"canceled" → "FAILED"
 */
export async function GET(
    _request: NextRequest,
    { params }: { params: { requestId: string } }
) {
    try {
        const { requestId } = params;

        const prediction = await replicate.predictions.get(requestId);

        if (prediction.status === "succeeded") {
            // Replicate returns output as an array of URL strings
            const outputUrls = Array.isArray(prediction.output)
                ? prediction.output
                : [prediction.output];

            // Normalize to the format the hook expects:
            // result.data.images[0].url
            return NextResponse.json({
                status: "COMPLETED",
                data: {
                    images: outputUrls.map((url: string) => ({
                        url,
                        width: 0,
                        height: 0,
                        content_type: "image/png",
                    })),
                },
            });
        }

        if (prediction.status === "failed" || prediction.status === "canceled") {
            return NextResponse.json({
                status: "FAILED",
                error: prediction.error || "Generation failed",
            });
        }

        // "starting" or "processing"
        return NextResponse.json({
            status: "IN_PROGRESS",
        });
    } catch (err) {
        console.error("Avatar generation status error:", err);
        const message =
            err instanceof Error
                ? err.message
                : "Failed to check generation status";
        return NextResponse.json({ detail: message }, { status: 500 });
    }
}
