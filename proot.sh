#!/data/data/com.termux/files/usr/bin/bash

# Unofficial Bash Strict Mode
set -euo pipefail
IFS=$'\n\t'

finish() {
  local ret=$?
  if [ ${ret} -ne 0 ] && [ ${ret} -ne 130 ]; then
    echo
    echo "ERROR: XFCE on Termux 설치에 실패하였습니다."
    echo "위 error message를 참고하세요"
  fi
}

trap finish EXIT

username="$1"

pkgs_proot=('sudo' 'wget' 'jq' 'flameshot' 'conky-all' 'zenity' 'eza')

#Install ubuntu proot
pd install ubuntu
pd login ubuntu --shared-tmp -- env DISPLAY=:1.0 apt update
pd login ubuntu --shared-tmp -- env DISPLAY=:1.0 apt upgrade -y
pd login ubuntu --shared-tmp -- env DISPLAY=:1.0 apt install "${pkgs_proot[@]}" -y -o Dpkg::Options::="--force-confold"

#Create user
pd login ubuntu --shared-tmp -- env DISPLAY=:1.0 groupadd storage
pd login ubuntu --shared-tmp -- env DISPLAY=:1.0 groupadd wheel
pd login ubuntu --shared-tmp -- env DISPLAY=:1.0 useradd -m -g users -G wheel,audio,video,storage -s /bin/bash "$username"

#Add user to sudoers
chmod u+rw $PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu/etc/sudoers
echo "$username ALL=(ALL) NOPASSWD:ALL" | tee -a $PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu/etc/sudoers > /dev/null
chmod u-w  $PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu/etc/sudoers

#Set proot DISPLAY
echo "export DISPLAY=:1.0" >> $PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu/home/$username/.bashrc

#Set Sound
echo "LD_PRELOAD=/system/lib64/libskcodec.so" >> $PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu/home/$username/.bashrc

#Set proot aliases
echo "
alias hud='GALLIUM_HUD=fps '
alias ls='eza -lF --icons'
alias ll='ls -alhF'
alias shutdown='kill -9 -1'
alias cat='bat '

alias python='/usr/bin/python3'
alias python3='/usr/bin/python3'
alias pip='/usr/bin/pip'
alias pip3='/usr/bin/pip'
alias start='echo please run from termux, not ubuntu proot.'
" >> $PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu/home/$username/.bashrc

source $PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu/home/$username/.bashrc

#Set proot timezone
timezone=$(getprop persist.sys.timezone)
pd login ubuntu --shared-tmp -- env DISPLAY=:1.0 rm /etc/localtime
pd login ubuntu --shared-tmp -- env DISPLAY=:1.0 cp /usr/share/zoneinfo/$timezone /etc/localtime

#Setup Fancybash Proot
cp .fancybash.sh $PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu/home/$username
echo "source ~/.fancybash.sh" >> $PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu/home/$username/.bashrc
sed -i '327s/termux/ubuntu/' $PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu/home/$username/.fancybash.sh

wget https://github.com/yanghoeg/Termux_XFCE/raw/main/conky.tar.gz
tar -xvzf conky.tar.gz
rm conky.tar.gz
mkdir $PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu/home/$username/.config
mv .config/conky/ $PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu/home/$username/.config
mv .config/neofetch $PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu/home/$username/.config

#Set theming from xfce to proot
cp -r $PREFIX/share/icons/dist-dark $PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu/usr/share/icons/dist-dark

cat <<'EOF' > $PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu/home/$username/.Xresources
Xcursor.theme: dist-dark
EOF

mkdir $PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu/home/$username/.fonts/
cp .fonts/NotoColorEmoji-Regular.ttf $PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu/home/$username/.fonts/ 

#Setup Hardware Acceleration
pd login ubuntu --shared-tmp -- env DISPLAY=:1.0 wget https://github.com/yanghoeg/Termux_XFCE/raw/main/mesa-vulkan-kgsl_24.1.0-devel-20240120_arm64.deb
pd login ubuntu --shared-tmp -- env DISPLAY=:1.0 sudo apt install -y --allow-downgrades ./mesa-vulkan-kgsl_24.1.0-devel-20240120_arm64.deb

wget https://github.com/yanghoeg/Termux_XFCE/raw/main/ubuntu_etc.sh
chmod +x ./ubuntu_etc.sh
cp ./ubuntu_etc.sh $PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu/root/ubuntu_etc.sh
chmod +x $PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu/root/ubuntu_etc.sh
proot-distro login ubuntu --user root --shared-tmp --no-sysvipc -- bash -c "./ubuntu_etc.sh $username"
sleep 1
rm -f $PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu/root/ubuntu_etc.sh
rm -f ./ubuntu_etc.sh
