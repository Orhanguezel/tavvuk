/** @type {import('next').NextConfig} */
const nextConfig = {
  reactCompiler: true,
  compiler: {
    removeConsole: process.env.NODE_ENV === 'production',
  },

  async redirects() {
    return [
      {
        source: '/dashboard',
        destination: '/dashboard/default',
        permanent: false,
      },
    ];
  },

  async rewrites() {
    // Backend origin: env > fallback
    const backend =
      process.env.PANEL_API_URL || process.env.NEXT_PUBLIC_PANEL_API_URL || 'http://localhost:8045';

    const base = String(backend).replace(/\/+$/, '');

    return [
      {
        // ✅ Same-origin /api proxy → backend /api
        source: '/api/:path*',
        destination: `${base}/api/:path*`,
      },
    ];
  },
};

export default nextConfig;
