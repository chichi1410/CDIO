"use client";

import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { loginSchema, LoginFormValues } from "../types";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { authApi } from "@/apis/auth.api";
import { toast } from "sonner";
import { useRouter } from "next/navigation";
import { Lock, Mail, ArrowRight } from "lucide-react";
import Link from "next/link";
import { useState } from "react";

export function LoginForm() {
  const router = useRouter();
  const [isLoading, setIsLoading] = useState(false);

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<LoginFormValues>({
    resolver: zodResolver(loginSchema),
    defaultValues: {
      email: "",
      password: "",
    },
  });

  const onSubmit = async (data: LoginFormValues) => {
    setIsLoading(true);
    try {
      const response = await authApi.login(data);
      const tokenData = response.data;
      if (tokenData?.accessToken) {
        localStorage.setItem("access_token", tokenData.accessToken);
        localStorage.setItem("user_info", JSON.stringify(tokenData.user));
        toast.success("Đăng nhập thành công!");
        router.push("/dashboard");
      } else {
        toast.error("Đăng nhập thất bại: Không nhận được token.");
      }
    } catch (err: any) {
      const errorMessage =
        err.response?.data?.message || err.response?.data?.error || "Đăng nhập thất bại. Vui lòng kiểm tra lại thông tin.";
      toast.error(errorMessage);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="space-y-5">
      <Input
        label="Địa chỉ Email"
        type="email"
        placeholder="user@example.com"
        icon={<Mail className="h-4 w-4" />}
        error={errors.email?.message}
        {...register("email")}
      />

      <Input
        label="Mật khẩu"
        type="password"
        placeholder="••••••••"
        icon={<Lock className="h-4 w-4" />}
        error={errors.password?.message}
        {...register("password")}
      />

      <div className="flex items-center justify-between text-xs">
        <label className="flex items-center space-x-2 text-slate-400 cursor-pointer">
          <input
            type="checkbox"
            className="rounded border-slate-700 bg-slate-900 text-indigo-600 focus:ring-indigo-500"
          />
          <span>Ghi nhớ đăng nhập</span>
        </label>
        <Link href="/forgot-password" className="text-indigo-400 hover:text-indigo-300 font-medium">
          Quên mật khẩu?
        </Link>
      </div>

      <Button type="submit" className="w-full text-base" isLoading={isLoading}>
        Đăng nhập
        <ArrowRight className="h-4 w-4 ml-1" />
      </Button>

      <div className="text-center text-xs text-slate-400 pt-2">
        Chưa có tài khoản?{" "}
        <Link href="/register" className="text-indigo-400 hover:text-indigo-300 font-semibold underline underline-offset-4">
          Tạo tài khoản mới
        </Link>
      </div>
    </form>
  );
}
