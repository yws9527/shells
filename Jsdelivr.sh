#!/bin/sh
# 因为unpkg被q，无法正常访问，所以该脚本从jsdelivr离线package
# ... 目前遇到一点问题，暂无头绪~~~~~~~~

host="https://data.jsdelivr.com"

root_dir="./packages"

package_name="esbuild"

# https://data.jsdelivr.com/v1/packages/npm/bootstrap

# https://data.jsdelivr.com/v1/packages/npm/bootstrap@5.1.0

function get_package_ver() {
  echo $(curl -sL $host/v1/packages/npm/$package_name 2>/dev/null | grep -Po 'latest[": ]+\K[^"]+')
}

function get_package_list() {
  echo $(curl -sL $host/v1/packages/npm/$package_name@$1 2>/dev/null | jq -r '.files')
}

function generateDir() {
  mkdir -p $1
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


# 获取版本号
package_ver=$(get_package_ver)

# 根据package最新版本号获取包的存放路径
package_dir=$root_dir/$package_name/$package_ver

# 生成package目录
generateDir "$package_dir"

# 获取package列表
# dd=$(get_package_list "$package_ver")

echo $(curl -sL $host/v1/packages/npm/$package_name@$package_ver | jq '.files')

### 只差一步了，写到这里不知道怎么继续...
### linux环境下一切正常输出
#### [ { "type": "directory", "name": "bin", "files": [ { "type": "file", "name": "esbuild", "hash": "29NY/6xAyACUMo6lZ9fO7lnplkXqT6T6dA2HNr6qUA0=", "size": 9180 } ] }, { "type": "directory", "name": "lib", "files": [ { "type": "file", "name": "main.d.ts", "hash": "UUvGKLT8SwNK6B8KtmOTpbKGbnz3/Si9QVnd/5pvxQo=", "size": 21152 }, { "type": "file", "name": "main.js", "hash": "ztJ4T/1VAP0XH16hIlMuea/2uX186kMm/A7zEGLuM20=", "size": 88340 } ] }, { "type": "file", "name": "install.js", "hash": "GPf/dbsYWA08Y/zs7ka22MOHLwGkaobCzduHMDN40oE=", "size": 10923 }, { "type": "file", "name": "LICENSE.md", "hash": "tA7Fuux7s0+lscCVIfo81S1frXra/tdJMqIBDTYSpoE=", "size": 1069 }, { "type": "file", "name": "package.json", "hash": "Ft1nXl0Pm2FtyiI35BjBcANx5S2n5ZwHicZ8lF8RRMI=", "size": 1260 }, { "type": "file", "name": "README.md", "hash": "bUgc1g7Dxnnl45X1R6tCIRR/NWQolPa5Wo3zj9Jch70=", "size": 175 } ]
### windows环境下异常
#### ]size": 175gc1g7Dxnnl45X1R6tCIRR/NWQolPa5Wo3zj9Jch70=",
### jq确定用法没错,,,。,,,.......................

# 递归获取package文件
# getTargetFiles "$package_main_page" ".target|.details"