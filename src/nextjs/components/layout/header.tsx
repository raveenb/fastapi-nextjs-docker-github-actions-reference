"use client";

import Link from "next/link";
import { Button } from "@/components/ui/button";
import { APP_NAME } from "@/config/constants";

export function Header() {
  return (
    <header className="border-b">
      <div className="container mx-auto px-4 h-16 flex items-center justify-between">
        <Link href="/" className="font-bold text-xl">
          {APP_NAME}
        </Link>
        
        <nav className="hidden md:flex items-center gap-6">
          <Link href="/dashboard" className="text-sm font-medium hover:text-primary">
            Dashboard
          </Link>
          <Link href="/api-test" className="text-sm font-medium hover:text-primary">
            API Test
          </Link>
          <Link href="/api-docs" className="text-sm font-medium hover:text-primary">
            API Docs
          </Link>
          <Link href="/settings" className="text-sm font-medium hover:text-primary">
            Settings
          </Link>
        </nav>

        <div className="flex items-center gap-4">
          <Button variant="ghost" size="sm">
            Sign In
          </Button>
          <Button size="sm">Get Started</Button>
        </div>
      </div>
    </header>
  );
}