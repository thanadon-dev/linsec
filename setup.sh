#!/bin/bash
set -e

### ===== REQUIRE TELEGRAM =====
# Try to inherit from parent process environment if not set
if [ -z "$TELEGRAM_TOKEN" ] && [ -n "$SUDO_USER" ]; then
  PARENT_PID=$(ps -o ppid= -p $$ | tr -d ' ')
  if [ -r "/proc/$PARENT_PID/environ" ]; then
    TELEGRAM_TOKEN=$(tr '\0' '\n' < /proc/$PARENT_PID/environ | grep ^TELEGRAM_TOKEN= | cut -d= -f2-)
  fi
fi

if [ -z "$TELEGRAM_CHAT_ID" ] && [ -n "$SUDO_USER" ]; then
  PARENT_PID=$(ps -o ppid= -p $$ | tr -d ' ')
  if [ -r "/proc/$PARENT_PID/environ" ]; then
    TELEGRAM_CHAT_ID=$(tr '\0' '\n' < /proc/$PARENT_PID/environ | grep ^TELEGRAM_CHAT_ID= | cut -d= -f2-)
  fi
fi

if [ -z "$TELEGRAM_TOKEN" ] || [ -z "$TELEGRAM_CHAT_ID" ]; then
  echo "❌ TELEGRAM_TOKEN or TELEGRAM_CHAT_ID not set"
  echo ""
  echo "Usage:"
  echo "  export TELEGRAM_TOKEN='your-token'"
  echo "  export TELEGRAM_CHAT_ID='your-chat-id'"
  echo "  curl -fsSL https://raw.githubusercontent.com/thanadon-dev/linsec/main/setup.sh | sudo -E bash"
  exit 1
fi

### ===== CONFIG (custom or random) =====
NEW_USER="${SSH_USER:-u$(tr -dc a-z0-9 </dev/urandom | head -c6)}"
NEW_PASSWORD="${SSH_PASSWORD:-$(tr -dc A-Za-z0-9 </dev/urandom | head -c16)}"
SSH_PORT="${SSH_PORT:-$(shuf -i 20000-40000 -n 1)}"
TIMEZONE="Asia/Bangkok"
HOSTNAME="$(hostname)"
SERVER_IP="$(curl -s ifconfig.me || echo unknown)"

### ===== BASIC SETUP =====
apt update && apt upgrade -y
apt install -y curl ufw fail2ban unattended-upgrades

timedatectl set-timezone "$TIMEZONE"

### ===== TELEGRAM CORE =====
cat > /usr/local/bin/telegram.sh <<EOF
#!/bin/bash
curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage" \
-d chat_id="$TELEGRAM_CHAT_ID" \
-d text="\$1" \
-d parse_mode="HTML" > /dev/null
EOF
chmod +x /usr/local/bin/telegram.sh

### ===== CREATE USER =====
useradd -m -s /bin/bash "$NEW_USER"
echo "$NEW_USER:$NEW_PASSWORD" | chpasswd
usermod -aG sudo "$NEW_USER"

echo "$NEW_USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$NEW_USER
chmod 440 /etc/sudoers.d/$NEW_USER

### ===== SSH LOGIN ALERT =====
cat > /usr/local/bin/ssh-login-alert.sh <<'EOF'
#!/bin/bash
MSG="🔐 <b>SSH LOGIN</b>
👤 User: $PAM_USER
🌐 IP: $PAM_RHOST
🕒 $(date)
💻 Host: $(hostname)"
/usr/local/bin/telegram.sh "$MSG"
EOF
chmod +x /usr/local/bin/ssh-login-alert.sh

grep -q pam_exec /etc/pam.d/sshd || \
echo "session optional pam_exec.so /usr/local/bin/ssh-login-alert.sh" >> /etc/pam.d/sshd

### ===== SSH HARDEN =====
sed -i "s/#Port 22/Port $SSH_PORT/" /etc/ssh/sshd_config
sed -i "s/^#\?PermitRootLogin.*/PermitRootLogin no/" /etc/ssh/sshd_config
sed -i "s/^#\?PasswordAuthentication.*/PasswordAuthentication yes/" /etc/ssh/sshd_config
sed -i "s/^#\?PubkeyAuthentication.*/PubkeyAuthentication yes/" /etc/ssh/sshd_config
sed -i "s/^#\?UseDNS.*/UseDNS no/" /etc/ssh/sshd_config

### ===== FIREWALL =====
ufw default deny incoming
ufw default allow outgoing
ufw allow "$SSH_PORT/tcp"
ufw --force enable

systemctl restart ssh

### ===== FAIL2BAN =====
systemctl enable fail2ban
systemctl start fail2ban

cat > /etc/fail2ban/jail.local <<EOF
[sshd]
enabled = true
port = $SSH_PORT
maxretry = 5
findtime = 10m
bantime = 1h
action = telegram
EOF

cat > /etc/fail2ban/action.d/telegram.conf <<EOF
[Definition]
actionban = /usr/local/bin/telegram.sh "🚫 <b>Fail2Ban</b>\nIP: <ip>\nJail: <name>"
EOF

systemctl restart fail2ban

### ===== KERNEL HARDEN =====
cat >> /etc/sysctl.conf <<EOF
net.ipv4.tcp_syncookies = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
EOF
sysctl -p

### ===== REBOOT ALERT =====
grep -q telegram.sh /etc/crontab || \
echo "@reboot root /usr/local/bin/telegram.sh '🔄 <b>Server rebooted</b>'" >> /etc/crontab

### ===== FINAL REPORT =====
/usr/local/bin/telegram.sh "✅ <b>SECURITY SETUP COMPLETED</b>

🖥 Host: $HOSTNAME
🌐 IP: $SERVER_IP

👤 User: <code>$NEW_USER</code>
🔑 Password: <code>$NEW_PASSWORD</code>
🔐 SSH Port: <code>$SSH_PORT</code>

⏱ Timezone: $TIMEZONE
🛡 Firewall: ENABLED
🚫 Fail2Ban: ENABLED
📡 SSH Notify: ENABLED
"
