-- CPU load average

require 'ubus'
local Instrument = require 'prometheusClient.instrument'

local function measure(metric)
  -- Establish connection
  local conn = ubus.connect()
  local info = conn:call('system', 'info', { })

  local keys = { 'average_1m', 'average_5m', 'average_15m' }

  for i, value in ipairs(info.load) do
      metric:set(value, { keys[i] })
  end

  -- Close connection
  conn:close()

  return metric
end

--
local function mem_info()
  local inst = Instrument('gauge', measure, 'cpu_load_avg',
                          'CPU load', { 'type' })
  return inst
end

return mem_info
