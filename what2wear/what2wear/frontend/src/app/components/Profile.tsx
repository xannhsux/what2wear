import { useState, useEffect } from "react";
import { authenticatedFetch } from "@/app/utils/api";

import { MannequinDisplay } from "@/app/components/MannequinDisplay";

export interface UserMeasurements {
  height: number;
  weight: number;
  shoeSize: number;
  chest: number;
  waist: number;
  hips: number;
}

const defaultMeasurements: UserMeasurements = {
  height: 170,
  weight: 65,
  shoeSize: 40,
  chest: 90,
  waist: 75,
  hips: 95,
};

export function Profile() {
  const [measurements, setMeasurements] = useState<UserMeasurements>(defaultMeasurements);
  const [isEditing, setIsEditing] = useState(false);
  const [editedMeasurements, setEditedMeasurements] = useState<UserMeasurements>(measurements);

  useEffect(() => {
    loadProfile();
  }, []);

  const loadProfile = async () => {
    try {
      const data = await authenticatedFetch('/profile');
      if (data) {
        setMeasurements({
          height: Number(data.height) || 0,
          weight: Number(data.weight) || 0,
          shoeSize: Number(data.shoe_size) || 0,
          chest: Number(data.chest) || 0,
          waist: Number(data.waist) || 0,
          hips: Number(data.hips) || 0,
        });
        setEditedMeasurements(measurements); // sync edit state
      }
    } catch (err) {
      console.error("Failed to load profile", err);
    }
  };

  const handleEdit = () => {
    setEditedMeasurements(measurements);
    setIsEditing(true);
  };

  const handleSave = async () => {
    try {
      // Convert to backend casing
      const payload = {
        height: editedMeasurements.height,
        weight: editedMeasurements.weight,
        shoe_size: editedMeasurements.shoeSize,
        chest: editedMeasurements.chest,
        waist: editedMeasurements.waist,
        hips: editedMeasurements.hips,
      };

      await authenticatedFetch('/profile', {
        method: 'PUT',
        body: JSON.stringify(payload)
      });

      setMeasurements(editedMeasurements);
      setIsEditing(false);
    } catch (err) {
      console.error("Failed to save profile", err);
    }
  };

  const handleCancel = () => {
    setEditedMeasurements(measurements);
    setIsEditing(false);
  };

  const handleChange = (field: keyof UserMeasurements, value: string) => {
    const numValue = parseFloat(value) || 0;
    setEditedMeasurements((prev) => ({ ...prev, [field]: numValue }));
  };

  const measurementFields = [
    { key: "height" as const, label: "Height", unit: "cm" },
    { key: "weight" as const, label: "Weight", unit: "kg" },
    { key: "shoeSize" as const, label: "Shoe Size", unit: "EU" },
    { key: "chest" as const, label: "Chest", unit: "cm" },
    { key: "waist" as const, label: "Waist", unit: "cm" },
    { key: "hips" as const, label: "Hips", unit: "cm" },
  ];

  return (
    <div className="flex-1 flex flex-col bg-white overflow-hidden">
      {/* Profile Card */}
      <div className="pt-16 px-6 pb-6">
        <div className="bg-white rounded-3xl border border-gray-100 shadow-[0_4px_16px_rgba(0,0,0,0.06)] p-6">
          {/* Card Header */}
          <div className="flex items-start justify-between mb-6">
            <div>
              <h2 className="text-2xl tracking-tight mb-1">My Profile</h2>
              <p className="text-sm text-gray-500">Current measurements</p>
            </div>
            {!isEditing && (
              <button
                onClick={handleEdit}
                className="text-sm text-black underline"
              >
                Edit
              </button>
            )}
          </div>

          {/* Measurements Grid */}
          {!isEditing ? (
            <div className="grid grid-cols-3 gap-6">
              {measurementFields.map(({ key, label, unit }) => (
                <div key={key} className="text-center">
                  <div className="text-2xl font-medium mb-1">
                    {measurements[key]}
                  </div>
                  <div className="text-xs text-gray-500">{label}</div>
                  <div className="text-xs text-gray-400">{unit}</div>
                </div>
              ))}
            </div>
          ) : (
            <div className="space-y-4">
              {/* Edit Mode - Input Fields */}
              <div className="grid grid-cols-2 gap-3">
                {measurementFields.map(({ key, label, unit }) => (
                  <div key={key}>
                    <label className="block text-xs text-gray-500 mb-1.5">
                      {label} ({unit})
                    </label>
                    <input
                      type="number"
                      value={editedMeasurements[key]}
                      onChange={(e) => handleChange(key, e.target.value)}
                      className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:outline-none focus:border-black transition-colors"
                    />
                  </div>
                ))}
              </div>

              {/* Save/Cancel Buttons */}
              <div className="flex gap-2 pt-2">
                <button
                  onClick={handleSave}
                  className="flex-1 bg-black text-white py-2.5 rounded-full text-sm font-medium"
                >
                  Save
                </button>
                <button
                  onClick={handleCancel}
                  className="flex-1 border border-gray-300 py-2.5 rounded-full text-sm"
                >
                  Cancel
                </button>
              </div>
            </div>
          )}
        </div>
      </div>

      {/* Mannequin Display */}
      <div className="flex-1 overflow-y-auto pb-24">
        <MannequinDisplay measurements={measurements} />
      </div>
    </div>
  );
}
