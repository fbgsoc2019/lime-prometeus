local class = require '30log'


local Server = class('Server')

function Server:init()
  self.instruments = {}
  return self
end

--- Add some instrument to the server
-- @param instrument Intrument class instance
function Server:add_instrument(instrument)
  self.instruments[#self.instruments + 1] = instrument
end

---
function Server:response()
  local response = 'Server: lua-metrics\r\nContent-Type: text/plain; charset=utf-8\r\n\r\n'
  for _, instrument in pairs(self.instruments) do
    instrument:read()
    response = response .. tostring(instrument)
    -- response = tostring(instrument)
  end

  return response
end

return Server
