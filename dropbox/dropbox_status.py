#!/usr/bin/python
# Filip Lundborg (filip@mkeyd.net)
import socket,os

# All the different daemon-states
state={\
  "0": "Up to date", \
  "1": "Synchronizing", \
  "2": "Not connected", \
  "NA": "Not available" \
    # except for that last one
    # it's for when we're not connected to the daemon.
  }

class DB():
  def __init__(self):
    self.connected=False
    self.state="NA"
  def connect(self):
    # try to connect
    try:
      self.cmd=socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
      self.iface=socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)

      self.cmd.connect(os.path.expanduser("~/.dropbox/command_socket"))
      self.iface.connect(os.path.expanduser("~/.dropbox/iface_socket"))
    except Exception,e:
      return False

    # alright, so we're connected to both sockets
    self.connected=True
    self.tmp=""
    return True
  
  def get_state(self):
    "Waits for a state change, and then returns it."
    if not self.connected:
      return state["NA"]

    tmp=self.tmp
    flg=False
    while True:
      t=self.iface.recv(1024)

      if t=="":
        self.connected=False
        return state["NA"]
      tmp+=t

      res=tmp.split("done\n")
      self.tmp=tmp=res[-1] # put the rest back in tmp
      res=res[:-1] # and just take the whole commands

      for s in res:
        if s.startswith("shell_touch") and os.path.isfile(s[17:-1]):
          print "File: "+ s[17:-1]
        if s.startswith("change_state"):
          flg=True
          self.state=s[23] 

      if flg:
        return self.state


if __name__=="__main__":
  import time
  db=DB()
  last = ""

  while True:
    if not db.connect():
      time.sleep(1) # to not wear out the CPU ;)
    while db.connected:
      current = db.get_state()
      if current != last:
        print state[current]
        last = current
