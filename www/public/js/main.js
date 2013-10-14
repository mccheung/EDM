$(document).ready(function(){
	
//Scrol
$('#menu li a, #logo').click(function() {
	var elementClicked = $(this).attr("href");
	var destination = $(elementClicked).offset().top;
	$("html:not(:animated),body:not(:animated)").animate({ scrollTop: destination-0}, 1000 );		   
	return false;
});	

var current_nav = 'home';

scroll_function = function(){
	
	$(".scrol-page,").each(function(index) {
		var h = $(this).offset().top;
		var y = $(window).scrollTop();
					
		if(y + 360 >= h && y < h + $(this).height() && $(this).attr('id') != current_nav) {
			
			current_nav = $(this).attr('id');
			
			$('#menu a').removeClass('current');
			$('.nav_' + current_nav).addClass('current').show("fast");	
				
		}
	});	
}
$(window).scroll(function(){
		scroll_function();
});



//Initializate fancybox
$("a[data-id^='fancybox']").fancybox({
				'overlayShow'	: true,
				'overlayColor'		: '#000',
				'transitionIn'	: 'elastic',
				'transitionOut'	: 'elastic'				
}); 


//Initializate fancybox
$("a[data-id^='fancybox-portfolio']").fancybox({
				'overlayShow'	: true,
				'overlayColor'		: '#000',
				'transitionIn'	: 'elastic',
				'transitionOut'	: 'elastic',
				'height' : 800,
				'width'	: 800		
}); 

//Portfolio Image Hover

jQuery(document).ready(function(){
	jQuery("#portfolio_box a").hover(function(){
		jQuery(this).find("img").stop().animate({
			opacity:0.4
		}, 400);
	}, function() {
		jQuery(this).find("img").stop().animate({
			opacity:1
		}, 400);
	});
});



//Portfolio Filterable

/*
* Copyright (C) 2009 Joel Sutherland.
* Liscenced under the MIT liscense
*/
(function($) {
	$.fn.filterable = function(settings) {
		settings = $.extend({
			useHash: true,
			animationSpeed: 800,
			show: { width: 'show', opacity: 'show' },
			hide: { width: 'hide', opacity: 'hide' },
			useTags: true,
			tagSelector: '#portfolio-filter a',
			selectedTagClass: 'current',
			allTag: 'all'
		}, settings);
		
		return $(this).each(function(){
		
			/* FILTER: select a tag and filter */
			$(this).bind("filter", function( e, tagToShow ){
				if(settings.useTags){
					$(settings.tagSelector).removeClass(settings.selectedTagClass);
					$(settings.tagSelector + '[href=' + tagToShow + ']').addClass(settings.selectedTagClass);
				}
				$(this).trigger("filterportfolio", [ tagToShow.substr(1) ]);
			});
		
			/* FILTERPORTFOLIO: pass in a class to show, all others will be hidden */
			$(this).bind("filterportfolio", function( e, classToShow ){
				if(classToShow == settings.allTag){
					$(this).trigger("show");
				}else{
					$(this).trigger("show", [ '.' + classToShow ] );
					$(this).trigger("hide", [ ':not(.' + classToShow + ')' ] );
				}
				if(settings.useHash){
					location.hash = '#' + classToShow;
				}
			});
			
			/* SHOW: show a single class*/
			$(this).bind("show", function( e, selectorToShow ){
				$(this).children(selectorToShow).animate(settings.show, settings.animationSpeed);
			});
			
			/* SHOW: hide a single class*/
			$(this).bind("hide", function( e, selectorToHide ){
				$(this).children(selectorToHide).animate(settings.hide, settings.animationSpeed);	
			});
			
			/* ============ Check URL Hash ====================*/
			if(settings.useHash){
				if(location.hash != '')
					$(this).trigger("filter", [ location.hash ]);
				else
					$(this).trigger("filter", [ '#' + settings.allTag ]);
			}
			
			/* ============ Setup Tags ====================*/
			if(settings.useTags){
				$(settings.tagSelector).click(function(){
					$('#portfolio_box ul').trigger("filter", [ $(this).attr('href') ]);					
					$(settings.tagSelector).removeClass('current');
					$(this).addClass('current');
				});
			}
		});
	}
})(jQuery);

$(document).ready(function(){	
	$('#portfolio_box ul').filterable();
});

//Scrol
$('#menu a, #logo, .scrol').click(function() {
	var elementClicked = $(this).attr("href");
	var destination = $(elementClicked).offset().top;
	$("html:not(:animated),body:not(:animated)").animate({ scrollTop: destination-0}, 1000 );		   
	return false;
});	
		
});



//Form Validation Javascript
$(document).ready(function() {
	$('form#contact_form').submit(function() {
		$('form#contact_form .error').remove();
		var hasError = false;
		$('.requiredField').each(function() {
			if(jQuery.trim($(this).val()) == '') {
            	var labelText = $(this).prev('label').text();
            	$(this).parent().append('<span class="error">You forgot to enter your '+labelText+'.</span>');
            	$(this).addClass('inputError');
            	hasError = true;
            } else if($(this).hasClass('email')) {
            	var emailReg = /^([\w-\.]+@([\w-]+\.)+[\w-]{2,4})?$/;
            	if(!emailReg.test(jQuery.trim($(this).val()))) {
            		var labelText = $(this).prev('label').text();
            		$(this).parent().append('<span class="error">You entered an invalid '+labelText+'.</span>');
            		$(this).addClass('inputError');
            		hasError = true;
            	}
            }
		});
		if(!hasError) {
			$('form#contact_form input.submit').fadeOut('normal', function() {
				$(this).parent().append('');
			});
			var formInput = $(this).serialize();
			$.post($(this).attr('action'),formInput, function(data){
				$('form#contact_form').slideUp("fast", function() {
					$(this).before('<p class="success"><strong>Thanks!</strong> Your email was successfully sent. We will contact you as soon as possible.</p>');
				});
			});
		}

		return false;

	});
});

//Homepage Slider 
function initCycle() {
	$('.project-item').css('display', 'block');
	
	var bFirstSlide = true;
	$('.project-items').cycle({ 
	    speed: 900,
		requeueTimeout: 500,
		fx: 'uncover',
		//easing: 'easeInQuint',
		easing: 'easeInExpo',
		timeout: 5000,
		prev: 'a.prev',
		next: 'a.next',
		width: '100%',
		requeueOnImageNotLoaded: true,
		fit: true,
		before: function(oCurrent, oNext, oOptions, bForward) {
			if(bFirstSlide == false) {
				if(bForward == true || bForward == 1) {
					$(oNext).css({
						'left': $(window).width()+'px'
					});
				} else {
					$(oNext).css({
						'left': '-'+$(window).width()+'px'
					});
				}
				
			} 
			bFirstSlide = false;
		}
	});	
	
	$(document).bind('keypress', function(e) {
		if(e.keyCode == 37) {
			$('.project-items').cycle('prev');
		} else if (e.keyCode == 39) {
			$('.project-items').cycle('next');
		}
    });
	
	$('#images-container').cycle({ 
	    speed: 700,
		fx: 'uncover',
		easing: 'easeInQuint',
		timeout: 0,
		prev: 'a.prev',
		next: 'a.next',
		requeueOnImageNotLoaded: true
	});	
	
}

function hideCycleNav() {
	var nCycleItems = $('#images-container .image').size();
	
	if(nCycleItems <= 1) {
		$('#slider-nav').hide();
	}
}

function checkPageHeight(p_sId) {
	
	// slider: min-height: 400px; bij viewheight van 500px;
	var nMinHeight = 400;
	var nMinViewHeight = 500;
	var nViewHeight = $(window).height();
	var nMaxSliderHeight = 600;
	var nNewSliderHeight;
	
	if(nViewHeight > nMinViewHeight) {
		nNewSliderHeight = (nViewHeight - nMinViewHeight) + nMinHeight;
	}
	
	if(nNewSliderHeight >= nMaxSliderHeight) {
		nNewSliderHeight = nMaxSliderHeight;
	}
	
	var oObject;
	if(p_sId != undefined && p_sId != '') {
		if(p_sId == 'home') {
			oObject = '.project-items, .project-item, .project-image';
		} else {
			oObject = 'section#'+p_sId;
		}
	} 
	
	// effect uitvoeren
	$(oObject).stop().animate({
		height: nNewSliderHeight
	}, 500, 'easeOutBounce');
}