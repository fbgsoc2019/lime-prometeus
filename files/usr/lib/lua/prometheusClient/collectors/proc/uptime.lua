-- Uptime and idle of the cpu from /proc/uptime

local Instrument = require 'prometheusClient.instrument'


local function measure(metric)
  local up
  local idle
  local line = io.input('/proc/uptime'):read()
  up, idle = string.match(line, '(%d+%.%d+) (%d+%.%d+)')

  metric:set(up, { 'uptime' })
  metric:set(idle, { 'idle' })

  return metric
end


local function uptime()
  return Instrument('gauge', measure, 'cpu_uptime', 'CPU uptime on seconds',
                    { 'type' })
end

return uptime
