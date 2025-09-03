import apiClient from "./api";
import { HealthResponse, ReadinessResponse, LivenessResponse } from "@/types/api";

export const healthService = {
  async getHealth(): Promise<HealthResponse> {
    return apiClient.get<HealthResponse>("/api/health");
  },

  async getReadiness(): Promise<ReadinessResponse> {
    return apiClient.get<ReadinessResponse>("/api/ready");
  },

  async getLiveness(): Promise<LivenessResponse> {
    return apiClient.get<LivenessResponse>("/api/live");
  },
};