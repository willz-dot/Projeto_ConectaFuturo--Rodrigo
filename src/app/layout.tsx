import type { Metadata } from "next";
import "./globals.css";
import { Shell } from "@/components/site";
export const metadata: Metadata = { title: { default:"Conecta Futuro | Aprenda e encontre oportunidades", template:"%s | Conecta Futuro" }, description:"Cursos, orientação e caminhos para o primeiro emprego para jovens em Canoinhas e municípios próximos." };
export default function RootLayout({children}:{children:React.ReactNode}) { return <html lang="pt-BR"><body><Shell>{children}</Shell></body></html> }
