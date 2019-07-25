require 'ubus'
require 'iwinfo'
local Instrument = require 'prometheusClient.instrument'

local function measure(metric)
  local conn = ubus.connect()

  -- Get all the wifi interfaces names
  local ifaces = {}
  local devices = conn:call('uci', 'get', { config='wireless', type='wifi-iface'})
  for iface, iface_conf in pairs(devices.values) do
    table.insert(ifaces, iface_conf.ifname)
  end

  --
  local status = conn:call('network.device', 'status', { })

  for i, ifname in pairs(ifaces) do
    for key, value in pairs(status[ifname].statistics) do
      metric:set(value, { ifname, key })
    end
  end

  -- Close connection
  conn:close()

  return metric
end

--
local function packages_per_interface()
  local inst = Instrument('gauge', measure, 'packages_per_interface',
                          'Amount of packages on each interface',
                          { 'interface', 'type' })
  return inst
end

return packages_per_interface
