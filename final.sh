#!/bin/bash

# This assumes the user is using Ubuntu

# Make sure to run as root
if [ "$(id -u)" -ne "0" ]; then
  echo "Run this script as root" >&2
  exit 1
fi

# The following creates users
users=("Michael" "Dwight" "Jim" "Phyllis" "Andy" "Stanley" "Pam" "Kevin" "Oscar" "Angela" "Meredith" "Creed" "Kelly" "Toby")
for user in "${users[@]}"; do
  if ! id "$user" &>/dev/null; then
    useradd -m "$user"
    echo "User $user created."
  else
    echo "User $user exists."
  fi
done

# The following creates groups
groups=("manager" "accounting" "sales" "support" "hr")
for group in "${groups[@]}"; do
  if ! getent group "$group" &>/dev/null; then
    groupadd "$group"
    echo "Group $group created."
  else
    echo "Group $group exists."
  fi
done

# The following assigns users to various groups
usermod -a -G manager Michael

for user in Dwight Jim Phyllis Andy Stanley; do
  usermod -a -G sales "$user"
done

for user in Kevin Oscar Angela; do
  usermod -a -G accounting "$user"
done

for user in Pam Meredith Creed; do
  usermod -a -G support "$user"
done

for user in Kelly Toby; do
  usermod -a -G hr "$user"
done

# The following creates directories
for group in "${groups[@]}"; do
  dir="/home/$group"
  if [ ! -d "$dir" ]; then
    mkdir "$dir"
    chown root:"$group" "$dir"
    chmod 770 "$dir"
    echo "Directory $dir created and set permissions."
  else
    echo "Directory $dir exists."
  fi
done

# The following ensures Michael and Toby have access to all files
usermod -a -G ${groups[@]} Michael
usermod -a -G ${groups[@]} Toby

# This installs and sets up the web server
if ! which apache2 &>/dev/null; then
  apt-get update && apt-get install -y apache2
  systemctl start apache2
  systemctl enable apache2
  echo "Apache2 installed and running."
else
  echo "Apache2 exists."
fi

# Boilerplate HTML page
echo "<html><body><h1>Testing 1, 2, 3</h1></body></html>" > /var/www/html/index.html

# The following installs the VSFTPD server
if ! which vsftpd &>/dev/null; then
  apt-get update && apt-get install -y vsftpd
  systemctl start vsftpd
  systemctl enable vsftpd
  echo "VSFTPD installed and running."
else
  echo "VSFTPD exists."
fi

echo "Setup complete."