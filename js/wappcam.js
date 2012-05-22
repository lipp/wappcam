$(function(){    
    // pseudo main 


    var gain = 50;
    var shutter = 50;
    var brightness = 50;
    var contrast = 50;
    var saturation = 50;

    $('#cameraImage').attr("localhost:8080/image?gain="+Math.floor(gain)+"&shutter="+Math.floor(shutter)+"&brightness="+Math.floor(brightness)+"&contrast="+Math.floor(contrast)+"&saturation="+Math.floor(saturation))

    $("#gainslider").noUiSlider("init",{
        dontActivate: "lower", startMax: gain,
        change: function() {
            gain = $(this).noUiSlider('getValue')[0];
            console.log(gain);
        }
    });
    $("#shutterslider").noUiSlider("init",{
        dontActivate: "lower", startMax: shutter,
        change: function() {
            shutter = $(this).noUiSlider('getValue')[0];
            console.log(shutter);
        }
    });
    $("#brightnessslider").noUiSlider("init",{
        dontActivate: "lower", startMax: brightness,
        change: function() {
            brightness = $(this).noUiSlider('getValue')[0];
            console.log(brightness);
        }
    });
    $("#contrastslider").noUiSlider("init",{
        dontActivate: "lower", startMax: contrast,
        change: function() {
            contrast = $(this).noUiSlider('getValue')[0];
            console.log(contrast);
        }
    });
    $("#saturationslider").noUiSlider("init",{
        dontActivate: "lower", startMax: saturation,
        change: function() {
            saturation = $(this).noUiSlider('getValue')[0];
            console.log(saturation);
        }
    });

    var testpics = ["img/kirlian30.jpg","img/09678925.jpg","img/kamera.jpg","img/6730.jpg","img/kirlian15.jpg","img/kirlian03.jpg","img/100325_simpsons.jpg"];
    var picsrc = new Array(7);
    var i=0;

    $("#single").click(function(){        
        i=i+1;
        var newpic=testpics[i%7];
        picsrc.unshift(newpic);
        picsrc.pop();

        $("#cameraImage").attr("src",picsrc[0]);
        $("#cameraImage1").attr("src",picsrc[1]);
        $("#cameraImage2").attr("src",picsrc[2]);
        $("#cameraImage3").attr("src",picsrc[3]);
        $("#cameraImage4").attr("src",picsrc[4]);
        $("#cameraImage5").attr("src",picsrc[5]);
        $("#cameraImage6").attr("src",picsrc[6]);

    });

    var clicked = false;
    var i=0;

    var start = function(){
        i = i+1 
        var newpic=testpics[i%7];
        picsrc.unshift(newpic);
        picsrc.pop();

        $("#cameraImage").attr("src",picsrc[0]);
        $("#cameraImage1").attr("src",picsrc[1]);
        $("#cameraImage2").attr("src",picsrc[2]);
        $("#cameraImage3").attr("src",picsrc[3]);
        $("#cameraImage4").attr("src",picsrc[4]);
        $("#cameraImage5").attr("src",picsrc[5]);
        $("#cameraImage6").attr("src",picsrc[6]);
    };

    var t = 0;

    $('#sequence').click(function(){
        clicked = !clicked;
        if (clicked){
            t = setInterval(start, 200);
        } else {
            clearInterval(t);
        }
    });   

});


