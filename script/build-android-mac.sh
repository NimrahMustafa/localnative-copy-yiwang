BIN_PATH=$HOME/Library/Android/sdk/ndk/21.0.6113669/toolchains/llvm/prebuilt/darwin-x86_64/bin
cd `dirname $0`/../localnative-rs/localnative_core
# cargo clean
PATH=$BIN_PATH:$PATH cargo build --target armv7-linux-androideabi --release
PATH=$BIN_PATH:$PATH cargo build --target i686-linux-android --release
PATH=$BIN_PATH:$PATH cargo build --target aarch64-linux-android --release
PATH=$BIN_PATH:$PATH cargo build --target x86_64-linux-android --release
