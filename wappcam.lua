#!/usr/bin/env orbit
local orbit = require"orbit"
local wappcam = orbit.new('wappcam')

wappcam:dispatch_static('.+')

return wappcam
