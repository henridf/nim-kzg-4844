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
  ret == C_KZG_OK

proc verify_aggregate_kzg_proof*(
  blobs: openArray[blob_t],
  expected_kzg_commitments: openArray[KZGCommitment],
  kp: KZGProof): bool =
  var ok: bool
  let ret = verify_aggregate_kzg_proof(addr(ok), blobs[0].unsafeAddr, expected_kzg_commitments[0].unsafeAddr,
                             csize_t(len(blobs)), kp[0].unsafeAddr, settings)
  ret == C_KZG_OK and ok

proc blob_to_kzg_commitment*(blob: blob_t): Opt[KZGCommitment] =
  var kc: KZGCommitment
  let ret = blob_to_kzg_commitment(kc, blob, settings)
  if ret == C_KZG_OK:
    ok(kc)
  else:
    err()

proc compute_aggregate_kzg_proof*(blobs: var openArray[blob_t]): Opt[KZGProof] =
  var kp: KZGProof
  let ret = compute_aggregate_kzg_proof(addr(kp[0]), addr(blobs[0]),
                                        csize_t(len(blobs)), settings)
  if ret == C_KZG_OK:
    ok(kp)
  else:
    err()
