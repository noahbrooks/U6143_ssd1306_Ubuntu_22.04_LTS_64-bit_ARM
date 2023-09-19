#!/bin/bash

# Download raspi-config package
wget -4 https://archive.raspberrypi.org/debian/pool/main/r/raspi-config/raspi-config_20230214_all.deb -P /tmp

# Install updates

sudo apt-get update -y

# Install required packages
sudo apt-get install libnewt0.52 whiptail parted triggerhappy lua5.1 alsa-utils make gcc -y

# Fix any broken dependencies
sudo apt-get install -fy

# Install raspi-config package
sudo dpkg -i /tmp/raspi-config_20230214_all.deb

# Clean up downloaded package
rm /tmp/raspi-config_20230214_all.deb

echo "***Raspi-config installation completed.***"

# Enable I2C interface
sudo raspi-config nonint do_i2c 0

echo "***I2C has been enabled via raspi-config.***"

# Change directory to home/ubuntu
cd /home/ubuntu

# Download Git repo

git clone https://github.com/UCTRONICS/U6143_ssd1306.git

echo "***Repo has been downloaded.***"

cd U6143_ssd1306/C

# Compile source code 

make

# Add content to rc-local.service file

lines_to_add="[Install]
WantedBy=multi-user.target
Alias=rc-local.service"

file_path="/lib/systemd/system/rc-local.service"

echo "$lines_to_add" | sudo tee -a "$file_path" > /dev/null
echo "***Lines added to $file_path.***"

# Create and add command to rc.local file

touch /etc/rc.local

lines_to_add0="#!/bin/sh
cd /home/ubuntu/U6143_ssd1306/C
sudo make clean
sudo make
sudo ./display &"

file_path0="/etc/rc.local"

echo "$lines_to_add0" | sudo tee -a "$file_path0" > /dev/null
echo "***Lines added to $file_path0.***"

# Make rc.local executable

sudo chmod +x /etc/rc.local

# Create soft link to /etc/systemd/system

sudo ln -s /lib/systemd/system/rc-local.service /etc/systemd/system/

# Restart host

echo "***Finished***"

sudo shutdown -r