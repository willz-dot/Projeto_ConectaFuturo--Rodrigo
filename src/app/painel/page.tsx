import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { UserDashboard } from "@/components/user-dashboard";

export default async function DashboardPage() {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect("/entrar");
  const { data: profile } = await supabase.from("profiles").select("id,full_name,email,phone,city,birth_date,user_type").eq("id", user.id).single();
  if (!profile) return <main className="container section"><h1>Perfil não encontrado</h1><p>Entre em contato com o suporte do projeto.</p></main>;
  return <UserDashboard initialProfile={profile} />;
}
