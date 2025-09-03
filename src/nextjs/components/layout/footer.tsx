import { APP_NAME, APP_VERSION } from "@/config/constants";

export function Footer() {
  const currentYear = new Date().getFullYear();

  return (
    <footer className="border-t">
      <div className="container mx-auto px-4 py-8">
        <div className="flex flex-col md:flex-row justify-between items-center gap-4">
          <div className="text-sm text-muted-foreground">
            © {currentYear} {APP_NAME}. All rights reserved.
          </div>
          
          <div className="flex items-center gap-6 text-sm">
            <a
              href="https://github.com/raveenb/fastapi-nextjs-docker-github-actions-reference"
              target="_blank"
              rel="noopener noreferrer"
              className="hover:text-primary"
            >
              GitHub
            </a>
            <a href="/api-docs" className="hover:text-primary">
              API Documentation
            </a>
            <span className="text-muted-foreground">v{APP_VERSION}</span>
          </div>
        </div>
      </div>
    </footer>
  );
}