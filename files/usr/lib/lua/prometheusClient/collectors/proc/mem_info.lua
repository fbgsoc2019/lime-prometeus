-- Use of memory from /proc/uptime

local Instrument = require 'prometheusClient.instrument'

local valid_fields = { }


local function measure (metric)
  for line in io.lines('/proc/meminfo') do
    local name, size, unit = string.match(line, '([^:]+):%s+(%d+)%s?(k?B?)')

    if valid_fields[name] then
      if unit == 'kB' then
        size = size * 1024
      end

      if name ~= 'MemTotal' then
        metric:set(size, { name })
      end
    end
  end

  return metric
end


local function mem_info(fields)
  local fields = fields or { }

  if fields then
    for _, name in ipairs(fields) do
      valid_fields[name] = true
    end
  end

  local inst = Instrument('gauge', measure, 'memory_use',
                          'Use of the memory', { 'type' })
  return inst
end


return mem_info
