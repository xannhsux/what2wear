// ─── Replicate LoRA Training ───
// Model: ostris/flux-dev-lora-trainer
export const LORA_TRAINER_OWNER = "ostris";
export const LORA_TRAINER_MODEL = "flux-dev-lora-trainer";
export const LORA_TRAINER_VERSION =
    "26dce37af90b9d997eeb970d92e47de3064d46c300504ae376c75bef6a9022d2";

// Destination for trained LoRA model on Replicate
// Set REPLICATE_USERNAME in .env.local to your Replicate username
export const REPLICATE_DESTINATION =
    `${process.env.REPLICATE_USERNAME || "what2wear-user"}/what2wear-lora`;

// ─── Replicate LoRA Generation ───
// Model: lucataco/flux-dev-lora
export const FLUX_LORA_VERSION =
    "091495765fa5ef2725a175a57b276ec30dc9d39c22d30410f2ede68a3eab66b3";

// ─── Polling ───
export const POLL_INTERVAL_MS = 1000;
export const MAX_POLL_ATTEMPTS = 120;
