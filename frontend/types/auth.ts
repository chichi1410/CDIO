export type Role = "ROLE_USER" | "ROLE_INSTRUCTOR" | "ROLE_ADMIN";

export interface UserResponse {
  id: number;
  name: string;
  email: string;
  avatarUrl?: string | null;
  role: Role;
  active: boolean;
  createdAt: string;
}

export interface TokenResponse {
  accessToken: string;
  tokenType: string;
  expiresIn: number;
  user: UserResponse;
}

export interface RestResponse<T> {
  statusCode: number;
  error?: string | null;
  message?: string | object;
  data: T;
}

export interface LoginRequest {
  email: string;
  password: string;
}

export interface RegisterRequest {
  name: string;
  email: string;
  password: string;
  role?: Role;
}

export interface ForgotPasswordRequest {
  email: string;
}

export interface ResetPasswordRequest {
  email: string;
  otp: string;
  newPassword: string;
}
