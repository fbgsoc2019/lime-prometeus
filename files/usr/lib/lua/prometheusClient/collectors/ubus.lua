local uptime = require 'prometheusClient.collectors.ubus.uptime'
local load_avg = require 'prometheusClient.collectors.ubus.load_avg'
local mem_info = require 'prometheusClient.collectors.ubus.mem_info'
local wifi_signal = require 'prometheusClient.collectors.ubus.wifi_signal'
local wifi_quality = require 'prometheusClient.collectors.ubus.wifi_quality'
local wifi_bit_rate = require 'prometheusClient.collectors.ubus.wifi_bit_rate'
local wifi_bytes_total = require 'prometheusClient.collectors.ubus.wifi_bytes_total'
local wifi_packets = require 'prometheusClient.collectors.ubus.wifi_packets'
local wifi_errors = require 'prometheusClient.collectors.ubus.wifi_errors'

return {
  uptime = uptime,
  load_avg = load_avg,
  mem_info = mem_info,
  wifi_signal = wifi_signal,
  wifi_quality = wifi_quality,
  wifi_bit_rate = wifi_bit_rate,
  wifi_bytes_total = wifi_bytes_total,
  wifi_packets = wifi_packets,
  wifi_errors = wifi_errors
}
