"use server";

import { HealthResponse, ReadinessResponse, LivenessResponse, ConfigResponse } from "@/types/api";

const API_URL = process.env.NEXT_PUBLIC_API_URL || "http://localhost:8000";

async function fetchFromAPI<T>(endpoint: string): Promise<T> {
  const url = `${API_URL}${endpoint}`;
  
  try {
    const response = await fetch(url, {
      method: "GET",
      headers: {
        "Content-Type": "application/json",
      },
      cache: "no-store",
    });

    if (!response.ok) {
      throw new Error(`API request failed: ${response.status} ${response.statusText}`);
    }

    return await response.json();
  } catch (error) {
    console.error(`Error fetching ${endpoint}:`, error);
    throw error;
  }
}

export async function getServerHealth(): Promise<HealthResponse> {
  return fetchFromAPI<HealthResponse>("/api/health");
}

export async function getServerReadiness(): Promise<ReadinessResponse> {
  return fetchFromAPI<ReadinessResponse>("/api/ready");
}

export async function getServerLiveness(): Promise<LivenessResponse> {
  return fetchFromAPI<LivenessResponse>("/api/live");
}

export async function getServerConfig(): Promise<ConfigResponse> {
  return fetchFromAPI<ConfigResponse>("/api/config");
}