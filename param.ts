import {
  Blockfrost,
  C,
  Data,
  Lucid,
  SpendingValidator,
  TxHash,
  fromHex,
  toHex,
  toUnit,
  Constr,
  MintingPolicy,
  fromText,
  mintingPolicyToId,
  applyParamsToScript,
  applyDoubleCborEncoding,
  attachSpendingValidator,
  UTxO,
} from "https://deno.land/x/lucid@0.10.6/mod.ts";
import * as cbor from "https://deno.land/x/cbor@v1.4.1/index.js";

// deno run --allow-net --allow-read --allow-env inc.ts

// assumes vesting validator is [0] if validators list
 
const lucid = await Lucid.new(
  new Blockfrost(
    "https://cardano-preview.blockfrost.io/api/v0",
    "previewLtKSAAN8MBR9TjuZwIVwvBnFJ1YKB6Y7",
  ),
  "Preview",
);
 
lucid.selectWalletFromPrivateKey(await Deno.readTextFile("./owner.sk"));
// lucid.selectWalletFromPrivateKey(await Deno.readTextFile("./beneficiary.sk"));
 
const ownerPKH = lucid.utils.getAddressDetails(await Deno.readTextFile("owner.addr"))
.paymentCredential.hash;

const authm = await readAuthValidator()
const authCS = lucid.utils.mintingPolicyToId(authm)
const ref = await readRefValidator()
const mint = await readMintValidator()
const mintCS = lucid.utils.mintingPolicyToId(mint)
const lock = await readLockValidator()
const vest = await readVestValidator()
 
// --- Supporting functions

async function readAuthValidator(): Promise<MintingPolicy> {
  const validator = JSON.parse(await Deno.readTextFile("plutus.json")).validators[1];
  return {
    type: "PlutusV2",
    script: applyParamsToScript(applyDoubleCborEncoding(validator.compiledCode), [ownerPKH]),
  };
}

async function readRefValidator(): Promise<SpendingValidator> {
  const validator = JSON.parse(await Deno.readTextFile("plutus.json")).validators[0];
  return {
    type: "PlutusV2",
    script: applyParamsToScript(applyDoubleCborEncoding(validator.compiledCode), [ownerPKH, authCS]),
  };
}

async function readMintValidator(): Promise<MintingPolicy> {
  const validator = JSON.parse(await Deno.readTextFile("plutus.json")).validators[3];
  return {
    type: "PlutusV2",
    script: applyParamsToScript(applyDoubleCborEncoding(validator.compiledCode), [ownerPKH]),
  };
}

async function readVestValidator(): Promise<SpendingValidator> {
  const validator = JSON.parse(await Deno.readTextFile("plutus.json")).validators[4];
  return {
    type: "PlutusV2",
    script: applyParamsToScript(applyDoubleCborEncoding(validator.compiledCode), [ownerPKH]),
  };
}

async function readLockValidator(): Promise<SpendingValidator> {
  const validator = JSON.parse(await Deno.readTextFile("plutus.json")).validators[2];
  return {
    type: "PlutusV2",
    script: applyParamsToScript(applyDoubleCborEncoding(validator.compiledCode), [ownerPKH, mintCS]),
  };
}


const ownerAddress = await Deno.readTextFile("./owner.addr");

const beneficiaryPublicKeyHash =
  lucid.utils.getAddressDetails(await Deno.readTextFile("beneficiary.addr"))
.paymentCredential.hash;

const beneficiaryAddress = await Deno.readTextFile("./beneficiary.addr");

const Metadata222 = Data.Map(Data.Bytes(), Data.Any());
type Metadata222 = Data.Static<typeof Metadata222>;

const DatumMetadata = Data.Object({
  metadata: Metadata222,
  version: Data.Integer({ minimum: 1, maximum: 99 }),
});
type DatumMetadata = Data.Static<typeof DatumMetadata>;

const metadata = {
  "name": "Rose Riot",
  "image": "ipfs://QmZBdUTpsZjLFfQvJ7bgcZNpEJqTTHUCtjEnqJSp22gXfi",
  "mediaType": "image/png",
}

const newMetadata = {
  "name": "Nose Riot",
  "image": "ipfs://QmZBdUTpsZjLFfQvJ7bgcZNpEJqTTHUCtjEnqJSp22gXfi",
  "mediaType": "image/png",
}

const metadataDatum = Data.to<DatumMetadata>({
  metadata: Data.castFrom<Metadata222>(Data.fromJson(metadata), Metadata222),
  version: BigInt(1),
}, DatumMetadata)

const newMetaDatum = Data.to<DatumMetadata>({
  metadata: Data.castFrom<Metadata222>(Data.fromJson(newMetadata), Metadata222),
  version: BigInt(1),
}, DatumMetadata)

const rHash = lucid.utils.validatorToScriptHash(ref)
const rAddress = lucid.utils.validatorToAddress(ref)

const lDatum = metadataDatum
const lHash = lucid.utils.validatorToScriptHash(lock)
const lAddress = lucid.utils.validatorToAddress(lock)

const vDatum = Data.to(new Constr(0, [BigInt(1000)]))
const vHash = lucid.utils.validatorToScriptHash(vest)
const vAddress = lucid.utils.validatorToAddress(vest)

const aDatum = Data.to(new Constr(0, [lHash]))

console.log(lHash)

const tokenName = fromText("SRFX20")

const redeemer = Data.to(new Constr(0, [BigInt(1), BigInt(0)]))

const mintRedeemer = Data.to(new Constr(0, [BigInt(1), BigInt(1000), tokenName]))

// const lockRedeemer = Data.to(new Constr(0, [BigInt(1), newMetadata]))

// const splitUtxo1 = await splitUtxos()

// await lucid.awaitTx(splitUtxo1)

// console.log(`Transactions Split!
//     Tx Hash: ${splitUtxo1}
// `)

const authTx = await authMint();
 
await lucid.awaitTx(authTx);
 
console.log(`Transaction Outputs
    Tx Hash: ${authTx}
    PolicyId: ${authCS}
`);
 
const txLock = await mintTokens();
 
await lucid.awaitTx(txLock);
 
console.log(`Transaction Outputs
    Tx Hash: ${txLock}
    Address: ${lAddress}
`);

const txRedeem = await userRedeem();

await lucid.awaitTx(txRedeem)

console.log(`Transaction Outputs
    Tx Hash: ${txRedeem}
    Signer: ${ownerPKH}
`);

const txUpdate = await updateMetadata();

await lucid.awaitTx(txUpdate)

console.log(`Transaction Outputs
    TxHash: ${txUpdate}
    Signer: ${mintCS}
`)
 
// --- Supporting functions

async function authMint() {
  const tx = await lucid
    .newTx()
    .mintAssets({
      [toUnit(authCS, fromText("ref10"))]: BigInt(1)
    }, redeemer)
    .attachMintingPolicy(authm)
    .payToContract(rAddress, { inline: aDatum }, { [toUnit(authCS, fromText("ref10"))]: BigInt(1)})
    .addSignerKey(ownerPKH)
    .complete()

  const signedTx = await tx.sign().complete()

  return signedTx.submit()
}

async function mintTokens() {
  const refUtxos = await lucid.utxosAtWithUnit(rAddress, [toUnit(authCS, fromText("ref10"))])
  console.log(refUtxos)
  
  const tx = await lucid
    .newTx()
    .readFrom(refUtxos)
    .mintAssets({
      [toUnit(mintCS, tokenName, 100)]: BigInt(1),
      [toUnit(mintCS, tokenName, 444)]: BigInt(1000)
    }, mintRedeemer)
    .attachMintingPolicy(mint)
    .payToContract(lAddress, { inline: lDatum }, { [toUnit(mintCS, tokenName, 100)]: BigInt(1) })
    .payToContract(vAddress, { inline: vDatum }, { [toUnit(mintCS, tokenName, 444)]: BigInt(1000) })
    .addSignerKey(ownerPKH)
    .complete();
 
  const signedTx = await tx.sign().complete();
 
  return signedTx.submit();
}

async function updateMetadata() {
  const utxos = await lucid.utxosAtWithUnit(lAddress, [toUnit(mintCS, tokenName, 100)])
  
  const utxo = utxos[0]
  console.log(utxo)
  const lDatum2 = newMetaDatum
  
  const tx = await lucid 
    .newTx()
    .collectFrom([utxo], redeemer)
    .attachSpendingValidator(lock)
    .payToContract(lAddress, { inline: lDatum2 }, { [toUnit(mintCS, tokenName, 100)]: BigInt(1) })
    .addSignerKey(ownerPKH)
    .complete()
  
  const signedTx = await tx.sign().complete()
  
  return signedTx.submit()
}

async function userRedeem() {

  const unit = toUnit(mintCS, tokenName, 444)
  const utxos: [UTxO] = await lucid.utxosAtWithUnit(vAddress, [toUnit(mintCS, tokenName, 444)])
  const utxo: UTxO = utxos[0]
  const value = await utxo.assets[unit]
  const outValue = value - 1n

  console.log(value)

  const tx = await lucid
    .newTx()
    .collectFrom([utxo], redeemer)
    .attachSpendingValidator(vest)
    .payToAddress(beneficiaryAddress, { [toUnit(mintCS, tokenName, 444)]: 1n })
    .payToContract(vAddress, vDatum, { [toUnit(mintCS, tokenName, 444)]: outValue })
    // .addSignerKey(ownerPKH)
    .complete()

  const signedTx = await tx.sign().complete()

  return signedTx.submit()
}

async function splitUtxos() {
  const tx = await lucid
    .newTx()
    .payToAddress(ownerAddress, {lovelace: 100000000n})
    .payToAddress(ownerAddress, {lovelace: 100000000n})
    .payToAddress(ownerAddress, {lovelace: 100000000n})
    .payToAddress(ownerAddress, {lovelace: 100000000n})
    .payToAddress(ownerAddress, {lovelace: 100000000n})
    .complete()

  const signedTx = await tx.sign().complete()

  return signedTx.submit()
}