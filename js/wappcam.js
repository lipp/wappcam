$(function(){    
    // pseudo main 


var gain = 0;
var shutter = 50;
var brightness = 50;
var contrast = 50;
var saturation = 50;
var i = 0;

var update_image = function() {
  var img_url = "/image?gain="+Math.floor(gain)+"&shutter="+Math.floor(shutter)+"&brightness="+Math.floor(brightness)+
	      "&contrast="+Math.floor(contrast)+"&saturation="+Math.floor(saturation)+"&i="+i+1;  
  $('#cameraImage').attr("src",img_url);	
}
   


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

 
var testpics = ["http://www.mpia.de/Public/Aktuelles/PR/2009/PR090205/PR090205_2ohr.jpg",
"http://static.pagenstecher.de/uploads/4/40/408/408f/homer20simpson.jpg",
"http://www.bilder.beofnf.de/wallpaper/simpsons.jpg",
"http://www.testedich.de/quiz25/picture/pic_1216037428_3.jpg",
"http://images3.wikia.nocookie.net/__cb20100626113247/reddeadredemption/images/1/11/Bart_Simpson.jpg",
"http://images2.wikia.nocookie.net/__cb20081212024429/inciclopedia/images/3/32/Homero-diablo-satans-los-simpson.jpg",
"http://img1.gbpicsonline.com/gb/193/009.jpg"];
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


