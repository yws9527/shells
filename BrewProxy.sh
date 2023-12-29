#!/bin/bash

# 快捷设置brew代理
# 给可执行权限: chmod +x ./BrewProxy.sh
# 执行命令: source ./BrewProxy.sh

default_proxy="//127.0.0.1:7890"

function setBrewProxy() {
  export https_proxy=http:$default_proxy
  export http_proxy=http:$default_proxy
  export all_proxy=socks5:$default_proxy
  echo "代理设置成功！"
}


setBrewProxy