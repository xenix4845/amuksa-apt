#!/bin/bash

# 스크립트 실행 권한 확인
if [ "$(id -u)" -ne 0 ]; then
   echo "이 스크립트는 root 권한으로 실행되어야 합니다."
   exit 1
fi

# 설정할 미러 주소
MIRROR="http://mirror.amuksa.com/almalinux"

# 레포지토리 파일 목록
REPOS=("almalinux-appstream.repo" "almalinux-baseos.repo")

# 각 레포지토리 파일에 대한 작업
for repo in "${REPOS[@]}"; do
    repo_file="/etc/yum.repos.d/$repo"
    
    if [ -f "$repo_file" ]; then
        # 파일의 기존 내용을 백업
        cp "$repo_file" "$repo_file.bak"
        
        # sed를 사용해 설정 변경
        sed -i 's|^mirrorlist=.*|#mirrorlist=https://mirrors.almalinux.org/mirrorlist/$releasever/'"$(echo $repo | sed 's/almalinux-//;s/.repo//')"'/|g' "$repo_file"
        sed -i 's|^baseurl=.*|baseurl='"$MIRROR"'/'"$releasever"'/'$(echo $repo | sed 's/almalinux-//;s/.repo//')'/'"$basearch"'/os/|g' "$repo_file"
        
        echo "$repo_file 파일 설정이 변경되었습니다."
    else
        echo "$repo_file 파일이 존재하지 않습니다."
    fi
done

# yum 캐시 클리어 및 패키지 목록 갱신
yum clean all
yum makecache

echo "모든 작업이 완료되었습니다."
