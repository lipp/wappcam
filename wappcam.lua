#!/usr/bin/env lua
cv=require('luacv')
require('orbit')
local wappcam = orbit.new('wappcam')

--[[local getindex = 
  function()
    local fileindex = io.open('static/index.html')
    local index = fileindex:read('*a')
  return index
end]]--

local loadimage = 
  function(path)
    local image = cv.LoadImage(path)
    return image
  end	

local getimage =  
  function(web)
    local imageindex = web.GET.file
    local gainconst = web.GET.gain
    local shutterconst = web.GET.shutter

    local image = loadimage('static/'..imageindex..'.jpg')
    local noise = loadimage('static/noise.jpg')

    local shutter = 50+(shutterconst-100)
    local gain  = 1-(gainconst/100)

    local noise_resize = cv.CloneImage(image)
    local dst = cv.CloneImage(image)
    cv.Resize(noise,noise_resize)
    cv.AddWeighted(image,1,noise_resize,gain,shutter,dst)
    web.headers['Content-Type'] = 'image/jpeg'
    web.headers['Content-Length'] = #image
  return image 
end

--[[local getcam =
	function()
	local filecam = io.open('static/lkdemo.lua')
	local cam= filecam:read('*a')
    --web.headers['Content-Type'] = 'image/jpeg'
    --web.headers['Content-Length'] = #image
  return cam 
end]]--


wappcam:dispatch_get(getimage,'/image')
wappcam:dispatch_static('/static/.+')
--wappcam:dispatch_get(getindex,'/')
--wappcam:dispatch_get(getcam,'/cam')

return wappcam
