import { NextRequest, NextResponse } from "next/server";

const WAVESPEED_PREDICTIONS_URL =
    "https://api.wavespeed.ai/api/v3/predictions";

/**
 * GET /api/face-swap/[requestId]
 * Polls the status of a head-swap task on WaveSpeed AI.
 *
 * Returns normalized status:
 *   "IN_PROGRESS" — still processing
 *   "COMPLETED"   — done, includes imageUrl
 *   "FAILED"      — error occurred
 */
export async function GET(
    _request: NextRequest,
    context: { params: Promise<{ requestId: string }> }
) {
    try {
        const { requestId } = await context.params;

        const apiKey = process.env.WAVESPEED_API_KEY;
        if (!apiKey) {
            return NextResponse.json(
                { detail: "WAVESPEED_API_KEY is not configured" },
                { status: 500 }
            );
        }

        const pollUrl = `${WAVESPEED_PREDICTIONS_URL}/${requestId}/result`;

        const response = await fetch(pollUrl, {
            headers: {
                Authorization: `Bearer ${apiKey}`,
            },
            cache: "no-store", // CRITICAL: disable Next.js fetch caching for polling
        });

        if (!response.ok) {
            const errText = await response.text();
            console.error("WaveSpeed poll error:", response.status, errText);
            throw new Error(`WaveSpeed API error (${response.status})`);
        }

        const result = await response.json();
        const taskData = result.data;

        console.log("WaveSpeed poll result:", JSON.stringify({
            status: taskData?.status,
            hasOutputs: !!taskData?.outputs,
            outputCount: taskData?.outputs?.length,
        }));

        if (!taskData) {
            return NextResponse.json({ status: "IN_PROGRESS" });
        }

        const taskStatus = taskData.status;

        if (taskStatus === "completed") {
            // WaveSpeed returns outputs as an array of URLs
            const outputs = taskData.outputs;
            const imageUrl =
                typeof outputs === "string"
                    ? outputs
                    : Array.isArray(outputs) && outputs.length > 0
                        ? outputs[0]
                        : null;

            console.log("Head swap completed! Image URL:", imageUrl);

            return NextResponse.json({
                status: "COMPLETED",
                imageUrl,
            });
        }

        if (taskStatus === "failed") {
            return NextResponse.json({
                status: "FAILED",
                error: taskData.error || "Head swap failed",
            });
        }

        // "created" or "processing"
        return NextResponse.json({ status: "IN_PROGRESS" });
    } catch (err) {
        console.error("Head swap status error:", err);
        const message =
            err instanceof Error
                ? err.message
                : "Failed to check head swap status";
        return NextResponse.json({ detail: message }, { status: 500 });
    }
}
