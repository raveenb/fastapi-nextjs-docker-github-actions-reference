# Next.js Reference Frontend

Reference implementation of a Next.js frontend with TypeScript, Tailwind CSS, and best practices.

## Technology Stack

- **Framework**: Next.js 15 with App Router
- **Language**: TypeScript
- **Styling**: Tailwind CSS v4
- **Package Manager**: pnpm
- **Linting**: ESLint
- **Formatting**: Prettier (to be configured)

## Getting Started

### Prerequisites

- Node.js 18.0.0 or later
- pnpm 10.0.0 or later

### Installation

```bash
pnpm install
```

### Development

Run the development server:

```bash
pnpm dev
```

Open [http://localhost:3000](http://localhost:3000) with your browser to see the result.

### Build

Build for production:

```bash
pnpm build
```

### Production

Start the production server:

```bash
pnpm start
```

## Scripts

- `pnpm dev` - Start development server with Turbopack
- `pnpm build` - Build for production with Turbopack
- `pnpm start` - Start production server
- `pnpm lint` - Run ESLint
- `pnpm format` - Format code with Prettier
- `pnpm type-check` - Run TypeScript type checking

## Project Structure

```
src/nextjs/
├── app/                # App router pages and layouts
│   ├── layout.tsx      # Root layout
│   ├── page.tsx        # Home page
│   └── globals.css     # Global styles
├── components/         # React components
├── lib/               # Utility functions
├── services/          # API services
├── types/             # TypeScript type definitions
├── public/            # Static assets
├── package.json       # Project dependencies
├── tsconfig.json      # TypeScript configuration
├── tailwind.config.ts # Tailwind CSS configuration
└── next.config.ts     # Next.js configuration
```

## Features

- ✅ TypeScript for type safety
- ✅ Tailwind CSS for styling
- ✅ Turbopack for fast builds
- ✅ App Router for modern routing
- ✅ ESLint for code quality
- 🚧 Prettier for code formatting
- 🚧 Jest for testing
- 🚧 API integration with FastAPI backend

## Environment Variables

Create a `.env.local` file in the root directory:

```env
# API Configuration
NEXT_PUBLIC_API_URL=http://localhost:8000
```

## Learn More

- [Next.js Documentation](https://nextjs.org/docs)
- [TypeScript Documentation](https://www.typescriptlang.org/docs)
- [Tailwind CSS Documentation](https://tailwindcss.com/docs)
