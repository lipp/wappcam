$(function(){    
    $(".sliderbar").noUiSlider("init",{
        dontActivate: "lower",
        change: function() {
            var value = $(this).noUiSlider('getValue')[0];
            console.log(value);
        }
    });
});
