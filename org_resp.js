/* Gets the json part of the json data file previously loaded */
function getJsonFromId(id){
	return jsonf[id];	
}

$( function(){ 
/* Allows Youtube autorun */
	var context = new AudioContext();

/* Mobile use case, prepare aestetic */
    $( ".contenue" ).slideUp( 0 );
    $( ".soustitre_mobile" ).on( "click", function(){
        $( this ).next( ".contenue" ).slideToggle();
    });

/* Prepare class for click event */
	 $( ".showPresPage" ).on( "click", function(){		
		firePres($( this ).attr('id'));
    });
/* A pretty load-at-start of the json containing node data*/
	window.jsonf = '';
	$.getJSON('data/hData.json', function(json) {
		window.jsonf = json; 
	});
	
});


/* Event on node click */

function firePres(id) {
	
	userJson = getJsonFromId(id);
	// Classname is given by the terminal
	var prefClass = (window.checkMobile())?"":"_dk";
	$('#inc_app').append("<div class='inc_app_1"+prefClass+"' id='inc_app_1_i'></div>") ;
	$('#inc_app_1_i').append("<div class='inc_app_3' id='inc_app_3_i'></div>") 
	$("#inc_app_3_i").html('Revenir à l\'organigramme : <img src="media/images/img_cl1.png" alt="Revenir à l\'organigramme" class="ico_close'+prefClass+'" height="100%"/>');
	$('#inc_app_1_i').append("<div class='inc_app_2' id='inc_app_2_i'></div>") 
		$("#inc_app_2_i").html(
		"<div class='describer_img"+prefClass+"'>"+userJson["img_html"][0]+"</div>"
		+"<div class='describer_txt"+prefClass+"'><p class = 'nom_agent"+prefClass+"'>"+userJson["nom"][0]+"</p>"
		+"<p class = 'poste_agent"+prefClass+"'>"+userJson["poste"][0].replace("\\n","<BR>")+"</p>"
		+"<p class = 'entite_agent"+prefClass+"'>"+userJson["entite"][0].replace("\\n","<BR>")+"</p></div>");
	// User website info
	if(userJson["site_web"]!==null&userJson["site_web"][0]!==null){
		$('#inc_app_1_i').append("<div class='site_web_agent"+prefClass+"' id='inc_app_22_i'>En savoir plus via le <a href='"+userJson["site_web"][0]+"'>site personnel</a> de l'agent.</div>") 
		$('#inc_app_22_i').on("click", function(){	
			window.location.replace(userJson["site_web"][0]);
		});	
	}
	$('#inc_app_1_i').append("<div class='inc_app_21' id='inc_app_21_i'></div>") 
	// Specific behavior
	if(window.checkMobile()){
		$("#inc_app_21_i").html(userJson["media_html"][0].replace("height='600","height='250").replace("height='550","height='250"));
		$("#inc_app_1_i").focus();
	}else{
		$("#inc_app_21_i").html(userJson["media_html"][0]);
		$("#inc_app_1_i").css({"overflow":"hidden"})
		$('#inc_app').append("<div class='inc_app_1u"+prefClass+"' id='inc_app_1u_i'></div>") ;
		$('#inc_app_1u_i').height($('#inc_app').height());
		$("#inc_app_1u_i").css({"overflow":"hidden"});
		$("#inc_app_1_i").focus();
	}

/* Associate event to click */	
	$("#inc_app_3_i").on("click", function(){	
			 $('#ytplayer').prop('src','');
			 $(".inc_app_1").remove();
			 $(".inc_app_1_dk").remove();
			 $(".inc_app_1u_dk").remove();
			 $("#menu_mobile").css({"overflow":"auto"/*,'position':'relative'*/});
		});

}