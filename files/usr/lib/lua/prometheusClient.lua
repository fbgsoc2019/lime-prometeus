local metrics = require 'prometheusClient.metrics'
local Instrument = require 'prometheusClient.instrument'

return {
  Counter = metrics.Counter,
  Gauge = metrics.Gauge,
  Histogram = metrics.Histogram,
  Instrument = Instrument
}
