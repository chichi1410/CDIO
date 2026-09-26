"use client";

import React, { useState } from "react";
import Link from "next/link";
import {
  GraduationCap,
  Search,
  BookOpen,
  Users,
  Star,
  Clock,
  Award,
  Video,
  CreditCard,
  MessageSquare,
  ShoppingCart,
  Bell,
  LogOut,
  LayoutDashboard,
  Menu,
  X,
  Send,
  ArrowRight,
  Sparkles,
  ChevronRight,
  FileText,
  ShieldCheck,
  SlidersHorizontal
} from "lucide-react";
import { toast } from "sonner";

export default function Home() {
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [cartCount, setCartCount] = useState(2);
  const [unreadNotifications, setUnreadNotifications] = useState(3);
  const [showUserDropdown, setShowUserDropdown] = useState(false);
  const [showBellDropdown, setShowBellDropdown] = useState(false);
  const [showMobileMenu, setShowMobileMenu] = useState(false);
  const [showChatModal, setShowChatModal] = useState(false);
  const [activeTab, setActiveTab] = useState("all");
  const [searchQuery, setSearchQuery] = useState("");
  
  const [chatMessages, setChatMessages] = useState([
    {
      id: 1,
      sender: "admin",
      text: "Xin chào học viên Huỳnh Tấn Lộc! 👋 Tôi là Chuyên viên tư vấn & hỗ trợ kỹ thuật của LHD – Learning. Bạn đang cần hỗ trợ vấn đề gì về khóa học hay thanh toán VNPay?",
      time: "22:20"
    }
  ]);
  const [chatInput, setChatInput] = useState("");

  const handleSendChat = (e: React.FormEvent) => {
    e.preventDefault();
    if (!chatInput.trim()) return;

    const userMsg = {
      id: Date.now(),
      sender: "user",
      text: chatInput,
      time: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
    };

    setChatMessages((prev) => [...prev, userMsg]);
    setChatInput("");

    setTimeout(() => {
      setChatMessages((prev) => [
        ...prev,
        {
          id: Date.now() + 1,
          sender: "admin",
          text: "Cảm ơn bạn đã nhắn tin! Đội ngũ LHD Admin đã ghi nhận thắc mắc của bạn và đang tự động xử lý hệ thống.",
          time: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
        }
      ]);
    }, 1000);
  };

  const courses = [
    {
      id: 1,
      title: "Lập Trình Fullstack Java Spring Boot 4 & Next.js 16 Pro",
      category: "Lập trình",
      rating: 4.9,
      reviews: 328,
      students: 2450,
      duration: "45 giờ • 120 bài học",
      price: "1.290.000đ",
      oldPrice: "1.990.000đ",
      badge: "Bán chạy nhất",
      badgeColor: "bg-amber-500",
      instructor: "Nguyễn Văn A",
      image: "https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=600&auto=format&fit=crop&q=80"
    },
    {
      id: 2,
      title: "Tiếng Anh Giao Tiếp Thực Chiến Cho Người Đi Làm (TOEIC 750+)",
      category: "Ngoại ngữ",
      rating: 4.8,
      reviews: 195,
      students: 1820,
      duration: "30 giờ • 85 bài học",
      price: "890.000đ",
      oldPrice: "1.450.000đ",
      badge: "Nổi bật",
      badgeColor: "bg-indigo-600",
      instructor: "Ms. Jessica",
      image: "https://images.unsplash.com/photo-1543269865-cbf427effbad?w=600&auto=format&fit=crop&q=80"
    },
    {
      id: 3,
      title: "Thiết Kế Giao Diện UI/UX Chuyên Nghiệp Với Figma & Design System",
      category: "Thiết kế",
      rating: 4.95,
      reviews: 412,
      students: 3100,
      duration: "38 giờ • 96 bài học",
      price: "1.090.000đ",
      oldPrice: "1.790.000đ",
      badge: "Giảm 40%",
      badgeColor: "bg-rose-500",
      instructor: "Trần Minh B",
      image: "https://images.unsplash.com/photo-1581291518633-83b4ebd1d83e?w=600&auto=format&fit=crop&q=80"
    },
    {
      id: 4,
      title: "Phân Tích Dữ Liệu Với Python, SQL & PowerBI Cho Người Mới",
      category: "Data Science",
      rating: 4.7,
      reviews: 142,
      students: 1290,
      duration: "28 giờ • 70 bài học",
      price: "990.000đ",
      oldPrice: "1.500.000đ",
      badge: "Mới ra mắt",
      badgeColor: "bg-emerald-600",
      instructor: "Lê Hoàng C",
      image: "https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=600&auto=format&fit=crop&q=80"
    }
  ];

  return (
    <div className="min-h-screen bg-slate-50 text-slate-800 relative overflow-hidden font-sans">
      <div className="fixed -top-24 -left-24 w-[500px] h-[500px] rounded-full bg-gradient-to-br from-pink-200/60 to-orange-200/60 blur-[100px] pointer-events-none -z-10 animate-pulse" />
      <div className="fixed top-1/3 -right-24 w-[600px] h-[600px] rounded-full bg-gradient-to-br from-purple-200/60 to-blue-200/60 blur-[120px] pointer-events-none -z-10" />

      {/* HEADER */}
      <header className="sticky top-0 z-50 bg-white/90 backdrop-blur-md border-b border-slate-200/80 shadow-xs">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 h-20 flex items-center justify-between gap-4">
          <div className="flex items-center gap-8">
            <Link href="/" className="flex items-center gap-3 group">
              <div className="w-11 h-11 rounded-xl bg-gradient-to-tr from-blue-600 via-indigo-600 to-pink-500 flex items-center justify-center text-white shadow-lg shadow-indigo-500/25 group-hover:scale-105 transition-transform">
                <GraduationCap className="h-6 w-6" />
              </div>
              <div className="flex flex-col">
                <span className="font-extrabold text-xl tracking-tight bg-gradient-to-r from-blue-600 via-purple-600 to-pink-600 bg-clip-text text-transparent">
                  LHD – Learning
                </span>
                <span className="text-[10px] font-semibold text-slate-400 tracking-wider uppercase">
                  E-Learning SaaS Platform
                </span>
              </div>
            </Link>

            <nav className="hidden lg:flex items-center gap-1">
              <Link
                href="/"
                className="px-4 py-2 rounded-full text-sm font-bold bg-gradient-to-r from-blue-600 via-indigo-600 to-purple-600 text-white shadow-md shadow-indigo-500/20"
              >
                Trang chủ
              </Link>
              <Link
                href="/courses"
                className="px-4 py-2 rounded-full text-sm font-semibold text-slate-600 hover:text-indigo-600 hover:bg-slate-100/80 transition-colors"
              >
                Khóa học
              </Link>
              <Link
                href="/dashboard"
                className="px-4 py-2 rounded-full text-sm font-semibold text-slate-600 hover:text-indigo-600 hover:bg-slate-100/80 transition-colors"
              >
                Học viên
              </Link>
            </nav>
          </div>

          <div className="flex items-center gap-3">
            <button
              onClick={() => toast.info("Giỏ hàng của bạn đang có 2 khóa học!")}
              className="relative p-2.5 rounded-full border border-slate-200 bg-white hover:border-indigo-500 hover:text-indigo-600 transition-all shadow-2xs group"
              title="Giỏ hàng"
            >
              <ShoppingCart className="h-5 w-5 text-slate-700 group-hover:text-indigo-600" />
              {cartCount > 0 && (
                <span className="absolute -top-1 -right-1 w-5 h-5 rounded-full bg-rose-500 text-white text-[10px] font-bold flex items-center justify-center">
                  {cartCount}
                </span>
              )}
            </button>

            {!isLoggedIn ? (
              <div className="flex items-center gap-2">
                <a
                  href="/auth/login.html"
                  className="px-4 py-2 rounded-full text-xs font-bold text-indigo-600 border border-indigo-200 hover:bg-indigo-50 transition-colors"
                >
                  Đăng nhập
                </a>
                <a
                  href="/auth/register.html"
                  className="px-4 py-2 rounded-full text-xs font-bold text-white bg-gradient-to-r from-blue-600 via-indigo-600 to-pink-500 hover:shadow-md transition-all shadow-indigo-500/20"
                >
                  Đăng ký
                </a>
              </div>
            ) : (
              <button
                onClick={() => setIsLoggedIn(false)}
                className="px-4 py-2 rounded-full text-xs font-bold text-rose-600 border border-rose-200 hover:bg-rose-50"
              >
                Đăng xuất
              </button>
            )}
          </div>
        </div>
      </header>

      {/* HERO SECTION */}
      <section className="relative pt-12 pb-20 md:pt-20 md:pb-28 max-w-7xl mx-auto px-4 sm:px-6">
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-12 items-center">
          <div className="lg:col-span-7 space-y-6 text-center lg:text-left">
            <div className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full border border-indigo-200 bg-indigo-50/80 text-indigo-700 text-xs font-bold tracking-wide shadow-2xs">
              <Sparkles className="h-4 w-4 text-amber-500 animate-spin" /> Nền tảng Học Trực Tuyến Thế Hệ Mới 🚀
            </div>

            <h1 className="text-4xl sm:text-5xl lg:text-6xl font-extrabold tracking-tight text-slate-900 leading-[1.15]">
              Nâng Lực Trình Độ, <br className="hidden sm:block" />
              <span className="bg-gradient-to-r from-blue-600 via-indigo-600 to-pink-600 bg-clip-text text-transparent">
                Bứt Phá Tương Lai
              </span> Cùng LHD Learning
            </h1>

            <p className="text-slate-600 text-base sm:text-lg leading-relaxed max-w-2xl mx-auto lg:mx-0">
              Hàng trăm khóa học chất lượng cao từ giảng viên hàng đầu. Học mọi lúc, mọi nơi với hệ thống chấm bài tự động & phòng học Live.
            </p>

            <div className="flex flex-wrap items-center justify-center lg:justify-start gap-4">
              <Link
                href="/courses"
                className="px-8 py-3.5 rounded-xl bg-gradient-to-r from-blue-600 via-indigo-600 to-pink-500 text-white font-bold text-sm shadow-lg shadow-indigo-500/25 hover:opacity-95 transition-all flex items-center gap-2"
              >
                Khám phá khóa học <ArrowRight className="h-4 w-4" />
              </Link>
            </div>
          </div>

          <div className="lg:col-span-5">
            <div className="rounded-3xl overflow-hidden bg-white border border-slate-200 shadow-2xl">
              <img
                src="https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=800&auto=format&fit=crop&q=80"
                alt="Students"
                className="w-full h-80 object-cover"
              />
            </div>
          </div>
        </div>
      </section>

      {/* COURSES LIST */}
      <section className="py-16 max-w-7xl mx-auto px-4 sm:px-6 space-y-10">
        <div className="text-center space-y-3">
          <h2 className="text-3xl font-extrabold text-slate-900">Danh Sách Khóa Học Nổi Bật</h2>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          {courses.map((c) => (
            <div key={c.id} className="bg-white rounded-2xl overflow-hidden border border-slate-200 shadow-xs p-4 space-y-3">
              <img src={c.image} alt={c.title} className="w-full h-40 object-cover rounded-xl" />
              <h3 className="font-bold text-sm text-slate-900 line-clamp-2">{c.title}</h3>
              <div className="text-xs text-indigo-600 font-bold">{c.price}</div>
              <Link
                href="/courses"
                className="block w-full text-center py-2 rounded-xl bg-indigo-600 text-white text-xs font-bold"
              >
                Xem chi tiết
              </Link>
            </div>
          ))}
        </div>
      </section>
    </div>
  );
}
