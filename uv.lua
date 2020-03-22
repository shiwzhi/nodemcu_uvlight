local uv = 5
local uv_led = 0

gpio.mode(uv, gpio.OUTPUT)
gpio.mode(uv_led, gpio.OUTPUT)

local timer = tmr.create()

local led_status = function() 
    if uv_power == 0 then
        return gpio.HIGH
    else 
        return gpio.LOW
    end
end

timer:register(200, tmr.ALARM_AUTO,
function()
    gpio.write(uv_led, led_status())
    gpio.write(uv, uv_power)
end)

timer:start()


local timer_led_pin = 4
local timer_led_status = 1
gpio.mode(timer_led_pin, gpio.OUTPUT)
gpio.write(timer_led_pin, timer_led_status)

local timer_led = tmr.create()
timer_led:register(1000, tmr.ALARM_AUTO, 
function()
    if led_timer then
        if timer_led_status == 1 then timer_led_status = 0 else timer_led_status = 1 end
        gpio.write(timer_led_pin, timer_led_status)
    else
        timer_led_status = 1
        gpio.write(timer_led_pin, timer_led_status)
    end
end)
timer_led:start()
