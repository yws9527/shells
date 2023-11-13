#!/bin/sh

# 操作类型
operations=("设置代理" "取消代理")

# 快速修改git代理
changeGitGlobalProxy() {
  PS3="请选择操作："
  select opselect in "${operations[@]}"; do
    case $opselect in
      "设置代理")
        setProxy
        break
        ;;
      "取消代理")
        unsetProxy
        break
        ;;
      *) echo "您的输入无效 $REPLY";;
    esac
  done
}

# 设置代理
setProxy() {
  read -p "请输入您的Git代理地址: " proxy_url
  git config --global http.proxy $proxy_url 
  git config --global https.proxy $proxy_url
  checkProxy
}

# 取消代理
unsetProxy() {
  git config --global --unset http.proxy
  git config --global --unset https.proxy
  echo "Git代理已取消."
}

# 查看代理
checkProxy() {
  curProxyUrl=`git config --global --get http.proxy`
  # git config --global --get https.proxy
  echo "Git当前代理为: $curProxyUrl"
}


changeGitGlobalProxy