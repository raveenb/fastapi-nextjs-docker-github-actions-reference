// API Response Types

export interface HealthResponse {
  status: "healthy" | "unhealthy";
  version: string;
  timestamp?: string;
}

export interface ReadinessResponse {
  status: "ready" | "not_ready";
  version: string;
  checks: {
    database?: boolean;
    cache?: boolean;
    external_api?: boolean;
  };
  timestamp?: string;
}

export interface LivenessResponse {
  status: "alive";
  uptime: number;
  timestamp?: string;
}

export interface ConfigResponse {
  environment: string;
  debug: boolean;
  features: {
    api_docs: boolean;
    metrics: boolean;
    [key: string]: boolean;
  };
  version: string;
}

export interface ApiErrorResponse {
  detail: string;
  status?: number;
  type?: string;
  instance?: string;
}

// Pagination Types
export interface PaginationParams {
  page?: number;
  limit?: number;
  sort?: string;
  order?: "asc" | "desc";
}

export interface PaginatedResponse<T> {
  items: T[];
  total: number;
  page: number;
  limit: number;
  pages: number;
}

// Generic API Types
export interface ApiResponse<T> {
  data: T;
  message?: string;
  timestamp?: string;
}

export interface ValidationError {
  field: string;
  message: string;
  type?: string;
}