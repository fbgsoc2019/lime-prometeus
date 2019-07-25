local uptime = require 'prometheusClient.collectors.uptime'
local loadavg = require 'prometheusClient.collectors.loadavg'
local mem_info = require 'prometheusClient.collectors.mem_info'
local packages_per_interface = require 'prometheusClient.collectors.packages_per_interface'

return {
    uptime = uptime,
    loadavg = loadavg,
    mem_info = mem_info,
    packages_per_interface = packages_per_interface
}
