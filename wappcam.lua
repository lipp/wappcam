#!/usr/bin/env lua							-- Einbindung von relevanten Kackdingern
cv=require('luacv')
require('orbit')

local wappcam = orbit.new('wappcam')					-- neues Wappcam-Objekt

local gain = 0								-- Start Wert gain
local shutter = 50							-- Start Wert shutter
local brightness = 50							-- Start Wert brightness
local contrast = 50							-- Start Wert contrast
local saturation = 50							-- Start Wert saturation


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


local query_image=make_fake_image  					-- SCHALTER


local getimage =  
  function(web)    
    local imagename = web.GET.file
print('hallo',imagename)
    local options = 							-- Options Tabelle
		    {gain=tonumber(web.GET.gain) or gain, shutter=tonumber(web.GET.shutter)or shutter, brightness=tonumber(web.GET.brightness)or brightness,
		    contrast=tonumber(web.GET.contrast)or contrast, saturation=tonumber(web.GET.saturation)or saturation}

    for i,v in pairs(options) do 					--  For Loop zur Drosselung der Eingabewerte
      if v > 100 then
	  options[i] = 100
      elseif  v < 0 then
	  options[i] = 0
      end
  
    end
    local image_data,type = query_image(imagename, options)
    web.headers['Content-Type'] = 'image/'..type			-- Content Typ anpassen
    web.headers['Content-Length'] = #image_data				-- content length anpassen
print('ok')
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