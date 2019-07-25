--

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

  for i, ifname in ipairs(ifaces) do
    metric:set(iwinfo.nl80211.signal(ifname), { ifname, 'signal' })
    metric:set(iwinfo.nl80211.noise(ifname), { ifname, 'noise' })
    metric:set(iwinfo.nl80211.txpower(ifname), { ifname, 'txpower' })
    metric:set(iwinfo.nl80211.quality(ifname), { ifname, 'quality' })
    metric:set(iwinfo.nl80211.bitrate(ifname), { ifname, 'bitrate' })
  end

  -- Close connection
  conn:close()

  return metric
end

--
local function iwinfo()
  local inst = Instrument('gauge', measure, 'iwinfo',
                          'iwinfo', { 'ifname', 'm' })
  return inst
end

return iwinfo
