#!/bin/bash

if [ "$(id -u)" != "0" ]; then
   echo "이 스크립트는 루트 권한으로 실행해야 합니다." 1>&2
   exit 1
fi

os_name=$(lsb_release -is)
os_version=$(lsb_release -rs)
codename=$(lsb_release -cs)
arch=$(dpkg --print-architecture)  # Get the architecture

if [ "$os_name" = "Kali" ]; then
    echo "칼리 리눅스용 스크립트를 실행합니다."
    
    cat > /etc/apt/sources.list << EOF
deb https://mirror.amuksa.com/kali kali-rolling main contrib non-free non-free-firmware
deb-src https://mirror.amuksa.com/kali kali-rolling main contrib non-free non-free-firmware
EOF

    echo "칼리 리눅스 sources.list 파일이 성공적으로 업데이트되었습니다."

elif [ "$os_name" = "Ubuntu" ]; then
    if (( $(echo "$os_version < 24" | bc -l) )); then
        echo "우분투 23 이하 버전용 스크립트를 실행합니다."
        
        if [ "$arch" = "arm64" ]; then
            base_url="https://mirror.amuksa.com/ubuntu-ports"
        else
            base_url="https://mirror.amuksa.com/ubuntu"
        fi
        
        cat > /etc/apt/sources.list << EOF
deb $base_url/ $codename main restricted universe multiverse
deb $base_url/ $codename-updates main restricted universe multiverse
deb $base_url/ $codename-backports main restricted universe multiverse
deb $base_url/ $codename-security main restricted universe multiverse
EOF

        echo "sources.list 파일이 성공적으로 업데이트되었습니다."

    else
        echo "우분투 24 이상 버전용 스크립트를 실행합니다."
        
        rm -f /etc/apt/sources.list.d/*.sources

        if [ "$arch" = "arm64" ]; then
            base_url="https://mirror.amuksa.com/ubuntu-ports"
        else
            base_url="https://mirror.amuksa.com/ubuntu"
        fi

        cat > /etc/apt/sources.list.d/amuksa-ubuntu.sources << EOF
Types: deb
URIs: $base_url/
Suites: $codename $codename-updates $codename-backports
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg

Types: deb
URIs: $base_url/
Suites: $codename-security
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
EOF

        echo "새로운 amuksa-ubuntu.sources 파일이 생성되었습니다."

        if [ -f /etc/apt/sources.list ]; then
            mv /etc/apt/sources.list /etc/apt/sources.list.disabled
            echo "기존 sources.list 파일을 비활성화했습니다."
        fi
    fi
else
    echo "지원되지 않는 운영체제입니다: $os_name"
    exit 1
fi

apt update

echo "apt 소스 목록이 업데이트되었습니다."
