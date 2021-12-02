# Build a json file, containing all nodes data for later JS calls.
# For further reuse, any developer will have to modify the content of HMTL tags to fulfill his new functions or logos.
# Customized IMG are used, and specific behavior due to client's needs (such as a different logo management) is written in "hard code mode".

generate_json <- function(data, export_to = "hData.json", youtubeHeight = 600, path_to_images = "media/images", path_to_slides = "media/slides") {
  export_table <- purrr::pmap(list(data$url, data$unique_code, data$nom, data$entite,data$poste, data$site_web),
  function(x,y,z,a,b,c) {
  # Media managment : Youtube video or embedded PDF ?  
    if (is.na(x)){
      media_html=""
    }else if(endsWith(tolower(x),".pdf")) {
      # Embedded pdf management
     #  media_html=paste("<embed src='",path_to_slides,"/",x,"#toolbar=1&navpanes=0&statusbar=0&messages=0&scrollbar=1' type='application/pdf' height='600px' width='100%'>", sep = "")
      media_html=paste('<object width="100%" height="580" type="application/pdf" data="',path_to_slides,"/",x,'?#zoom=79&scrollbar=0&toolbar=0&navpanes=0"><p>Votre navigateur n\'accepte pas la lecture standard de PDF.<BR>Retrouvez le fichier <a href="',path_to_slides,'/',x,'">ici</a>.</p></object>', sep = "")
      
    }else if (startsWith(tolower(x),"https://youtu")) {
      # Youtube management : only "embed" URL form is supported.
      media_html=paste("<iframe id='ytplayer' type='text/html' allow='autoplay; fullscreen' width='100%' height='",youtubeHeight,"' src='",gsub("https://youtu.be/","https://www.youtube.com/embed/",x),"?enablejsapi=1&autoplay=1&mute=0&showinfo=0&controls=1' frameborder='0'/>", sep = "")
    }else if (startsWith(tolower(x),"https://www.youtu")) {
      # Youtube management : only "embed" URL form is supported.
      media_html=paste("<iframe id='ytplayer' type='text/html' allow='autoplay; fullscreen' width='100%' height='",youtubeHeight,"' src='",gsub("/watch\\?v=","/embed/",x),"?enablejsapi=1&autoplay=1&mute=0&showinfo=0&controls=1' frameborder='0'/>"                       , sep = "")
    } else {
      media_html="Média non supporté."
    }
    if (is.na(a)){
        img_html=''
      }else if(grepl( "patrinat", tolower(a), fixed = TRUE)) {
        img_html=img_html=paste('<img class="org_logo_multi" src="',path_to_images,'/logo-patrinat.png" alt="UMS Patrinat"><img class="org_logo_multi" src="',path_to_images,'/logo-ofb.png" alt="DSUED/OFB">', sep="")
    } else {
        img_html=paste('<img class="org_logo" src="',path_to_images,'/logo-ofb-v.png" alt="DSUED/OFB">', sep="")
    }
    trombi_html = paste('<img class = "org_trombi" src ="',path_to_images,'/trombi/',y,'.jpg"/>', sep="")
    list(id = y, media_html = media_html, nom = z, entite = a, poste = b, site_web = c, img_html = img_html, trombi_html = trombi_html)
  })%>% purrr::set_names(nm = data$unique_code)
  #JSON fie export
  json_exp = jsonlite::toJSON(export_table)
  write(json_exp, file=export_to, append = FALSE)
}
