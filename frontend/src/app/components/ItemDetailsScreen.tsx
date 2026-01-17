import { useState } from "react";
import { X } from "lucide-react";

interface ItemDetailsScreenProps {
  imageData: string;
  existingCategories: string[];
  onSave: (name: string, category: string) => void;
  onCancel: () => void;
  onAddCategory: (category: string) => void;
}

export function ItemDetailsScreen({
  imageData,
  existingCategories,
  onSave,
  onCancel,
  onAddCategory,
}: ItemDetailsScreenProps) {
  const [itemName, setItemName] = useState("");
  const [selectedCategory, setSelectedCategory] = useState("");
  const [isAddingCategory, setIsAddingCategory] = useState(false);
  const [newCategoryName, setNewCategoryName] = useState("");

  const handleSaveNewCategory = () => {
    if (newCategoryName.trim()) {
      onAddCategory(newCategoryName.trim());
      setSelectedCategory(newCategoryName.trim());
      setNewCategoryName("");
      setIsAddingCategory(false);
    }
  };

  const handleSaveItem = () => {
    if (itemName.trim() && selectedCategory) {
      onSave(itemName.trim(), selectedCategory);
    }
  };

  const canSave = itemName.trim() && selectedCategory;

  return (
    <div className="fixed inset-0 bg-white z-50 flex flex-col">
      {/* Header */}
      <div className="pt-4 px-4 flex justify-between items-center">
        <button onClick={onCancel} className="p-2">
          <X className="w-6 h-6" />
        </button>
        <h2 className="text-lg font-medium">Add Item</h2>
        <div className="w-10" /> {/* Spacer for alignment */}
      </div>

      {/* Content */}
      <div className="flex-1 overflow-y-auto px-6 pt-8 pb-24">
        {/* Photo Preview */}
        <div className="w-32 h-32 mx-auto mb-8 rounded-2xl overflow-hidden bg-gray-100">
          <img
            src={imageData}
            alt="Clothing preview"
            className="w-full h-full object-cover"
          />
        </div>

        {/* Item Name */}
        <div className="mb-8">
          <label className="block text-sm text-gray-500 mb-2">Item Name</label>
          <input
            type="text"
            value={itemName}
            onChange={(e) => setItemName(e.target.value)}
            placeholder="Name this item"
            className="w-full px-4 py-3 border border-gray-200 rounded-xl focus:outline-none focus:border-black transition-colors"
          />
        </div>

        {/* Category Section */}
        <div>
          <label className="block text-sm text-gray-500 mb-3">Category</label>

          {/* No categories exist - show Add Category button */}
          {existingCategories.length === 0 && !isAddingCategory && (
            <button
              onClick={() => setIsAddingCategory(true)}
              className="w-full px-4 py-3 border border-gray-300 rounded-xl text-sm text-gray-700 hover:border-black transition-colors"
            >
              Add a category
            </button>
          )}

          {/* Adding new category inline */}
          {isAddingCategory && (
            <div className="space-y-2">
              <input
                type="text"
                value={newCategoryName}
                onChange={(e) => setNewCategoryName(e.target.value)}
                placeholder="Category name"
                className="w-full px-4 py-3 border border-gray-200 rounded-xl focus:outline-none focus:border-black transition-colors"
                autoFocus
              />
              <div className="flex gap-2">
                <button
                  onClick={handleSaveNewCategory}
                  className="flex-1 bg-black text-white py-2 rounded-full text-sm"
                >
                  Save
                </button>
                <button
                  onClick={() => {
                    setIsAddingCategory(false);
                    setNewCategoryName("");
                  }}
                  className="flex-1 border border-gray-300 py-2 rounded-full text-sm"
                >
                  Cancel
                </button>
              </div>
            </div>
          )}

          {/* Existing categories - show pills */}
          {existingCategories.length > 0 && !isAddingCategory && (
            <div className="space-y-3">
              <div className="flex flex-wrap gap-2">
                {existingCategories.map((category) => (
                  <button
                    key={category}
                    onClick={() => setSelectedCategory(category)}
                    className={`px-5 py-2.5 rounded-full text-sm transition-all ${
                      selectedCategory === category
                        ? "bg-black text-white"
                        : "bg-white text-gray-600 border border-gray-200"
                    }`}
                  >
                    {category}
                  </button>
                ))}
              </div>
              <button
                onClick={() => setIsAddingCategory(true)}
                className="text-sm text-gray-500 underline"
              >
                Add new category
              </button>
            </div>
          )}
        </div>
      </div>

      {/* Save Button */}
      <div className="fixed bottom-0 left-0 right-0 p-6 bg-white border-t border-gray-100">
        <button
          onClick={handleSaveItem}
          disabled={!canSave}
          className={`w-full py-4 rounded-full text-sm font-medium transition-all ${
            canSave
              ? "bg-black text-white"
              : "bg-gray-200 text-gray-400 cursor-not-allowed"
          }`}
        >
          Save to Wardrobe
        </button>
      </div>
    </div>
  );
}
