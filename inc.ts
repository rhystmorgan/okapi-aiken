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
  applyDoubleCborEncoding
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
 
const mint = await readMintValidator();
const vest = await readVestValidator()
const lock = await readLockValidator()
 
// --- Supporting functions
 
async function readMintValidator(): Promise<MintingPolicy> {
  const validator = JSON.parse(await Deno.readTextFile("plutus.json")).validators[5];
  return {
    type: "PlutusV2",
    script: toHex(cbor.encode(fromHex(validator.compiledCode))),
  };
}

async function readLockValidator(): Promise<SpendingValidator> {
  const validator = JSON.parse(await Deno.readTextFile("plutus.json")).validators[6];
  return {
    type: "PlutusV2",
    script: toHex(cbor.encode(fromHex(validator.compiledCode))),
  };
}

async function readVestValidator(): Promise<SpendingValidator> {
  const validator = JSON.parse(await Deno.readTextFile("plutus.json")).validators[8];
  return {
    type: "PlutusV2",
    script: toHex(cbor.encode(fromHex(validator.compiledCode))),
  };
}

const mintCS = lucid.utils.mintingPolicyToId(mint);

const vAddress = lucid.utils.validatorToAddress(vest)

const ownerPublicKeyHash = lucid.utils.getAddressDetails(
  await lucid.wallet.address()
).paymentCredential.hash;

const ownerAddress = await Deno.readTextFile("./owner.addr");

const beneficiaryPublicKeyHash =
  lucid.utils.getAddressDetails(await Deno.readTextFile("beneficiary.addr"))
.paymentCredential.hash;

const beneficiaryAddress = await Deno.readTextFile("./beneficiary.addr");

const pmint = await applyParamsToScript(mint.script, [ownerPublicKeyHash])
const pmintCS = await lucid.utils.mintingPolicyToId({type: "PlutusV2", script: pmint})
// const plock = await applyParamsToScript(lock.script, [ownerPublicKeyHash, pmintCS])
// const plAddress = lucid.utils.validatorToAddress({type: "PlutusV2", script: plock})
// const pvest = await applyParamsToScript(vest.script, [ownerPublicKeyHash])
// const pvAddress = lucid.utils.validatorToAddress({type: "PlutusV2", script: pvest})

const Metadata222 = Data.Map(Data.Bytes(), Data.Any());
type Metadata222 = Data.Static<typeof Metadata222>;

const DatumMetadata = Data.Object({
  metadata: Metadata222,
  version: Data.Integer({ minimum: 1, maximum: 99 }),
});
type DatumMetadata = Data.Static<typeof DatumMetadata>;

type NFTMetadata = {
  name: string;
  image: string;
  mediaType?: string;
  description?: string;
  files?: FileDetails[];
};

type FileDetails = {
  name?: string;
  mediaType: string;
  src: string;
};
 
const metadata = {
  "name": "Rose Riot",
  "image": "ipfs://QmZBdUTpsZjLFfQvJ7bgcZNpEJqTTHUCtjEnqJSp22gXfi",
  "mediaType": "image/png",
}

const tokenName = fromText("IncTest5")

const metadataDatum = Data.to<DatumMetadata>({
    metadata: Data.castFrom<Metadata222>(Data.fromJson(metadata), Metadata222),
    version: BigInt(1),
  }, DatumMetadata)

const vDatum = Data.to(BigInt(0))
const vHash = lucid.utils.validatorToScriptHash(vest)

console.log(vHash)

const redeemer = Data.to(BigInt(0))
 
const txLock = await incTest1();
 
await lucid.awaitTx(txLock);
 
console.log(`Minted Items
    Tx Hash: ${txLock}
    Datum: ${metadataDatum}
`);
 
// --- Supporting functions

async function incTest2() {
  const tx = await lucid
    .newTx()
    .mintAssets({
      [toUnit(mintCS, tokenName, 100)]: BigInt(1),
      [toUnit(mintCS, tokenName, 222)]: BigInt(1)
    }, Data.to(new Constr(0, [BigInt(1), vHash])))
    .payToContract(vAddress, { inline: metadataDatum }, { [toUnit(mintCS, tokenName, 100)]: BigInt(1) })
    .payToAddress(beneficiaryAddress, { [toUnit(mintCS, tokenName, 222)]: BigInt(1) })
    .attachMintingPolicy(mint)
    .complete();
 
  const signedTx = await tx.sign().complete();
 
  return signedTx.submit();
}

async function incTest1() {
  const tx = await lucid
    .newTx()
    .mintAssets({
      [toUnit(pmintCS, tokenName, 100)]: BigInt(1),
      [toUnit(pmintCS, tokenName, 222)]: BigInt(1)
    }, Data.to(new Constr(0, [BigInt(1), vHash])))
    .payToContract(vAddress, { inline: metadataDatum }, { [toUnit(pmintCS, tokenName, 100)]: BigInt(1) })
    .payToAddress(beneficiaryAddress, { [toUnit(pmintCS, tokenName, 222)]: BigInt(1) })
    .attachMintingPolicy(pmint)
    .complete();
 
  const signedTx = await tx.sign().complete();
 
  return signedTx.submit();
}