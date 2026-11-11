import { createServerClient } from "@supabase/ssr";
import { NextResponse, type NextRequest } from "next/server";

export async function middleware(request: NextRequest) {
  let response = NextResponse.next({ request });
  const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const key = process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY || process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;
  if (!url || !key) {
    if (request.nextUrl.pathname.startsWith("/painel") || request.nextUrl.pathname.startsWith("/admin")) {
      return NextResponse.redirect(new URL("/supabase-indisponivel", request.url));
    }
    return response;
  }

  const supabase = createServerClient(url, key, {
    cookies: {
      getAll: () => request.cookies.getAll(),
      setAll(cookiesToSet) {
        cookiesToSet.forEach(({ name, value }) => request.cookies.set(name, value));
        response = NextResponse.next({ request });
        cookiesToSet.forEach(({ name, value, options }) => response.cookies.set(name, value, options));
      },
    },
  });

  const { data: { user } } = await supabase.auth.getUser();
  const pathname = request.nextUrl.pathname;
  if ((pathname.startsWith("/painel") || pathname.startsWith("/admin")) && !user) {
    const destination = request.nextUrl.clone();
    destination.pathname = "/entrar";
    destination.searchParams.set("redirect", pathname);
    return NextResponse.redirect(destination);
  }
  if (pathname.startsWith("/admin") && user) {
    const { data: profile } = await supabase.from("profiles").select("user_type").eq("id", user.id).maybeSingle();
    if (profile?.user_type !== "admin") return NextResponse.redirect(new URL("/painel", request.url));
  }
  if ((pathname === "/entrar" || pathname === "/cadastrar") && user) return NextResponse.redirect(new URL("/painel", request.url));
  return response;
}

export const config = { matcher: ["/painel/:path*", "/admin/:path*", "/entrar", "/cadastrar"] };
