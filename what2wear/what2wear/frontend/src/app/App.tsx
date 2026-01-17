import { useState } from "react";
import { DateSelector } from "@/app/components/DateSelector";
import { OutfitCard } from "@/app/components/OutfitCard";
import { BottomNav } from "@/app/components/BottomNav";
import { DateCalendarDialog } from "@/app/components/DateCalendarDialog";
import { Wardrobe, type ClothingItem } from "@/app/components/Wardrobe";
import { CameraScreen } from "@/app/components/CameraScreen";
import { PhotoConfirmation } from "@/app/components/PhotoConfirmation";
import { ItemDetailsScreen } from "@/app/components/ItemDetailsScreen";
import { Profile } from "@/app/components/Profile";
import { getEventForDate, getOutfitsForEvent, formatDate, type Outfit } from "@/app/utils/outfitData";
import { AuthProvider, useAuth } from "@/app/auth/AuthContext";
import LoginPage from "@/app/auth/LoginPage";
import { authenticatedFetch } from "@/app/utils/api";
import { useEffect } from "react";


type AddFlowStep = "camera" | "confirm" | "details" | null;

export default function App() {
  return (
    <AuthProvider>
      <AppContent />
    </AuthProvider>
  );
}

function AppContent() {
  const { user, loading } = useAuth();

  const [selectedDate, setSelectedDate] = useState<Date>(new Date());
  const [isCalendarOpen, setIsCalendarOpen] = useState(false);
  const [activeTab, setActiveTab] = useState("home");

  // Add clothing flow state
  const [addFlowStep, setAddFlowStep] = useState<AddFlowStep>(null);
  const [capturedImage, setCapturedImage] = useState<string>("");
  const [categories, setCategories] = useState<string[]>([]);

  // Wardrobe items state
  const [wardrobeItems, setWardrobeItems] = useState<ClothingItem[]>([]);

  // Fetch wardrobe items when tab changes to wardrobe or on mount
  useEffect(() => {
    if (user && activeTab === 'wardrobe') {
      loadWardrobe();
    }
  }, [user, activeTab]);

  const loadWardrobe = async () => {
    try {
      const data = await authenticatedFetch('/wardrobe');
      // Map database fields to frontend model if necessary
      // Assuming backend returns matching shape or we adapt here
      const items = data.map((item: any) => ({
        id: item.id,
        name: item.name,
        category: item.category,
        imageUrl: item.image_url // Note the underscore from DB
      }));
      setWardrobeItems(items);
    } catch (err) {
      console.error("Failed to load wardrobe", err);
    }
  };


  // Get event and outfits based on selected date
  const event = getEventForDate(selectedDate);
  const [outfits, setOutfits] = useState<Outfit[]>(getOutfitsForEvent(event));
  const { weekday, dateStr } = formatDate(selectedDate);

  const handleDateSelect = (date: Date | undefined) => {
    if (date) {
      setSelectedDate(date);
      const newEvent = getEventForDate(date);
      setOutfits(getOutfitsForEvent(newEvent));
    }
  };

  const handleSwipe = (direction: "left" | "right") => {
    // Remove the top card after swipe
    setOutfits((prev) => prev.slice(1));
  };

  // Add clothing flow handlers
  const handleAddClick = () => {
    setAddFlowStep("camera");
  };

  const handleCameraCapture = (imageData: string) => {
    setCapturedImage(imageData);
    setAddFlowStep("confirm");
  };

  const handleRetake = () => {
    setAddFlowStep("camera");
  };

  const handleUsePhoto = () => {
    setAddFlowStep("details");
  };

  const handleAddCategory = (category: string) => {
    if (!categories.includes(category)) {
      setCategories((prev) => [...prev, category]);
    }
  };

  const handleSaveItem = async (name: string, category: string) => {
    try {
      const newItem = await authenticatedFetch('/wardrobe', {
        method: 'POST',
        body: JSON.stringify({
          name,
          category,
          imageUrl: capturedImage,
        }),
      });

      // Adapt response
      const adaptedItem: ClothingItem = {
        id: newItem.id,
        name: newItem.name,
        category: newItem.category,
        imageUrl: newItem.image_url
      };

      setWardrobeItems((prev) => [adaptedItem, ...prev]); // Add to top
    } catch (err) {
      console.error("Failed to save item", err);
      // Ideally show toast error here
    }


    // Reset add flow
    setAddFlowStep(null);
    setCapturedImage("");

    // Navigate to wardrobe to see the new item
    setActiveTab("wardrobe");
  };

  const handleCancelAddFlow = () => {
    setAddFlowStep(null);
    setCapturedImage("");
  };

  if (loading) {
    return <div className="flex items-center justify-center min-h-screen">Loading...</div>;
  }

  if (!user) {
    return <LoginPage />;
  }

  return (
    <div className="size-full flex flex-col bg-[#FAFAFA] overflow-hidden">

      {/* Mobile Container */}
      <div className="flex-1 flex flex-col max-w-[430px] w-full mx-auto bg-white relative">
        {/* Home Screen */}
        {activeTab === "home" && (
          <>
            {/* Date Selector - Top Section */}
            <div className="pt-16 pb-8">
              <DateSelector
                weekday={weekday}
                date={dateStr}
                event={event}
                onDateClick={() => setIsCalendarOpen(true)}
              />
            </div>

            {/* Section Title */}
            <div className="px-6 pb-6">
              <h2 className="text-2xl tracking-tight text-center">Today's Recommendation</h2>
            </div>

            {/* Card Deck Section - Center */}
            <div className="flex-1 flex items-center justify-center px-6 relative pb-24">
              <div className="relative w-full h-[420px] flex items-center justify-center">
                {outfits.length > 0 ? (
                  outfits.slice(0, 3).map((outfit, index) => (
                    <OutfitCard
                      key={outfit.id}
                      style={outfit.style}
                      imageUrl={outfit.imageUrl}
                      onSwipe={handleSwipe}
                      index={index}
                    />
                  ))
                ) : (
                  <div className="text-center text-gray-400">
                    <p className="text-lg">No more recommendations</p>
                    <p className="text-sm mt-2">Check back tomorrow!</p>
                  </div>
                )}

                {/* Card Indicator Dots */}
                {outfits.length > 0 && (
                  <div className="absolute bottom-0 left-1/2 transform -translate-x-1/2 flex gap-2">
                    {outfits.slice(0, 3).map((_, index) => (
                      <div
                        key={index}
                        className={`w-2 h-2 rounded-full transition-colors ${index === 0 ? "bg-black" : "bg-gray-300"
                          }`}
                      />
                    ))}
                  </div>
                )}
              </div>
            </div>
          </>
        )}

        {/* Wardrobe Screen */}
        {activeTab === "wardrobe" && <Wardrobe items={wardrobeItems} />}

        {/* Profile Screen */}
        {activeTab === "profile" && <Profile />}

        {/* Bottom Navigation */}
        <BottomNav
          activeTab={activeTab}
          onTabChange={setActiveTab}
          onAddClick={handleAddClick}
        />
      </div>

      {/* Date Calendar Dialog */}
      <DateCalendarDialog
        open={isCalendarOpen}
        onOpenChange={setIsCalendarOpen}
        selectedDate={selectedDate}
        onDateSelect={handleDateSelect}
      />

      {/* Add Clothing Flow */}
      {addFlowStep === "camera" && (
        <CameraScreen
          onCapture={handleCameraCapture}
          onCancel={handleCancelAddFlow}
        />
      )}

      {addFlowStep === "confirm" && (
        <PhotoConfirmation
          imageData={capturedImage}
          onRetake={handleRetake}
          onUsePhoto={handleUsePhoto}
        />
      )}

      {addFlowStep === "details" && (
        <ItemDetailsScreen
          imageData={capturedImage}
          existingCategories={categories}
          onSave={handleSaveItem}
          onCancel={handleCancelAddFlow}
          onAddCategory={handleAddCategory}
        />
      )}
    </div>
  );
}