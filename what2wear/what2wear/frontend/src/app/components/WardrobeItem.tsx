interface WardrobeItemProps {
  id: string;
  name: string;
  imageUrl?: string;
  category: string;
}

export function WardrobeItem({ name, imageUrl }: WardrobeItemProps) {
  return (
    <div className="bg-white rounded-3xl shadow-[0_4px_16px_rgba(0,0,0,0.06)] overflow-hidden">
      {/* Image Container */}
      <div className="aspect-square bg-gray-50 flex items-center justify-center">
        {imageUrl ? (
          <img src={imageUrl} alt={name} className="w-full h-full object-cover" />
        ) : (
          <div className="w-full h-full bg-gradient-to-br from-gray-100 to-gray-50" />
        )}
      </div>

      {/* Item Name */}
      <div className="p-4">
        <p className="text-sm text-center tracking-wide">{name}</p>
      </div>
    </div>
  );
}
