#!/usr/bin/env bash

cd ~

declare option=$1
declare inst_path='~/snarkOS/'



function log () {  
    printf "\033[1;33m[Setup]\t$1\033[1;35m\n"; sleep 1
}
function is_installed () {
    REQUIRED_PKG=$1
    PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG|grep "install ok installed")
    #echo Checking for $REQUIRED_PKG: $PKG_OK
    if [ "" = "$PKG_OK" ]; then
        echo 0
    else
        echo 1
    fi
}
function install_if_not_installed () {
    installed=$(is_installed $1)
    if [[ installed -eq 0 ]]; then
        log "Installing $1 ..." &&
        sudo apt-get --yes install $REQUIRED_PKG
        wait
    fi
}



if [[ option == "uninstall" ]]; then

    sudo apt update

    log "Uninstall Aleo SnarkOS setup ..."

    # remove curl
    sudo apt remove curl &&

    # uninstall rust
    rustup self uninstall &&

    # remove snarkOS
    rm -r ~/snarkOS &&

    log "Finished."

else 

    log "Start Aleo SnarkOS setup ..."
    if [[ -d $inst_path ]]; then
        log "Found an snarkOS installation at $inst_path"
    fi

    # check rust dependency
    # install rust
    rust_installed=$(is_installed "rust")
    if [[ rust_installed -eq 0 ]]; then
        log "Installing rust ..."
        install_if_not_installed curl 
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
        wait
    fi

    # clone the repository
    git clone https://github.com/AleoHQ/snarkOS.git --depth 1 &&
    cd snarkOS &&

    # # build for Ubuntu
    bash ./build_ubuntu.sh
    wait

    # generate prover address
    log "Do you want to generate a new prover address? (y/n)"
    read i 
    if [[ i == "y" ]]; then
        log "Generating new prover address ..." &&
        snarkos experimental new_account &&
        log "^^^^^^ SAVE THIS INFORMATION! ^^^^^^" &&
        log "You will need your address when running the node." &&
    fi
    
    log "Finished. To start the node please run the $inst_path run-prover.sh."

fi