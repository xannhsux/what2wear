const image1 = "https://images.unsplash.com/photo-1594938298603-c8148c47e356?w=800&auto=format&fit=crop&q=60";
const image2 = "https://images.unsplash.com/photo-1591561954557-26941169b49e?w=800&auto=format&fit=crop&q=60";

export interface Outfit {
  id: number;
  style: string;
  imageUrl?: string;
}

export interface EventData {
  event: string;
  outfits: Outfit[];
}

// Get event based on date
export function getEventForDate(date: Date): string {
  const day = date.getDay(); // 0 = Sunday, 6 = Saturday
  const hour = date.getHours();

  // Weekend
  if (day === 0 || day === 6) {
    return "Weekend – Leisure";
  }

  // Weekday
  return "Work Day – Office";
}

// Get outfit recommendations based on event
export function getOutfitsForEvent(event: string): Outfit[] {
  const outfitData: { [key: string]: Outfit[] } = {
    "Work Day – Office": [
      {
        id: 1,
        style: "Business Professional",
        imageUrl: image1,
      },
      {
        id: 2,
        style: "Smart Casual",
        imageUrl: image2,
      },
      {
        id: 3,
        style: "Minimalist Chic",
      },
      {
        id: 4,
        style: "Contemporary Classic",
      },
    ],
    "Weekend – Leisure": [
      {
        id: 5,
        style: "Casual Comfort",
        imageUrl: image2,
      },
      {
        id: 6,
        style: "Urban Street",
        imageUrl: image1,
      },
      {
        id: 7,
        style: "Relaxed Elegance",
      },
      {
        id: 8,
        style: "Weekend Chic",
      },
    ],
    "Evening – Dinner": [
      {
        id: 9,
        style: "Smart Evening",
        imageUrl: image1,
      },
      {
        id: 10,
        style: "Sophisticated Night",
        imageUrl: image2,
      },
      {
        id: 11,
        style: "Elegant Casual",
      },
    ],
  };

  return outfitData[event] || outfitData["Work Day – Office"];
}

// Format date for display
export function formatDate(date: Date): { weekday: string; dateStr: string } {
  const weekdays = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
  const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

  const weekday = weekdays[date.getDay()];
  const month = months[date.getMonth()];
  const day = date.getDate();

  return {
    weekday,
    dateStr: `${month} ${day}`,
  };
}
