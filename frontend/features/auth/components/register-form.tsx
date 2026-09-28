"use client";

import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { registerSchema, RegisterFormValues } from "../types";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { authApi } from "@/apis/auth.api";
import { toast } from "sonner";
import { useRouter } from "next/navigation";
import { Lock, Mail, User as UserIcon, ArrowRight, GraduationCap, School } from "lucide-react";
import Link from "next/link";
import { useState } from "react";
import { Role } from "@/types/auth";

export function RegisterForm() {
  const router = useRouter();
  const [isLoading, setIsLoading] = useState(false);

  const {
    register,
    handleSubmit,
    setValue,
    watch,
    formState: { errors },
  } = useForm<RegisterFormValues>({
    resolver: zodResolver(registerSchema),
    defaultValues: {
      name: "",
      email: "",
      password: "",
      confirmPassword: "",
      role: "ROLE_USER",
    },
  });

  const selectedRole = watch("role");

  const onSubmit = async (data: RegisterFormValues) => {
    setIsLoading(true);
    try {
      await authApi.register({
        name: data.name,
        email: data.email,
        password: data.password,
        role: data.role as Role,
      });
      toast.success("Đăng ký thành công! Vui lòng đăng nhập.");
      router.push("/login");
    } catch (err: any) {
      const errorMessage =
        err.response?.data?.message || err.response?.data?.error || "Đăng ký thất bại. Email có thể đã tồn tại.";
      toast.error(errorMessage);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
      {/* Role Selection Switcher */}
      <div className="space-y-1.5">
        <label className="block text-xs font-semibold tracking-wider text-slate-300 uppercase">
          Bạn đăng ký với vai trò gì?
        </label>
        <div className="grid grid-cols-2 gap-2 p-1 bg-slate-950/80 rounded-xl border border-slate-800">
          <button
            type="button"
            onClick={() => setValue("role", "ROLE_USER")}
            className={`flex items-center justify-center gap-2 py-2 px-3 rounded-lg text-xs font-semibold transition-all ${
              selectedRole === "ROLE_USER"
                ? "bg-gradient-to-r from-indigo-600 to-purple-600 text-white shadow-md shadow-indigo-500/20"
                : "text-slate-400 hover:text-slate-200 hover:bg-slate-900"
            }`}
          >
            <GraduationCap className="h-4 w-4" /> Học viên
          </button>
          <button
            type="button"
            onClick={() => setValue("role", "ROLE_INSTRUCTOR")}
            className={`flex items-center justify-center gap-2 py-2 px-3 rounded-lg text-xs font-semibold transition-all ${
              selectedRole === "ROLE_INSTRUCTOR"
                ? "bg-gradient-to-r from-indigo-600 to-purple-600 text-white shadow-md shadow-indigo-500/20"
                : "text-slate-400 hover:text-slate-200 hover:bg-slate-900"
            }`}
          >
            <School className="h-4 w-4" /> Giảng viên
          </button>
        </div>
      </div>

      <Input
        label="Họ và tên"
        type="text"
        placeholder="Nguyễn Văn A"
        icon={<UserIcon className="h-4 w-4" />}
        error={errors.name?.message}
        {...register("name")}
      />

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

      <Input
        label="Xác nhận mật khẩu"
        type="password"
        placeholder="••••••••"
        icon={<Lock className="h-4 w-4" />}
        error={errors.confirmPassword?.message}
        {...register("confirmPassword")}
      />

      <Button type="submit" className="w-full text-base mt-2 shadow-indigo-500/25" isLoading={isLoading}>
        Tạo tài khoản {selectedRole === "ROLE_INSTRUCTOR" ? "Giảng viên" : "Học viên"}
        <ArrowRight className="h-4 w-4 ml-1" />
      </Button>

      <div className="text-center text-xs text-slate-400 pt-2">
        Đã có tài khoản?{" "}
        <Link href="/login" className="text-indigo-400 hover:text-indigo-300 font-semibold underline underline-offset-4">
          Đăng nhập ngay
        </Link>
      </div>
    </form>
  );
}
