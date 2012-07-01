#!/usr/bin/env orbit
-- Wappcam v.1.0
-- Program uses Orbit framework to create a webserver, which 
-- returns static content and also dynamic content (if requested).
-- It Tries to access the default camera via OpenCV.
-- If no default camera is found, it returns a fake image.
--
-- Dynamic Html-Requests:
-- '/image' -> returns a new camera image, with current properties or last properties
-- '/image?{PROPERTY1}=xx&{PROPERTY2}=yy&...' -> returns a new camera image, with requested properties
-- Properties: gain, brightness, contrast, saturation, format

local cv_load_ok, cv = pcall(require,'luacv')
cv=require('luacv')
require('orbit')

local cam
if cv_load_ok then
   -- if camera is available, its signal is returned
   cam = cv.CreateCameraCapture(-1)
   -- width properties, valid values e.g.: 640, 320
   cv.SetCaptureProperty(cam,cv.CV_CAP_PROP_FRAME_WIDTH, 320)
   -- height properties, valid values e.g.: 480, 240
   cv.SetCaptureProperty(cam,cv.CV_CAP_PROP_FRAME_HEIGHT, 240)
   print(cam)
end

-- new wappcam object
local wappcam = orbit.new('wappcam')

-- set defaults
local gain = 0
local shutter = 50
local brightness = 50
local contrast = 50
local saturation = 50
local format = 'jpg'

-- table for last camera settings
local options_old = {}

-- function to normalize the values of the camera settings
local normalize = function(para)
   if  para > 100 then
      para= 100
   elseif para < 0 then
      para = 0
   end
   return para
end

-- function to redirect an "empty" url to index.html
local redirectindex = function(web)
   web:redirect('/index.html')
   return 
end	

-- internal buffers of the camera get emptied
local skip_old = function()
   print('skipping old frames')
   cv.QueryFrame(cam)
   cv.QueryFrame(cam)
   cv.QueryFrame(cam)
   cv.QueryFrame(cam)
end

-- function to select the plugged camera || returns the camera image
local get_camera_image = function(camname, options)    
   
   -- last options get applied (if different from new ones)
   if options_old.gain ~= options.gain then
      cv.SetCaptureProperty(cam,cv.CV_CAP_PROP_GAIN, options.gain/100)
   end
   if options_old.brightness ~= options.brightness then 
      cv.SetCaptureProperty(cam,cv.CV_CAP_PROP_BRIGHTNESS, (options.brightness)/100)
   end
   if options_old.contrast ~= options.contrast then 
      cv.SetCaptureProperty(cam,cv.CV_CAP_PROP_CONTRAST, (options.contrast)/100)
   end
   if options_old.saturation ~= options.saturation then 
      cv.SetCaptureProperty(cam,cv.CV_CAP_PROP_SATURATION, (options.saturation)/100)
   end

   -- if single button gets pushed, the internal memory buffer gets deleted and
   if options.skip_buffered_images then
      -- the newest capture is returned
      skip_old()
   end
   local image = cv.QueryFrame(cam)    
   local encoded = cv.EncodeImage('.'..options.format,image)
   local data = cv.MatToDataString(encoded)
   
   -- saves the values of the camera setting
   options_old.gain = options.gain	
   options_old.shutter = options.shutter
   options_old.brightness = options.brightness
   options_old.contrast = options.contrast
   options_old.saturation = options.saturation

   -- renames value for server-client communication
   if options.format == 'jpg' then
      options.format = 'jpeg'
   end

   -- returns image and its format
   return data,options.format
end

-- fake-/errorpicture for maintenance
local make_fake_image = function(imagename, options)
   -- loads in the picture
   local src = cv.LoadImage('img/test.jpg')
   -- load a synthetic noisepicture (gain-imitation)
   local noise = cv.LoadImage('img/noise.jpg')	
   -- normalizes brightness
   local gamma = 2*(options.brightness-50)
   -- merging-parameters for gained image
   local Alpha = 1-(options.gain/100)
   local Beta  = options.gain/100
   -- equalizes the imagesizes
   local noise_resize = cv.CloneImage(src)
   -- new object: resulting picture
   local dst = cv.CloneImage(src)
   -- writes a noise-extract in noise_resize
   cv.Resize(noise,noise_resize)
   -- resulting picture is created. -> dst=(Image*Alpha+Noise_resize*beta)+gamma
   cv.AddWeighted(src,Alpha,noise_resize,Beta,gamma,dst)	
   local encoded = cv.EncodeImage('.'..options.format,dst)
   local data = cv.MatToDataString(encode)
   -- renames value for server-client communication
   if options.format == 'jpg' then
      options.format = 'jpeg'
   end

   -- returns image and its format
   return data,options.format
end

-- if a camera-object available -> live picture, else fake image
local query_image	
if cam then
   query_image = get_camera_image
else
   query_image = make_fake_image
end

-- function / is called whenever HTTP GET request is made on URL '/image'
local dispatch_image_request = function(web)    
   local imagename 
   if cam then
      imagename = cam
   else
      imagename = web.GET.file
   end
   -- requests former camera properties (or default values)
   gain = normalize(tonumber(web.GET.gain) or gain)
   shutter = normalize(tonumber(web.GET.shutter) or shutter)
   brightness= normalize(tonumber(web.GET.brightness) or brightness)
   contrast= normalize(tonumber(web.GET.contrast) or contrast)
   saturation= normalize(tonumber(web.GET.saturation) or saturation)
   format = web.GET.format or format
   -- camera-properties-table 
   local options = 
      {gain=gain, shutter=shutter, brightness=brightness, contrast=contrast, 
      saturation=saturation, skip_buffered_images=skip_buffered_images}

    options.skip_buffered_images =web.GET.skip_buffered_images and web.GET.skip_buffered_images == 'true'
    options.format = format
      
    local image_data,type = query_image(imagename, options)
    -- adjusts content-type 
    web.headers['Content-Type'] = 'image/'..type
    -- adjusts content-length
    web.headers['Content-Length'] = #image_data
    return image_data 
end

-- static dispatches
wappcam:dispatch_static('/index.html')
wappcam:dispatch_static('/css/.+')
wappcam:dispatch_static('/js/.+')
wappcam:dispatch_static('/img/.+')
-- dynamic dispatches
wappcam:dispatch_get(dispatch_image_request,'/image')
wappcam:dispatch_get(redirectindex,'/')

return wappcam