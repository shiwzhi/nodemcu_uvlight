local m = mqtt.Client("esp8266"..tostring(node.chipid(), 120))

local mqtt_prefix = "/shiweizhi/uv"

uv_power = 0;
led_timer = false;
dofile("uv.lua")

local timer = tmr.create()
timer:register(1000, tmr.ALARM_AUTO,
function()
    m:publish(
        mqtt_prefix.."/power_status",
        tostring(uv_power),
        0,
        0
    )
end)


local stop_timer = tmr.create()
local stop_timer_timestamp = 0;
local stop_timer_interval = 0;

local stop_timer_poster = tmr.create()
stop_timer_poster:register(1000, tmr.ALARM_AUTO, 
function()
    if led_timer then
        m:publish(
                mqtt_prefix.."/time_status",
                math.floor(((stop_timer_timestamp+stop_timer_interval*1000*1000) - tmr.now()) /1000/1000),
                2,
                0
        )
    end
end)

m:on("connect", 
function() 
    print("MQTT connected")
    timer:start()
    print("Start upload status")
    m:subscribe({[mqtt_prefix.."/power"]=2, [mqtt_prefix.."/time"]=2}, 
    function(conn) 
        print("MQTT subscribed")
        m:publish(
                mqtt_prefix.."/time_status",
                tostring(0),
                2,
                0
        )
    end)
end)

m:on("message",
function(client, topic, msg)
    print("Recive: "..topic .. " ".. msg)
    if (topic == mqtt_prefix.."/power") then
        if (msg == "0" or msg == "1") then 
            uv_power = tonumber(msg)
            stop_timer_poster:stop()
            m:publish(
                mqtt_prefix.."/time_status",
                tostring(0),
                2,
                0
            )
        end
    end

    if (topic == mqtt_prefix.."/time") then
        if msg == "0" then
            uv_power = 0
            stop_timer:stop()
            stop_timer_poster:stop()
            led_timer = false
            m:publish(
                mqtt_prefix.."/time_status",
                tostring(0),
                2,
                0
            )
            return;
        end

        uv_power = 1
        stop_timer:unregister()
        stop_timer:register(tonumber(msg)*1000, tmr.ALARM_SINGLE, function()
            uv_power = 0
            led_timer = false
            stop_timer_poster:stop()
            m:publish(
                mqtt_prefix.."/time_status",
                tostring(0),
                2,
                0
            )
            print("Timer stopped")
            
        end)
        stop_timer:start()
        led_timer = true
        stop_timer_timestamp = tmr.now()
        stop_timer_interval = tonumber(msg)
        stop_timer_poster:stop()
        stop_timer_poster:start()
        print("Timer started")
    end
end
)

m:on("offline",
function()
    timer:stop()
    m:connect("broker.hivemq.com", 1883, false)
end
)


m:connect("broker.hivemq.com", 1883, false)