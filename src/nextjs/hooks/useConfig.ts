import useSWR from "swr";
import { configService } from "@/services/config";
import { ConfigResponse } from "@/types/api";

export function useConfig() {
  const { data, error, isLoading, mutate } = useSWR<ConfigResponse>(
    "/api/config",
    () => configService.getConfig(),
    {
      revalidateOnFocus: false,
      revalidateOnReconnect: false,
      shouldRetryOnError: true,
      errorRetryCount: 3,
      errorRetryInterval: 5000,
    }
  );

  return {
    config: data,
    isLoading,
    isError: !!error,
    error,
    mutate,
    environment: data?.environment,
    features: data?.features,
    isDebug: data?.debug || false,
  };
}

export function useFeatureFlag(featureName: string): boolean {
  const { features } = useConfig();
  return features?.[featureName] || false;
}