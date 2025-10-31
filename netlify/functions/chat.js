export async function handler(event){
  const {q=''}=JSON.parse(event.body||'{}');
  return new Response(JSON.stringify({reply:`Got it: ${q||'Say something to start.'}`}),{
    headers:{'content-type':'application/json','access-control-allow-origin':'*'}
  });
}
