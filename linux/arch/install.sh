#!/usr/bin/env sh

# Reference
# https://nobodyzxc.github.io/2019/06/06/arch-install/#more
# https://wiki.archlinux.org/title/Installation_guide
# https://zhuanlan.zhihu.com/p/107135290

# Steps
# 1. Boot by USB
# 2. Connect to the Internet - iwctl
# 3. curl -fsSL https://raw.githubusercontent.com/nobody-cya/dots/refs/heads/main/linux/arch/install.sh > install.sh
# 4. chmod +x install.sh
# 5. write down your os information
# 6. sh install.sh

# Debugging
set -e

# TTY Font
setfont ter-218b.psf.gz

# System clock
timedatectl set-ntp true

# Variables
HDLOC=/dev/nvme0n1
ROOTSIZE=32G
SWAPSIZE=16G
UEFISIZE=250M
NEWHOSTNAME=
USERNAME=
ROOTPASS=
USERPASS=

# Partition
# Use 'cgdisk /dev/sda' to clean your HDD.
read -p "${USERNAME}@${NEWHOSTNAME} on $HDLOC
$(lsblk)
swap size: $SWAPSIZE
root directory size: $ROOTSIZE
boot partition size: $UEFISIZE
enter to contine, ^C to stop:"
# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
trap 'echo "\"${last_command}\" command end with exit code $?."' EXIT
(
  echo "g"
  sleep 1
  echo "n"
  echo "1"
  echo ""
  echo "+$UEFISIZE"
  sleep 1
  echo "n"
  echo "2"
  echo ""
  echo "+$ROOTSIZE"
  sleep 1
  echo "n"
  echo "3"
  echo ""
  echo "+$SWAPSIZE"
  sleep 1
  echo "n"
  echo "4"
  echo ""
  echo ""
  sleep 1
  echo "t"
  echo "1"
  echo "1"
  sleep 1
  echo "t"
  echo "2"
  echo "20"
  sleep 1
  echo "t"
  echo "3"
  echo "19"
  sleep 1
  echo "t"
  echo "4"
  echo "20"
  sleep 5
  echo "w"
  sleep 1
) | fdisk $HDLOC

# Format
mkfs.vfat ${HDLOC}p1
mkfs.ext4 ${HDLOC}p2
mkfs.ext4 ${HDLOC}p4
mkswap ${HDLOC}p3
swapon ${HDLOC}p3

# Mount
mount ${HDLOC}p2 /mnt
mkdir /mnt/boot
mount ${HDLOC}p1 /mnt/boot
mkdir /mnt/home
mount ${HDLOC}p4 /mnt/home

# Mirror
# https://wiki.archlinux.org/title/Reflector
# Use 'reflector' to find the fastest 15 sources to override /etc/pacman.d/mirrorlist
reflector --verbose --latest 15 --sort rate --save /etc/pacman.d/mirrorlist

# Base & Kernel
pacstrap /mnt base linux linux-firmware

# fstab
genfstab -U /mnt >>/mnt/etc/fstab

# Time Zone
arch-chroot /mnt ln -s -f /usr/share/zoneinfo/Asia/Taipei /etc/localtime
arch-chroot /mnt hwclock --systohc

# Localization
sed -i "s/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/" /mnt/etc/locale.gen
sed -i "s/#zh_TW.UTF-8 UTF-8/zh_TW.UTF-8 UTF-8/" /mnt/etc/locale.gen
arch-chroot /mnt locale-gen
echo "LANG=en_US.UTF-8" >/mnt/etc/locale.conf
echo "$NEWHOSTNAME" >/mnt/etc/hostname
cat <<EOF >/mnt/etc/hosts
127.0.0.1      localhost
::1            localhost
127.0.1.1      $NEWHOSTNAME.localdomain      $NEWHOSTNAME
EOF
echo "nameserver 8.8.8.8" >>/mnt/etc/resolv.conf

# User
arch-chroot /mnt pacman -Syy --noconfirm --needed sudo
sed -i 's/^#\s*\(%wheel\s\+ALL=(ALL\:ALL)\s\+ALL\)/\1/' /mnt/etc/sudoers
arch-chroot /mnt useradd -m -u 1001 $USERNAME
arch-chroot /mnt usermod $USERNAME -G wheel
arch-chroot /mnt bash -c "echo root:$ROOTPASS | chpasswd"
arch-chroot /mnt bash -c "echo ${USERNAME}:${USERPASS} | chpasswd"

# Grub
# https://wiki.archlinux.org/title/GRUB
arch-chroot /mnt mkinitcpio -p linux
arch-chroot /mnt pacman -S --noconfirm --needed grub os-prober efibootmgr
arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=grub
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg # warnning here

# Network
arch-chroot /mnt pacman -S --noconfirm --needed net-tools wireless_tools
arch-chroot /mnt pacman -S --noconfirm --needed wpa_supplicant openssh
arch-chroot /mnt pacman -S --noconfirm --needed networkmanager network-manager-applet
arch-chroot /mnt systemctl enable NetworkManager.service
echo "Network services are enabled."
arch-chroot /mnt pacman -S --noconfirm --needed dhclient dhcpcd
arch-chroot /mnt systemctl enable dhcpcd.service
echo "DHCPCD services are enabled."

# Bluetooth
arch-chroot /mnt pacman -S --noconfirm --needed bluez
arch-chroot /mnt systemctl enable bluetooth.service
echo "Bluetooth services are enabled."

# Official pakcage
SYSTOOL1="brightnessctl pulseaudio pulseaudio-alsa pamixer xclip fastfetch udiskie"
SYSTOOL2="blueman polkit-kde-agent alsa-utils flatpak btop npm kitty ibus ibus-chewing gvim"
SYSTOOL3="redshift flameshot unzip p7zip tmux arandr fzf lsd ripgrep"
SYSTOOL4="pcmanfm lxappearance qt5ct awesome xorg-xinit xorg-server"
arch-chroot /mnt sudo pacman -S --noconfirm --needed $SYSTOOL1 $SYSTOOL2 $SYSTOOL3 $SYSTOOL4
ADOBE1="adobe-source-code-pro-fonts	adobe-source-han-sans-cn-fonts adobe-source-han-sans-hk-fonts"
ADOBE2="adobe-source-han-sans-jp-fonts adobe-source-han-sans-kr-fonts adobe-source-han-sans-otc-fonts"
ADOBE3="adobe-source-han-sans-tw-fonts adobe-source-han-serif-cn-fonts"
arch-chroot /mnt sudo pacman -S --noconfirm --needed $ADOBE1 $ADOBE2 $ADOBE3
WQY="wqy-bitmapfont wqy-microhei wqy-microhei-lite wqy-zenhei"
MATH="otf-latinmodern-math otf-latinmodern-math otf-latin-modern"
NOTO="noto-fonts-emoji noto-fonts-extra noto-fonts ttf-noto-nerd noto-fonts-cjk"
UBUNTU="ttf-ubuntu-mono-nerd ttf-ubuntu-nerd"
CASCADIA="ttf-cascadia-code-nerd ttf-cascadia-mono-nerd"
SYMBOLS="ttf-nerd-fonts-symbols ttf-nerd-fonts-symbols-common ttf-nerd-fonts-symbols-mono"
LIBERATION="ttf-liberation ttf-liberation-mono-nerd"
arch-chroot /mnt sudo pacman -S --noconfirm --needed $WQY $MATH $NOTO $UBUNTU $CASCADIA $SYMBOLS $LIBERATION
INCONSOLATA="ttf-inconsolata-nerd ttf-inconsolata-go-nerd ttf-inconsolata-lgc-nerd"
DEJAVU="ttf-dejavu ttf-dejavu-nerd"
FIRA="otf-fira-mono otf-fira-sans otf-firamono-nerd ttf-fira-code ttf-fira-mono ttf-fira-sans ttf-firacode-nerd"
FANTASQUE="ttf-fantasque-nerd ttf-fantasque-sans-mono otf-fantasque-sans-mono"
HACK="ttf-hack ttf-hack-nerd"
JETBRAINS="ttf-jetbrains-mono ttf-jetbrains-mono-nerd"
ROBOTO="ttf-roboto ttf-roboto-mono ttf-roboto-mono-nerd"
arch-chroot /mnt sudo pacman -S --noconfirm --needed $INCONSOLATA $DEJAVU $FIRA $FANTASQUE $HACK $JETBRAINS $ROBOTO
NERD1="ttf-ibmplex-mono-nerd ttf-terminus-nerd"
NERD2="ttf-iosevka-nerd ttf-meslo-nerd"
NERD3="ttf-mononoki-nerd ttf-mplus-nerd"
NERD4="ttf-victor-mono-nerd ttf-zed-mono-nerd ttf-sarasa-gothic"
arch-chroot /mnt sudo pacman -S --noconfirm --needed $NERD1 $NERD2 $NERD3 $NERD4
MISC="otf-codenewroman-nerd otf-comicshanns-nerd otf-droid-nerd otf-monaspace-nerd ttf-font-awesome"
arch-chroot /mnt sudo pacman -S --noconfirm --needed $MISC

# yay
arch-chroot /mnt pacman -S --noconfirm --needed git base-devel
arch-chroot /mnt sudo -u $USERNAME bash -c "cd && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si"

# AUR package
AURAPP="google-chrome visual-studio-code-bin"
AURFONT="ttf-tw ttf-ms-fonts ttf-pt-mono otf-monego-git ttf-monaco apple-fonts otf-apple-pingfang-relaxed otf-apple-pingfang otf-stix nerd-fonts-sf-mono"
arch-chroot /mnt sudo -u $USERNAME bash -c "yay -S --sudoloop $AURAPP $AURFONT"
