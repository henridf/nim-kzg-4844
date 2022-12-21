# nim-kzg
# Copyright (c) Henri DF
# Licensed under either of
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE))
#  * MIT license ([LICENSE-MIT](LICENSE-MIT))
# at your option.
# This file may not be copied, modified, or distributed except according to
# those terms.

import std/strformat

const FIELD_ELEMENTS_PER_BLOB*{.strdefine.} = 4096

{.compile: "../vendor/c-kzg-4844/blst/build/assembly.S".}
{.compile: "../vendor/c-kzg-4844/blst/src/server.c"}
{.compile: "../vendor/c-kzg-4844/src/c_kzg_4844.c"}

{.passc: "-I/Users/henridf/work/nim-kzg-4844/vendor/c-kzg-4844/blst/bindings -DFIELD_ELEMENTS_PER_BLOB=" & fmt"{FIELD_ELEMENTS_PER_BLOB}".}



const
  BYTES_PER_FIELD_ELEMENT* = 32

type C_KZG_RET* = cint
const
  C_KZG_OK* = (0).C_KZG_RET
  C_KZG_BADARGS* = (1).C_KZG_RET
  C_KZG_ERROR* = (2).C_KZG_RET
  C_KZG_MALLOC* = (3).C_KZG_RET



type
  limb_t = uint64

  blst_fr {.byref.} = object
    l: array[typeof(256)(typeof(256)(256 / typeof(256)(8)) /
        typeof(256)(sizeof((limb_t)))), limb_t]

  blob_t* {.byref.} = array[FIELD_ELEMENTS_PER_BLOB*BYTES_PER_FIELD_ELEMENT, uint8]

  fr_t = blst_fr

  blst_fp {.byref.} = object
    l*: array[typeof(384)(typeof(384)(384 / typeof(384)(8)) /
        typeof(384)(sizeof((limb_t)))), limb_t]

  blst_p1 {.byref.} = object
    x*: blst_fp
    y*: blst_fp
    z*: blst_fp

  g1_t* = blst_p1

  KZGCommitment* = g1_t
  KZGProof* = g1_t

  # temporary pending c-kzg upgrade
  KZGCommitmentBytes* = array[48, byte]
  KZGProofBytes* = array[48, byte]


  FFTSettings {.byref.} = object
    max_width: uint64
    expanded_roots_of_unity: fr_t
    reverse_roots_of_unity: fr_t
    roots_of_unity: fr_t

  KZGSettings* {.byref.} = object
    fs*: ptr FFTSettings
    g1values*: ptr g1_t
    g2values*: ptr g1_t


proc bytes_to_g1*(res: var g1_t, input: array[48, uint8]): C_KZG_RET  {.cdecl, importc: "bytes_to_g1".}

proc bytes_from_g1(res: var array[48, uint8], input: g1_t) {.cdecl, importc: "bytes_from_g1".}

proc load_trusted_setup_file*(ks: var KZGSettings, inf: File): C_KZG_RET {.cdecl, importc: "load_trusted_setup_file".}

proc blob_to_kzg_commitment*(kc: var KZGCommitment, blob: blob_t, s: KZGSettings): C_KZG_RET  {.cdecl, importc: "blob_to_kzg_commitment".}

proc compute_aggregate_kzg_proof*(kp: var KZGProof, blobs: ptr blob_t, n: csize_t, s: KZGSettings): C_KZG_RET  {.cdecl, importc: "compute_aggregate_kzg_proof".}

proc verify_aggregate_kzg_proof*(ok: ptr bool, blobs: ptr blob_t, expected_kzg_commitments: ptr KZGCommitment, n: csize_t, proof: KZGProof, s: KZGSettings): C_KZG_RET  {.cdecl, importc: "verify_aggregate_kzg_proof".}

proc verify_kzg_proof*(ok: ptr bool, kc: KZGCommitment, z: array[32, uint8], y: array[32, uint8], proof: KZGProof, s: KZGSettings): C_KZG_RET  {.cdecl, importc: "verify_kzg_proof".}
