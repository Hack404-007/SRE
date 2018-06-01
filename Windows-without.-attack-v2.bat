@echo off 
echo.
echo =====" Windows   0days   without   Attack "=====
echo.
echo =====" Firewall Disabled Port 139 137 445 "=====
echo.
echo "禁用139端口"
netsh advfirewall firewall add rule name="139-drop-tcp" protocol=TCP dir=in localport=139 action=block >nul
netsh advfirewall firewall add rule name="139-drop-udp" protocol=UDP dir=in localport=139 action=block >nul
echo "关闭139端口成功"
echo.
echo "关闭137端口"
netsh advfirewall firewall add rule name="137-drop-tcp" protocol=TCP dir=in localport=137 action=block >nul
netsh advfirewall firewall add rule name="137-drop-udp" protocol=UDP dir=in localport=137 action=block >nul
echo "关闭137端口成功"
echo.
echo "关闭445端口"
netsh advfirewall firewall add rule name="445-drop-tcp" protocol=TCP dir=in localport=445 action=block >nul
netsh advfirewall firewall add rule name="445-drop-udp" protocol=UDP dir=in localport=445 action=block >nul
echo "关闭445端口成功"
echo "关闭禁用智能卡登陆功能"
sc stop SCPolicySvc >nul
sc stop SCardSvr >nul
sc config SCardSvr start= disabled >nul
sc config SCPolicySvc start= disabled >nul
echo "关闭禁用智能卡登陆功能成功"
echo.
echo ====="@^_^@"=====
echo.
pause