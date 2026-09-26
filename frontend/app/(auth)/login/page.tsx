import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { LoginForm } from "@/features/auth/components/login-form";
import { ShieldCheck } from "lucide-react";

export const metadata = {
  title: "Đăng nhập | Language Learning Platform",
  description: "Đăng nhập vào hệ thống Language Learning Platform",
};

export default function LoginPage() {
  return (
    <div className="min-h-screen flex items-center justify-center p-4 relative overflow-hidden bg-slate-950">
      {/* Dynamic Background Glows */}
      <div className="absolute top-1/4 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[500px] h-[500px] bg-cyan-500/20 rounded-full blur-[120px] pointer-events-none" />
      <div className="absolute bottom-10 right-10 w-[300px] h-[300px] bg-blue-600/15 rounded-full blur-[100px] pointer-events-none" />

      <div className="w-full max-w-md relative z-10">
        <div className="flex flex-col items-center mb-8">
          <div className="flex items-center justify-center w-14 h-14 rounded-2xl bg-gradient-to-tr from-cyan-500 to-blue-600 text-white shadow-xl shadow-cyan-500/30 mb-3">
            <ShieldCheck className="h-8 w-8" />
          </div>
          <h1 className="text-2xl font-bold tracking-tight text-white">Language Learning</h1>
          <p className="text-xs text-slate-400 mt-1">Nền tảng học ngoại ngữ thế hệ mới</p>
        </div>

        <Card className="border-slate-800/80 bg-slate-900/90 shadow-2xl backdrop-blur-2xl">
          <CardHeader className="space-y-1 text-center pb-4">
            <CardTitle className="text-xl font-bold">Chào mừng trở lại</CardTitle>
            <CardDescription>Nhập thông tin tài khoản của bạn để đăng nhập</CardDescription>
          </CardHeader>
          <CardContent>
            <LoginForm />
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
