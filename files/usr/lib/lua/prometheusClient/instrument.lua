local class = require '30log'
local metrics = require 'prometheusClient.metrics'

local valid_metrics = { counter = true, gauge = true,
  summary = true, histogram = true }


--- Instrument class
local Instrument = class('Instrument')

--- Create a new instrument to measure some promerty
-- @param metric Kind of metric. Can be 'counter', 'gauge', 'summary' or 'histogram'
-- @param name Name of the metric
-- @param docstring Description of the metric
-- @param ext Label or buckets depending the metric
-- @param measure Function that performs the measurement
-- @return New Instrument instance
function Instrument:init(metric, measure, name, docstring, ext)
  if not valid_metrics[metric] then
    error('Invalid kind of metric. Can be "counter", "gauge", "summary" or "histogram"', 2)
  end

  metric = metric:gsub("^%l", string.upper)

  self.metric = metrics[metric](name, docstring, ext)
  self.measure = measure

  return self
end

--- Make the measure
function Instrument:read()
  self.metric = self.measure(self.metric)
end

--- Get the metric str representation follow the prometheus exposition formats
function Instrument:__tostring()
  return self.metric:__tostring()
end


return Instrument
