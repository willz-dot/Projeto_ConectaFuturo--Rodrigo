"use client";
import Link from "next/link";
import { useState } from "react";
import { ArrowLeft } from "lucide-react";
import { createClient } from "@/lib/supabase/client";

export default function ResetPassword() {
  const [message, setMessage] = useState(""); const [error, setError] = useState("");
  async function submit(form: FormData) {
    setError(""); setMessage("");
    try { const supabase = createClient(); const { error } = await supabase.auth.resetPasswordForEmail(String(form.get("email")), { redirectTo: `${window.location.origin}/redefinir-senha` }); if (error) throw error; setMessage("Se esse e-mail estiver cadastrado, você receberá um link para redefinir a senha."); }
    catch (e) { setError(e instanceof Error ? e.message : "Não foi possível solicitar a recuperação."); }
  }
  return <section className="auth-section"><div className="auth-card"><Link href="/entrar" className="back-link dark-back"><ArrowLeft size={16}/> Voltar ao login</Link><span className="eyebrow">RECUPERAÇÃO DE ACESSO</span><h1>Redefina sua senha.</h1><p>Enviaremos um link para o e-mail informado.</p><form action={submit}><label className="field">E-mail<input name="email" required type="email" autoComplete="email" placeholder="voce@email.com"/></label>{error&&<p className="form-error" role="alert">{error}</p>}{message&&<p className="form-success" role="status">{message}</p>}<button className="button button-wide">Enviar link</button></form></div></section>;
}
