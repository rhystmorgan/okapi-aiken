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
 
const mint = await readValidator();
 
// --- Supporting functions
 
async function readValidator(): Promise<MintingPolicy> {
  const validator = JSON.parse(await Deno.readTextFile("plutus.json")).validators[1];
  return {
    type: "PlutusV2",
    script: toHex(cbor.encode(fromHex(validator.compiledCode))),
  };
}

const mintCS = lucid.utils.mintingPolicyToId(mint);

const ownerPublicKeyHash = lucid.utils.getAddressDetails(
  await lucid.wallet.address()
).paymentCredential.hash;

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
  name: "IncTest4",
  image: "ipfs://1234",
  mediaType: "image/png"
}

const tokenName = fromText("IncTest4")
const rTokenName = "SRTest3"
const metadataDatum = Data.to<DatumMetadata>({
    metadata: Data.castFrom<Metadata222>(Data.fromJson(metadata), Metadata222),
    version: BigInt(1),
  }, DatumMetadata)

const redeemer = Data.to(BigInt(0))
 
const txLock = await incTest1();
 
await lucid.awaitTx(txLock);
 
console.log(`Minted Items
    Tx Hash: ${txLock}
    Datum: ${metadataDatum}
`);
 
// --- Supporting functions
 
async function lock(lovelace, { into, datum }): Promise<TxHash> {
  const contractAddress = lucid.utils.validatorToAddress(into);
 
  const tx = await lucid
    .newTx()
    .payToContract(contractAddress, { inline: datum }, { lovelace })
    .complete();
 
  const signedTx = await tx.sign().complete();
 
  return signedTx.submit();
}

async function incTest1() {
  const tx = await lucid
    .newTx()
    .mintAssets({
      [toUnit(mintCS, tokenName, 100)]: BigInt(1),
      [toUnit(mintCS, tokenName, 222)]: BigInt(1)
    }, Data.to(new Constr(0, [])))
    .payToAddressWithData(ownerAddress, { inline: metadataDatum }, { [toUnit(mintCS, tokenName, 100)]: BigInt(1) })
    .payToAddress(beneficiaryAddress, { [toUnit(mintCS, tokenName, 222)]: BigInt(1) })
    .attachMintingPolicy(mint)
    .complete();
 
  const signedTx = await tx.sign().complete();
 
  return signedTx.submit();
}