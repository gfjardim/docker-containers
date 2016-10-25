# Load default values if empty
VNC_PORT=${TCP_PORT_4239:-4239}
WEB_PORT=${TCP_PORT_4280:-4280} 
BACKUP_PORT=${TCP_PORT_4242:-4242}
SERVICE_PORT=${TCP_PORT_4243:-4243}
VNC_CREDENTIALS=/nobody/.vnc_passwd

APP_NAME="CrashPlan ${CP_VERSION}"

if [[ -n $VNC_PASSWD ]]; then
  VNC_SECURITY="SecurityTypes TLSVnc,VncAuth -PasswordFile ${VNC_CREDENTIALS}"
else
  VNC_SECURITY="SecurityTypes None"
fi
