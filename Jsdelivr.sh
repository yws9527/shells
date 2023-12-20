#!/bin/bash
# 因为unpkg被q，无法正常访问，所以该脚本从jsdelivr离线package
# ... 目前遇到一点兼容问题，在win下有bug，建议在linux环境跑

host="https://data.jsdelivr.com"

download_host="https://fastly.jsdelivr.net"

root_dir="./packages"

package_name=""

package_ver=""

package_path=""

download_path=""

setPackage() {
  read -p "请输入你要离线的包名: " name
  if [ ! -n "$name" ];then
    echo "包名为空，程序退出！"
    exit
  else
    package_name=$name
    echo -e "\e[93m即将开始下载: $name\e[0m"
  fi
}

function get_package_ver() {
  echo $(curl -sL $host/v1/packages/npm/$package_name 2>/dev/null | grep -Po 'latest[": ]+\K[^"]+')
}

function get_package_list() {
  echo $(curl -sL $package_path 2>/dev/null | jq -r '.files')
}

function generateDir() {
  mkdir -p $1
}

function generateFile() {
  curl -sL $1 -o $2
  echo "$1"
}

function getTargetFiles() {
  echo $1 | jq .[] -c | while read item; do
    type=$(echo $item | jq -r .type -c)
    name=$(echo $item | jq -r .name -c)
    # echo "$package_path$2/$name"
    if [ $type = "file" ]; then
      generateFile "$2/$name" "$3/$name"
    else
      generateDir "$3/$name"
      files=$(echo $item | jq -r .files  -c)
      getTargetFiles "$files" "$2/$name" "$3/$name"
    fi
  done
}

# 交互式设置包名
setPackage

# 获取版本号
package_ver=$(get_package_ver)

# 根据版本号获取包的访问路径
package_path=$host/v1/packages/npm/$package_name@$package_ver

# 根据版本号获取包的下载路径
download_path=$download_host/npm/$package_name@$package_ver

# 根据版本号获取包的存放路径
package_dir=$root_dir/$package_name@$package_ver

# 生成package目录
generateDir "$package_dir"

# 获取package列表
package_list=$(get_package_list)

# 递归获取package文件
getTargetFiles "$package_list" "$download_path" "$package_dir"