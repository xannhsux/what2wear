import { Home, Plus, Search, User } from "lucide-react";

// Custom wardrobe/door icon using SVG
const WardrobeIcon = () => (
  <svg
    width="24"
    height="24"
    viewBox="0 0 24 24"
    fill="none"
    xmlns="http://www.w3.org/2000/svg"
    className="stroke-current"
  >
    <rect x="4" y="3" width="16" height="18" rx="1" strokeWidth="1.5" />
    <line x1="12" y1="3" x2="12" y2="21" strokeWidth="1.5" />
    <circle cx="10" cy="12" r="0.75" fill="currentColor" />
    <circle cx="14" cy="12" r="0.75" fill="currentColor" />
  </svg>
);

interface BottomNavProps {
  activeTab?: string;
  onTabChange?: (tab: string) => void;
  onAddClick?: () => void;
}

export function BottomNav({ activeTab = "home", onTabChange, onAddClick }: BottomNavProps) {
  const tabs = [
    { id: "home", icon: Home, label: "Home" },
    { id: "wardrobe", icon: WardrobeIcon, label: "Wardrobe", isCustom: true },
    { id: "add", icon: Plus, label: "Add" },
    { id: "search", icon: Search, label: "Search" },
    { id: "profile", icon: User, label: "Profile" },
  ];

  return (
    <div className="fixed bottom-0 left-0 right-0 bg-white border-t border-gray-100 safe-area-bottom">
      <div className="flex justify-around items-center h-20 max-w-[430px] mx-auto px-6">
        {tabs.map(({ id, icon: Icon, label, isCustom }) => {
          const isActive = activeTab === id;
          const isAddButton = id === "add";

          if (isAddButton) {
            return (
              <button
                key={id}
                onClick={() => onAddClick?.()}
                className="flex items-center justify-center w-14 h-14 bg-black rounded-full hover:bg-gray-800 transition-colors"
                aria-label={label}
              >
                <Icon className="w-6 h-6 text-white" strokeWidth={1.5} />
              </button>
            );
          }

          return (
            <button
              key={id}
              onClick={() => onTabChange?.(id)}
              className={`flex items-center justify-center w-12 h-12 rounded-full transition-colors ${
                isActive ? "text-black" : "text-gray-400"
              } hover:text-black`}
              aria-label={label}
            >
              {isCustom ? (
                <Icon />
              ) : (
                <Icon className="w-6 h-6" strokeWidth={1.5} />
              )}
              {isActive && id !== "add" && (
                <div className="absolute bottom-6 w-1 h-1 bg-black rounded-full" />
              )}
            </button>
          );
        })}
      </div>
    </div>
  );
}