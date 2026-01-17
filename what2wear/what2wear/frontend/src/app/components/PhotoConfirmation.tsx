interface PhotoConfirmationProps {
  imageData: string;
  onRetake: () => void;
  onUsePhoto: () => void;
}

export function PhotoConfirmation({
  imageData,
  onRetake,
  onUsePhoto,
}: PhotoConfirmationProps) {
  return (
    <div className="fixed inset-0 bg-black z-50 flex flex-col">
      {/* Photo Preview */}
      <div className="flex-1 relative overflow-hidden">
        <img
          src={imageData}
          alt="Captured clothing"
          className="absolute inset-0 w-full h-full object-cover"
        />
      </div>

      {/* Action Buttons */}
      <div className="bg-white p-6 space-y-3">
        <button
          onClick={onUsePhoto}
          className="w-full bg-black text-white py-4 rounded-full text-sm font-medium"
        >
          Use Photo
        </button>
        <button
          onClick={onRetake}
          className="w-full text-black py-4 text-sm"
        >
          Retake
        </button>
      </div>
    </div>
  );
}
