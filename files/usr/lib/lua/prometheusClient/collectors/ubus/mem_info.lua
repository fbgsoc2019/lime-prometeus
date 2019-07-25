-- Use of memory (total, free, shared and buffered)

require 'ubus'
local Instrument = require 'prometheusClient.instrument'


local function measure(metric)
  -- Establish connection
  local conn = ubus.connect()
  local info = conn:call('system', 'info', { })

  for name, value in pairs(info.memory) do
    if name ~= 'total' then
      metric:set(value, { name })
    end
  end

  -- Close connection
  conn:close()

  return metric
end

--
local function mem_info()
  local inst = Instrument('gauge', measure, 'memory_use',
                          'Use of the memory', { 'type' })
  return inst
end

return mem_info
