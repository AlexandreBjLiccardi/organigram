## Check packages availability and install ONLY the missing ones
package_loader <- function(list_of_packages){
  new_packages <- list_of_packages[!(list_of_packages %in% installed.packages()[,"Package"])]
  if(length(new_packages)) install.packages(new_packages)
  if("dplyr" %in% list_of_packages)'%>%' <- dplyr::'%>%'
}
