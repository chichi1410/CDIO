import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { ForgotPasswordForm } from "@/features/auth/components/forgot-password-form";
import { Key } from "lucide-react";

export const metadata = {
  title: "Quên mật khẩu | SaaS Starter Platform",
  description: "Khôi phục mật khẩu tài khoản SaaS Starter Platform qua mã OTP",
};

export default function ForgotPasswordPage() {
  return (
    <div className="min-h-screen flex items-center justify-center p-4 relative overflow-hidden bg-slate-950">
      {/* Dynamic Background Glows */}
      <div className="absolute top-1/3 left-1/3 w-[500px] h-[500px] bg-indigo-600/20 rounded-full blur-[120px] pointer-events-none" />

      <div className="w-full max-w-md relative z-10">
        <div className="flex flex-col items-center mb-6">
          <div className="flex items-center justify-center w-14 h-14 rounded-2xl bg-gradient-to-tr from-indigo-600 to-purple-600 text-white shadow-xl shadow-indigo-500/30 mb-3">
            <Key className="h-8 w-8" />
          </div>
          <h1 className="text-2xl font-bold tracking-tight text-white">SaaS Starter</h1>
          <p className="text-xs text-slate-400 mt-1">Khôi phục mật khẩu tài khoản</p>
        </div>

        <Card className="border-slate-800/80 bg-slate-900/90 shadow-2xl backdrop-blur-2xl">
          <CardHeader className="space-y-1 text-center pb-3">
            <CardTitle className="text-xl font-bold">Quên mật khẩu?</CardTitle>
            <CardDescription>Nhập Email để nhận mã OTP khôi phục mật khẩu</CardDescription>
          </CardHeader>
          <CardContent>
            <ForgotPasswordForm />
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
