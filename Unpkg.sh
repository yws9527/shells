#!/bin/sh

# 注意！！！！！！！！！
# 当前脚本需要jq工具，在使用之前需要确保已安装
# 1. 在线安装
# 安装jq: curl -L -o /usr/bin/jq.exe https://github.com/stedolan/jq/releases/latest/download/jq-win64.exe
# 2. 离线安装
# 使用我仓库里提供的:/bin/jq.exe
# windows用户建议将jq.exe放在Git目录：D:\xxx\Git\usr\bin\
# 检测jq：jq --version

host="https://unpkg.com"

root_dir="./packages"

package_name="axios"

package_ver=""

package_dir=""

package_main_page=""


function fetchCtx() {
  echo $(curl -sL $1 2>/dev/null | grep -o 'window.__DATA__ = .*}<\/script>' | sed 's/window.__DATA__ = //g' | sed 's/}<\/script>/}/g' | jq .)
}

function generateDir() {
  mkdir -p $1
}

function getTargetVer() {
  target_ver=$(echo $package_main_page | jq -r $1);
  echo $target_ver
}

function generateFile() {
  curl -sL $1 -o $2
}

function getTargetFiles() {
  items=$(echo $1 | jq "$2 | to_entries | map(.value)" -c)
  echo $items | jq .[] -c | while read item; do
    type=$(echo $item | jq -r .type -c)
    path=$(echo $item | jq -r .path -c)
    echo "$host/$package_name@$package_ver$path"
    if [ $type = "file" ]; then
      generateFile $host/$package_name@$package_ver$path $package_dir$path
    else
      generateDir $package_dir$path
      temp=$(fetchCtx $host/$package_name@$package_ver$path/)
      getTargetFiles "$temp" ".target|.details"
    fi
    # echo -e "item: $type ---- $path"
  done
}

# 获取package首页内容
package_main_page=$(fetchCtx $host/$package_name/)

# 从package首页内容获取版本号
package_ver=$(getTargetVer ".packageVersion")

# 根据package最新版本号获取包的存放路径
package_dir=$root_dir/$package_name/$package_ver

# 生成package目录
generateDir "$package_dir"

# 递归获取package文件
getTargetFiles "$package_main_page" ".target|.details"


# echo "获取的内容：$package_main_page"