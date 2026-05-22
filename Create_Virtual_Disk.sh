read -p "Enter the name of the disk : " name
read -p "Enter the location for the disk to be in : " location
read -p "The size : " size
qemu-img create -f qcow2 "$location/$name.qcow2" "$size"G
