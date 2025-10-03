(function($){
	'use script';
    $(window).on('load', function(event) {
        $('#preloader').delay(500).fadeOut(500);
    });
	// WOW JS
	new WOW().init();

	// Nice Select
	$('select').niceSelect();
	// Scroll Area
	$(document).ready(function(){
	    $('.scroll-area').click(function(){
	      	$('html').animate({
	        	'scrollTop' : 0,
	      	},700);
	      	return false;
	    });
	    $(window).on('scroll',function(){
	      	var a = $(window).scrollTop();
	      	if(a>400){
	            $('.scroll-area').slideDown(300);
	        }else{
	            $('.scroll-area').slideUp(200);
	        }
	    });
	});

	// Mini Cart
	$('#minicart_open').click(function(){
        $('.minicart-sidebar, .off_canvars_overlay').addClass('active');
    });
    $('.mini-cart-off, .off_canvars_overlay').click(function(){
        $('.minicart-sidebar, .off_canvars_overlay').removeClass('active');
    });

     // /*---slider activation---*/
    var $HeroSlider = $('.hero-slider-full');
    if($HeroSlider.length > 0){
        $HeroSlider.owlCarousel({
            loop: true,
            dots:false,
            autoplay: true,
            autoplayTimeout: 20000,
            items: 1,
            nav:true,
            smartSpeed: 1500,
            navText:['<span class="hero-slider-nav"><i class="bi bi-arrow-left"></i></span>','<span class="hero-slider-nav"><i class="bi bi-arrow-right"></i></span>'],
            responsive:{
                    0:{
                    dots:true,
                },
                577:{
                    dots:false,
                },
            }
        });
    }
     // /*---slider activation---*/
    var $HeroSlider2 = $('.hero-slider-style-2');
    if($HeroSlider2.length > 0){
        $HeroSlider2.owlCarousel({
            loop: true,
            dots:false,
            autoplay: true,
            autoplayTimeout: 20000,
            items: 1,
            animateOut: 'fadeOut',
            nav:true,
            smartSpeed: 500,
            navText:['<span class="hero-slider-nav"><i class="bi bi-arrow-left"></i></span>','<span class="hero-slider-nav"><i class="bi bi-arrow-right"></i></span>'],
             responsive:{
                    0:{
                    dots:true,
                },
                577:{
                    dots:false,
                },
            }
        });
    }
     // /*---slider activation---*/
    var $HeroSlider3 = $('.hero-slider-style-3');
    if($HeroSlider3.length > 0){
        $HeroSlider3.owlCarousel({
            loop: true,
            dots:false,
            autoplay: true,
            autoplayTimeout: 20000,
            items: 1,
            animateOut: 'fadeOut',
            nav:true,
            smartSpeed: 500,
            navText:['<span class="hero-slider-nav"><i class="bi bi-arrow-left"></i></span>','<span class="hero-slider-nav"><i class="bi bi-arrow-right"></i></span>'],
            responsive:{
                    0:{
                    dots:true,
                },
                577:{
                    dots:false,
                },
            }
        });
    }

    /*---product navactive activation---*/
    var $productNavactive = $('.product_navactive');
        if($productNavactive.length > 0){
        $('.product_navactive').owlCarousel({
            autoplay: true,
            loop: false,
            nav: false,
            autoplay: false,
            autoplayTimeout: 8000,
            items: 4,
            dots:false,
            responsiveClass:true,
            responsive:{
                    0:{
                    items:1,
                },
                250:{
                    items:2,
                },
                480:{
                    items:3,
                },
                768:{
                    items:4,
                },

            }
        });
    } 
     $('.modal').on('shown.bs.modal', function (e) {
        $('.product_navactive').resize();
    })

    $('.product_navactive a').on('click',function(e){
      e.preventDefault();

      var $href = $(this).attr('href');

      $('.product_navactive a').removeClass('active');
      $(this).addClass('active');

      $('.product-details-large .tab-pane').removeClass('active show');
      $('.product-details-large '+ $href ).addClass('active show');

    })

    /*---Featured Products---*/
    var $FeaturedProductSlider = $('.feature-product-slider');
        if($FeaturedProductSlider.length > 0){
        $('.feature-product-slider').owlCarousel({
            autoplay: true,
            loop: false,
            nav: true,
            autoplay: false,
            autoplayTimeout: 8000,
            items: 4,
            margin:30,
            dots:false,
            navText:['<span class="feature-slider-nav"><i class="bi bi-arrow-left"></i></span>','<span class="feature-slider-nav"><i class="bi bi-arrow-right"></i></span>'],
            responsiveClass:true,
            responsive:{
                    0:{
                    items: 1,
                    stagePadding: 0,
                    margin: 0,
                },
                400:{
                    items:2,
                },
                876:{
                    items:3,
                },
                991:{
                    items:4,
                },
            }
        });
    } 
    /*---Related Products---*/
    var $RelatedProductSlider = $('.related-product-slider');
        if($RelatedProductSlider.length > 0){
        $('.related-product-slider').owlCarousel({
            autoplay: true,
            loop: false,
            nav: true,
            autoplay: false,
            autoplayTimeout: 8000,
            items: 4,
            margin:30,
            dots:false,
            navText:['<span class="feature-slider-nav"><i class="bi bi-arrow-left"></i></span>','<span class="feature-slider-nav"><i class="bi bi-arrow-right"></i></span>'],
            responsiveClass:true,
            responsive:{
                    0:{
                    items: 1,
                    stagePadding: 0,
                    margin: 0,
                },
                400:{
                    items:2,
                },
                876:{
                    items:3,
                },
                991:{
                    items:4,
                },
            }
        });
    } 
    /*---Products Category---*/
    var $ShopCateSlider = $('.shop-category-full');
        if($ShopCateSlider.length > 0){
        $('.shop-category-full').owlCarousel({
            autoplay: true,
            loop: false,
            nav: true,
            autoplay: false,
            autoplayTimeout: 8000,
            items: 4,
            margin:30,
            dots:false,
            navText:['<span class="shopcate-slider-nav"><i class="bi bi-arrow-left"></i></span>','<span class="shopcate-slider-nav"><i class="bi bi-arrow-right"></i></span>'],
            responsiveClass:true,
            responsive:{
                    0:{
                    items: 2,
                    stagePadding: 0,
                    margin: 0,
                },
                400:{
                    items:2,
                },
                876:{
                    items:3,
                },
                991:{
                    items:5,
                },
            }
        });
    }
    /*---Client Testimonial---*/
    var $TestimonialSlider = $('.client-testimonial-full');
        if($TestimonialSlider.length > 0){
        $('.client-testimonial-full').owlCarousel({
            autoplay: true,
            loop: false,
            nav: true,
            autoplay: false,
            autoplayTimeout: 8000,
            items: 2,
            margin:30,
            dots:false,
            navText:['<span class="testimonial-slider-nav"><i class="bi bi-arrow-left"></i></span>','<span class="testimonial-slider-nav"><i class="bi bi-arrow-right"></i></span>'],
            responsiveClass:true,
            responsive:{
                    0:{
                    items: 1,
                    stagePadding: 0,
                    margin: 0,
                },
                600:{
                    items:1,
                },
                876:{
                    items:1,
                },
                992:{
                    items:2,
                },
            }
        });
    } 


    // Quantity
    jQuery('<div class="quantity-nav"><div class="quantity-button quantity-up">+</div><div class="quantity-button quantity-down">-</div></div>').insertAfter('.quantity input');
    jQuery('.quantity').each(function() {
      var spinner = jQuery(this),
        input = spinner.find('input[type="number"]'),
        btnUp = spinner.find('.quantity-up'),
        btnDown = spinner.find('.quantity-down'),
        min = input.attr('min'),
        max = input.attr('max');

      btnUp.click(function() {
        var oldValue = parseFloat(input.val());
        if (oldValue >= max) {
          var newVal = oldValue;
        } else {
          var newVal = oldValue + 1;
        }
        spinner.find("input").val(newVal);
        spinner.find("input").trigger("change");
      });

      btnDown.click(function() {
        var oldValue = parseFloat(input.val());
        if (oldValue <= min) {
          var newVal = oldValue;
        } else {
          var newVal = oldValue - 1;
        }
        spinner.find("input").val(newVal);
        spinner.find("input").trigger("change");
      });

    });

       /**
   * Countdown timer
   */
   var FuristCountdown = $('#FuristCountdown');
    if(FuristCountdown.length > 0){

      let FuristCountdown = document.getElementById('FuristCountdown');
      const output = FuristCountdown.innerHTML;

      const countDownDate = function() {
        let timeleft = new Date(FuristCountdown.getAttribute('data-countdown-codepopular')).getTime() - new Date().getTime();

        let days = Math.floor(timeleft / (1000 * 60 * 60 * 24));
        let hours = Math.floor((timeleft % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
        let minutes = Math.floor((timeleft % (1000 * 60 * 60)) / (1000 * 60));
        let seconds = Math.floor((timeleft % (1000 * 60)) / 1000);

        FuristCountdown.innerHTML = output.replace('%d', days).replace('%h', hours).replace('%m', minutes).replace('%s', seconds);
      }
      countDownDate();
      setInterval(countDownDate, 1000);
    }


	$('.video-btn a').magnificPopup({
        type: 'iframe'
    });

	// Sticky Menu
	$(document).ready(function(){
		$(window).on('scroll',function(){
			var scroll = $(window).scrollTop();
			if(scroll < 150){
				$('.header-bottom').removeClass('sticky');
			}else{
				$('.header-bottom').addClass('sticky');
			}
		});
	});

}(jQuery));