sudo dnf install -y terminus-fonts-console
echo 'FONT="ter-v32n"' | sudo tee /etc/vconsole.conf > /dev/null
sudo dracut -f