echo "This script is to setup git and connect it with github using ssh"
read -p "Enter your user name : " name
git config --global user.name $name
read -p "Enter your user email : " email
git config --global user.email $email
git config --list
echo "Your configured successfully"

ssh-keygen -t ed25519 -C "$email"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
echo "ssh generated successfully"
echo "add this ssh key in github : "
cat ~/.ssh/id_ed25519.pub
