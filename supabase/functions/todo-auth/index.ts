// Username/password bridge. Privileged keys stay in the Edge Function runtime.
const project = Deno.env.get("SUPABASE_URL")!;
const adminKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const anonKey = Deno.env.get("SUPABASE_ANON_KEY")!;
const legacyAuth = "https://little-hero-dev-d7f95sqy70d3a475.api.tcloudbasegateway.com";
const legacyRegister = "https://little-hero-dev-d7f95sqy70d3a475.service.tcloudbase.com/api/auth/register";
const headers = { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*", "Access-Control-Allow-Headers": "authorization, apikey, content-type, x-client-info" };
function reply(status: number, code: string, message: string) { return new Response(JSON.stringify({code,message}), {status,headers}); }
async function digest(value: string) { return Array.from(new Uint8Array(await crypto.subtle.digest("SHA-256",new TextEncoder().encode(value)))).map(x=>x.toString(16).padStart(2,"0")).join(""); }
async function limited(key: string) {
  const response = await fetch(project+"/rest/v1/rpc/todo_auth_allow", {method:"POST",headers:{...headers,apikey:adminKey,Authorization:"Bearer "+adminKey},body:JSON.stringify({p_key:await digest(key)})});
  return response.ok && await response.json() === true;
}
Deno.serve(async (request: Request) => {
  if(request.method==="OPTIONS") return new Response("ok",{headers});
  if(request.method!=="POST") return reply(405,"METHOD_NOT_ALLOWED","不支持此请求。");
  try {
    if(Number(request.headers.get("content-length")||0)>4096) return reply(413,"INVALID_REQUEST","请求过大。");
    const raw=await request.text();
    if(raw.length>4096) return reply(413,"INVALID_REQUEST","请求过大。");
    const body=JSON.parse(raw);
    const username=typeof body.username==="string"?body.username.trim():"";
    const password=typeof body.password==="string"?body.password:"";
    const action=body.action;
    if(!/^1[3-9]\d{9}$/.test(username)||password.length<6||password.length>128||!["migrate","register"].includes(action))
      return reply(400,"INVALID_REQUEST","请填写有效账号和密码。");
    const ip=request.headers.get("x-forwarded-for")?.split(",")[0].trim()||"unknown";
    if(!await limited("username:"+username)||!await limited("ip:"+ip)) return reply(429,"RATE_LIMITED","尝试次数过多，请十分钟后重试。");
    const email="todo."+username+"@accounts.little-hero.invalid";
    // An existing Supabase identity is never overwritten or password-reset here.
    const existing=await fetch(project+"/auth/v1/token?grant_type=password",{method:"POST",headers:{...headers,apikey:anonKey},body:JSON.stringify({email,password})});
    if(existing.ok) {
      if(action==="register") return reply(409,"USERNAME_ALREADY_EXISTS","该账号已注册，请直接登录。");
      return new Response(await existing.text(),{status:200,headers});
    }
    if(existing.status>=500) return reply(503,"AUTH_SERVICE_UNAVAILABLE","登录服务暂时不可用。");
    if(action==="register") {
      // Reserve legacy usernames during migration, so nobody can claim an old account.
      const registration=await fetch(legacyRegister,{method:"POST",headers,body:JSON.stringify({username,password,privacyAccepted:body.privacyAccepted===true}),signal:AbortSignal.timeout(15000)});
      if(!registration.ok) {
        const data=await registration.json().catch(()=>({}));
        return reply(registration.status===409?409:400,typeof data.code==="string"?data.code:"REGISTRATION_FAILED",typeof data.message==="string"?data.message:"注册未完成，请检查账号或稍后重试。");
      }
    }
    const verified=await fetch(legacyAuth+"/auth/v1/token",{method:"POST",headers:{...headers,"x-device-id":"todo-supabase-migration"},body:JSON.stringify({grant_type:"password",username,password}),signal:AbortSignal.timeout(15000)});
    if(!verified.ok) return reply(verified.status>=500?503:401,"INVALID_USERNAME_OR_PASSWORD","账号或密码不正确，或旧账号验证服务暂时不可用。");
    const oldSession=await verified.json();
    if(typeof oldSession.sub!=="string"||!oldSession.sub) return reply(502,"INVALID_AUTH_RESPONSE","旧账号验证未完成。");
    const created=await fetch(project+"/auth/v1/admin/users",{method:"POST",headers:{...headers,apikey:adminKey,Authorization:"Bearer "+adminKey},body:JSON.stringify({email,password,email_confirm:true,app_metadata:{todo_username:username,legacy_subject:oldSession.sub,phone_ownership_verified:false},user_metadata:{username}})});
    if(!created.ok) {
      // Could be another device completing the same migration: sign in, never reset.
      const retry=await fetch(project+"/auth/v1/token?grant_type=password",{method:"POST",headers:{...headers,apikey:anonKey},body:JSON.stringify({email,password})});
      if(retry.ok) return new Response(await retry.text(),{status:200,headers});
      return reply(409,"ACCOUNT_ALREADY_MIGRATED","此账号已有新登录凭据，请使用迁移后的密码登录。");
    }
    const session=await fetch(project+"/auth/v1/token?grant_type=password",{method:"POST",headers:{...headers,apikey:anonKey},body:JSON.stringify({email,password})});
    if(!session.ok) return reply(503,"AUTH_SERVICE_UNAVAILABLE","账号已创建，请重新登录。");
    return new Response(await session.text(),{status:200,headers});
  } catch { return reply(503,"AUTH_SERVICE_UNAVAILABLE","登录服务暂时不可用，请稍后重试。"); }
});
