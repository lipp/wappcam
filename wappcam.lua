#!/usr/bin/env lua
-- Wappcam v.1.0
-- 
-- 
--
--
--
--

local cv_load_ok, cv = pcall(require,'luacv')						--
cv=require('luacv')
require('orbit')

local cam
if cv_load_ok then									
   -- if camera is available, its signal is returned
   cam = cv.CreateCameraCapture(-1)
   -- width properties
   cv.SetCaptureProperty(cam,cv.CV_CAP_PROP_FRAME_WIDTH, 640)				
   -- height properties
   cv.SetCaptureProperty(cam,cv.CV_CAP_PROP_FRAME_HEIGHT, 480)				
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
local form = 'jpg'

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

-- function to select the plugged camera 
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
   local encoded = cv.EncodeImage('.'..options.form,image)
   local data = cv.MatToDataString(encoded)
   
   -- saves the values of the camera setting
   options_old.gain = options.gain	
   options_old.shutter = options.shutter
   options_old.brightness = options.brightness
   options_old.contrast = options.contrast
   options_old.saturation = options.saturation

   -- renames value for server-client communication
   if options.form == 'jpg' then							
      options.form = 'jpeg'
   end

   -- returns image and its format
   return data,options.form								
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
   local encoded = cv.EncodeImage('.'..options.form,dst)
   local data = cv.MatToDataString(encode)
   -- renames value for server-client communication
   if options.form == 'jpg' then						
      options.form = 'jpeg'
   end

   -- returns image and its format
   return data,options.form			
end

-- if a camera-object is available -> Kamera ..sonst fakebild
local query_image	
if cam then
   query_image = get_camera_image
else
   query_image = make_fake_image
end
local count = 0
local getimage = function(web)    
   print('GET IN',count)
   count = count +1
   local imagename 
   if cam then
      imagename = cam
   else
      imagename = web.GET.file
   end

   gain = normalize(tonumber(web.GET.gain) or gain)
   shutter = normalize(tonumber(web.GET.shutter) or shutter)
   brightness= normalize(tonumber(web.GET.brightness) or brightness)
   contrast= normalize(tonumber(web.GET.contrast) or contrast)
   saturation= normalize(tonumber(web.GET.saturation) or saturation)

   form = web.GET.format or form
   -- Options Tabelle
   local options = 							
      {gain=gain, shutter=shutter, brightness=brightness,
       contrast=contrast, saturation=saturation, skip_buffered_images=skip_buffered_images}

      options.skip_buffered_images =web.GET.skip_buffered_images and web.GET.skip_buffered_images == 'true'
      options.form = form

--      print(options.form)
      
      local image_data,type = query_image(imagename, options)
      -- Content Typ anpassen
      web.headers['Content-Type'] = 'image/'..type				
      -- content length anpassen
      web.headers['Content-Length'] = #image_data				   print('GET OUT')
      return image_data 					
end


-- funktion getimage aufrufen bei .../image
wappcam:dispatch_get(getimage,'/image')				
wappcam:dispatch_static('/index.html')
wappcam:dispatch_get(redirectindex,'/')
wappcam:dispatch_static('/css/.+')	
wappcam:dispatch_static('/js/.+')
-- .../static/x ruft datei mit dem namen x aus dem ordner static auf
wappcam:dispatch_static('/img/.+')					

return wappcam



