local station_cfg={}
station_cfg.ssid="HOME"
station_cfg.pwd="12345679"
station_cfg.save=true

wifi.setmode(wifi.STATION)
wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, function(result)
    print("\nConnected to ".. result.SSID .. " " .. result.BSSID .. " CH:"..tostring(result.channel))
end)
wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(result)
    print("IP:"..result.IP)
    print("GW:"..result.gateway)
    dofile("mqtt.lua")
end)

function reconnect()
    wifi.sta.disconnect()
    wifi.sta.connect()
end

wifi.eventmon.register(wifi.eventmon.STA_DHCP_TIMEOUT, function(result)
    print("DHCP time out")
    reconnect()
end)

wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, function(result)
    print("WiFi disconnected")
    reconnect()
end)

wifi.sta.config(station_cfg)
