/**
 * Minimal ZIP file creator for bundling training images.
 * No external dependencies — uses raw byte manipulation.
 * 
 * This creates a valid ZIP archive that Replicate can process.
 */

function base64ToUint8Array(base64DataUri: string): {
    data: Uint8Array;
    ext: string;
} {
    // Strip data URI prefix: "data:image/jpeg;base64,..."
    const match = base64DataUri.match(/^data:image\/(\w+);base64,(.+)$/);
    if (!match) {
        throw new Error("Invalid base64 data URI");
    }

    const ext = match[1] === "jpeg" ? "jpg" : match[1];
    const raw = atob(match[2]);
    const arr = new Uint8Array(raw.length);
    for (let i = 0; i < raw.length; i++) {
        arr[i] = raw.charCodeAt(i);
    }
    return { data: arr, ext };
}

function crc32(data: Uint8Array): number {
    let crc = 0xffffffff;
    for (let i = 0; i < data.length; i++) {
        crc ^= data[i];
        for (let j = 0; j < 8; j++) {
            crc = crc & 1 ? (crc >>> 1) ^ 0xedb88320 : crc >>> 1;
        }
    }
    return (crc ^ 0xffffffff) >>> 0;
}

interface ZipEntry {
    name: string;
    data: Uint8Array;
    crc: number;
    offset: number;
}

export async function createZipFromBase64Images(
    base64Images: string[]
): Promise<Uint8Array> {
    const entries: ZipEntry[] = [];
    let offset = 0;
    const localHeaders: Uint8Array[] = [];

    // Create local file entries
    for (let i = 0; i < base64Images.length; i++) {
        const { data, ext } = base64ToUint8Array(base64Images[i]);
        const name = `image_${String(i + 1).padStart(3, "0")}.${ext}`;
        const nameBytes = new TextEncoder().encode(name);
        const crc = crc32(data);

        // Local file header (30 bytes + name + data)
        const header = new Uint8Array(30 + nameBytes.length);
        const view = new DataView(header.buffer);

        view.setUint32(0, 0x04034b50, true); // Local file header signature
        view.setUint16(4, 20, true); // Version needed (2.0)
        view.setUint16(6, 0, true); // General purpose flags
        view.setUint16(8, 0, true); // Compression method (stored)
        view.setUint16(10, 0, true); // Mod time
        view.setUint16(12, 0, true); // Mod date
        view.setUint32(14, crc, true); // CRC-32
        view.setUint32(18, data.length, true); // Compressed size
        view.setUint32(22, data.length, true); // Uncompressed size
        view.setUint16(26, nameBytes.length, true); // Filename length
        view.setUint16(28, 0, true); // Extra field length

        header.set(nameBytes, 30);

        entries.push({ name, data, crc, offset });
        localHeaders.push(header);

        offset += header.length + data.length;
    }

    // Create central directory entries
    const centralDirEntries: Uint8Array[] = [];
    let centralDirSize = 0;

    for (let i = 0; i < entries.length; i++) {
        const entry = entries[i];
        const nameBytes = new TextEncoder().encode(entry.name);

        const cdEntry = new Uint8Array(46 + nameBytes.length);
        const view = new DataView(cdEntry.buffer);

        view.setUint32(0, 0x02014b50, true); // Central directory signature
        view.setUint16(4, 20, true); // Version made by
        view.setUint16(6, 20, true); // Version needed
        view.setUint16(8, 0, true); // Flags
        view.setUint16(10, 0, true); // Compression method
        view.setUint16(12, 0, true); // Mod time
        view.setUint16(14, 0, true); // Mod date
        view.setUint32(16, entry.crc, true); // CRC-32
        view.setUint32(20, entry.data.length, true); // Compressed size
        view.setUint32(24, entry.data.length, true); // Uncompressed size
        view.setUint16(28, nameBytes.length, true); // Filename length
        view.setUint16(30, 0, true); // Extra field length
        view.setUint16(32, 0, true); // Comment length
        view.setUint16(34, 0, true); // Disk number start
        view.setUint16(36, 0, true); // Internal attributes
        view.setUint32(38, 0, true); // External attributes
        view.setUint32(42, entry.offset, true); // Relative offset

        cdEntry.set(nameBytes, 46);

        centralDirEntries.push(cdEntry);
        centralDirSize += cdEntry.length;
    }

    // End of central directory record (22 bytes)
    const eocd = new Uint8Array(22);
    const eocdView = new DataView(eocd.buffer);

    eocdView.setUint32(0, 0x06054b50, true); // EOCD signature
    eocdView.setUint16(4, 0, true); // Disk number
    eocdView.setUint16(6, 0, true); // Central dir disk
    eocdView.setUint16(8, entries.length, true); // Entries on this disk
    eocdView.setUint16(10, entries.length, true); // Total entries
    eocdView.setUint32(12, centralDirSize, true); // Central dir size
    eocdView.setUint32(16, offset, true); // Central dir offset
    eocdView.setUint16(20, 0, true); // Comment length

    // Calculate total size
    let totalSize = 0;
    for (const h of localHeaders) totalSize += h.length;
    for (const e of entries) totalSize += e.data.length;
    for (const c of centralDirEntries) totalSize += c.length;
    totalSize += eocd.length;

    // Combine everything
    const result = new Uint8Array(totalSize);
    let pos = 0;

    for (let i = 0; i < entries.length; i++) {
        result.set(localHeaders[i], pos);
        pos += localHeaders[i].length;
        result.set(entries[i].data, pos);
        pos += entries[i].data.length;
    }

    for (const cd of centralDirEntries) {
        result.set(cd, pos);
        pos += cd.length;
    }

    result.set(eocd, pos);

    return result;
}
