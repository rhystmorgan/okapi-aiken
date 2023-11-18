import {
  applyDoubleCborEncoding,
  applyParamsToScript,
  Constr,
  fromText,
  Lucid,
  MintingPolicy,
  OutRef,
  SpendingValidator,
  PaymentCredential,
  Address,
  CurrencySymbol,
  ScriptHash
} from "lucid/mod.ts";
 
import blueprint from "~/plutus.json" assert { type: "json" };
 
export type Validators = {
  lock: SpendingValidator;
  mint: MintingPolicy;
  refscript: SpendingValidator;
  refmint: MintingPolicy;
};
 
export function readValidators(): Validators {
  const lock = blueprint.validators.find((v) => v.title === "soundrig.metadata_validator");
 
  if (!lock) {
    throw new Error("Locking validator not found");
  }
 
  const mint = blueprint.validators.find(
    (v) => v.title === "soundrig.mint68"
  );
 
  if (!mint) {
    throw new Error("minting policy not found");
  }

  const refscript = blueprint.validators.find((v) => v.title === "soundrig.reference_validator");

  if (!refscript) {
    throw new Error("Ref validator not found");
  }

  const refmint = blueprint.validators.find((v) => v.title === "soundrig.reference_mint");

  if (!refmint) {
    throw new Error("Ref mint not found");
  }
 
  return {
    lock: {
      type: "PlutusV2",
      script: lock.compiledCode,
    },
    mint: {
      type: "PlutusV2",
      script: mint.compiledCode,
    },
    refscript: {
      type: "PlutusV2",
      script: refscript.compiledCode,
    },
    refmint: {
      type: "PlutusV2",
      script: refmint.compiledCode,
    },
  };
}

// export type AppliedValidators = {
//   redeem: SpendingValidator;
//   giftCard: MintingPolicy;
//   policyId: string;
//   lockAddress: string;
// };
 
export type AppliedValidators = {
  lock: SpendingValidator;
  mint: MintingPolicy;
  refscript: SpendingValidator;
  refmint: MintingPolicy;
  policyId: CurrencySymbol;
  refpolicyId: CurrencySymbol;
  lockAddress: Address;
  lockHash: ScriptHash;
  refAddress: Address;
  refHash: ScriptHash;
};

export function applyParams(
  owner: PaymentCredential.hash,
  validators: Validators,
  lucid: Lucid
): AppliedValidators {
 
  const mint = applyParamsToScript(validators.mint.script, [
    owner,
  ]);
 
  const policyId = lucid.utils.validatorToScriptHash({
    type: "PlutusV2",
    script: mint,
  });
 
  const lock = applyParamsToScript(validators.lock.script, [
    policyId,
  ]);
 
  const lockAddress = lucid.utils.validatorToAddress({
    type: "PlutusV2",
    script: lock,
  });

  const lockHash = lucid.utils.validatorToScriptHash({
    type: "PlutusV2",
    script: lock
  })

  const refscript = applyParamsToScript(validators.refscript.script, [
    owner,
  ]);

  const refAddress = lucid.utils.validatorToAddress({
    type: "PlutusV2",
    script: refscript
  })

  const refHash = lucid.utils.validatorToScriptHash({
    type: "PlutusV2",
    script: refscript
  })

  const refmint = applyParamsToScript(validators.refmint.script, [
    owner,
  ]);

  const refpolicyId = lucid.utils.validatorToScriptHash({
    type: "PlutusV2",
    script: refmint,
  });
 
  return {
    lock: { type: "PlutusV2", script: applyDoubleCborEncoding(lock) },
    mint: { type: "PlutusV2", script: applyDoubleCborEncoding(mint) },
    refscript: { type: "PlutusV2", script: applyDoubleCborEncoding(refscript) },
    refmint: { type: "PlutusV2", script: applyDoubleCborEncoding(refmint) },
    policyId,
    refpolicyId,
    lockAddress,
    lockHash,
    refAddress,
    refHash,
  };
}