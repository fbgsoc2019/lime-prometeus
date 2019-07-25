-- Carga media cpu
-- /proc/loadavg
-- promedio carga ultimo minuto, 5 min, 10 min, nan, cantidad de procesos

local Instrument = require 'prometheusClient.instrument'

--- Parser /proc/uptime to get the uptime
function load_measure(metric)
  local average_1m
  local average_5m
  local average_10m
  local nan
  local amount_process

  local line = io.input('/proc/loadavg'):read()
  average_1m, average_5m, average_10m, nan, amount_process = string.match(line,
    '(%d+%.%d+) (%d+%.%d+) (%d+%.%d+) (%d+%/%d+) (%d+)')

  metric:set(average_1m, { 'average_1m' })
  metric:set(average_5m, { 'average_5m' })
  metric:set(average_10m, { 'average_10m' })
  metric:set(amount_process, { 'amount_process' })

  return metric
end

function loadavg()
  return Instrument('gauge', load_measure, 'cpu_load_avg', 'CPU load', { 'type' })
end

return loadavg
