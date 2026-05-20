echo "This script setups gns3 with all the previlages needed to setup"
echo "Make sure yay is installed in Arch Linux"
yay -S qemu docker vpcs dynamips libvirt ubridge inetutils
yay -S gns3-server gns3-gui
sudo usermod -aG ubridge,libvirt,kvm,wireshark,docker $(whoami)
