import { Metadata } from "next";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { 
  Activity, 
  Users, 
  Server, 
  Database,
  BarChart3,
  Settings,
  ArrowUpRight,
  ArrowDownRight
} from "lucide-react";

export const metadata: Metadata = {
  title: "Dashboard",
  description: "Application dashboard and metrics",
};

export default function DashboardPage() {
  const stats = [
    {
      title: "Total Requests",
      value: "12,345",
      change: "+12.5%",
      trend: "up",
      icon: Activity,
    },
    {
      title: "Active Users",
      value: "573",
      change: "+8.2%",
      trend: "up",
      icon: Users,
    },
    {
      title: "API Latency",
      value: "45ms",
      change: "-5.3%",
      trend: "down",
      icon: Server,
    },
    {
      title: "Database Size",
      value: "2.4 GB",
      change: "+2.1%",
      trend: "up",
      icon: Database,
    },
  ];

  return (
    <div className="container mx-auto px-4 py-8">
      <div className="flex items-center justify-between mb-8">
        <div>
          <h1 className="text-3xl font-bold">Dashboard</h1>
          <p className="text-muted-foreground mt-1">
            Monitor your application performance and metrics
          </p>
        </div>
        <Button variant="outline" className="gap-2">
          <Settings className="h-4 w-4" />
          Settings
        </Button>
      </div>

      {/* Stats Grid */}
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4 mb-8">
        {stats.map((stat) => {
          const Icon = stat.icon;
          const isPositiveTrend = stat.trend === "up";
          const TrendIcon = isPositiveTrend ? ArrowUpRight : ArrowDownRight;
          const trendColor = isPositiveTrend ? "text-green-500" : "text-red-500";

          return (
            <Card key={stat.title}>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">
                  {stat.title}
                </CardTitle>
                <Icon className="h-4 w-4 text-muted-foreground" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold">{stat.value}</div>
                <div className="flex items-center gap-1 text-xs mt-1">
                  <TrendIcon className={`h-3 w-3 ${trendColor}`} />
                  <span className={trendColor}>{stat.change}</span>
                  <span className="text-muted-foreground">from last week</span>
                </div>
              </CardContent>
            </Card>
          );
        })}
      </div>

      {/* Main Content Grid */}
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-7">
        <Card className="col-span-4">
          <CardHeader>
            <CardTitle>API Request Overview</CardTitle>
            <CardDescription>
              Request volume over the last 7 days
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div className="h-[300px] flex items-center justify-center text-muted-foreground">
              <div className="text-center">
                <BarChart3 className="h-12 w-12 mx-auto mb-2" />
                <p>Chart visualization will be implemented here</p>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card className="col-span-3">
          <CardHeader>
            <CardTitle>Recent Activity</CardTitle>
            <CardDescription>
              Latest system events and notifications
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              {[
                { time: "2 min ago", event: "New user registration", type: "info" },
                { time: "15 min ago", event: "API deployment completed", type: "success" },
                { time: "1 hour ago", event: "Database backup completed", type: "info" },
                { time: "2 hours ago", event: "High memory usage detected", type: "warning" },
                { time: "3 hours ago", event: "SSL certificate renewed", type: "success" },
              ].map((item, index) => (
                <div key={index} className="flex items-start gap-3">
                  <div
                    className={cn(
                      "h-2 w-2 rounded-full mt-1.5",
                      item.type === "success" && "bg-green-500",
                      item.type === "warning" && "bg-yellow-500",
                      item.type === "info" && "bg-blue-500"
                    )}
                  />
                  <div className="flex-1 space-y-1">
                    <p className="text-sm">{item.event}</p>
                    <p className="text-xs text-muted-foreground">{item.time}</p>
                  </div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Additional Sections */}
      <div className="grid gap-4 mt-4 md:grid-cols-2">
        <Card>
          <CardHeader>
            <CardTitle>System Health</CardTitle>
            <CardDescription>
              Current system resource utilization
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              <div>
                <div className="flex items-center justify-between mb-1">
                  <span className="text-sm">CPU Usage</span>
                  <span className="text-sm font-medium">45%</span>
                </div>
                <div className="h-2 bg-muted rounded-full overflow-hidden">
                  <div className="h-full bg-primary" style={{ width: "45%" }} />
                </div>
              </div>
              <div>
                <div className="flex items-center justify-between mb-1">
                  <span className="text-sm">Memory Usage</span>
                  <span className="text-sm font-medium">62%</span>
                </div>
                <div className="h-2 bg-muted rounded-full overflow-hidden">
                  <div className="h-full bg-primary" style={{ width: "62%" }} />
                </div>
              </div>
              <div>
                <div className="flex items-center justify-between mb-1">
                  <span className="text-sm">Disk Usage</span>
                  <span className="text-sm font-medium">38%</span>
                </div>
                <div className="h-2 bg-muted rounded-full overflow-hidden">
                  <div className="h-full bg-primary" style={{ width: "38%" }} />
                </div>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Quick Actions</CardTitle>
            <CardDescription>
              Common administrative tasks
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-2">
            <Button variant="outline" className="w-full justify-start">
              Clear Cache
            </Button>
            <Button variant="outline" className="w-full justify-start">
              Run Database Backup
            </Button>
            <Button variant="outline" className="w-full justify-start">
              View Logs
            </Button>
            <Button variant="outline" className="w-full justify-start">
              Restart Services
            </Button>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}

function cn(...classes: (string | boolean | undefined)[]) {
  return classes.filter(Boolean).join(" ");
}