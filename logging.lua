-- Copyright (C) 2012 Matthieu Tourne
-- @author Matthieu Tourne <matthieu@cloudflare.com>

-- Simple helper functions for logging

local logging = {}

local module = logging

local function incr(dict, key, increment)
   increment = increment or 1
   local newval, err = dict:incr(key, increment)
   if err then
      dict:set(key, increment)
      newval = increment
   end
   return newval
end

function logging.add_plot(dict, key, value)
   local sum_key = key .. "-sum"
   local count_key = key .. "-count"
   local start_time_key = key .. "-start_time"

   local start_time = dict:get(start_time_key)
   if not start_time then
      ngx.log(ngx.ERR, 'now: ', ngx.now())
      dict:set(start_time_key, ngx.now())
   end

   local sum = incr(dict, sum_key, value)
   incr(dict, count_key)
end

function logging.get_plot(dict, key)
   local sum_key = key .. "-sum"
   local count_key = key .. "-count"
   local start_time_key = key .. "-start_time"

   local elapsed_time = 0
   local avg = 0

   local start_time = dict:get(start_time_key)
   if start_time then
      elapsed_time = ngx.now() - start_time
   end
   dict:delete(start_time_key)

   local count = dict:get(count_key) or 0
   dict:delete(count_key)

   local sum = dict:get(sum_key) or 0
   dict:delete(sum_key)

   if count > 0 then
      avg = sum / count
   end

   return count, avg, elapsed_time
end


-- safety net
local module_mt = {
   __newindex = (
      function (table, key, val)
         error('Attempt to write to undeclared variable "' .. key .. '"')
      end),
}

setmetatable(module, module_mt)

-- expose the module
return logging
