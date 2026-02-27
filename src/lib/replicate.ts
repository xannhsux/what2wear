import Replicate from "replicate";

if (!process.env.REPLICATE_API_TOKEN) {
  throw new Error(
    "REPLICATE_API_TOKEN environment variable is not set. " +
      "Get your token at https://replicate.com/account/api-tokens"
  );
}

export const replicate = new Replicate({
  auth: process.env.REPLICATE_API_TOKEN,
});
