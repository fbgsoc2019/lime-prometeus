require 'ubus'
require 'iwinfo'
local Instrument = require 'prometheusClient.instrument'

local keys = { 'tx_fifo_errors', 'tx_heartbeat_errors', 'tx_aborted_errors',
               'tx_window_errors', 'tx_carrier_errors', 'rx_fifo_errors',
               'rx_frame_errors', 'rx_length_errors', 'rx_missed_errors',
               'rx_over_errors', 'rx_crc_errors' }

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
      metric:set(status[iface].statistics[key], { channel, mode, key})
    end
  end

  -- Close connection
  conn:close()

  return metric
end

--
local function wifi_errors()
  local inst = Instrument('counter', measure, 'wifi_errors',
                          'tx/rx errors by wifi interface',
                          { 'channel', 'mode', 'type' })
  return inst
end

return wifi_errors
