#!/bin/bash
# Fix ClamAV
#For CPU 100% problem, error fixed, in VESTACP on CENTOS 7 (64)
#This script i was pull from https://github.com/serghey-rodin/vesta/issues/645

cat > /etc/tmpfiles.d/clamav.conf << 'EOF'
d /var/run/clamav 0755 clam clam
EOF

cat > /usr/bin/fixclamd << 'EOF'
#!/bin/bash
# Simple script to create clamd run directory for socket and pid

mkdir /var/run/clamav
chown -R clam.clam /var/run/clamav

exit 0
EOF

cat > /lib/systemd/system/clamd.service << 'EOF'
[Unit]
Description = clamd scanner (clamd) daemon
After = syslog.target nss-lookup.target network.target

[Service]
Type = simple
ExecStartPre = /usr/bin/fixclamd
ExecStart = /usr/sbin/clamd -c /etc/clamd.conf --foreground=yes
Restart = on-failure
PrivateTmp = true

[Install]
WantedBy=multi-user.target
EOF

chmod +x /usr/bin/fixclamd

systemctl daemon-reload
systemctl restart clamd
