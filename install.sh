#!/data/data/com.termux/files/usr/bin/bash
export GREEN='\033[0;32m'
export TURQ='\033[0;36m'
export URED='\033[4;31m'
export UYELLOW='\033[4;33m'
export WHITE='\033[0;37m'

# Unofficial Bash Strict Mode
set -euo pipefail
IFS=$'\n\t'

finish() {
  local ret=$?
  if [ ${ret} -ne 0 ] && [ ${ret} -ne 130 ]; then
    echo
    echo "ERROR: XFCE on Termux 설치를 실패하였습니다."
    echo "위 error message(s)를 참고하세요."
  fi
}

trap finish EXIT

clear

echo ""
echo "이 스크립트는 Termux XFCE Desktop 및 proot-distro ubuntu를 설치 합니다."
echo ""
read -r -p "사용자 이름(id)을 입력하세요.: " username </dev/tty

termux-change-repo
pkg update -y -o Dpkg::Options::="--force-confold"
pkg upgrade -y -o Dpkg::Options::="--force-confold"
sed -i 's/# allow-external-apps = true/allow-external-apps = true/g' /data/data/com.termux/files/home/.termux/termux.properties

# Display a message 
clear -x
echo ""
echo "Termux 저장소 접근 허용." 
# Wait for a single character input 
echo ""
read -n 1 -s -r -p "아무키나 누르세요..."
termux-setup-storage

pkgs=('wget' 'ncurses-utils' 'dbus' 'proot-distro' 'x11-repo' 'tur-repo' 'pulseaudio')

pkg uninstall dbus -y
pkg update
pkg install "${pkgs[@]}" -y -o Dpkg::Options::="--force-confold"

#Create default directories
mkdir -p Desktop
mkdir -p Downloads

#Download required install scripts
wget https://github.com/mint3100/Termux_XFCE/raw/main/xfce.sh
wget https://github.com/mint3100/Termux_XFCE/raw/main/proot.sh
wget https://github.com/mint3100/Termux_XFCE/raw/main/utils.sh
wget https://github.com/mint3100/Termux_XFCE/raw/main/etc.sh
wget https://github.com/mint3100/Termux_XFCE/raw/main/temp_background.sh
chmod +x *.sh

./xfce.sh "$username"
./etc.sh
./proot.sh "$username"
./utils.sh
./temp_background.sh

# Display a message 
clear -x
echo ""
echo -e ${GREEN} "Termux-X11 APK를 설치합니다.${WHITE}" 
# Wait for a single character input 
echo ""
read -n 1 -s -r -p "아무키나 누르세요..."
wget https://github.com/termux/termux-x11/releases/download/nightly/app-arm64-v8a-debug.apk
mv app-arm64-v8a-debug.apk $HOME/storage/downloads/
termux-open $HOME/storage/downloads/app-arm64-v8a-debug.apk

source $PREFIX/etc/bash.bashrc
termux-reload-settings

#echo -e "${GREEN}Kali-linux를 설치합니다. 생성되는 ID는 기존에 지정한 ID와 동일합니다.${WHITE}"  
#echo -e "${UYELLOW}Kali-linux()를 설치하겠습니까?(y/n)${WHITE}"  

#echo -e "${GREEN}Kali-linux를 설치하겠습니까? (y/n)${WHITE}"
#read yn
#	case $yn in 
#		y ) echo -e "${GREEN}Kali-linux를 설치합니다....${WHITE}"
#          read -r -p "칼리리눅스 사용자 이름(id)을 입력하세요.: " kaliname </dev/tty
#			    wget https://github.com/yanghoeg/Termux_XFCE/raw/main/kali_install.sh
#			    wget https://github.com/yanghoeg/Termux_XFCE/raw/main/kali_install_app.sh
#            chmod +x *.sh
#            ./kali_install.sh $username $kaliname
#            ./kali_install_app.sh $kaliname
#            rm kali_install.sh
#            rm kali_install_app.sh
#            ;;
#		* ) echo -e "${GREEN}kali-linux를 설치하지 않습니다.${WHITE}"
#            ;;
#	esac

clear -x

echo ""
echo "성공적으로 설치하였습니다."
echo ""

rm xfce.sh
rm proot.sh
rm utils.sh
rm etc.sh
rm install.sh
