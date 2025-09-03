// Application Constants
export const APP_NAME = "FastAPI Next.js Reference";
export const APP_DESCRIPTION = "Reference implementation of FastAPI and Next.js";
export const APP_VERSION = "0.1.0";

// API Configuration
export const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || "http://localhost:8000";
export const API_TIMEOUT = 30000; // 30 seconds
export const API_RETRY_ATTEMPTS = 3;
export const API_RETRY_DELAY = 1000; // 1 second

// UI Configuration
export const DEFAULT_PAGE_SIZE = 20;
export const MAX_PAGE_SIZE = 100;
export const DEBOUNCE_DELAY = 300; // 300ms
export const TOAST_DURATION = 5000; // 5 seconds

// Storage Keys
export const STORAGE_KEYS = {
  AUTH_TOKEN: "auth_token",
  REFRESH_TOKEN: "refresh_token",
  USER_PREFERENCES: "user_preferences",
  THEME: "theme",
  LOCALE: "locale",
} as const;

// Route Paths
export const ROUTES = {
  HOME: "/",
  LOGIN: "/auth/login",
  REGISTER: "/auth/register",
  DASHBOARD: "/dashboard",
  PROFILE: "/profile",
  SETTINGS: "/settings",
  API_DOCS: "/api-docs",
} as const;

// Feature Flags
export const FEATURES = {
  DARK_MODE: true,
  NOTIFICATIONS: true,
  API_DOCS: process.env.NODE_ENV === "development",
  ANALYTICS: process.env.NODE_ENV === "production",
} as const;

// Validation Rules
export const VALIDATION = {
  PASSWORD_MIN_LENGTH: 8,
  PASSWORD_MAX_LENGTH: 128,
  EMAIL_MAX_LENGTH: 255,
  NAME_MAX_LENGTH: 100,
} as const;

// Date Formats
export const DATE_FORMATS = {
  SHORT: "MM/dd/yyyy",
  LONG: "MMMM dd, yyyy",
  WITH_TIME: "MM/dd/yyyy HH:mm",
  ISO: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
} as const;