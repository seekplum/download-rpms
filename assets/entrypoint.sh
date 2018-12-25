#!/usr/bin/env bash

prepare_td_target(){
   # add GPG key
  rpm --import https://packages.treasuredata.com/GPG-KEY-td-agent

  # add treasure data repository to yum
  cat >/etc/yum.repos.d/td.repo <<'EOF';
[treasuredata]
name=TreasureData
baseurl=http://packages.treasuredata.com/2/redhat/7/\$basearch
gpgcheck=1
gpgkey=https://packages.treasuredata.com/GPG-KEY-td-agent
EOF

  # update your sources
  yum check-update
}

check_prepare(){
    software_name=$1
    if [ "${software_name}" == "td-agent" ];then
        prepare_td_target
    fi
}

download_rpms() {
    software_name=$1
    
    check_prepare ${software_name}

    mkdir -p ${RPMS_DATA}/$software_name
    yum -y install --downloadonly --downloaddir=${RPMS_DATA}/$software_name ${software_name}
}

start_server() {
    print "start server..."
    cd ${RPMS_DATA}
    # python -m SimpleHTTPServer $PORT >/dev/null 2>&1
    python -m SimpleHTTPServer $PORT
}

init_repo() {
    createrepo -pdo ${RPMS_DATA} ${RPMS_DATA}
}

updaet_repo() {
    createrepo --update ${RPMS_DATA}
}

create_repo() {
    print "create repo"
    if [ -f "${RPMS_DATA}/repodata/repomd.xml" ]; then
        updaet_repo
    else
        init_repo
    fi
}

print () {
    echo -e "\033[32m$1\033[0m"
}

print_help() {
    echo "\033[32mStart yum source service on the server side\n\033[0m"
    message="docker run --rm -it --name download-rpms -p 8080:80 -v /root/rpms:/rpms/data/admin/files/repo/rhel74-x86_64 download-rpms <software name1> <software name2>"
    echo ${message}
    
    echo "\033[32m\nSet yum sources on the client side\n\033[0m"
    cat <<EOF1
cat >/etc/yum.repos.d/rpm-install.repo <<EOF
[td-agent]
name=Server
baseurl=http://10.10.20.98:8080
enable=1
gpgcheck=0
EOF
EOF1
    echo ""
}

check_params() {
    for argument in $*
    do
       if [ "${argument}" == "-h" ] || [ "${argument}" == "--help" ]; then
           print_help
           exit 0
       fi
    done
}

main() {
    for software_name in $*
    do
        download_rpms ${software_name}
    done
    print "download packages done!"
    create_repo
    start_server
}


check_params $*
main $*
exit $?
