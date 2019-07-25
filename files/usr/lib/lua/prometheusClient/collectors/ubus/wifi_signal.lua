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

    metric:set(iwinfo.nl80211.signal(iface), { channel, mode, 'signal' })
    metric:set(iwinfo.nl80211.noise(iface), { channel, mode, 'noise' })
    metric:set(iwinfo.nl80211.txpower(iface), { channel, mode, 'txpower' })
  end

  -- Close connection
  conn:close()

  return metric
end

--
local function wifi_signal()
  local inst = Instrument('gauge', measure, 'wifi_signal_db',
                          'Signal of all wifi interfaces in db',
                          { 'channel', 'mode', 'type' })
  return inst
end

return wifi_signal
