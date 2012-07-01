// -Initials all sliders,
// -installs clickhandlers for single- and life-image button, 
// -sets interval for live-image,
// -manage image history


$(function(){
    // pseudo main

//sets the attribute for the first pic 
    var gain = 0;
    var shutter = 50;
    var brightness = 50;
    var contrast = 50;
    var saturation = 50;
    var j = 0;
    var image_query = $.get('image');
    var format = "jpg";
    // for debugging purposes, when no real wappcam server is available
    var testpics = ["http://www.mpia.de/Public/Aktuelles/PR/2009/PR090205/PR090205_2ohr.jpg",
                    "http://static.pagenstecher.de/uploads/4/40/408/408f/homer20simpson.jpg",
                    "http://www.bilder.beofnf.de/wallpaper/simpsons.jpg",
                    "http://www.testedich.de/quiz25/picture/pic_1216037428_3.jpg",
                    "http://images3.wikia.nocookie.net/__cb20100626113247/reddeadredemption/images/1/11/Bart_Simpson.jpg",
                    "http://images2.wikia.nocookie.net/__cb20081212024429/inciclopedia/images/3/32/Homero-diablo-satans-los-simpson.jpg",
                    "http://img1.gbpicsonline.com/gb/193/009.jpg"];
    var testpic_index=0;

//returns a new image-url with current parameters
    var imgurl = function(skip_buffered_images){
//verify the image for a camera picture
        if(image_query.statusText == "Ok" ) {
            j=j+1;
            var img_url = "/image?gain="+Math.floor(gain)+
                "&shutter="+Math.floor(shutter)+
                "&brightness="+Math.floor(brightness)+
                "&contrast="+Math.floor(contrast)+
                "&saturation="+Math.floor(saturation)+
                "&format="+format+"&j="+j+
                "&skip_buffered_images="+skip_buffered_images;
            return img_url;
        }
//if no picture is given it uses the testpics which was create before
        else{
            testpic_index++;
            var newpic=testpics[testpic_index%7];
            return newpic;
        }
    };

// changes the attribute of the live image-url
    var update_image = function() {
        $('#liveImage').attr("src",imgurl(true))
    };
//sets interval between each picture which is given from the server
    var timerid;
    var live_update = function() {
        var img = $('#liveImage');
        img.attr("src",imgurl(false));
        img.load(function(){
            timerid = setTimeout(function(){
                img.attr('src',imgurl(false));
            },100);
        });       
    };
//cancel timer, no image from the server anymore, no new picture is shown at the browser
    var cancel_live_update = function() {
        clearTimeout(timerid);
        $('#liveImage').off('load');
    };
//changes the format attribute at the image-url, format at the shown picture changes 
    $("#format").change(function(){
        format = $(this).val();
        console.log(format);
        update_image();
    });
//resets the attribute to default again
    $("#reset").click(function(){
        gain = 0;
        shutter = 50;
        brightness = 50;
        contrast = 50;
        saturation = 50;
    });
//changes the gain attribute at the image-url, gain at the shown picture changes
    $("#gainslider").noUiSlider("init",{
        dontActivate: "lower", startMax: gain,
        change: function() {
            gain = $(this).noUiSlider('getValue')[0];
            console.log(gain);
            update_image();
        }
    });
//changes the shutter attribute at the image-url, shutter at the shown picture changes
    $("#shutterslider").noUiSlider("init",{
        dontActivate: "lower", startMax: shutter,
        change: function() {
            shutter = $(this).noUiSlider('getValue')[0];
            console.log(shutter);
            update_image();
        }
    });
//changes the brightness attribute at the image-url, brightness at the shown picture changes
    $("#brightnessslider").noUiSlider("init",{
        dontActivate: "lower", startMax: brightness,
        change: function() {
            brightness = $(this).noUiSlider('getValue')[0];
            console.log(brightness);
            update_image();
        }
    });
//changes the contrast attribute at the image-url, contrast at the shown picture changes
    $("#contrastslider").noUiSlider("init",{
        dontActivate: "lower", startMax: contrast,
        change: function() {
            contrast = $(this).noUiSlider('getValue')[0];
            console.log(contrast);
            update_image();
        }
    });
//changes the saturation attribute at the image-url, saturation at the shown picture changes
    $("#saturationslider").noUiSlider("init",{
        dontActivate: "lower", startMax: saturation,
        change: function() {
            saturation = $(this).noUiSlider('getValue')[0];
            console.log(saturation);
            update_image();
        }
    });


//saves the picture at the next image spot, the last picture at the last spot deleted
    $("#single").click(function(){
        var new_image = $('<img class="span2">').attr('src',imgurl(true));
        $('#imageHistory').prepend(new_image);
        $('#imageHistory').children(':last-child').remove();
    });
//changes the live-button, triggers the sets interval again
    var clicked = false;
    $('#Live').click(function(){
        clicked = !clicked;
        if (clicked){
            live_update();
        } else {
            cancel_live_update();
        }
    });
//explicitly trigger the click event of the life button to a life image per default, button clicked when website opens
    $('#Live').trigger('click');
});
