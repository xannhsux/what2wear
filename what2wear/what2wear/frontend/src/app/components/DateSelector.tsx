import { Briefcase, ChevronDown } from "lucide-react";

interface DateSelectorProps {
  weekday: string;
  date: string;
  event: string;
  onDateClick?: () => void;
}

export function DateSelector({ weekday, date, event, onDateClick }: DateSelectorProps) {
  return (
    <div className="w-full px-6">
      {/* Weekday and Date Header */}
      <div className="flex justify-between items-baseline mb-4">
        <h1 className="text-5xl tracking-tight">{weekday}</h1>
        <span className="text-gray-400 text-lg">{date}</span>
      </div>

      {/* Event Pill Button */}
      <button
        onClick={onDateClick}
        className="w-full bg-black text-white rounded-full px-5 py-4 flex items-center justify-between hover:bg-gray-800 transition-colors"
      >
        <div className="flex items-center gap-3">
          <Briefcase className="w-5 h-5" strokeWidth={1.5} />
          <span className="tracking-wide">{event}</span>
        </div>
        <ChevronDown className="w-5 h-5" strokeWidth={1.5} />
      </button>
    </div>
  );
}