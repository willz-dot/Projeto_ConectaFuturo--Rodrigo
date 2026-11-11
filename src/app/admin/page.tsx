import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { AdminDashboard } from "@/components/admin-dashboard";

export default async function AdminPage(){
  const supabase=await createClient();
  const {data:{user}}=await supabase.auth.getUser();
  if(!user)redirect("/entrar");
  const {data:profile}=await supabase.from("profiles").select("user_type").eq("id",user.id).single();
  if(profile?.user_type!=="admin")redirect("/painel");
  return <AdminDashboard/>;
}
