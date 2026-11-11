"use client";
import Link from "next/link";
import { useState } from "react";
import { ArrowLeft, ArrowRight } from "lucide-react";
import { createClient } from "@/lib/supabase/client";

export default function Register() {
  const [message, setMessage] = useState(""); const [error, setError] = useState(""); const [busy, setBusy] = useState(false);
  async function submit(form: FormData) {
    setBusy(true); setError(""); setMessage("");
    try {
      const supabase = createClient();
      const { data, error } = await supabase.auth.signUp({ email: String(form.get("email")), password: String(form.get("password")), options: { data: { full_name: String(form.get("full_name")) } } });
      if (error) throw error;
      setMessage(data.session ? "Conta criada. Redirecionando ao seu painel…" : "Cadastro recebido. Confirme seu e-mail para ativar a conta.");
      if (data.session) window.location.assign("/painel");
    } catch (e) { setError(e instanceof Error ? e.message : "Não foi possível criar a conta."); }
    finally { setBusy(false); }
  }
  return <section className="auth-section"><div className="auth-card"><Link href="/" className="back-link dark-back"><ArrowLeft size={16}/> Voltar ao início</Link><span className="eyebrow">SEU PRÓXIMO PASSO</span><h1>Crie sua conta.</h1><p>Cadastre-se gratuitamente e comece a explorar caminhos para o seu futuro.</p><form action={submit}><label className="field">Nome completo<input name="full_name" required minLength={2} maxLength={120} autoComplete="name" placeholder="Seu nome"/></label><label className="field">E-mail<input name="email" required type="email" autoComplete="email" placeholder="voce@email.com"/></label><label className="field">Senha<input name="password" required type="password" minLength={8} autoComplete="new-password" placeholder="Mínimo de 8 caracteres"/></label><label className="check-field"><input type="checkbox" required/><span>Tenho entre 18 e 24 anos e li as informações de privacidade.</span></label>{error&&<p className="form-error" role="alert">{error}</p>}{message&&<p className="form-success" role="status">{message}</p>}<button className="button button-wide" disabled={busy}>{busy?"Criando conta…":"Criar conta"} <ArrowRight size={17}/></button></form><div className="auth-switch">Já tem uma conta? <Link href="/entrar">Entrar</Link></div></div></section>;
}
