import useSWR from "swr";
import { healthService } from "@/services/health";
import { HealthResponse, ReadinessResponse, LivenessResponse } from "@/types/api";

export function useHealth(refreshInterval: number = 30000) {
  const { data, error, isLoading, mutate } = useSWR<HealthResponse>(
    "/api/health",
    () => healthService.getHealth(),
    {
      refreshInterval,
      revalidateOnFocus: true,
      shouldRetryOnError: true,
      errorRetryCount: 3,
      errorRetryInterval: 5000,
    }
  );

  return {
    health: data,
    isLoading,
    isError: !!error,
    error,
    mutate,
  };
}

export function useReadiness(refreshInterval: number = 30000) {
  const { data, error, isLoading, mutate } = useSWR<ReadinessResponse>(
    "/api/ready",
    () => healthService.getReadiness(),
    {
      refreshInterval,
      revalidateOnFocus: true,
      shouldRetryOnError: true,
      errorRetryCount: 3,
      errorRetryInterval: 5000,
    }
  );

  return {
    readiness: data,
    isLoading,
    isError: !!error,
    error,
    mutate,
  };
}

export function useLiveness(refreshInterval: number = 30000) {
  const { data, error, isLoading, mutate } = useSWR<LivenessResponse>(
    "/api/live",
    () => healthService.getLiveness(),
    {
      refreshInterval,
      revalidateOnFocus: true,
      shouldRetryOnError: true,
      errorRetryCount: 3,
      errorRetryInterval: 5000,
    }
  );

  return {
    liveness: data,
    isLoading,
    isError: !!error,
    error,
    mutate,
  };
}