require 'ubus'
require 'iwinfo'
local Instrument = require 'prometheusClient.instrument'

local keys = { 'packets', 'dropped', 'errors', 'compressed'}

local function measure(metric)
  local conn = ubus.connect()

  -- Get all the wifi interfaces names
  local ifaces = {}
  local devices = conn:call('uci', 'get', { config='wireless',
                            type='wifi-iface'})
  for iface, iface_conf in pairs(devices.values) do
    table.insert(ifaces, iface_conf.ifname)
  end

  --
  local status = conn:call('network.device', 'status', { })

  for i, iface in pairs(ifaces) do
    local mode = iwinfo.nl80211.mode(iface)
    local channel = iwinfo.nl80211.channel(iface)

    for _, key in ipairs(keys) do
      metric:set(status[iface].statistics['rx_' .. key], { channel, mode, 'rx_' .. key})
      metric:set(status[iface].statistics['tx_' .. key], { channel, mode, 'tx_' .. key})
    end
  end

  -- Close connection
  conn:close()

  return metric
end

--
local function wifi_bytes_total()
  local inst = Instrument('counter', measure, 'wifi_bytes_total',
                          'Total bytes tx/rx by wifi interface',
                          { 'channel', 'mode', 'type' })
  return inst
end

return wifi_bytes_total
