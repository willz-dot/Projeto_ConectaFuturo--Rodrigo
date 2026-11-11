"use client";
import Link from "next/link";
import { useState } from "react";
import { ArrowLeft, ArrowRight, LockKeyhole } from "lucide-react";
import { createClient } from "@/lib/supabase/client";

export default function Login() {
  const [error, setError] = useState("");
  const [busy, setBusy] = useState(false);
  async function submit(form: FormData) {
    setBusy(true); setError("");
    try {
      const supabase = createClient();
      const { error } = await supabase.auth.signInWithPassword({ email: String(form.get("email")), password: String(form.get("password")) });
      if (error) throw error;
      const target = new URLSearchParams(window.location.search).get("redirect");
      const destination = target ? new URL(target, window.location.origin) : new URL("/painel", window.location.origin);
      window.location.assign(destination.origin === window.location.origin ? `${destination.pathname}${destination.search}${destination.hash}` : "/painel");
    } catch (e) { setError(e instanceof Error ? e.message : "Não foi possível entrar."); setBusy(false); }
  }
  return <section className="auth-section"><div className="auth-card"><Link href="/" className="back-link dark-back"><ArrowLeft size={16}/> Voltar ao início</Link><span className="eyebrow">BEM-VINDO DE VOLTA</span><h1>Entre na sua conta.</h1><p>Acesse seu espaço para continuar sua jornada.</p><form action={submit}><label className="field">E-mail<input name="email" required type="email" autoComplete="email" placeholder="voce@email.com"/></label><label className="field">Senha<input name="password" required type="password" autoComplete="current-password" placeholder="Sua senha"/></label>{error&&<p className="form-error" role="alert">{error}</p>}<button className="button button-wide" disabled={busy}>{busy?"Entrando…":"Entrar"} <ArrowRight size={17}/></button><p className="auth-privacy"><LockKeyhole size={14}/> Sessão protegida pelo Supabase Auth.</p></form><div className="auth-switch"><Link href="/esqueci-senha">Esqueci minha senha</Link></div><div className="auth-switch">Ainda não tem conta? <Link href="/cadastrar">Cadastre-se</Link></div></div></section>;
}
