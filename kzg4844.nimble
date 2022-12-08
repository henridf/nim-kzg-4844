mode = ScriptMode.Verbose

packageName   = "kzg4844"
version       = "0.1.0"
author        = "Henri DF"
description   = "c-kzg-4844 wrapper in nim"
license       = "Apache License 2.0"
skipDirs      = @["tests"]

installDirs = @["kzg4844", "vendor"]
installFiles = @["kzg4844.nim"]

requires "nim >= 1.2.0"

let nimc = getEnv("NIMC", "nim") # Which nim compiler to use
let flags = getEnv("NIMFLAGS", "") # Extra flags for the compiler
let verbose = getEnv("V", "") notin ["", "0"]

let styleCheckStyle = if (NimMajor, NimMinor) < (1, 6): "hint" else: "error"
let cfg =
  " --styleCheck:usages --styleCheck:" & styleCheckStyle &
  (if verbose: "" else: " --verbosity:0 --hints:off") &
  " --skipParentCfg --skipUserCfg --outdir:build --nimcache:build/nimcache -f"

proc build(args, path: string) =
  exec nimc & " c " & cfg & " " & flags & " " & args & " " & path

proc run(args, path: string) =
  build args & " -r", path

### tasks
task test, "Run all tests":
  run "", "tests/verify_proof.nim"
