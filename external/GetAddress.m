function mac = GetAddress()

if ispc
    fmt = '%02X-%02X-%02X-%02X-%02X-%02X'; 
else
    fmt = '%02x:%02x:%02x:%02x:%02x:%02x';
end

try
    a = Screen('computer');
    mac = a.MACAddress; % works for OSX/Linux for now
    if ~isempty(mac) && sum(mac=='0')<12, return; end
end
if exist('/sys/class/net/eth0/address', 'file') % linux
    [~, mac] = system('cat /sys/class/net/eth0/address');
    if ~isempty(mac) && sum(mac=='0')<12, return; end
end

try % java approach is faster than system command, and is OS independent
    ni = java.net.NetworkInterface.getNetworkInterfaces;
    while ni.hasMoreElements
        a = ni.nextElement.getHardwareAddress;
        if numel(a)~=6 || all(a==0), continue; end % not valid mac
        a = typecast(a, 'uint8'); % from int8
        mac = sprintf(fmt, a);
    end
    if ~isempty(mac), return; end
end
try % system command is slow, use as last resort
    if ispc
        [err, str] = system('getmac.exe');
        expr = '(?<=\s)([0-9A-F]{2}-){5}[0-9A-F]{2}(?=\s)'; % separator -
    else
        [err, str] = system('ifconfig');
        expr = '(?<=\s)([0-9a-f]{2}:){5}[0-9a-f]{2}(?=\s)'; % separator :
    end
    if err, error(str); end % unlikely to happen
    mac = regexp(str, expr, 'match', 'once');
    if ~isempty(mac), return; end
end
a = ones(1,6)*255;
mac = sprintf(fmt, a);
