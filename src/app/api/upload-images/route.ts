import { NextRequest, NextResponse } from "next/server";
import { replicate } from "@/lib/replicate";

/**
 * POST /api/upload-images
 * Accepts base64 images, creates a zip archive, uploads to Replicate file storage,
 * and returns the URL for training.
 *
 * Body: { images: string[] } — array of base64 data URIs
 * Returns: { imagesDataUrl: string }
 */
export async function POST(request: NextRequest) {
    try {
        const body = await request.json();
        const { images } = body;

        if (!Array.isArray(images) || images.length < 4) {
            return NextResponse.json(
                { detail: "Please upload at least 4 images for training." },
                { status: 400 }
            );
        }

        if (images.length > 20) {
            return NextResponse.json(
                { detail: "Maximum 20 images allowed." },
                { status: 400 }
            );
        }

        // Build a zip archive from the base64 images
        const { createZipFromBase64Images } = await import("@/lib/zip-utils");
        const zipBuffer = await createZipFromBase64Images(images);

        // Upload the zip to Replicate file storage
        const zipFile = new File(
            [zipBuffer.buffer as ArrayBuffer],
            "training-images.zip",
            { type: "application/zip" }
        );
        const file = await replicate.files.create(zipFile);

        return NextResponse.json({ imagesDataUrl: file.urls.get });
    } catch (err) {
        console.error("Image upload error:", err);
        const message =
            err instanceof Error ? err.message : "Failed to upload images";
        return NextResponse.json({ detail: message }, { status: 500 });
    }
}
