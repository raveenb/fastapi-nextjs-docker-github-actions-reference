import Link from "next/link";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { ApiStatus } from "@/components/common/api-status";
import { ArrowRight, Code2, Zap, Shield, Rocket, GitBranch, Container } from "lucide-react";

export default function Home() {
  return (
    <div className="flex flex-col">
      {/* Hero Section */}
      <section className="relative overflow-hidden bg-gradient-to-br from-slate-50 to-slate-100 dark:from-slate-900 dark:to-slate-800">
        <div className="container mx-auto px-4 py-24 sm:py-32">
          <div className="mx-auto max-w-4xl text-center">
            <h1 className="text-4xl font-bold tracking-tight text-gray-900 dark:text-white sm:text-6xl">
              FastAPI + Next.js
              <span className="block text-primary">Reference Architecture</span>
            </h1>
            <p className="mt-6 text-lg leading-8 text-gray-600 dark:text-gray-300">
              Production-ready full-stack application with FastAPI backend, Next.js frontend,
              Docker containerization, and GitHub Actions CI/CD pipeline.
            </p>
            <div className="mt-10 flex items-center justify-center gap-4">
              <Link href="/dashboard">
                <Button size="lg" className="gap-2">
                  View Dashboard
                  <ArrowRight className="h-4 w-4" />
                </Button>
              </Link>
              <Link href="/api-docs">
                <Button size="lg" variant="outline">
                  API Documentation
                </Button>
              </Link>
            </div>
          </div>
        </div>
      </section>

      {/* API Status Section */}
      <section className="py-8 border-b">
        <div className="container mx-auto px-4">
          <ApiStatus />
        </div>
      </section>

      {/* Features Section */}
      <section className="py-16 sm:py-24">
        <div className="container mx-auto px-4">
          <div className="mx-auto max-w-2xl text-center mb-12">
            <h2 className="text-3xl font-bold tracking-tight sm:text-4xl">
              Modern Tech Stack
            </h2>
            <p className="mt-4 text-lg text-muted-foreground">
              Built with best practices and industry-standard tools
            </p>
          </div>

          <div className="mx-auto max-w-6xl">
            <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3">
              <Card>
                <CardHeader>
                  <Zap className="h-8 w-8 text-primary mb-2" />
                  <CardTitle>FastAPI Backend</CardTitle>
                  <CardDescription>
                    High-performance async Python API with automatic OpenAPI documentation
                  </CardDescription>
                </CardHeader>
                <CardContent>
                  <ul className="text-sm space-y-1 text-muted-foreground">
                    <li>• Pydantic validation</li>
                    <li>• Async/await support</li>
                    <li>• Auto-generated docs</li>
                    <li>• Type safety</li>
                  </ul>
                </CardContent>
              </Card>

              <Card>
                <CardHeader>
                  <Code2 className="h-8 w-8 text-primary mb-2" />
                  <CardTitle>Next.js Frontend</CardTitle>
                  <CardDescription>
                    React framework with server-side rendering and static generation
                  </CardDescription>
                </CardHeader>
                <CardContent>
                  <ul className="text-sm space-y-1 text-muted-foreground">
                    <li>• TypeScript</li>
                    <li>• Tailwind CSS</li>
                    <li>• App Router</li>
                    <li>• Turbopack</li>
                  </ul>
                </CardContent>
              </Card>

              <Card>
                <CardHeader>
                  <Container className="h-8 w-8 text-primary mb-2" />
                  <CardTitle>Docker & Kubernetes</CardTitle>
                  <CardDescription>
                    Containerized deployment with orchestration support
                  </CardDescription>
                </CardHeader>
                <CardContent>
                  <ul className="text-sm space-y-1 text-muted-foreground">
                    <li>• Multi-stage builds</li>
                    <li>• Docker Compose</li>
                    <li>• K8s manifests</li>
                    <li>• Health checks</li>
                  </ul>
                </CardContent>
              </Card>

              <Card>
                <CardHeader>
                  <GitBranch className="h-8 w-8 text-primary mb-2" />
                  <CardTitle>GitHub Actions</CardTitle>
                  <CardDescription>
                    Automated CI/CD pipeline with testing and deployment
                  </CardDescription>
                </CardHeader>
                <CardContent>
                  <ul className="text-sm space-y-1 text-muted-foreground">
                    <li>• Automated testing</li>
                    <li>• Code quality checks</li>
                    <li>• Docker builds</li>
                    <li>• Multi-environment deploy</li>
                  </ul>
                </CardContent>
              </Card>

              <Card>
                <CardHeader>
                  <Shield className="h-8 w-8 text-primary mb-2" />
                  <CardTitle>Security First</CardTitle>
                  <CardDescription>
                    Built-in security features and best practices
                  </CardDescription>
                </CardHeader>
                <CardContent>
                  <ul className="text-sm space-y-1 text-muted-foreground">
                    <li>• Environment configs</li>
                    <li>• Secret management</li>
                    <li>• CORS handling</li>
                    <li>• Input validation</li>
                  </ul>
                </CardContent>
              </Card>

              <Card>
                <CardHeader>
                  <Rocket className="h-8 w-8 text-primary mb-2" />
                  <CardTitle>Production Ready</CardTitle>
                  <CardDescription>
                    Monitoring, logging, and observability built-in
                  </CardDescription>
                </CardHeader>
                <CardContent>
                  <ul className="text-sm space-y-1 text-muted-foreground">
                    <li>• Health endpoints</li>
                    <li>• Structured logging</li>
                    <li>• OpenTelemetry</li>
                    <li>• Error tracking</li>
                  </ul>
                </CardContent>
              </Card>
            </div>
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-16 bg-primary/5">
        <div className="container mx-auto px-4 text-center">
          <h2 className="text-3xl font-bold mb-4">Ready to Get Started?</h2>
          <p className="text-lg text-muted-foreground mb-8 max-w-2xl mx-auto">
            Clone the repository and start building your next production application
            with our comprehensive reference architecture.
          </p>
          <div className="flex items-center justify-center gap-4">
            <a
              href="https://github.com/raveenb/fastapi-nextjs-docker-github-actions-reference"
              target="_blank"
              rel="noopener noreferrer"
            >
              <Button size="lg" className="gap-2">
                <GitBranch className="h-4 w-4" />
                View on GitHub
              </Button>
            </a>
            <Link href="/docs">
              <Button size="lg" variant="outline">
                Read Documentation
              </Button>
            </Link>
          </div>
        </div>
      </section>
    </div>
  );
}