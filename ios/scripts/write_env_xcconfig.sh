#!/bin/sh
# 저장소 루트 .env에서 iOS 빌드 설정에 필요한 값만 꺼내 Flutter/Env.xcconfig로 씁니다.
#
# Info.plist의 카카오 URL 스킴(kakao$(KAKAO_NATIVE_APP_KEY))에 키를 넣기 위해서입니다.
# .env는 # 주석이 있어 xcconfig로 바로 읽을 수 없고, 키를 git에 올리지 않으려고
# 빌드할 때마다 만듭니다. Runner 스킴의 빌드 pre-action에서 부릅니다.
set -eu

ios_dir="$(cd "$(dirname "$0")/.." && pwd)"
env_file="$ios_dir/../.env"
out_file="$ios_dir/Flutter/Env.xcconfig"

key=""
if [ -f "$env_file" ]; then
  key="$(sed -n 's/^[[:space:]]*KAKAO_NATIVE_APP_KEY[[:space:]]*=[[:space:]]*//p' "$env_file" | tail -n 1 | tr -d '[:space:]"'"'")"
fi

printf '// write_env_xcconfig.sh가 .env로 만드는 파일입니다. 직접 고치지 않습니다.\nKAKAO_NATIVE_APP_KEY = %s\n' "$key" > "$out_file"
