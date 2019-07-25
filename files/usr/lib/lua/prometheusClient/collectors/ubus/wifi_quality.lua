require 'ubus'
require 'iwinfo'
local Instrument = require 'prometheusClient.instrument'


local function measure(metric)
  local conn = ubus.connect()
  local devices = conn:call("uci", "get", { config="wireless",
                            type="wifi-iface"})

  -- Get all the wifi interfaces names
  local ifaces = {}
  for iface, iface_conf in pairs(devices.values) do
          table.insert(ifaces, iface_conf.ifname)
  end

  for i, iface in ipairs(ifaces) do
    local mode = iwinfo.nl80211.mode(iface)
    local channel = iwinfo.nl80211.channel(iface)

    metric:set(iwinfo.nl80211.quality(iface), { channel, mode })
  end

  -- Close connection
  conn:close()

  return metric
end

--
local function wifi_quality()
  local inst = Instrument('gauge', measure, 'wifi_quality',
                          'Quality of the wifi link',
                          { 'channel', 'mode' })
  return inst
end

return wifi_quality
