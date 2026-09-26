"use client";

import Link from "next/link";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { ShieldCheck, Cpu, Database, Zap, ArrowRight, CheckCircle, Layout, Lock } from "lucide-react";
import { useEffect, useState } from "react";
import { apiClient } from "@/services/api-client";

export default function Home() {
  const [backendStatus, setBackendStatus] = useState<"checking" | "online" | "offline">("checking");

  useEffect(() => {
    // Ping backend auth endpoint or health check
    apiClient
      .get("/auth/me")
      .then(() => setBackendStatus("online"))
      .catch((err) => {
        // 401 unauthenticated means backend IS responding!
        if (err.response?.status === 401 || err.response?.status === 403 || err.response?.status === 200) {
          setBackendStatus("online");
        } else {
          setBackendStatus("offline");
        }
      });
  }, []);

  return (
    <div className="min-h-screen bg-slate-950 text-slate-100 flex flex-col justify-between relative overflow-hidden">
      {/* Glow Effects */}
      <div className="absolute top-0 left-1/2 -translate-x-1/2 w-[800px] h-[500px] bg-gradient-to-b from-indigo-600/20 via-purple-600/10 to-transparent blur-[140px] pointer-events-none" />

      {/* Navigation Header */}
      <header className="border-b border-slate-800/80 bg-slate-900/40 backdrop-blur-xl sticky top-0 z-50">
        <div className="max-w-6xl mx-auto px-6 h-16 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="flex items-center justify-center w-9 h-9 rounded-xl bg-gradient-to-tr from-indigo-600 to-purple-600 text-white shadow-md shadow-indigo-500/20">
              <ShieldCheck className="h-5 w-5" />
            </div>
            <span className="font-bold text-lg tracking-tight text-white">SaaS Architecture</span>
          </div>

          <div className="flex items-center gap-4">
            <div className="hidden sm:flex items-center gap-2 px-3 py-1 rounded-full border border-slate-800 bg-slate-900 text-xs">
              <span className={`w-2 h-2 rounded-full ${backendStatus === "online" ? "bg-emerald-400 animate-pulse" : backendStatus === "offline" ? "bg-red-500" : "bg-amber-400"}`} />
              <span className="text-slate-300">
                Backend: {backendStatus === "online" ? "Online (Port 8080)" : backendStatus === "offline" ? "Offline" : "Đang kiểm tra..."}
              </span>
            </div>
            <Link href="/login">
              <Button variant="ghost" size="sm">
                Đăng nhập
              </Button>
            </Link>
            <Link href="/register">
              <Button variant="default" size="sm">
                Đăng ký ngay
              </Button>
            </Link>
          </div>
        </div>
      </header>

      {/* Main Hero Section */}
      <main className="max-w-6xl mx-auto px-6 py-16 md:py-24 space-y-20 relative z-10 flex-1">
        <div className="text-center space-y-6 max-w-3xl mx-auto">
          <div className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full border border-indigo-500/30 bg-indigo-500/10 text-indigo-300 text-xs font-medium">
            <Zap className="h-3.5 w-3.5 text-indigo-400" /> Enterprise-Grade Stack Standardized
          </div>

          <h1 className="text-4xl sm:text-6xl font-extrabold tracking-tight leading-tight bg-gradient-to-r from-white via-slate-100 to-slate-400 bg-clip-text text-transparent">
            Next-Gen SaaS Boilerplate
          </h1>

          <p className="text-slate-400 text-base sm:text-lg leading-relaxed">
            Hệ thống mẫu hoàn chỉnh kết hợp sức mạnh kiến trúc của <strong className="text-slate-200">Spring Boot 4.1.0</strong> + Java 17 và <strong className="text-slate-200">Next.js 16</strong> App Router, sẵn sàng cho quy mô doanh nghiệp.
          </p>

          <div className="flex flex-wrap items-center justify-center gap-4 pt-4">
            <Link href="/login">
              <Button size="lg" className="shadow-indigo-500/30">
                Khám phá Demo App <ArrowRight className="h-4 w-4 ml-1" />
              </Button>
            </Link>
            <Link href="/dashboard">
              <Button size="lg" variant="outline">
                Truy cập Dashboard
              </Button>
            </Link>
          </div>
        </div>

        {/* Feature Grid */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <Card className="border-slate-800/80 bg-slate-900/60 backdrop-blur-xl">
            <CardHeader>
              <div className="w-10 h-10 rounded-xl bg-indigo-500/10 text-indigo-400 flex items-center justify-center mb-2 border border-indigo-500/20">
                <Cpu className="h-5 w-5" />
              </div>
              <CardTitle className="text-lg">Spring Boot 4 Backend</CardTitle>
              <CardDescription>
                Gradle Kotlin DSL, Jakarta Validation, Turkraft SpringFilter, Global Rest Exception handler.
              </CardDescription>
            </CardHeader>
            <CardContent className="space-y-2 text-xs text-slate-400">
              <div className="flex items-center gap-2"><CheckCircle className="h-3.5 w-3.5 text-emerald-400" /> Tự động gắn prefix /api/v1</div>
              <div className="flex items-center gap-2"><CheckCircle className="h-3.5 w-3.5 text-emerald-400" /> Chuẩn hóa RestResponse wrapper</div>
              <div className="flex items-center gap-2"><CheckCircle className="h-3.5 w-3.5 text-emerald-400" /> Static Analysis SpotBugs & Checkstyle</div>
            </CardContent>
          </Card>

          <Card className="border-slate-800/80 bg-slate-900/60 backdrop-blur-xl">
            <CardHeader>
              <div className="w-10 h-10 rounded-xl bg-purple-500/10 text-purple-400 flex items-center justify-center mb-2 border border-purple-500/20">
                <Lock className="h-5 w-5" />
              </div>
              <CardTitle className="text-lg">RSA256 JWT Security</CardTitle>
              <CardDescription>
                Bảo mật xác thực sử dụng cặp khóa bất đối xứng Public/Private RSA keys với BCrypt Password Encoder.
              </CardDescription>
            </CardHeader>
            <CardContent className="space-y-2 text-xs text-slate-400">
              <div className="flex items-center gap-2"><CheckCircle className="h-3.5 w-3.5 text-emerald-400" /> OAuth2 Resource Server</div>
              <div className="flex items-center gap-2"><CheckCircle className="h-3.5 w-3.5 text-emerald-400" /> Stateless Session Management</div>
              <div className="flex items-center gap-2"><CheckCircle className="h-3.5 w-3.5 text-emerald-400" /> CORS Allowed Origin Integration</div>
            </CardContent>
          </Card>

          <Card className="border-slate-800/80 bg-slate-900/60 backdrop-blur-xl">
            <CardHeader>
              <div className="w-10 h-10 rounded-xl bg-blue-500/10 text-blue-400 flex items-center justify-center mb-2 border border-blue-500/20">
                <Layout className="h-5 w-5" />
              </div>
              <CardTitle className="text-lg">Next.js 16 Frontend</CardTitle>
              <CardDescription>
                React 19, Tailwind CSS v4, TanStack Query v5, Axios interceptors & Lucide Icons.
              </CardDescription>
            </CardHeader>
            <CardContent className="space-y-2 text-xs text-slate-400">
              <div className="flex items-center gap-2"><CheckCircle className="h-3.5 w-3.5 text-emerald-400" /> Feature-Driven Architecture</div>
              <div className="flex items-center gap-2"><CheckCircle className="h-3.5 w-3.5 text-emerald-400" /> Form Validation với Zod & Hook Form</div>
              <div className="flex items-center gap-2"><CheckCircle className="h-3.5 w-3.5 text-emerald-400" /> Sonner Toast & Dynamic Aesthetics</div>
            </CardContent>
          </Card>
        </div>
      </main>

      {/* Footer */}
      <footer className="border-t border-slate-800/80 bg-slate-950 py-8 text-center text-xs text-slate-500">
        <p>© 2026 SaaS Boilerplate Project. Spring Boot 4 + Next.js 16 Integration.</p>
      </footer>
    </div>
  );
}
