local uptime = require 'prometheusClient.collectors.proc.uptime'
local load_avg = require 'prometheusClient.collectors.proc.load_avg'
local mem_info = require 'prometheusClient.collectors.proc.mem_info'
local packages_per_interface = require 'prometheusClient.collectors.proc.packages_per_interface'

return {
  uptime = uptime,
  load_avg = load_avg,
  mem_info = mem_info,
  packages_per_interface = packages_per_interface
}
