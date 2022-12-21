import
  kzg_abi,
  stew/results

export
  results

export kzg_abi.blob_t

var
  settings: KZGSettings
  settings_init: bool

proc load_trusted_setup_file*(filename: string): bool =
  var file = open(filename)
  let ret =  load_trusted_setup_file(settings, file)
  settings_init=true
  return ret == C_KZG_OK

proc verify_aggregate_kzg_proof_points*(blobs: openArray[blob_t], expected_kzg_commitments: openArray[KZGCommitment], proof: KZGProof): bool =
  var ok: bool
  let ret = verify_aggregate_kzg_proof(addr(ok), blobs[0].unsafeAddr, expected_kzg_commitments[0].unsafeAddr, csize_t(len(blobs)), proof, settings)
  return ret == C_KZG_OK and ok

proc verify_aggregate_kzg_proof*(blobs: openArray[blob_t], expected_kzg_commitments: openArray[KZGCommitmentBytes], proof: KZGProofBytes): bool =
  # this conversion from bytes to g1's is temporary, pending an update to the c-kzg interface to only use bytes.
  var proof_g1: KZGProof
  let ret = bytes_to_g1(proof_g1, proof)
  if ret != C_KZG_OK:
    return false

  var expected_g1s: seq[KZGCommitment]
  for i in 0..<len(expected_kzg_commitments):
    var kc_g1: g1_t
    let ret = bytes_to_g1(kc_g1, expected_kzg_commitments[i])
    if ret != C_KZG_OK:
      return false
    expected_g1s.add(kc_g1)
  verify_aggregate_kzg_proof_points(blobs, expected_g1s, proof_g1)

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

