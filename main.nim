import kzg/kzg_abi


proc readSetup(filename: string) : KZGSettings =
  #  var ks: KZGSettings
  var file = open(filename)
  let ret =  load_trusted_setup(result, file)
  if ret != C_KZG_OK:
    return

  echo "fs: ", result.fs[]
  echo "g1: ", result.g1values[]
  echo "g2: ", result.g2values[]

let settings = readSetup("trusted_setup.txt")

import std/sysrand


var blobs: array[3, blob_t]
for i in 0..<len(blobs):
  var blob: array[FIELD_ELEMENTS_PER_BLOB*BYTES_PER_FIELD_ELEMENT, uint8]
  discard urandom(blob)
  blobs[i]=blob


#echo "blob: ", blob

var kzgcommits: array[3, KZGCommitment]
for i in 0..<len(blobs):
  echo blob_to_kzg_commitment(kzgcommits[i], blobs[i], settings)

for i in 0..<len(blobs):
  echo blobs[i][0]
  echo kzgcommits[i].x.l[0]

var kp: KZGProof
echo "compute_aggregate_kzg_proof: " ,compute_aggregate_kzg_proof(kp, addr(blobs[0]), csize_t(1), settings)
echo kp
# proc compute_aggregate_kzg_proof*(blobs: ptr blob_t, n: csize_t, s: KZGSettings): C_KZG_RET  {.cdecl, importc: "compute_aggregate_kzg_proof".}

var ok: bool
echo verify_aggregate_kzg_proof(addr(ok), addr(blobs[0]), addr(kzgcommits[0]), csize_t(1), kp, settings)
echo ok
