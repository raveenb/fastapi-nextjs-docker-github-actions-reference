import { z } from "zod";

// Environment variable schema
const envSchema = z.object({
  // Required
  NEXT_PUBLIC_API_URL: z.string().url(),
  
  // Optional with defaults
  NEXT_PUBLIC_APP_NAME: z.string().optional().default("FastAPI Next.js Reference"),
  NEXT_PUBLIC_APP_VERSION: z.string().optional().default("0.1.0"),
  NEXT_PUBLIC_ENABLE_ANALYTICS: z
    .string()
    .optional()
    .default("false")
    .transform((val) => val === "true"),
  NEXT_PUBLIC_ENABLE_DEBUG: z
    .string()
    .optional()
    .default("false")
    .transform((val) => val === "true"),
});

// Parse and validate environment variables
export const env = (() => {
  try {
    return envSchema.parse({
      NEXT_PUBLIC_API_URL: process.env.NEXT_PUBLIC_API_URL,
      NEXT_PUBLIC_APP_NAME: process.env.NEXT_PUBLIC_APP_NAME,
      NEXT_PUBLIC_APP_VERSION: process.env.NEXT_PUBLIC_APP_VERSION,
      NEXT_PUBLIC_ENABLE_ANALYTICS: process.env.NEXT_PUBLIC_ENABLE_ANALYTICS,
      NEXT_PUBLIC_ENABLE_DEBUG: process.env.NEXT_PUBLIC_ENABLE_DEBUG,
    });
  } catch (error) {
    if (error instanceof z.ZodError) {
      console.error("❌ Invalid environment variables:", error.flatten().fieldErrors);
      throw new Error("Invalid environment variables");
    }
    throw error;
  }
})();

// Export typed environment variables
export default env;