import { useEffect, useState } from "preact/hooks";
import { Blockfrost, Constr, Data, fromText, Lucid } from "lucid/mod.ts";

import { Input } from "~/components/Input.tsx";
import { Button } from "~/components/Button.tsx";

import {
  AppliedValidators,
  applyParams,
  LocalCache,
  Validators,
} from "~/utils.ts";

export interface AppProps {
  validators: Validators;
}

export default function App({ validators }: AppProps) {
  const [lucid, setLucid] = useState<Lucid | null>(null);
  const [blockfrostAPIKey, setBlockfrostAPIKey] = useState<string>("");
  const [owner, setOwner] = useState<string>("");
  const [giftADA, setGiftADA] = useState<string | undefined>();
  const [lockTxHash, setLockTxHash] = useState<string | undefined>(undefined);
  const [waitingLockTx, setWaitingLockTx] = useState<boolean>(false);
  const [unlockTxHash, setUnlockTxHash] = useState<string | undefined>(
    undefined,
  );
  const [waitingUnlockTx, setWaitingUnlockTx] = useState<boolean>(false);
  const [parameterizedContracts, setParameterizedContracts] = useState<
    AppliedValidators | null
  >(null);

  const setupLucid = async (e: Event) => {
    e.preventDefault();

    const lucid = await Lucid.new(
      new Blockfrost(
        "https://cardano-preprod.blockfrost.io/api/v0",
        blockfrostAPIKey,
      ),
      "Preview",
    );

    const cache = localStorage.getItem("cache");

    if (cache) {
      const {
        owner,
        parameterizedValidators,
        lockTxHash,
      }: LocalCache = JSON.parse(cache);

      setOwner(owner);
      setParameterizedContracts(parameterizedValidators);
      setLockTxHash(lockTxHash);
    }

    setLucid(lucid);
  };

  useEffect(() => {
    if (lucid) {
      window.cardano
        .nami
        .enable()
        .then((wallet) => {
          lucid.selectWallet(wallet);
        });
    }
  }, [lucid]);

  const Metadata222 = Data.Map(Data.Bytes(), Data.Any());
  type Metadata222 = Data.Static<typeof Metadata222>;

  const DatumMetadata = Data.Object({
    metadata: Metadata222,
    version: Data.Integer({ minimum: 1, maximum: 1 }),
    extra: Data.Any(),
  });
  type DatumMetadata = Data.Static<typeof DatumMetadata>;

  const initValidators = async (e: Event) => {
    e.preventDefault();

    const owner = await lucid?.utils.paymentCredentialOf("addr_test1vqlhvhcwaddssxnkfugwlvmk69925xjdx7nc20j2nzuc0gq43pzgq").hash!;

    const contracts = applyParams(
      owner,
      validators,
      lucid!,
    );

    setParameterizedContracts(contracts);
  };

  const mintRef = async (e: Event) => {
    e.preventDefault();

    setMintRefTx(true);

    try {
      const lovelace = Number(2) * 1000000;

      const assetName = `${parameterizedContracts!.refpolicyId}${
        fromText("refToken")
      }`;

      // Action::Mint
      const mintRedeemer = Data.to(new Constr(0, [
        new Constr(0, [parameterizedContracts!.refscriptHash]),
        new Constr(0, [parameterizedContracts!.lockHash]),
      ]));

      const refDatum = Data.to({
        metadata_script_hash: parameterizedContracts!.lockHash,
        refCS: parameterizedContracts!.refpolicyId,
      })

      const utxos = await lucid?.wallet.getUtxos()!;
      const utxo = utxos[0];

      const tx = await lucid!
        .newTx()
        .collectFrom([utxo])
        .attachMintingPolicy(parameterizedContracts!.refmint)
        .mintAssets(
          { [assetName]: BigInt(1) },
          mintRedeemer,
        )
        .payToContract(
          parameterizedContracts!.lockAddress,
          { inline: Data.void() },
          { "lovelace": BigInt(lovelace) },
        )
        .complete();

      const txSigned = await tx.sign().complete();

      const txHash = await txSigned.submit();

      const success = await lucid!.awaitTx(txHash);

      // Wait a little bit longer so ExhaustedUTxOError doesn't happen
      // in the next Tx
      setTimeout(() => {
        setWaitingLockTx(false);

        if (success) {
          localStorage.setItem(
            "cache",
            JSON.stringify({
              owner,
              parameterizedValidators: parameterizedContracts,
              lockTxHash: txHash,
            }),
          );

          setLockTxHash(txHash);
        }
      }, 3000);
    } catch {
      setWaitingLockTx(false);
    }
  };

  const redeemGiftCard = async (e: Event) => {
    e.preventDefault();

    setWaitingUnlockTx(true);

    try {
      const utxos = await lucid!.utxosAt(parameterizedContracts!.lockAddress);

      const assetName = `${parameterizedContracts!.policyId}${
        fromText(tokenName)
      }`;

      // Action::Burn
      const burnRedeemer = Data.to(new Constr(1, []));

      const tx = await lucid!
        .newTx()
        .collectFrom(utxos, Data.void())
        .attachMintingPolicy(parameterizedContracts!.giftCard)
        .attachSpendingValidator(parameterizedContracts!.redeem)
        .mintAssets(
          { [assetName]: BigInt(-1) },
          burnRedeemer,
        )
        .complete();

      const txSigned = await tx.sign().complete();

      const txHash = await txSigned.submit();

      const success = await lucid!.awaitTx(txHash);

      setWaitingUnlockTx(false);

      if (success) {
        localStorage.removeItem("cache");

        setUnlockTxHash(txHash);
      }
    } catch {
      setWaitingUnlockTx(false);
    }
  };

  return (
    <div>
      {!lucid
        ? (
          <form
            class="mt-10 grid grid-cols-1 gap-y-8"
            onSubmit={setupLucid}
          >
            <Input
              type="password"
              id="blockfrostAPIKey"
              onInput={(e) => setBlockfrostAPIKey(e.currentTarget.value)}
            >
              Blockfrost API Key
            </Input>

            <Button type="submit">Setup Lucid</Button>
          </form>
        )
        : (
          <form
            class="mt-10 grid grid-cols-1 gap-y-8"
            onSubmit={submitTokenName}
          >
            <Input
              type="text"
              name="tokenName"
              id="tokenName"
              value={tokenName}
              onInput={(e) => setTokenName(e.currentTarget.value)}
            >
              Token Name
            </Input>

            {tokenName && (
              <Button type="submit">
                Make Contracts
              </Button>
            )}
          </form>
        )}
      {lucid && parameterizedContracts && (
        <>
          <h3 class="mt-4 mb-2">Redeem</h3>
          <pre class="bg-gray-200 p-2 rounded overflow-x-scroll">
            {parameterizedContracts.redeem.script}
          </pre>

          <h3 class="mt-4 mb-2">Gift Card</h3>
          <pre class="bg-gray-200 p-2 rounded overflow-x-scroll">
            {parameterizedContracts.giftCard.script}
          </pre>

          <div class="mt-10 grid grid-cols-1 gap-y-8">
            <Input
              type="text"
              name="giftADA"
              id="giftADA"
              value={giftADA}
              onInput={(e) => setGiftADA(e.currentTarget.value)}
            >
              ADA Amount
            </Input>

            <Button
              onClick={createGiftCard}
              disabled={waitingLockTx || !!lockTxHash}
            >
              {waitingLockTx
                ? "Waiting for Tx..."
                : "Create Gift Card (Locks ADA)"}
            </Button>

            {lockTxHash && (
              <>
                <h3 class="mt-4 mb-2">ADA Locked</h3>

                <a
                  class="mb-2"
                  target="_blank"
                  href={`https://preview.cardanoscan.io/transaction/${lockTxHash}`}
                >
                  {lockTxHash}
                </a>

                <Button
                  onClick={redeemGiftCard}
                  disabled={waitingLockTx || !!unlockTxHash}
                >
                  {waitingUnlockTx
                    ? "Waiting for Tx..."
                    : "Redeem Gift Card (Unlocks ADA)"}
                </Button>
              </>
            )}

            {unlockTxHash && (
              <>
                <h3 class="mt-4 mb-2">ADA Unlocked</h3>

                <a
                  class="mb-2"
                  target="_blank"
                  href={`https://preview.cardanoscan.io/transaction/${unlockTxHash}`}
                >
                  {unlockTxHash}
                </a>
              </>
            )}
          </div>
        </>
      )}
    </div>
  );
}