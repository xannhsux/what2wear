/**
 * One-time script to remove the background from avatar-placeholder.png
 * and save the cropped result as avatar-placeholder-cropped.png.
 *
 * Run with: node scripts/crop-placeholder.mjs
 */
import Replicate from "replicate";
import { readFile, writeFile } from "fs/promises";
import { join, dirname } from "path";
import { fileURLToPath } from "url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const ROOT = join(__dirname, "..");

async function main() {
    const replicate = new Replicate({
        auth: process.env.REPLICATE_API_TOKEN,
    });

    // Read the placeholder image as base64 data URI
    const placeholderPath = join(ROOT, "public", "avatar-placeholder.png");
    const buf = await readFile(placeholderPath);
    const dataUri = `data:image/png;base64,${buf.toString("base64")}`;
    console.log("Image loaded, size:", buf.length, "bytes");

    // Run background removal using data URI directly
    console.log("Running background removal...");
    const output = await replicate.run(
        "lucataco/remove-bg:95fcc2a26d3899cd6c2691c900465aaeff466285a65c14638cc5f36f34befaf1",
        {
            input: {
                image: dataUri,
            },
        }
    );

    // Output is a URL (or ReadableStream) to the result image
    let resultUrl;
    if (typeof output === "string") {
        resultUrl = output;
    } else if (output && typeof output === "object" && "url" in output) {
        resultUrl = output.url();
    } else {
        resultUrl = String(output);
    }
    console.log("Result URL:", resultUrl);

    // Download and save
    const response = await fetch(resultUrl);
    const arrayBuf = await response.arrayBuffer();
    const outPath = join(ROOT, "public", "avatar-placeholder-cropped.png");
    await writeFile(outPath, Buffer.from(arrayBuf));
    console.log("Saved cropped image to:", outPath);
    console.log("Output size:", arrayBuf.byteLength, "bytes");
}

main().catch(console.error);
