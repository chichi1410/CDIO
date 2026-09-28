import { apiClient } from "@/services/api-client";
import {
  ForgotPasswordRequest,
  LoginRequest,
  RegisterRequest,
  ResetPasswordRequest,
  RestResponse,
  TokenResponse,
  UserResponse,
} from "@/types/auth";

export const authApi = {
  login: async (data: LoginRequest): Promise<RestResponse<TokenResponse>> => {
    const res = await apiClient.post<RestResponse<TokenResponse>>("/auth/login", data);
    return res.data;
  },

  register: async (data: RegisterRequest): Promise<RestResponse<UserResponse>> => {
    const res = await apiClient.post<RestResponse<UserResponse>>("/auth/register", data);
    return res.data;
  },

  getMe: async (): Promise<RestResponse<UserResponse>> => {
    const res = await apiClient.get<RestResponse<UserResponse>>("/auth/me");
    return res.data;
  },

  forgotPassword: async (
    data: ForgotPasswordRequest
  ): Promise<RestResponse<{ message: string; otpDemo?: string }>> => {
    const res = await apiClient.post<RestResponse<{ message: string; otpDemo?: string }>>(
      "/auth/forgot-password",
      data
    );
    return res.data;
  },

  resetPassword: async (
    data: ResetPasswordRequest
  ): Promise<RestResponse<{ message: string }>> => {
    const res = await apiClient.post<RestResponse<{ message: string }>>(
      "/auth/reset-password",
      data
    );
    return res.data;
  },

  logout: async (): Promise<RestResponse<{ message: string }>> => {
    const res = await apiClient.post<RestResponse<{ message: string }>>("/auth/logout");
    return res.data;
  },
};
