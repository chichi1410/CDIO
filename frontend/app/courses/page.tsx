"use client";

import React, { useState } from "react";
import Link from "next/link";
import { GraduationCap, Search, Star, Clock, ShoppingCart, ArrowLeft, Filter } from "lucide-react";
import { toast } from "sonner";

export default function CoursesPage() {
  const [searchQuery, setSearchQuery] = useState("");
  const [selectedCategory, setSelectedCategory] = useState("all");

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

  const filteredCourses = courses.filter((c) => {
    const matchesSearch = c.title.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesCat = selectedCategory === "all" || c.category === selectedCategory;
    return matchesSearch && matchesCat;
  });

  return (
    <div className="min-h-screen bg-slate-50 text-slate-800 font-sans">
      {/* Header */}
      <header className="sticky top-0 z-50 bg-white border-b border-slate-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 h-20 flex items-center justify-between">
          <Link href="/" className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl bg-indigo-600 text-white flex items-center justify-center font-bold">
              <GraduationCap className="h-6 w-6" />
            </div>
            <span className="font-extrabold text-xl bg-gradient-to-r from-blue-600 to-indigo-600 bg-clip-text text-transparent">
              LHD – Learning
            </span>
          </Link>

          <Link
            href="/"
            className="flex items-center gap-2 text-xs font-bold text-slate-600 hover:text-indigo-600"
          >
            <ArrowLeft className="h-4 w-4" /> Quay lại trang chủ
          </Link>
        </div>
      </header>

      {/* Main Container */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 py-10 space-y-8">
        <div>
          <h1 className="text-3xl font-extrabold text-slate-900 tracking-tight">Tất Cả Khóa Học</h1>
          <p className="text-slate-500 text-sm mt-1">Khám phá danh sách các khóa học chất lượng cao trên LHD Learning</p>
        </div>

        {/* Search and Filters */}
        <div className="flex flex-col sm:flex-row gap-4 items-center justify-between bg-white p-4 rounded-2xl border border-slate-200 shadow-2xs">
          <div className="relative w-full sm:w-96">
            <input
              type="text"
              placeholder="Tìm kiếm khóa học..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full pl-9 pr-4 py-2 text-xs rounded-xl border border-slate-200 bg-slate-50 focus:bg-white focus:outline-none focus:border-indigo-500"
            />
            <Search className="h-4 w-4 text-slate-400 absolute left-3 top-2.5" />
          </div>

          <div className="flex items-center gap-2 w-full sm:w-auto">
            <Filter className="h-4 w-4 text-slate-400" />
            <select
              value={selectedCategory}
              onChange={(e) => setSelectedCategory(e.target.value)}
              className="text-xs py-2 px-3 rounded-xl border border-slate-200 bg-slate-50 focus:outline-none focus:border-indigo-500 font-medium"
            >
              <option value="all">Tất cả danh mục</option>
              <option value="Lập trình">Lập trình</option>
              <option value="Ngoại ngữ">Ngoại ngữ</option>
              <option value="Thiết kế">Thiết kế</option>
              <option value="Data Science">Data Science</option>
            </select>
          </div>
        </div>

        {/* Course Cards Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          {filteredCourses.map((c) => (
            <div key={c.id} className="bg-white rounded-2xl overflow-hidden border border-slate-200 shadow-xs hover:shadow-lg transition-all flex flex-col justify-between p-4 space-y-3">
              <div>
                <img src={c.image} alt={c.title} className="w-full h-44 object-cover rounded-xl mb-3" />
                <div className="text-xs font-bold text-indigo-600 bg-indigo-50 px-2 py-0.5 rounded-md inline-block mb-2">
                  {c.category}
                </div>
                <h3 className="font-bold text-sm text-slate-900 line-clamp-2">{c.title}</h3>
                <div className="text-xs text-slate-400 mt-1">{c.instructor}</div>
              </div>

              <div className="pt-3 border-t border-slate-100 flex items-center justify-between">
                <span className="font-extrabold text-base text-slate-900">{c.price}</span>
                <button
                  onClick={() => toast.success(`Đã thêm "${c.title.slice(0, 15)}..." vào giỏ`)}
                  className="p-2 rounded-xl bg-indigo-600 text-white hover:bg-indigo-700 transition-colors"
                >
                  <ShoppingCart className="h-4 w-4" />
                </button>
              </div>
            </div>
          ))}
        </div>
      </main>
    </div>
  );
}
