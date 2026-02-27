import { NextRequest, NextResponse } from "next/server";

const WAVESPEED_API_URL =
    "https://api.wavespeed.ai/api/v3/wavespeed-ai/flux-kontext-pro";

const AVATAR_PROMPT =
    "Transform this into a full body photo of the same person, standing straight facing the camera, " +
    "wearing a plain white tank top and light blue jeans, barefoot, arms relaxed at sides, " +
    "clean white background, fashion catalog style, studio lighting, high quality photography. " +
    "Keep the exact same face, skin tone, hair style and hair color.";

/**
 * POST /api/face-swap
 * Takes a user photo and generates a full-body avatar using FLUX Kontext Pro.
 * This preserves the person's face, skin tone, hair, and identity while
 * generating a full-body shot — no placeholder needed.
 *
 * Body: { faceImage: string (base64 data URI) }
 * Returns: { requestId: string }
 */
export async function POST(request: NextRequest) {
    try {
        const body = await request.json();
        const { faceImage } = body;

        if (!faceImage || typeof faceImage !== "string") {
            return NextResponse.json(
                { detail: "Missing or invalid 'faceImage' (base64 data URI expected)" },
                { status: 400 }
            );
        }

        const apiKey = process.env.WAVESPEED_API_KEY;
        if (!apiKey) {
            return NextResponse.json(
                { detail: "WAVESPEED_API_KEY is not configured. Get one at https://wavespeed.ai/accesskey" },
                { status: 500 }
            );
        }

        // Ensure proper data URI format
        const imageDataUri = faceImage.startsWith("data:")
            ? faceImage
            : `data:image/png;base64,${faceImage}`;

        console.log("Generating full-body avatar with FLUX Kontext Pro...");

        // Submit generation task using FLUX Kontext Pro (image-to-image)
        // The model preserves the person's identity while generating a full body
        const response = await fetch(WAVESPEED_API_URL, {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                Authorization: `Bearer ${apiKey}`,
            },
            body: JSON.stringify({
                prompt: AVATAR_PROMPT,
                image: imageDataUri,
                output_format: "png",
                enable_base64_output: false,
                enable_sync_mode: false,
            }),
        });

        if (!response.ok) {
            const errText = await response.text();
            console.error("WaveSpeed API error:", response.status, errText);
            throw new Error(`WaveSpeed API error (${response.status}): ${errText}`);
        }

        const result = await response.json();

        if (result.code !== 200 || !result.data?.id) {
            throw new Error(result.message || "Failed to submit avatar generation task");
        }

        const taskId = result.data.id;
        console.log("Avatar generation task submitted:", taskId);

        return NextResponse.json({ requestId: taskId }, { status: 202 });
    } catch (err) {
        console.error("Avatar generation error:", err);
        const message =
            err instanceof Error ? err.message : "Failed to submit avatar generation";
        return NextResponse.json({ detail: message }, { status: 500 });
    }
}
