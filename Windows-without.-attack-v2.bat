@echo off 
echo.
echo =====" Windows   0days   without   Attack "=====
echo.
echo =====" Firewall Disabled Port 139 137 445 "=====
echo.
echo "����139�˿�"
netsh advfirewall firewall add rule name="139-drop-tcp" protocol=TCP dir=in localport=139 action=block >nul
netsh advfirewall firewall add rule name="139-drop-udp" protocol=UDP dir=in localport=139 action=block >nul
echo "�ر�139�˿ڳɹ�"
echo.
echo "�ر�137�˿�"
netsh advfirewall firewall add rule name="137-drop-tcp" protocol=TCP dir=in localport=137 action=block >nul
netsh advfirewall firewall add rule name="137-drop-udp" protocol=UDP dir=in localport=137 action=block >nul
echo "�ر�137�˿ڳɹ�"
echo.
echo "�ر�445�˿�"
netsh advfirewall firewall add rule name="445-drop-tcp" protocol=TCP dir=in localport=445 action=block >nul
netsh advfirewall firewall add rule name="445-drop-udp" protocol=UDP dir=in localport=445 action=block >nul
echo "�ر�445�˿ڳɹ�"
echo "�رս������ܿ���½����"
sc stop SCPolicySvc >nul
sc stop SCardSvr >nul
sc config SCardSvr start= disabled >nul
sc config SCPolicySvc start= disabled >nul
echo "�رս������ܿ���½���ܳɹ�"
echo.
echo ====="@^_^@"=====
echo.
pause