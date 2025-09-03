"use client";

import { useEffect, useState } from "react";
import { Card, CardContent } from "@/components/ui/card";
import { Loading } from "@/components/common/loading";
import { healthService } from "@/services/health";
import { HealthResponse } from "@/types/api";
import { CheckCircle2, XCircle, AlertCircle, Activity } from "lucide-react";
import { cn } from "@/lib/utils";

export function ApiStatus() {
  const [status, setStatus] = useState<HealthResponse | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const checkHealth = async () => {
      try {
        setLoading(true);
        setError(null);
        const response = await healthService.getHealth();
        setStatus(response);
      } catch (err) {
        setError("Unable to connect to API");
        console.error("Health check failed:", err);
      } finally {
        setLoading(false);
      }
    };

    checkHealth();
    // Refresh every 30 seconds
    const interval = setInterval(checkHealth, 30000);
    return () => clearInterval(interval);
  }, []);

  if (loading) {
    return (
      <Card>
        <CardContent className="py-4">
          <div className="flex items-center gap-4">
            <Loading size="sm" />
            <span className="text-sm text-muted-foreground">Checking API status...</span>
          </div>
        </CardContent>
      </Card>
    );
  }

  const isHealthy = status?.status === "healthy";
  const statusIcon = error ? (
    <XCircle className="h-5 w-5 text-destructive" />
  ) : isHealthy ? (
    <CheckCircle2 className="h-5 w-5 text-green-500" />
  ) : (
    <AlertCircle className="h-5 w-5 text-yellow-500" />
  );

  const statusText = error ? "API Offline" : isHealthy ? "API Online" : "API Degraded";
  const statusColor = error
    ? "text-destructive"
    : isHealthy
    ? "text-green-500"
    : "text-yellow-500";

  return (
    <Card>
      <CardContent className="py-4">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-3">
            <Activity className="h-5 w-5 text-muted-foreground" />
            <div className="flex items-center gap-2">
              {statusIcon}
              <span className={cn("font-medium", statusColor)}>{statusText}</span>
            </div>
          </div>
          {status && (
            <div className="flex items-center gap-4 text-sm text-muted-foreground">
              <span>Version: {status.version}</span>
              {status.timestamp && (
                <span>
                  Last checked: {new Date(status.timestamp).toLocaleTimeString()}
                </span>
              )}
            </div>
          )}
        </div>
      </CardContent>
    </Card>
  );
}