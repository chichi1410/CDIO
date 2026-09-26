"use client";

import { useState } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import {
  forgotPasswordSchema,
  ForgotPasswordFormValues,
  resetPasswordSchema,
  ResetPasswordFormValues,
} from "../types";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { authApi } from "@/apis/auth.api";
import { toast } from "sonner";
import { useRouter } from "next/navigation";
import { Mail, KeyRound, Lock, ArrowRight, CheckCircle } from "lucide-react";
import Link from "next/link";

export function ForgotPasswordForm() {
  const router = useRouter();
  const [step, setStep] = useState<"REQUEST_OTP" | "RESET_PASSWORD">("REQUEST_OTP");
  const [userEmail, setUserEmail] = useState("");
  const [isLoading, setIsLoading] = useState(false);

  // Form Step 1: Request OTP
  const {
    register: registerRequest,
    handleSubmit: handleSubmitRequest,
    formState: { errors: errorsRequest },
  } = useForm<ForgotPasswordFormValues>({
    resolver: zodResolver(forgotPasswordSchema),
    defaultValues: { email: "" },
  });

  // Form Step 2: Reset Password with OTP
  const {
    register: registerReset,
    handleSubmit: handleSubmitReset,
    setValue: setValueReset,
    formState: { errors: errorsReset },
  } = useForm<ResetPasswordFormValues>({
    resolver: zodResolver(resetPasswordSchema),
    defaultValues: { email: "", otp: "", newPassword: "" },
  });

  const onRequestOtp = async (data: ForgotPasswordFormValues) => {
    setIsLoading(true);
    try {
      const response = await authApi.forgotPassword(data);
      setUserEmail(data.email);
      setValueReset("email", data.email);
      
      const otpCode = response.data?.otpDemo;
      if (otpCode) {
        toast.success(`Mã OTP của bạn là ${otpCode}`, { duration: 10000 });
        setValueReset("otp", otpCode); // prefill for demo convenience
      } else {
        toast.success("Mã OTP đã được gửi đến email của bạn!");
      }
      setStep("RESET_PASSWORD");
    } catch (err: any) {
      const errorMessage =
        err.response?.data?.message || err.response?.data?.error || "Không tìm thấy tài khoản với email này.";
      toast.error(errorMessage);
    } finally {
      setIsLoading(false);
    }
  };

  const onResetPassword = async (data: ResetPasswordFormValues) => {
    setIsLoading(true);
    try {
      await authApi.resetPassword(data);
      toast.success("Đặt lại mật khẩu thành công! Vui lòng đăng nhập.");
      router.push("/login");
    } catch (err: any) {
      const errorMessage =
        err.response?.data?.message || err.response?.data?.error || "Mã OTP không hợp lệ hoặc đã hết hạn.";
      toast.error(errorMessage);
    } finally {
      setIsLoading(false);
    }
  };

  if (step === "REQUEST_OTP") {
    return (
      <form onSubmit={handleSubmitRequest(onRequestOtp)} className="space-y-5">
        <Input
          label="Địa chỉ Email tài khoản"
          type="email"
          placeholder="user@example.com"
          icon={<Mail className="h-4 w-4" />}
          error={errorsRequest.email?.message}
          {...registerRequest("email")}
        />

        <Button type="submit" className="w-full text-base" isLoading={isLoading}>
          Gửi mã OTP xác nhận
          <ArrowRight className="h-4 w-4 ml-1" />
        </Button>

        <div className="text-center text-xs text-slate-400 pt-2">
          Quay lại{" "}
          <Link href="/login" className="text-indigo-400 hover:text-indigo-300 font-semibold underline underline-offset-4">
            Đăng nhập
          </Link>
        </div>
      </form>
    );
  }

  return (
    <form onSubmit={handleSubmitReset(onResetPassword)} className="space-y-4">
      <div className="p-3 rounded-xl bg-slate-950 border border-slate-800 text-xs text-slate-400 flex items-center justify-between">
        <span>Email: <strong className="text-slate-200">{userEmail}</strong></span>
        <button
          type="button"
          onClick={() => setStep("REQUEST_OTP")}
          className="text-indigo-400 hover:text-indigo-300 underline font-medium"
        >
          Đổi email
        </button>
      </div>

      <Input
        label="Mã OTP 6 chữ số"
        type="text"
        placeholder="123456"
        icon={<KeyRound className="h-4 w-4" />}
        error={errorsReset.otp?.message}
        {...registerReset("otp")}
      />

      <Input
        label="Mật khẩu mới"
        type="password"
        placeholder="••••••••"
        icon={<Lock className="h-4 w-4" />}
        error={errorsReset.newPassword?.message}
        {...registerReset("newPassword")}
      />

      <Button type="submit" className="w-full text-base mt-2" isLoading={isLoading}>
        Xác nhận đổi mật khẩu
        <CheckCircle className="h-4 w-4 ml-1" />
      </Button>

      <div className="text-center text-xs text-slate-400 pt-2">
        Nhớ mật khẩu?{" "}
        <Link href="/login" className="text-indigo-400 hover:text-indigo-300 font-semibold underline underline-offset-4">
          Quay lại Đăng nhập
        </Link>
      </div>
    </form>
  );
}
