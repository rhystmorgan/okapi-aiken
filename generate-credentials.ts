import { Lucid } from "https://deno.land/x/lucid@0.8.3/mod.ts";
 
const lucid = await Lucid.new(undefined, "Preview");
 
const privateKey = lucid.utils.generatePrivateKey();
await Deno.writeTextFile("me.sk", privateKey);
 
const address = await lucid
  .selectWalletFromPrivateKey(privateKey)
  .wallet.address();
await Deno.writeTextFile("me.addr", address);

// run :
// deno run --allow-net --allow-write generate-credentials.ts