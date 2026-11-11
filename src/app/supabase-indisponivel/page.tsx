import Link from "next/link";
import { PageIntro } from "@/components/site";

export default function SupabaseUnavailable(){return <><PageIntro eyebrow="CONFIGURAÇÃO NECESSÁRIA" title="Painéis temporariamente indisponíveis." description="O projeto Supabase ainda não está configurado neste ambiente."/><section className="container section"><div className="notice"><p>Configure a URL e a chave publicável em <code>.env.local</code>, aplique as migrations documentadas e reinicie o servidor para ativar autenticação, dados e painéis.</p><Link className="text-link" href="/">Voltar ao início</Link></div></section></>}
