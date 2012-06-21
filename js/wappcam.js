$(function(){
    // pseudo main


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


    var imgurl = function(skip_buffered_images){
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
        else{
            testpic_index++;
            var newpic=testpics[testpic_index%7];
            return newpic;
        }
    };


    var update_image = function() {
        $('#liveImage').attr("src",imgurl(true))
    };

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

    var cancel_live_update = function() {
        clearTimeout(timerid);
        $('#liveImage').off('load');
    };

    $("#format").change(function(){
        format = $(this).val();
        console.log(format);
        update_image();
    });

    $("#reset").click(function(){
        gain = 0;
        shutter = 50;
        brightness = 50;
        contrast = 50;
        saturation = 50;
    });

    $("#gainslider").noUiSlider("init",{
        dontActivate: "lower", startMax: gain,
        change: function() {
            gain = $(this).noUiSlider('getValue')[0];
            console.log(gain);
            update_image();
        }
    });
    $("#shutterslider").noUiSlider("init",{
        dontActivate: "lower", startMax: shutter,
        change: function() {
            shutter = $(this).noUiSlider('getValue')[0];
            console.log(shutter);
            update_image();
        }
    });
    $("#brightnessslider").noUiSlider("init",{
        dontActivate: "lower", startMax: brightness,
        change: function() {
            brightness = $(this).noUiSlider('getValue')[0];
            console.log(brightness);
            update_image();
        }
    });
    $("#contrastslider").noUiSlider("init",{
        dontActivate: "lower", startMax: contrast,
        change: function() {
            contrast = $(this).noUiSlider('getValue')[0];
            console.log(contrast);
            update_image();
        }
    });
    $("#saturationslider").noUiSlider("init",{
        dontActivate: "lower", startMax: saturation,
        change: function() {
            saturation = $(this).noUiSlider('getValue')[0];
            console.log(saturation);
            update_image();
        }
    });



    $("#single").click(function(){
        var new_image = $('<img class="span2">').attr('src',imgurl(true));
        $('#imageHistory').prepend(new_image);
        $('#imageHistory').children(':last-child').remove();
    });

    var clicked = false;
    $('#Live').click(function(){
        clicked = !clicked;
        if (clicked){
            live_update();
        } else {
            cancel_live_update();
        }
    });
    $('#Live').trigger('click');
});
