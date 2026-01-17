import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/app/components/ui/dialog";
import { Calendar } from "@/app/components/ui/calendar";

interface DateCalendarDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  selectedDate: Date;
  onDateSelect: (date: Date | undefined) => void;
}

export function DateCalendarDialog({
  open,
  onOpenChange,
  selectedDate,
  onDateSelect,
}: DateCalendarDialogProps) {
  const handleSelect = (date: Date | undefined) => {
    if (date) {
      onDateSelect(date);
      onOpenChange(false);
    }
  };

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-[425px] bg-white rounded-3xl border-0 shadow-2xl">
        <DialogHeader>
          <DialogTitle className="text-2xl text-center">Select Date</DialogTitle>
        </DialogHeader>
        <div className="flex justify-center py-4">
          <Calendar
            mode="single"
            selected={selectedDate}
            onSelect={handleSelect}
            className="rounded-2xl"
          />
        </div>
      </DialogContent>
    </Dialog>
  );
}
