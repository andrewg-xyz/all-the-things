# ubuntu desktop

1. manually create VM from ISO
2. configure X11 Forwarding
   1. Server (ubuntu)
      1. /etc/ssh/sshd_config 
        ```
            X11Forwarding yes
            X11DisplayOffset 10
         ```   
    2. Client (mac)
        1. export DISPLAY=:0
        2. ssh -X user@server

X11 and VNC connections perform poorly. RDP has better performance.