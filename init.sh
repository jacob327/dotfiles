#!/bin/bash

LOST_COMMAND_AND_INSTALL=true
TARGET_SHELL=zsh
BASH=/bin/bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")">/dev/null 2>&1&&pwd)"
if [ ! -d "${DIR}/tmp" ];then
    mkdir "${DIR}/tmp"
fi
cd "${DIR}/tmp"

sys_exit(){
    # {{{
    code="$1"
    printf ".\e[31;1m%s\n\e[m" "[ABORT(errno:${code})]"
    exit
}
# }}}
yn(){
    # {{{
    read -n1 -p "ok? (y/n): " yn
    if [[ $yn = [yY] ]]; then
      echo y
    else
      echo n
    fi
}
# }}}
check_cmd(){
    # {{{
    cmd="$1"
    if [ ! $(which ${cmd}) ];then
        if [ "${LOST_COMMAND_AND_INSTALL}" = 'true' ];then
            echo "${cmd} "
        else
            printf ".\e[31;1m%s\n\e[m" "NG"
            sys_exit 1
        fi
    fi
}
# }}}

# Main
msg="Initing system.."
# {{{
printf "${msg}"
ln -snf ${DIR}/.zshrc ${DIR}/../../.zshrc
ln -snf ${DIR}/.zprofile ${DIR}/../../.zprofile
ln -snf ${DIR}/.xmodmap ${DIR}/../../.xmodmap
ln -snf ${DIR}/.xinitrc ${DIR}/../../.xinitrc

ln -snf ${DIR}/.vimrc ${DIR}/../../.vimrc
ln -snf ${DIR}/.vim ${DIR}/../../.vim
ln -snf ${DIR}/.sshrc ${DIR}/../../.sshrc
printf ".\e[32;1m%s\n\e[m" "OK"
# }}}
msg="Pre checking required commands.."
# {{{
printf "${msg}"
need2install=''
for c in curl git vim zsh wget aptitude jq;do
    [ "$(check_cmd "${c}")" != '' ] && need2install+=" $(check_cmd "${c}")"
done
printf ".\e[32;1m%s\n\e[m" "OK"
if [ "${need2install}" = '' ];then
    echo "All commands are installed. Proceed.."
else
    msg="Some commands missing, and installing.."
    printf "${msg}"
    sudo apt install -y ${need2install} >/dev/null 2>&1 || sys_exit 1
    printf ".\e[32;1m%s\n\e[m" "OK"
fi
# }}}
msg="Setting up login shell.."
# {{{
printf "${msg}"
if [ ! -f "$(which ${TARGET_SHELL})" ];then
    printf ".\e[32;1m%s\n\e[m" "NG"
    sys_exit 1
else
    [ "$(grep ${USER} /etc/passwd|sed -e 's/.*:\(.*\)$/\1/')" != "$(which ${TARGET_SHELL})" ] && chsh -s $(which ${TARGET_SHELL}) $USER
    # [ "$(grep root /etc/passwd|sed -e 's/.*:\(.*\)$/\1/')" != "$(which ${TARGET_SHELL})" ] && sudo chsh -s $(which ${TARGET_SHELL}) root
    if [ "$(grep ${USER} /etc/passwd|sed -e 's/.*:\(.*\)$/\1/')" != "$(which ${TARGET_SHELL})" ];then
        # || [ "$(grep root /etc/passwd|sed -e 's/.*:\(.*\)$/\1/')" != "$(which ${TARGET_SHELL})" ];then
        printf ".\e[32;1m%s\n\e[m" "NG"
        sys_exit 1
    else
        printf ".\e[32;1m%s\n\e[m" "OK"
    fi
fi
# }}}

msg="-----\nPlease set up your environment.."
echo -e "${msg}"

# Packages
# {{{
packages="$(cat <<'EOM'
    {
        "kde": {
            "description": "KDE Plasma and desktop system",
            "preinstall": "sudo apt install aptitude tasksel",
            "install": ["~t^desktop$", "~t^kde-desktop$"],
            "postinstall": ""
        },
        "mozc": {
            "description": "fcitx and mozc, Japanese I/O environment",
            "preinstall": "",
            "install": ["fcitx", "fcitx-mozc", "fcitx-frontend-gtk2", "fcitx-frontend-gtk3", "fcitx-frontend-qt4", "fcitx-frontend-qt5", "fcitx-ui-classic", "kde-config-fcitx", "mozc-utils-gui"],
            "postinstall": "source ~/.zprofile && im-config -n fcitx && sed -i.org -e 's/,mozc:False,/,mozc:True,/' ~/.config/fcitx/profile"
        },
        "thunderbird": {
            "description": "Email client",
            "preinstall": "",
            "install": ["thunderbird"],
            "postinstall": ""
        },
        "nvidia": {
            "description": "Nvidia drivers for GPU",
            "preinstall": "sudo dpkg --add-architecture i386",
            "install": ["firmware-linux", "nvidia-driver", "nvidia-settings", "nvidia-xconfig"],
            "postinstall": "nvidia-xconfig"
        },
        "firefox": {
            "description": "Mozilla Firefox(Latest) web browser",
            "preinstall": "if [ ! -f FirefoxSetup.tar.bz2 ];then wget -O FirefoxSetup.tar.bz2 'https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=en-US';fi",
            "install": [],
            "postinstall": "if [ ! -f /opt/firefox ];then mkdir -p /opt/firefox;fi && tar xjf FirefoxSetup.tar.bz2 -C /opt/firefox/ && if [ -d /usr/lib/firefox-esr/firefox-esr ];then mv /usr/lib/firefox-esr/firefox-esr /usr/lib/firefox-esr/firefox-esr.org;fi && ln -snf /opt/firefox/firefox/firefox /usr/lib/firefox-esr/firefox-esr && rm FirefoxSetup.tar.bz2"
        },
        "chrome": {
            "description": "Google Chrome(Latest) web browser",
            "preinstall": "",
            "install": [],
            "postinstall": "[ ! -f google-chrome-stable_current_amd64.deb ] && wget 'https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb'; apt install -y ./google-chrome-stable_current_amd64.deb && rm google-chrome-stable_current_amd64.deb"
        },
        "slack": {
            "description": "Chat client",
            "preinstall": "",
            "install": ["ca-certificates"],
            "postinstall": "if [ ! -f $(curl -Ss https://slack.com/intl/ja-jp/downloads/instructions/ubuntu|grep 'slack-desktop'|grep 'amd64.deb'|sed -e's/.*\\(slack-desktop-3.4.2-amd64.deb\\).*/\\1/') ];then wget https://downloads.slack-edge.com/linux_releases/$(curl -Ss https://slack.com/intl/ja-jp/downloads/instructions/ubuntu|grep 'slack-desktop'|grep 'amd64.deb'|sed -e's/.*\\(slack-desktop-3.4.2-amd64.deb\\).*/\\1/');fi && sudo apt install -y ./$(curl -Ss https://slack.com/intl/ja-jp/downloads/instructions/ubuntu|grep 'slack-desktop'|grep 'amd64.deb'|sed -e's/.*\\(slack-desktop-3.4.2-amd64.deb\\).*/\\1/') && rm slack-desktop*"
        },
        "Rust": {
            "description": "Rustlang",
            "preinstall": "curl https://sh.rustup.rs -sSf|sh -s -- -y",
            "install": [],
            "postinstall": ""
        },
        "nodejs": {
            "description": "node.js and yarn",
            "preinstall": "apt install -y npm && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - && echo 'deb https://dl.yarnpkg.com/debian/ stable main' | sudo tee /etc/apt/sources.list.d/yarn.list && apt update",
            "install": ["nodejs", "yarn"],
            "postinstall": "sudo yarn global add n && sudo n stable"
        },
        "gcloud": {
            "description": "google cloud platform",
            "preinstall": "echo 'deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main' | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && apt install -y apt-transport-https ca-certificates && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - && sudo apt update",
            "install": ["google-cloud-sdk"],
            "postinstall": ""
        }
    }
EOM
)"
# }}}

keys="$(echo ${packages}|jq '.|keys')"
len="$(echo ${keys}|jq '.|length')"

while :;do
    # {{{
    declare -a pre_install=()
    declare -a pos_install=()
    trg_packages='' ins_packages=''
    for i in $(seq 0 $((${len}-1)));do
        k=$(echo "${keys}"|jq -r ".[${i}]")
        desc="$(echo ${packages}|jq -r ".${k}.description" 2>/dev/null||echo '')"
        pre="$(echo ${packages}|jq -r ".${k}.preinstall" 2>/dev/null||echo '')"
        ins="$(echo -n $(echo ${packages}|jq -r ".${k}.install[]"))"
        pos="$(echo ${packages}|jq -r ".${k}.postinstall" 2>/dev/null||echo '')"
        # echo "$pre $ins $pos"

        msg=""
        printf "Gonna install \e[36;1m%s\e[m - ${desc} \n" "${k}"
        if [ "$(yn)" = 'y' ];then
            trg_packages="${trg_packages} ${k}"
            ins_packages="${ins_packages} ${ins}"
            if [ "${pre}" != '' ];then
                pre_install=("${pre_install[@]}" "${pre}")
            fi
            if [ "${pos}" != '' ];then
                pos_install=("${pos_install[@]}" "${pos}")
            fi
        fi
        printf "\n"
    done
    printf "Settings up.\nTarget Programs are:\n\e[36;1m%s\e[m\n" "${trg_packages}"
    if [ "$(yn)" = 'y' ];then
        break
    fi
    printf "\n"
done
printf "\n\e[32;1m%s\n\e[m" "OK"
# }}}

for ((i = 0; i< ${#pre_install[@]}; i++));do
    "${BASH}" -c "${pre_install[$i]}"
done

sudo apt update && sudo apt upgrade -y -qq
for p in ${ins_packages};do
    sudo aptitude install -y "${p}"
done

for ((i = 0; i< ${#pos_install[@]}; i++));do
    sudo "${BASH}" -c "${pos_install[$i]}"
done


if [ ! -d ${HOME}/.cache/dein ];then
    # {{{
    # vim-dein setup
    cd ~/dotfiles/.vim
    mkdir -p ~/.cache/dein
    cd ~/.cache/dein
    curl https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh > dein_installer.sh
    sh ./dein_installer.sh ~/.cache/dein
    rm ./dein_installer.sh
fi
# }}}

mkdir -p ~/.local/share/fonts
mkdir -p ./fonts
git clone https://github.com/edihbrandon/RictyDiminished.git ./fonts/r && cp ./fonts/r/*.ttf ~/.local/share/fonts
git clone https://github.com/tonsky/FiraCode.git ./fonts/f && cp ./fonts/f/distr/ttf/*.ttf ~/.local/share/fonts

