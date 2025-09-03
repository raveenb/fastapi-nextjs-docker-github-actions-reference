"use client";

import { useState } from "react";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Loading } from "@/components/common/loading";
import { useHealth, useReadiness, useLiveness } from "@/hooks/useHealth";
import { useConfig } from "@/hooks/useConfig";
import { CheckCircle2, XCircle, RefreshCw, Server, Activity, Settings, Heart } from "lucide-react";
import { cn } from "@/lib/utils";

export default function ApiTestPage() {
  const { health, isLoading: healthLoading, isError: healthError, mutate: refreshHealth } = useHealth(0);
  const { readiness, isLoading: readinessLoading, isError: readinessError, mutate: refreshReadiness } = useReadiness(0);
  const { liveness, isLoading: livenessLoading, isError: livenessError, mutate: refreshLiveness } = useLiveness(0);
  const { config, isLoading: configLoading, isError: configError, mutate: refreshConfig } = useConfig();

  const [isRefreshing, setIsRefreshing] = useState(false);

  const handleRefreshAll = async () => {
    setIsRefreshing(true);
    await Promise.all([
      refreshHealth(),
      refreshReadiness(),
      refreshLiveness(),
      refreshConfig(),
    ]);
    setIsRefreshing(false);
  };

  const StatusIcon = ({ isError, isLoading }: { isError: boolean; isLoading: boolean }) => {
    if (isLoading) return <Loading size="sm" />;
    if (isError) return <XCircle className="h-5 w-5 text-destructive" />;
    return <CheckCircle2 className="h-5 w-5 text-green-500" />;
  };

  return (
    <div className="container mx-auto px-4 py-8">
      <div className="flex items-center justify-between mb-8">
        <div>
          <h1 className="text-3xl font-bold">API Integration Test</h1>
          <p className="text-muted-foreground mt-1">
            Test the connection between frontend and backend services
          </p>
        </div>
        <Button 
          onClick={handleRefreshAll} 
          disabled={isRefreshing}
          className="gap-2"
        >
          <RefreshCw className={cn("h-4 w-4", isRefreshing && "animate-spin")} />
          Refresh All
        </Button>
      </div>

      <div className="grid gap-6 md:grid-cols-2">
        {/* Health Check */}
        <Card>
          <CardHeader>
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2">
                <Activity className="h-5 w-5" />
                <CardTitle>Health Check</CardTitle>
              </div>
              <StatusIcon isError={healthError} isLoading={healthLoading} />
            </div>
            <CardDescription>Basic API health status</CardDescription>
          </CardHeader>
          <CardContent>
            {healthLoading ? (
              <div className="text-sm text-muted-foreground">Loading...</div>
            ) : healthError ? (
              <div className="text-sm text-destructive">Failed to connect to API</div>
            ) : health ? (
              <div className="space-y-2">
                <div className="flex justify-between text-sm">
                  <span className="text-muted-foreground">Status:</span>
                  <span className={cn(
                    "font-medium",
                    health.status === "healthy" ? "text-green-500" : "text-yellow-500"
                  )}>
                    {health.status}
                  </span>
                </div>
                <div className="flex justify-between text-sm">
                  <span className="text-muted-foreground">Version:</span>
                  <span className="font-medium">{health.version}</span>
                </div>
                {health.timestamp && (
                  <div className="flex justify-between text-sm">
                    <span className="text-muted-foreground">Timestamp:</span>
                    <span className="font-medium">
                      {new Date(health.timestamp).toLocaleTimeString()}
                    </span>
                  </div>
                )}
              </div>
            ) : null}
          </CardContent>
        </Card>

        {/* Readiness Check */}
        <Card>
          <CardHeader>
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2">
                <Server className="h-5 w-5" />
                <CardTitle>Readiness Check</CardTitle>
              </div>
              <StatusIcon isError={readinessError} isLoading={readinessLoading} />
            </div>
            <CardDescription>Service readiness status</CardDescription>
          </CardHeader>
          <CardContent>
            {readinessLoading ? (
              <div className="text-sm text-muted-foreground">Loading...</div>
            ) : readinessError ? (
              <div className="text-sm text-destructive">Failed to connect to API</div>
            ) : readiness ? (
              <div className="space-y-2">
                <div className="flex justify-between text-sm">
                  <span className="text-muted-foreground">Status:</span>
                  <span className={cn(
                    "font-medium",
                    readiness.status === "ready" ? "text-green-500" : "text-yellow-500"
                  )}>
                    {readiness.status}
                  </span>
                </div>
                <div className="flex justify-between text-sm">
                  <span className="text-muted-foreground">Version:</span>
                  <span className="font-medium">{readiness.version}</span>
                </div>
                {readiness.checks && (
                  <div className="pt-2 border-t space-y-1">
                    <div className="text-xs font-medium text-muted-foreground mb-1">Service Checks:</div>
                    {Object.entries(readiness.checks).map(([key, value]) => (
                      <div key={key} className="flex justify-between text-sm">
                        <span className="text-muted-foreground capitalize">
                          {key.replace(/_/g, " ")}:
                        </span>
                        <span className={cn(
                          "font-medium",
                          value ? "text-green-500" : "text-red-500"
                        )}>
                          {value ? "Ready" : "Not Ready"}
                        </span>
                      </div>
                    ))}
                  </div>
                )}
              </div>
            ) : null}
          </CardContent>
        </Card>

        {/* Liveness Check */}
        <Card>
          <CardHeader>
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2">
                <Heart className="h-5 w-5" />
                <CardTitle>Liveness Check</CardTitle>
              </div>
              <StatusIcon isError={livenessError} isLoading={livenessLoading} />
            </div>
            <CardDescription>Service liveness probe</CardDescription>
          </CardHeader>
          <CardContent>
            {livenessLoading ? (
              <div className="text-sm text-muted-foreground">Loading...</div>
            ) : livenessError ? (
              <div className="text-sm text-destructive">Failed to connect to API</div>
            ) : liveness ? (
              <div className="space-y-2">
                <div className="flex justify-between text-sm">
                  <span className="text-muted-foreground">Status:</span>
                  <span className="font-medium text-green-500">
                    {liveness.status}
                  </span>
                </div>
                <div className="flex justify-between text-sm">
                  <span className="text-muted-foreground">Uptime:</span>
                  <span className="font-medium">
                    {Math.floor(liveness.uptime / 60)}m {Math.floor(liveness.uptime % 60)}s
                  </span>
                </div>
                {liveness.timestamp && (
                  <div className="flex justify-between text-sm">
                    <span className="text-muted-foreground">Timestamp:</span>
                    <span className="font-medium">
                      {new Date(liveness.timestamp).toLocaleTimeString()}
                    </span>
                  </div>
                )}
              </div>
            ) : null}
          </CardContent>
        </Card>

        {/* Configuration */}
        <Card>
          <CardHeader>
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2">
                <Settings className="h-5 w-5" />
                <CardTitle>Configuration</CardTitle>
              </div>
              <StatusIcon isError={configError} isLoading={configLoading} />
            </div>
            <CardDescription>Backend configuration settings</CardDescription>
          </CardHeader>
          <CardContent>
            {configLoading ? (
              <div className="text-sm text-muted-foreground">Loading...</div>
            ) : configError ? (
              <div className="text-sm text-destructive">Failed to connect to API</div>
            ) : config ? (
              <div className="space-y-2">
                <div className="flex justify-between text-sm">
                  <span className="text-muted-foreground">Environment:</span>
                  <span className="font-medium capitalize">{config.environment}</span>
                </div>
                <div className="flex justify-between text-sm">
                  <span className="text-muted-foreground">Debug Mode:</span>
                  <span className={cn(
                    "font-medium",
                    config.debug ? "text-yellow-500" : "text-green-500"
                  )}>
                    {config.debug ? "Enabled" : "Disabled"}
                  </span>
                </div>
                <div className="flex justify-between text-sm">
                  <span className="text-muted-foreground">Version:</span>
                  <span className="font-medium">{config.version}</span>
                </div>
                {config.features && (
                  <div className="pt-2 border-t space-y-1">
                    <div className="text-xs font-medium text-muted-foreground mb-1">Features:</div>
                    {Object.entries(config.features).map(([key, value]) => (
                      <div key={key} className="flex justify-between text-sm">
                        <span className="text-muted-foreground">
                          {key.replace(/_/g, " ")}:
                        </span>
                        <span className={cn(
                          "font-medium",
                          value ? "text-green-500" : "text-gray-400"
                        )}>
                          {value ? "Enabled" : "Disabled"}
                        </span>
                      </div>
                    ))}
                  </div>
                )}
              </div>
            ) : null}
          </CardContent>
        </Card>
      </div>

      {/* API Connection Status Summary */}
      <Card className="mt-6">
        <CardHeader>
          <CardTitle>Connection Summary</CardTitle>
          <CardDescription>Overall API connection status</CardDescription>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            <div className="text-center">
              <div className="text-2xl font-bold">
                {[health, readiness, liveness, config].filter(Boolean).length}
              </div>
              <div className="text-sm text-muted-foreground">Connected</div>
            </div>
            <div className="text-center">
              <div className="text-2xl font-bold">
                {[healthError, readinessError, livenessError, configError].filter(Boolean).length}
              </div>
              <div className="text-sm text-muted-foreground">Failed</div>
            </div>
            <div className="text-center">
              <div className="text-2xl font-bold">
                {[healthLoading, readinessLoading, livenessLoading, configLoading].filter(Boolean).length}
              </div>
              <div className="text-sm text-muted-foreground">Loading</div>
            </div>
            <div className="text-center">
              <div className="text-2xl font-bold">4</div>
              <div className="text-sm text-muted-foreground">Total Endpoints</div>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}