#!/usr/bin/env orbit
local orbit = require"orbit"
local wappcam = orbit.new('wappcam')

wappcam:dispatch_get(
   function(web)                       
      return [[
               <html><head></head>
               <body>
               <h1>TEST</h1>
               </body>
         ]]
   end, "/", "/index")

return wappcam
