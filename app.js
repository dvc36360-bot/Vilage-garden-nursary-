/* Shared public-site helpers and product catalogue. */
const cfg = window.JACT_CONFIG || {};
const WA = cfg.whatsappNumber || "27676259831";
function money(value){return "R " + Number(value||0).toFixed(2)}
function safe(value){return String(value??"").replace(/[&<>"']/g,c=>({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#39;"}[c]))}
function whatsapp(message){window.open("https://wa.me/"+WA+"?text="+encodeURIComponent(message),"_blank","noopener")}
function showStatus(el,message,type="success"){if(!el)return;el.textContent=message;el.className="status show "+type}
function setYear(){document.querySelectorAll("[data-year]").forEach(x=>x.textContent=new Date().getFullYear())}
document.addEventListener("DOMContentLoaded",()=>{
  setYear();
  const menu=document.querySelector(".menu-btn"),links=document.querySelector(".nav-links");
  if(menu&&links)menu.addEventListener("click",()=>links.classList.toggle("open"));
});
async function getSupabase(){
  if(!cfg.supabaseUrl||cfg.supabaseUrl.includes("PASTE_")||!cfg.supabaseAnonKey||cfg.supabaseAnonKey.includes("PASTE_"))throw new Error("Supabase is not configured yet. Add the project URL and public anon/publishable key in config.js.");
  if(!window.supabase)throw new Error("Supabase library did not load. Check your internet connection.");
  return window.supabase.createClient(cfg.supabaseUrl,cfg.supabaseAnonKey);
}
