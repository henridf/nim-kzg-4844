# nim-kzg
# Copyright (c) Henri DF
# Licensed under either of
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE))
#  * MIT license ([LICENSE-MIT](LICENSE-MIT))
# at your option.
# This file may not be copied, modified, or distributed except according to
# those terms.


{.compile: "../vendor/c-kzg-4844/blst/build/assembly.S".}
{.compile: "../vendor/c-kzg-4844/blst/src/server.c"}
{.compile: "../vendor/c-kzg-4844/src/c_kzg_4844.c"}

{.passc: "-I/Users/henridf/work/nim-kzg-4844/vendor/c-kzg-4844/blst/bindings".}
