import
  std/[sysrand, unittest],
  ../kzg4844/[kzg_abi, kzg]

const trusted_setup_file = "tests/trusted_setup.txt"

proc readSetup(filename: string) : KZGSettings =
  var file = open(filename)
  let ret =  load_trusted_setup_file(result, file)
  doAssert ret == C_KZG_OK

let settings = readSetup(trusted_setup_file)

const MAX_TOP_BYTE=114
proc createBlobsAndCommits(n: int): (seq[blob_t], seq[KZGCommitment]) =

  var blobs: seq[blob_t]

  for i in 0..<n:
    var blob: array[FIELD_ELEMENTS_PER_BLOB*BYTES_PER_FIELD_ELEMENT, uint8]
    discard urandom(blob)
    for i in 0..<len(blob):
      # don't overflow modulus
      if blob[i] > MAX_TOP_BYTE and i %% BYTES_PER_FIELD_ELEMENT == 31:
        blob[i] = MAX_TOP_BYTE
    blobs.add(blob)

  var commits: seq[KZGCommitment]
  for i in 0..<n:
    var kzgcommit: KZGCommitment
    doAssert blob_to_kzg_commitment(kzgcommit, blobs[i], settings) == C_KZG_OK
    commits.add(kzgcommit)

  return (blobs, commits)


suite "verify proof (abi)":
  const nblobs = 5
  test "verify proof success":
    var (blobs, commits) = createBlobsAndCommits(nblobs)
    var kp: KZGProof
    doAssert compute_aggregate_kzg_proof(kp, addr(blobs[0]), csize_t(nblobs), settings) == C_KZG_OK

    var ok: bool
    doAssert verify_aggregate_kzg_proof(addr(ok), addr(blobs[0]), addr(commits[0]), csize_t(nblobs), kp, settings) == C_KZG_OK
    doAssert ok

  test "verify proof failure":
    var (blobs, commits) = createBlobsAndCommits(nblobs)
    var kp: KZGProof
    doAssert compute_aggregate_kzg_proof(kp, addr(blobs[0]), csize_t(nblobs), settings) == C_KZG_OK

    kp.x.l[0]=1
    var ok: bool
    doAssert verify_aggregate_kzg_proof(addr(ok), addr(blobs[0]), addr(commits[0]), csize_t(nblobs), kp, settings) == C_KZG_OK
    doAssert not ok

suite "verify proof (high-level)":
  const nblobs = 5
  test "load trusted setup file":
    doAssert load_trusted_setup_file(trusted_setup_file)

  test "verify proof success":
    var (blobs, commits) = createBlobsAndCommits(nblobs)
    let proofOpt = compute_aggregate_kzg_proof(blobs)
    doAssert not proofOpt.isNone()
    let proof = proofOpt.get()

    doAssert verify_aggregate_kzg_proof_points(blobs, commits, proof)

  test "verify proof failure":
    var (blobs, commits) = createBlobsAndCommits(nblobs)
    let proofOpt = compute_aggregate_kzg_proof(blobs)
    doAssert not proofOpt.isNone()
    var proof = proofOpt.get()
    proof.z.l[0]=1
    doAssert not verify_aggregate_kzg_proof_points(blobs, commits, proof)
