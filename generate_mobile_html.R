
# Recursive function that :
#   - finds out all nodes included in the hierarchical entity
#   - compute the HTML mobile list
#   - finds out all relative nodes (node that can be children)
#   - launches the function using these new nodes
#   - compiles and returns the HTML string, including those of identified children.
# NB. Inifinite loops can occur, if duplicate named nodes ("nom") with different hierarchical entities ("superieur") are provided.

get_content_unite <- function(unitei, data, level){
# Build and HTML computing of lists, of current node included in the hierarchical entity
# Order of appearence is given with "nom" columns
  unite_lines_hier <- data %>% dplyr::filter(unite == unitei & nom %in% data$superieur)%>%  dplyr::arrange(nom) %>% {glue::glue("<li id='{.$unique_code}' class='agent_mobile showPresPage org_sup{level} suph'>{.$nom}</li>")}
  unite_lines_agents <- data %>% dplyr::filter(unite == unitei & !nom %in% data$superieur) %>%  dplyr::arrange(nom)  %>% {glue::glue("<li id='{.$unique_code}' class='agent_mobile showPresPage'>{.$nom}</li>")}
# List of current node included in the hierarchical entity, later used as a filter for identifying children.
  unite_lines_agents_posssh <- data %>% dplyr::filter(unite == unitei) %>% .$nom
# Finding out the children (differents sub-unit children)
# Order of appearence is given with "nom" columns
  unite_lines_children <- data %>% dplyr::filter(superieur %in% unite_lines_agents_posssh & unite != unitei) %>%  dplyr::arrange(unite)  %>%  dplyr::distinct(.$unite) 
# Level info for later CSS class management
  level2 <- level + 1
# Recursive build of the HTML strings
  header = paste("<div class='soustitre_mobile org_st",level,"'>", unitei,"</div><div class='contenue org_ct",level,"'>",sep="")
# Including HTML strings of children, sometimes (end of the graph) no child is found. Includes the recursive call
  unite_lines_children_str <- if(dim(unite_lines_children[1])[1] != 0) paste(apply(unite_lines_children,1,get_content_unite, data = data, level = level2),collapse="") else ""
  paste(header,"<ul>", paste(unite_lines_hier,collapse=""),"</ul>","<ul>",paste(unite_lines_agents,collapse=""),"</ul>",unite_lines_children_str,"</div>", sep="")
}

# HTML generation function for mobile device. 
# Builds lists suited with accordion menus and HTML editorial completion.

generate_mobile_html <- function(data, export_to = "react/mobile.html") {
# The first node is the one with no hierachical ("superieur") information
  unite_lines_children <- data %>% dplyr::filter(is.na(superieur)) %>%  dplyr::distinct(.$unite)
# Call of the get_content_unite function on this first node, others will be recursively used.
# Results ar stored in the menu_mobile div for later CSS and JS management.
  write(paste("<div id='menu_mobile'>", get_content_unite(unite_lines_children[[1]],data,1), "</div>", sep=""), file=export_to, append = FALSE)
}


