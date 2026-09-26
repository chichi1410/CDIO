"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { authApi } from "@/apis/auth.api";
import { UserResponse } from "@/types/auth";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { toast } from "sonner";
import { User, LogOut, Shield, CheckCircle2, Server, Key, RefreshCw } from "lucide-react";

export default function DashboardPage() {
  const router = useRouter();
  const [user, setUser] = useState<UserResponse | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [token, setToken] = useState<string | null>(null);

  const fetchProfile = async () => {
    setIsLoading(true);
    try {
      const response = await authApi.getMe();
      setUser(response.data);
    } catch (err: any) {
      toast.error("Không thể xác thực thông tin người dùng. Vui lòng đăng nhập lại.");
      localStorage.removeItem("access_token");
      localStorage.removeItem("user_info");
      router.push("/login");
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    const savedToken = localStorage.getItem("access_token");
    if (!savedToken) {
      toast.error("Bạn chưa đăng nhập!");
      router.push("/login");
      return;
    }
    setToken(savedToken);
    fetchProfile();
  }, [router]);

  const handleLogout = () => {
    localStorage.removeItem("access_token");
    localStorage.removeItem("user_info");
    toast.success("Đã đăng xuất thành công");
    router.push("/login");
  };

  if (isLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-slate-950 text-slate-200">
        <div className="flex flex-col items-center gap-3">
          <RefreshCw className="h-8 w-8 animate-spin text-indigo-500" />
          <p className="text-sm font-medium text-slate-400">Đang tải dữ liệu hồ sơ từ Spring Boot Backend...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-slate-950 text-slate-100 p-6 md:p-12 relative overflow-hidden">
      {/* Background accents */}
      <div className="absolute top-0 right-0 w-[500px] h-[500px] bg-indigo-600/10 rounded-full blur-[140px] pointer-events-none" />
      <div className="absolute bottom-0 left-0 w-[400px] h-[400px] bg-purple-600/10 rounded-full blur-[140px] pointer-events-none" />

      <div className="max-w-5xl mx-auto space-y-8 relative z-10">
        {/* Header */}
        <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 border-b border-slate-800 pb-6">
          <div>
            <div className="flex items-center gap-2 text-indigo-400 font-semibold text-xs uppercase tracking-wider mb-1">
              <Shield className="h-4 w-4" /> User Dashboard
            </div>
            <h1 className="text-3xl font-extrabold tracking-tight text-white">
              Xin chào, {user?.name || "User"}!
            </h1>
            <p className="text-slate-400 text-sm mt-1">
              Bạn đã đăng nhập thành công qua JWT OAuth2 Resource Server.
            </p>
          </div>
          <div className="flex items-center gap-3">
            <Button variant="outline" size="sm" onClick={fetchProfile} className="gap-2">
              <RefreshCw className="h-3.5 w-3.5" /> Làm mới
            </Button>
            <Button variant="danger" size="sm" onClick={handleLogout} className="gap-2">
              <LogOut className="h-3.5 w-3.5" /> Đăng xuất
            </Button>
          </div>
        </div>

        {/* Info Grid */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <Card className="border-slate-800 bg-slate-900/60 backdrop-blur-xl">
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium text-slate-300">Thông tin cá nhân</CardTitle>
              <User className="h-4 w-4 text-indigo-400" />
            </CardHeader>
            <CardContent className="pt-4 space-y-3">
              <div>
                <p className="text-xs text-slate-500">Họ và tên</p>
                <p className="font-semibold text-slate-100">{user?.name}</p>
              </div>
              <div>
                <p className="text-xs text-slate-500">Email</p>
                <p className="font-semibold text-slate-100">{user?.email}</p>
              </div>
              <div>
                <p className="text-xs text-slate-500">Trạng thái</p>
                <span className="inline-flex items-center gap-1 text-xs font-semibold text-emerald-400 bg-emerald-500/10 px-2.5 py-0.5 rounded-full border border-emerald-500/20 mt-1">
                  <CheckCircle2 className="h-3 w-3" /> Hoạt động
                </span>
              </div>
            </CardContent>
          </Card>

          <Card className="border-slate-800 bg-slate-900/60 backdrop-blur-xl">
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium text-slate-300">Quyền hạn & Vai trò</CardTitle>
              <Shield className="h-4 w-4 text-purple-400" />
            </CardHeader>
            <CardContent className="pt-4 space-y-3">
              <div>
                <p className="text-xs text-slate-500">Role</p>
                <span className="inline-block font-mono text-xs font-bold text-indigo-300 bg-indigo-500/20 px-3 py-1 rounded-lg border border-indigo-500/30 mt-1">
                  {user?.role || "USER"}
                </span>
              </div>
              <div>
                <p className="text-xs text-slate-500">ID Người dùng</p>
                <p className="font-mono text-slate-200">#{user?.id}</p>
              </div>
              <div>
                <p className="text-xs text-slate-500">Ngày khởi tạo</p>
                <p className="text-xs text-slate-300">
                  {user?.createdAt ? new Date(user.createdAt).toLocaleString("vi-VN") : "N/A"}
                </p>
              </div>
            </CardContent>
          </Card>

          <Card className="border-slate-800 bg-slate-900/60 backdrop-blur-xl">
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium text-slate-300">Kết nối Cross-Stack</CardTitle>
              <Server className="h-4 w-4 text-emerald-400" />
            </CardHeader>
            <CardContent className="pt-4 space-y-3">
              <div>
                <p className="text-xs text-slate-500">Backend Status</p>
                <p className="text-xs text-emerald-400 font-semibold flex items-center gap-1.5 mt-1">
                  <span className="w-2 h-2 rounded-full bg-emerald-400 animate-pulse" /> Connected (Spring Boot 4.1)
                </p>
              </div>
              <div>
                <p className="text-xs text-slate-500">Authentication Mode</p>
                <p className="text-xs text-slate-300 mt-0.5">RSA256 JWT Pair Key</p>
              </div>
              <div>
                <p className="text-xs text-slate-500">Frontend Stack</p>
                <p className="text-xs text-slate-300 mt-0.5">Next.js 16 + React 19 + Tailwind v4</p>
              </div>
            </CardContent>
          </Card>
        </div>

        {/* Token Inspect Card */}
        <Card className="border-slate-800 bg-slate-900/40 backdrop-blur-xl">
          <CardHeader>
            <div className="flex items-center gap-2">
              <Key className="h-5 w-5 text-indigo-400" />
              <CardTitle className="text-base font-semibold">JWT Bearer Token Inspection</CardTitle>
            </div>
            <CardDescription>
              Token được gửi tự động qua HTTP Header Authorization: Bearer trong mọi request đến API Backend.
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div className="bg-slate-950 p-4 rounded-xl border border-slate-800/80 font-mono text-xs text-slate-400 break-all leading-relaxed max-h-32 overflow-y-auto">
              {token || "Không tìm thấy token trong localStorage"}
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
