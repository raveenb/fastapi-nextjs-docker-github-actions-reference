import { ConfigResponse } from "@/types/api";
import apiClient from "./api";

export const configService = {
  async getConfig(): Promise<ConfigResponse> {
    return apiClient.get<ConfigResponse>("/api/config");
  },

  async getEnvironment(): Promise<string> {
    const config = await this.getConfig();
    return config.environment;
  },

  async getFeatures(): Promise<Record<string, boolean>> {
    const config = await this.getConfig();
    return config.features;
  },

  async isFeatureEnabled(feature: string): Promise<boolean> {
    const features = await this.getFeatures();
    return features[feature] || false;
  },
};