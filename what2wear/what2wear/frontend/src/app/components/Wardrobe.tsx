import { useState } from "react";
import { WardrobeItem } from "@/app/components/WardrobeItem";

export interface ClothingItem {
  id: string;
  name: string;
  category: string;
  imageUrl?: string;
}

interface WardrobeProps {
  items?: ClothingItem[];
}

export function Wardrobe({ items = [] }: WardrobeProps) {
  // Extract unique categories from items
  const categories = items.length > 0 
    ? ["All", ...Array.from(new Set(items.map((item) => item.category)))]
    : [];

  const [selectedCategory, setSelectedCategory] = useState("All");

  // Filter items based on selected category
  const filteredItems =
    selectedCategory === "All"
      ? items
      : items.filter((item) => item.category === selectedCategory);

  return (
    <div className="flex-1 flex flex-col bg-white overflow-hidden">
      {/* Title */}
      <div className="pt-16 px-6 pb-6">
        <h1 className="text-5xl tracking-tight">My Wardrobe</h1>
      </div>

      {/* Category Filter Pills - Only show if items exist */}
      {items.length > 0 && (
        <div className="px-6 pb-6">
          <div className="flex gap-2 overflow-x-auto no-scrollbar">
            {categories.map((category) => (
              <button
                key={category}
                onClick={() => setSelectedCategory(category)}
                className={`px-5 py-2.5 rounded-full text-sm whitespace-nowrap transition-all ${
                  selectedCategory === category
                    ? "bg-black text-white"
                    : "bg-white text-gray-600 border border-gray-200"
                }`}
              >
                {category}
              </button>
            ))}
          </div>
        </div>
      )}

      {/* Wardrobe Grid or Empty State */}
      <div className="flex-1 overflow-y-auto px-6 pb-24">
        {items.length > 0 ? (
          <div className="grid grid-cols-2 gap-4">
            {filteredItems.map((item) => (
              <WardrobeItem
                key={item.id}
                id={item.id}
                name={item.name}
                category={item.category}
                imageUrl={item.imageUrl}
              />
            ))}
          </div>
        ) : (
          // Empty state - intentionally minimal and calm
          <div className="h-full" />
        )}
      </div>
    </div>
  );
}
