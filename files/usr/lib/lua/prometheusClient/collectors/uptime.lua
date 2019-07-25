-- Uptime and idle of the cpu

local Instrument = require 'prometheusClient.instrument'

--- Parser /proc/uptime to get the uptime
function up_measure(metric)
  local up
  local idle
  local line = io.input('/proc/uptime'):read()
  up, idle = string.match(line, '(%d+%.%d+) (%d+%.%d+)')

  metric:set(up, { 'uptime' })
  metric:set(idle, { 'idle' })

  return metric
end

function uptime()
  return Instrument('gauge', up_measure, 'cpu_uptime', 'CPU uptime on seconds', { 'type' })
end

return uptime
