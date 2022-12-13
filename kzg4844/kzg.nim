import
  kzg_abi,
  stew/results

export
  results


var
  settings: KZGSettings
  settings_init: bool

proc load_trusted_setup_file*(filename: string): bool =
  var file = open(filename)
  let ret =  load_trusted_setup_file(settings, file)
  settings_init=true
  return ret == C_KZG_OK

proc verify_aggregate_kzg_proof*(blobs: var openArray[blob_t], expected_kzg_commitments: var openArray[KZGCommitment], proof: KZGProof): bool =
  var ok: bool
  let ret = verify_aggregate_kzg_proof(addr(ok), addr(blobs[0]), addr(expected_kzg_commitments[0]), csize_t(len(blobs)), proof, settings)
  return ret == C_KZG_OK and ok

proc blob_to_kzg_commitment*(kc: var KZGCommitment, blob: blob_t): Opt[KZGCommitment] =
  var kzgcommit: KZGCommitment
  let ret : C_KZG_RET = blob_to_kzg_commitment(kzgcommit, blob, settings)
  if ret == C_KZG_OK:
    ok(kzgcommit)
  else:
    err()

proc compute_aggregate_kzg_proof*(blobs: var openArray[blob_t]): Opt[KZGProof] =
  var kzgproof: KZGProof
  let ret = compute_aggregate_kzg_proof(kzgproof, addr(blobs[0]), csize_t(len(blobs)), settings)
  if ret == C_KZG_OK:
    ok(kzgproof)
  else:
    err()

