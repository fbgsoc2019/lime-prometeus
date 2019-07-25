-- more /proc/net/dev

local Instrument = require 'prometheusClient.instrument'

-- Create the array ot modes (receive or transmit) and the type. The main idea
-- is avoid the if
local types = { 'bytes', 'packets', 'errs', 'drop', 'fifo', 'frame',
  'compressed', 'multicast', 'bytes', 'packets', 'errs', 'drop', 'fifo',
  'colls', 'carrier', 'compressed' }

local modes = {}
for i = 1, 8, 1 do
  modes[#modes + 1] = 'receive'
end
for i = 1, 8, 1 do
  modes[#modes + 1] = 'transmit'
end

--- Read the /proc/net/dev and set the news values
-- @param metric Counter instance
-- @return The update Counter instance
function packages_measure(metric)
  local interface_name
  local rest

  -- Skip the first two lines
  local iter = io.lines('/proc/net/dev')
  iter()
  iter()

  -- Get the interface name
  for line in iter do
    interface_name, rest = string.match(line, '([a-zA-z0-9]+): (.+)')

    -- Split the values
    local values = {}
    for val in string.gmatch(rest, '(%d+)') do
      values[#values + 1] = tonumber(val)
    end

    -- Update the values
    for i, mode in ipairs(modes) do
      metric:set(values[i], { interface_name, mode, types[i] })
    end
  end

  return metric
end


function packages_per_interface()
  return Instrument('gauge', packages_measure, 'packages_per_interface',
  'Amount of packages on each interface', { 'interface', 'mode', 'type' })
end

return packages_per_interface
