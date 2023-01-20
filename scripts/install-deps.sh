#!/bin/bash

readonly nvm_version="0.39.1"
readonly bashrc="$HOME/.bashrc"
node_lts="16.15.1"

big_machine="false"

while getopts ':b' 'flag'
do
    case "${flag}" in
        'b')
        big_machine="true"
        ;;
        '?')
            echo "INVALID OPTION -- ${flag}" >&2
            exit 1
            ;;
        ':')
            echo "MISSING ARGUMENT for option -- ${flag}" >&2
            exit 1
            ;;
        *)
            echo "UNIMPLEMENTED OPTION -- ${flag}" >&2
            exit 1
            ;;
    esac
done

# Turn on swap for big machine
if $big_machine; then
    echo "We are running on a bigger machine thus turning on swap space."
    sudo mkswap -f /dev/nvme1n1
    sudo swapon /dev/nvme1n1
    sudo sh -c 'echo "vm.max_map_count=10000000" >>/etc/sysctl.conf'
    sudo sh -c 'echo 10000000 > /proc/sys/vm/max_map_count'
fi

function append_to_bashrc() {
    echo "$1" >> "$bashrc"
    source "$bashrc"
}

function install_basic_deps() {
    sudo apt update
    sudo apt install build-essential libgmp-dev libsodium-dev nasm python3 g++ make nlohmann-json3-dev python3-distutils -y
}

function install_rust() {
    if ! command -v "rustc" &>/dev/null; then
        rustup_url="https://sh.rustup.rs"
        curl --proto '=https' --tlsv1.2 "$rustup_url" -sSf  | sh -s -- -y
        append_to_bashrc "export PATH=\"\$PATH:\$HOME/.cargo/bin\""
        source "$bashrc"
    fi
}

function install_nvm() {
    if [ ! -d "$HOME/.nvm" ] ; then
        curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/v$nvm_version/install.sh" | bash
        append_to_bashrc "export PATH=\"\$PATH:\$HOME/.nvm\""
    fi
}

function install_node() {
    if ! command -v "node" &>/dev/null; then
        export NVM_DIR=$HOME/.nvm;
        source $NVM_DIR/nvm.sh;
        nvm install --lts --default
        nvm alias default "$node_lts"
    fi
}

function install_circom() {
    if ! command -v "circom" &>/dev/null; then
        circom_path="/tmp/circom"
        git clone https://github.com/iden3/circom.git "$circom_path"
        pushd "$circom_path"
            cargo build --release
            cargo install --path circom
        popd
    fi
}

function install_snarkjs() {
    if ! command -v "snarkjs" &>/dev/null; then
        npm install --location=global snarkjs
    fi
}

function install_rapidsnark() {
    if [ ! -d "$HOME/rapidsnark" ]; then
        git clone https://github.com/iden3/rapidsnark.git $HOME/rapidsnark
        pushd $HOME/rapidsnark
        npm install
        git submodule init
        git submodule update
        npx task createFieldSources
        npx task buildProver
        popd
        append_to_bashrc "alias rapidsnark=\"\$HOME/rapidsnark/build/prover\""
    fi
}

function install_patched_nodejs() {
    if [ ! -f "$HOME/bin/usr/local/bin/node" ]; then
        nodejs_path="/tmp/nodejs"
        git clone https://github.com/nodejs/node.git "$nodejs_path"
        pushd "$nodejs_path"
        git checkout 8beef5eeb82425b13d447b50beafb04ece7f91b1
        patch -p1 <<EOL
index 0097683120..d35fd6e68d 100644
--- a/deps/v8/src/api/api.cc
+++ b/deps/v8/src/api/api.cc
@@ -7986,7 +7986,7 @@ void BigInt::ToWordsArray(int* sign_bit, int* word_count,
void Isolate::ReportExternalAllocationLimitReached() {
i::Heap* heap = reinterpret_cast<i::Isolate*>(this)->heap();
if (heap->gc_state() != i::Heap::NOT_IN_GC) return;
-  heap->ReportExternalMemoryPressure();
+  // heap->ReportExternalMemoryPressure();
}

HeapProfiler* Isolate::GetHeapProfiler() {
diff --git a/deps/v8/src/objects/backing-store.cc b/deps/v8/src/objects/backing-store.cc
index bd9f39b7d3..c7d7e58ef3 100644
--- a/deps/v8/src/objects/backing-store.cc
+++ b/deps/v8/src/objects/backing-store.cc
@@ -34,7 +34,7 @@ constexpr bool kUseGuardRegions = false;
// address space limits needs to be smaller.
constexpr size_t kAddressSpaceLimit = 0x8000000000L;  // 512 GiB
#elif V8_TARGET_ARCH_64_BIT
-constexpr size_t kAddressSpaceLimit = 0x10100000000L;  // 1 TiB + 4 GiB
+constexpr size_t kAddressSpaceLimit = 0x40100000000L;  // 4 TiB + 4 GiB
#else
constexpr size_t kAddressSpaceLimit = 0xC0000000;  // 3 GiB
#endif
EOL
        ./configure
        make -j16
        DESTDIR=$HOME/bin  make install
        popd
        append_to_bashrc "alias nodex=\"\$HOME/bin/usr/local/bin/node\""
    fi
}

install_basic_deps
install_rust
install_nvm
install_node
install_circom
install_snarkjs
install_rapidsnark
install_patched_nodejs
