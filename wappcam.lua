#!/usr/bin/env lua

local cv_load_ok, cv = pcall(require,'luacv')
cv=require('luacv')
require('orbit')

local cam
if cv_load_ok then
   cam = cv.CreateCameraCapture(-1)
   cv.SetCaptureProperty(cam,cv.CV_CAP_PROP_FRAME_COUNT, 1)
   print(cam)
end

local wappcam = orbit.new('wappcam')					-- neues Wappcam-Objekt


local gain = 0								-- Start Wert gain
local shutter = 50							-- Start Wert shutter
local brightness = 50							-- Start Wert brightness
local contrast = 50							-- Start Wert contrast
local saturation = 50							-- Start Wert saturation

 local optionsx = {}


local loadimage = 							-- Funktion fürs Bild einladen
  function(path)
    local fileindex = io.open(path)
    local image=fileindex:read("*a")
  return image
end	

local redirectindex = 							-- Funktion für die Index-Seite
  function(web)
    web:redirect('/index.html')
  return 
end	

local get_camera_image = 
   function(camname, options)

print('haha')
    
    if optionsx.gain ~= options.gain then 
    cv.SetCaptureProperty(cam,cv.CV_CAP_PROP_GAIN, options.gain/100)
    end
    if optionsx.brightness ~= options.brightness then 
    cv.SetCaptureProperty(cam,cv.CV_CAP_PROP_BRIGHTNESS, (options.brightness)/100)
    end
    if optionsx.contrast ~= options.contrast then 
    cv.SetCaptureProperty(cam,cv.CV_CAP_PROP_CONTRAST, (options.contrast)/100)
    end
    if optionsx.saturation ~= options.saturation then 
    cv.SetCaptureProperty(cam,cv.CV_CAP_PROP_SATURATION, (options.saturation)/100)
    end
print('haha2')
    local image = cv.QueryFrame(cam)
    local encoded = cv.EncodeImage('.jpg',image)
    local data = cv.MatToDataString(encoded)
print('haha3')   
 		
    optionsx.gain = options.gain					-- Start Wert gain
    optionsx.shutter = options.shutter					-- Start Wert shutter
    optionsx.brightness = options.brightness				-- Start Wert brightness
    optionsx.contrast = options.contrast				-- Start Wert contrast
    optionsx.saturation = options.saturation				-- Start Wert saturation
   return data,'jpeg'
end



local make_fake_image = 						-- Fakebild kreieren
  function(imagename, options)
    print(options.gain)
    print(options.brightness)
    
    local src = cv.LoadImage('static/'..(imagename or 'testa')..'.jpg')	-- fakebild laden
    local noise = cv.LoadImage('static/noise.jpg')			-- fakerauschen laden

    local gamma = 2*(options.brightness-50)				-- shutter anpassung
    local Alpha = 1-(options.gain/100)
    local Beta  = options.gain/100					-- gain nomiert
    local noise_resize = cv.CloneImage(src)				-- größe des rauschbildes angleichen

    local dst = cv.CloneImage(src)					-- resultat anlegen
    cv.Resize(noise,noise_resize)					-- noise in noise_resize einfügen
    cv.AddWeighted(src,Alpha,noise_resize,Beta,gamma,dst)		-- Methode wird ausgeführt dst=(Image*Alpha+Noise_resize*beta)+gamma
    cv.SaveImage('Fakebild.jpg', dst)					-- Bild speichern
    local image = loadimage('Fakebild.jpg')
    return image,'jpeg'
end

local query_image							-- Schalter.. bei vorhandener Kamera -> Kamera ..sonst fakebild
if cam then
   query_image = get_camera_image
else
   query_image = make_fake_image
end

local getimage =  
  function(web)    
    local imagename 
if cam then
  imagename = cam
else
  imagename = web.GET.file
end

gain = tonumber(web.GET.gain) or gain
shutter = tonumber(web.GET.shutter)or shutter
brightness=tonumber(web.GET.brightness)or brightness
contrast=tonumber(web.GET.contrast)or contrast
saturation=tonumber(web.GET.saturation)or saturation

local options = 							-- Options Tabelle
	{gain=gain, shutter=shutter, brightness=brightness,
	contrast=contrast, saturation=saturation}

for i,v in pairs(options) do 						--  For Loop zur Drosselung der Eingabewerte
  if v > 100 then
    options[i] = 100
   elseif  v < 0 then
    options[i] = 0
   end
end

local image_data,type = query_image(imagename, options)
web.headers['Content-Type'] = 'image/'..type				-- Content Typ anpassen
web.headers['Content-Length'] = #image_data				-- content length anpassen
  return image_data 							-- Rückgabe Image an den server
end


wappcam:dispatch_get(getimage,'/image')					-- funktion getimage aufrufen bei .../image
wappcam:dispatch_static('/index.html')
wappcam:dispatch_get(redirectindex,'/')
wappcam:dispatch_static('/css/.+')	
wappcam:dispatch_static('/js/.+')
wappcam:dispatch_static('/img/.+')					-- .../static/x ruft datei mit dem namen x aus dem ordner static auf

return wappcam


--[[local getcam =
	function()
	local filecam = io.open('static/lkdemo.lua')
	local cam= filecam:read('*a')
    --web.headers['Content-Type'] = 'image/jpeg'
    --web.headers['Content-Length'] = #image
  return cam 
end]]--
