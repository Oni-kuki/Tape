#!/bin/bash

display_error() {
    echo "an error has occurred : $1"
    exit 1
}
check_protobuf_installed () {
    export PATH="$PATH:$HOME/.local/bin"
    if ! command -v protoc &> /dev/null; then
        echo "protobuf not installed...we will try to install it..."
        wget https://github.com/protocolbuffers/protobuf/releases/download/v26.1/protoc-26.1-linux-x86_64.zip
        unzip protoc-26.1-linux-x86_64.zip -d $HOME/.local
        export PATH="$PATH:$HOME/.local/bin"
    else
        echo "protobuf installed."
    fi
}

check_gvm_installed () {
    if ! command -v gvm &> /dev/null; then
        echo "gvm not installed...we will try to install it..."
        bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)
        source /root/.gvm/scripts/gvm
    else
        echo "gvm installed."
    fi
}


personal_forking() {
    echo "personal forking.. that's allowed to obfuscate some strings more easily"
    
    #in coherence with your forked repository name change the repository name and the github account name
    find . -type f -exec sed -i 's|github.com/bishopfox/sliver|github.com/XXXXXXXXXXX/XXXXXXX|g' {} \;
    find . -type f -exec sed -i 's|bishopfox|XXXXXXXXXXX|g' {} \;
    find . -type f -exec sed -i 's|sliver|XXXXXX|g' {} \;
    find . -type f -exec sed -i 's|Sliver|XXXXXX|g' {} \;
    find . -depth -name '*sliver*' | while IFS= read -r file; do mv "$file" "$(dirname "$file")/$(basename "$file" | sed 's/sliver/XXXXXX/g')"; done

    # change strings artefact that we see in yara rules (for wazuh and ELK)
    find . -type f -exec sed -i 's|InvokeSpawnDllReq|InvokeSpawnDlllReq|g' {} \;
    find . -type f -exec sed -i 's|NetstatReq|NetstsatReq|g' {} \;
    find . -type f -exec sed -i 's|HTTPSessionInit|HTTPSescionInit|g' {} \;
    find . -type f -exec sed -i 's|RegistryReadReq|RegistryReedReq|g' {} \;
    find . -type f -exec sed -i 's|RequestResend|RekuestRessend|g' {} \;
    find . -type f -exec sed -i 's|ScreenshotReq|CaptureScreen|g' {} \;
    find . -type f -exec sed -i 's|GetPrivInfo|PrivInfo|g' {} \;
    find . -type f -exec sed -i 's|GetReconnectIntervalSeconds|GetRecoIntSeconds|g' {} \;
    find . -type f -exec sed -i 's|GetPivotID|PivotID|g' {} \;
    find . -type f -exec sed -i 's|name=PrivInfo|name=PrivescInfo|g' {} \;
    find . -type f -exec sed -i 's|name=ReconnectIntervalSeconds|name=RecoIntervalScs|g' {} \;
    find . -type f -exec sed -i 's|name=PivotID|name=IDPivot|g' {} \;
}

keep_armory() {
    # in Makefile just don't change this lines if you want to continue to use armory
    sed -i 's/^RELEASES_URL.*/RELEASES_URL ?= https:\/\/api.github.com\/repos\/BishopFox\/sliver\/releases/' Makefile
    sed -i 's/^ARMORY_PUB_KEY.*/ARMORY_PUB_KEY ?= RWSBpxpRWDrD7Fe+VvRE3c2VEDC2NK80rlNCj+BX0gz44Xw07r6KQD9L/' Makefile
    sed -i 's/^ARMORY_REPO_URL.*/ARMORY_REPO_URL ?= https:\/\/api.github.com\/repos\/sliverarmory\/armory\/releases/' Makefile
    #RELEASES_URL ?= https://api.github.com/repos/BishopFox/sliver/releases
    #ARMORY_PUB_KEY ?= RWSBpxpRWDrD7Fe+VvRE3c2VEDC2NK80rlNCj+BX0gz44Xw07r6KQD9L
    #ARMORY_REPO_URL ?= https://api.github.com/repos/sliverarmory/armory/releases
} 
prerequisite () {
    sudo apt-get update -y
    sudo apt-get install -y curl unzip wget git make build-essential libpcap-dev apt-get install bsdmainutils uname sed git zip date cut golang-go

}

version_to_install() {
    sliver_version=$1
    if [ -z "$sliver_version" ]; then
        echo "Please specify the version of sliver you want to install."
        display_error "version not specified"
    fi
    folder=$2
    if [ -z "$folder" ]; then
        echo "Please specify the folder for which you want to enter in interaction."
        display_error "folder not specified"
    fi
    cd $folder
    read -p "WARNING: Are you sure about that ?! Do have modified the specific lines in this script in link with your repository name and owner? (yes/no): " choice
        if [[ "$choice" == "yes" ]]; then
            echo "Ok, so let's continue..."
            echo "that's take while..."
            personal_forking
            keep_armory
            check_protobuf_installed
        
            sliver_version=$1
            allowed_versions=("1.6" "1.5")
            if [[ ! " ${allowed_versions[@]} " =~ " ${sliver_version} " ]]; then
                display_error "version $sliver_version is not allowed, just 1.5 or 1.6"
            fi
            if [[ $sliver_version == "1.6" ]]; then
                check=$(go version | awk -F" " '{ print $3 }' | awk -F. '{ print $2 }')
                    if [[ $check -ge 20 ]]; then
                        #sudo apt-get install golang-go -y
                        go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.27.1
                        go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.2.0
                    fi
        
            fi
            if [[ $sliver_version == "1.5" ]]; then
                one=$(go version | awk -F" " '{ print $3 }' | awk -F. '{ print $2 }' | tr -d '[:space:]')
                two=$(go version | awk -F" " '{ print $3 }' | awk -F. '{ print $2,3 }' | awk -F" " '{ print $2 }' | tr -d '[:space:]')
        
                if [[ $one -eq 20 ]] && [[ $two -eq 7 ]]; then
                	echo "good version of go already installed and selected"
                else
                    #if you want multiple versions of go in same time
                    sudo apt-get install bison -y
                    check_gvm_installed
                    gvm install go1.20.7
                    source /root/.gvm/scripts/gvm
                    gvm use go1.20.7
                    go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.27.1
                    go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.2.0
                fi
        
            fi
        
            export PATH=$PATH:/usr/local/go/bin
            export GOROOT_BOOTSTRAP=$GOROOT
            export PATH="$PATH:$(go env GOPATH)/bin"
            make pb
            make 
        else
            echo "Aborted ... Please modify the script and try again."
            exit 1
        fi
}

help() {
    echo "Help :"
    echo ""
    echo "Usage: taping.sh <version> [1.6 or 1.5] [our forked repository name {the folder}]"
    echo "  help     		Display the Help Menu"
    echo ""
}

main() {
    action=$1
    sliver_version=$2
    folder=$3
    shift
    
    case $action in
        "version")
            shift 2
            version_to_install "$sliver_version" "$folder"
            ;;
        "help")
            help
            ;;
        *)
            echo "Usage: taping.sh <version|help|> [1.6 or 1.5]"
            ;;
    esac
}
# Main function call
main $@
