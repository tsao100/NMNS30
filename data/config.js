// 站長設定：到訪者反饋要送到哪裡。兩項都留空時，反饋頁仍可「複製」或「下載」留言內容。
// FEEDBACK_REPO：GitHub 倉庫，例如 "yourname/nmns30"（按送出會開啟預填好的 Issue，需有 GitHub 帳號）
// FEEDBACK_EMAIL：收信信箱（按送出會開啟到訪者的郵件程式，預填好內容）
// SUPABASE_URL / SUPABASE_ANON_KEY：Supabase 專案的 Project URL 與 anon public key（可以公開；千萬不要放 service_role key）。
// 兩項都填了才會啟用高分榜與「送到資料庫」的反饋；先到 Supabase 執行 supabase/schema.sql。
window.NMNS_CONFIG = {
  SUPABASE_URL: "https://biqoidvqctkorvlxezkd.supabase.co", SUPABASE_ANON_KEY: "sb_publishable_NRcNwG8PhIs6rgg7W-0YmQ_kQq27d8N",
  FEEDBACK_REPO: "tsao100/NMNS30", FEEDBACK_EMAIL: "tsao100@ms17.hinet.net" };
