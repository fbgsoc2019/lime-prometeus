-- System uptime

require 'ubus'
local Instrument = require 'prometheusClient.instrument'


local function measure(metric)
  -- Establish connection
  local conn = ubus.connect()
  local info = conn:call('system', 'info', { })

  metric:set(info.uptime)

  -- Close connection
  conn:close()

  return metric
end

local function uptime()
  return Instrument('gauge', measure, 'cpu_uptime', 'CPU uptime on seconds')
end

return uptime
