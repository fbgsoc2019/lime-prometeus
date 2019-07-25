local class = require '30log'

local inf = 1/0

--- Validate a name of metric or label following the prometheus best practices
-- @local
-- @param name Name to validate
-- @param type Type of field. Can by 'name' or 'label'
-- @raise Invalid name. Must follow the pattern '^[a-zA-Z][a-zA-Z0-9_:]*$'
local function is_valid_name (name, type)
  local text = [===[
  "%s" is invalid metric %s. Must starts with a letter and follow
  the pattern %s
  ]===]

  local pattern
  if type == 'name' then
    pattern = '^[a-zA-Z_:][a-zA-Z0-9_:]*$'
  else
    pattern = '^[a-zA-Z_][a-zA-Z0-9_]*$'
  end

  if not name:match(pattern) then
    error(text:format(name, type, pattern), 2)
  end

  return true
end

--- Generate the key given the metrics labels
-- @param labels
-- @param valid_labels
-- @return
function generate_key(labels, valid_labels)
  -- create a table key
  local key
  for i, v in pairs(labels) do
    local partial = string.format('%s="%s"', valid_labels[i], v)
    if not key then
      key = partial
    else
      key = key .. ',' .. partial
    end
  end

  if #valid_labels == 0 then
    key = '_'
  end

  return key
end


local default_buckets = { 0.005, 0.01, 0.025, 0.05, 0.075, 0.1, 0.25,
  0.5, 0.75, 1.0, 2.5, 5.0, 7.5, 10.0, inf }

function generate_buckets(start, stop, amount, kind)

end

--- Base class of Counter and Gauge metrics
-- @classmod BaseMetric
local BaseMetric = class('BaseMetric')

--- Create a new BaseMetric
-- @param type Type of the new metric. Can be 'counter' or 'gauge'
-- @param name Name of the new metric
-- @param[opt=''] docstring Metric description
-- @param[opt={}] labels Labels of the metric
-- @return New Counter instance
-- @raise Invalid name. Must follow the pattern '^[a-zA-Z][a-zA-Z0-9_:]*$'
function BaseMetric:init(type, name, docstring, labels)
  -- Check metric name according to the best practices
  is_valid_name(name, 'name')

  local suffixes = { '_sum', '_count', '_bucket' }
  if type ~= 'counter' then suffixes[#suffixes + 1] = '_total' end

  for _, suffix in ipairs(suffixes) do
    if name:sub(-#suffix) == suffix then
      error(string.format('"%s" is invalid metric name. Cant end with %s',
       name, suffix), 2)
    end
  end

  -- Check metric labels according to the best practices
  if labels then
    for i, label in ipairs(labels) do
      is_valid_name(label, 'label')
    end
  end

  -- Initialize
  self.name = name
  self.docstring = docstring or ''
  self.__type = type
  self.__values = {}
  self.__labels = labels or { }

  return self
end

--- Increment the BaseMetric value. If the metric have labels, pass it
-- @param value Value to add. If not specific, this is 1.
-- @param labels[opt={}]
-- @return The Counter instance
-- @raise Counters can only be incremented by non-negative amounts
-- @raise Unspecified labels
function BaseMetric:inc(value, labels)
  local value = value or 1
  local labels = labels or { }

  if self.__type == 'counter' and value < 0 then
    error('Counters can only be incremented by non-negative amounts')
  end

  if #labels ~= #self.__labels then
    error('Unspecified labels')
  end

  -- Values table key
  local key = generate_key(labels, self.__labels)

  -- If the label dont exist, init it
  if not self.__values[key] then
    self.__values[key] = { 0, nil }
  end

  local timestamp = os.time()
  self.__values[key] = { self.__values[key][1] + value, timestamp }

  return self
end

--- Set the value of the BaseMetric
-- @param value New value to set
-- @param labels
function BaseMetric:set (value, labels)
  local labels = labels or { }

  if #labels ~= #self.__labels then
    error('Unspecified labels')
  end

  -- Values table key
  local key = generate_key(labels, self.__labels)

  local timestamp = os.time()
  self.__values[key] = { value, timestamp }
end

--- Given a labels, return the value on the Counter
-- @param labels Labels uses on the Counter
-- @return Value and timestamp
function BaseMetric:value(labels)
  local labels = labels or { }

  -- Values table key
  local key = generate_key(labels, self.__labels)

  if self.__values[key] then
    return table.unpack(self.__values[key])
  else
    return nil, nil
  end
end

--- String representation of the couter using the prometheus exposition formats
-- @return String with the exposition format of the Counter
function BaseMetric:__tostring()
  local line = ''

  if #self.__labels == 0 then
    line = string.format('%s %g\n', self.name, self.__values._[1])
  else
    for labels, val in pairs(self.__values) do
      line = line .. string.format('%s{%s} %g\n', self.name,
      labels, val[1])
    end
  end

  -- Remove last line break
  line = line:sub(1, -2)

  return string.format([===[
# HELP %s %s
# TYPE %s %s
%s
]===], self.name, self.docstring, self.name, self.__type, line)
end


local Counter = BaseMetric:extend()

--- Counter metric
-- @param name Name of the new metric
-- @param[opt=''] docstring Metric escription
-- @param[opt={}] labels Labels of the metric
-- @return New Counter instance
-- @raise Invalid name. Must follow the pattern '^[a-zA-Z][a-zA-Z0-9_:]*$'
function Counter:init(name, docstring, labels)
  Counter.super.init(self, 'counter', name, docstring, labels)

  if name:sub(-#'_total') ~= '_total' then
    name = name .. '_total'
  end

  self.name = name
  return self
end


local Gauge = BaseMetric:extend()

--- Gauge metric
-- @param name Name of the new metric
-- @param[opt=''] docstring Metric escription
-- @param[opt={}] labels Labels of the metric
-- @return New Gauge instance
-- @raise Invalid name. Must follow the pattern '^[a-zA-Z][a-zA-Z0-9_:]*$'
function Gauge:init(name, docstring, labels)
  Gauge.super.init(self, 'gauge', name, docstring, labels)

  return self
end

--- Decrement the Gauge
-- @param value Value to decrement. If not specific, this is 1.
-- @param labels[opt={}]
-- @raise Unspecified labels
function Gauge:dec (value, labels)
  self:inc(-value, lables)

  return self
end


local Histogram = class('Histogram')

function Histogram:init(name, docstring, buckets)
  -- Check metric name according to the best practices
  is_valid_name(name, 'name')

  local suffixes = { '_sum', '_count', '_bucket' }
  if type ~= 'counter' then suffixes[#suffixes + 1] = '_total' end

  for _, suffix in ipairs(suffixes) do
    if name:sub(-#suffix) == suffix then
      error(string.format('"%s" is invalid metric name. Cant end with %s',
       name, suffix), 2)
    end
  end

  self.name = name
  self.docstring = docstring or ''
  self.upper_bounds = buckets or default_buckets
  self.__type = 'histogram'
  self.count = 0
  self.sum = 0

  self.__values = { }
  for i, bound in ipairs(self.upper_bounds) do
    self.__values[i] = 0
  end

end

function Histogram:observe(value)
  self.count = self.count + 1
  self.sum = self.sum + value

  for i, bound in ipairs(self.upper_bounds) do
    if value <= bound then
      self.__values[i] = self.__values[i] + 1
    end
  end
end

function Histogram:__tostring()
  local line = ''

  for i, bound in ipairs(self.upper_bounds) do
    line = line .. string.format('%s{le="%s"} %g\n', self.name,
    tostring(bound):gsub('inf', '+Inf'), self.__values[i])
  end

  -- Remove last line break
  line = line:sub(1, -2)

  return string.format([===[
# HELP %s %s
# TYPE %s %s
%s
%s_sum %s
%s_count %s
  ]===], self.name, self.docstring, self.name, self.__type, line,
  self.name, self.sum, self.name, self.count)
end

return {
  Counter = Counter,
  Gauge = Gauge,
  Histogram = Histogram,
  generate_buckets = generate_buckets
}
