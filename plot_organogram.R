plot_organogram <- function(data,
                            layout            = "dendrogram",
                            circular          = TRUE,
                            title             = NULL,
                            color             = "black",
                            background_color  = "white",
                            shift_annotations = NULL,
                            width             = NA, # Autoconf for full-width
                            height            = 900,
                            pruning_factor    = 5,
                            script_path       = "script") {
# Verifying the root of the graph
   if (nrow(subset(data, is.na(from)))!=1)stop("Only one row, used as the root of the graph, can have and MUST have empty cell for the 'from' column")

# Data passed to JS, through the plotly tooltip tool
#  The use of pmap_chr could sound strange, but allows the build of more complex JSON if needed
    provided_data <- purrr::pmap_chr(list(data$unique_code),function(x) {
            retList <- list(unique_code = x)
            jsonlite::toJSON(retList)
    })%>%purrr::set_names(nm = data$to)

# # Generate the graphical datas and graphical layout
    static_graph <- data           %>%
      # remove the root of the graph
      dplyr::filter(!is.na(from))     %>%
      # build data relation and nodes
      tidygraph::as_tbl_graph()  %>%
      tidygraph::activate(nodes) %>%
      # associate data with nodes ## this part is copied from cedric.mondy, with some deletions
      tidygraph::mutate(
        label      = data$hover_label[match(tidygraph::pull(., name), data$to)],
        provided_data  = provided_data[tidygraph::pull(., name)],
        annotation = data$annotation[match(tidygraph::pull(., name), data$to)]) %>%
      # SUppress the first of the list : the root according to the given order
      # build geometry (draw the graph)
        ggraph::ggraph(layout = layout, circular = circular) +  # canvas
        ggraph::geom_edge_diagonal(colour = color)           +  # graph
        ggraph::geom_node_point(ggplot2::aes(text = label, image = provided_data), colour = color) +  # node as points
        ggraph::geom_node_text(ggplot2::aes(label = annotation), colour = color)  # annotation, i.e. main hierarchical entites provided by specific file annotation.csv by default

## Build graph matrix for further reuse... ## this part is copied from cedric.mondy, with some deletions
 gg_data <- ggplot2::ggplot_build(static_graph)$data

 ## ...in interactive graph, with points deletion for output file size improvement
  data_edges <- gg_data[[1]]          %>%
    dplyr::select(-dplyr::starts_with("label"), -circular, -dplyr::ends_with("_cap"), -family, -fontface) %>%
    # the graph accepts duplicated points and/or near points. The script groups and delete unnecessary geometries.
    dplyr::group_by(group)            %>%       # group are made according to group definition in gg_plot (represents different points)
    dplyr::group_modify(function(df, ...) {
      df                                    %>%
        dplyr::mutate(i = seq(dplyr::n()))  %>% # n() is the number of rows. Here is given to each group
        dplyr::filter((i %% pruning_factor) < 2) # Only 2 points up to pruning factor (5 in the generator, 8 by default). Asumption is made (and probably false), that the remaining point are the best choice amongst the 5 considered.
      })                                      %>%
    dplyr::ungroup()

  data_nodes <- gg_data[[2]]

  # data annotation preparation
  data_annotations <- gg_data[[3]] %>% dplyr::filter(label != "")
  
  ## If shift annotations are defined, shifted values are added
  if (!is.null(shift_annotations)) {
  # Controls on tibble
    required_names <- c("annotation", "shift_x", "shift_y")
    if (!is.data.frame(shift_annotations) | !all(required_names %in% colnames(shift_annotations))) stop(glue::glue("shift_annotations must be a data frame with three columns: {paste(required_names, collapse = ', ')}"))
    if (!dplyr::between(shift_annotations$shift_x[1],-1,1)|!dplyr::between(shift_annotations$shift_y[1],-1,1))stop("shift_x and shift_y must be expressed in proportions [-1;1] of the plot width and height, respectively")
  # Annotation reference : position (x, y are given by a range within the displayed layout and a location node) and value
    ranges_xy         <- apply(dplyr::select(gg_data[[2]], x, y), 2, function(x) diff(range(x)))
    data_annotations  <- dplyr::mutate(shift_annotations, shift_x = shift_x * ranges_xy[["x"]], shift_y = shift_y * ranges_xy[["y"]]) %>%
                      dplyr::right_join(data_annotations, by = c("annotation"="label"))
  }

## Standard Plotly graph generation
  interactive_graph <- plotly::plot_ly(
    data       = data_edges,
    x          = ~x, 
    y          = ~y,
    name       = ~group, 
    type       = "scatter", 
    mode       = "lines", 
    hoverinfo  = "none",
    width      = width,
    height     = height
  )                                        %>%
    # Passing data prepared early at the beginning of the function, using JSON, to fire events on click on points
    plotly::add_markers(
      data       = gg_data[[2]],
      x          = ~x, 
      y          = ~y, 
      customdata = ~image,
      text       = ~text, 
      hoverinfo  = "text"
    )                                      %>%
    # Passing the annotations for display on layout
    plotly::add_text(
      data  = data_annotations,
      x     = ~ (x + shift_x),
      y     = ~ (y + shift_y),
      text  = ~annotation,
      color = I(color)
    )                                      %>%
    # Aestical options
    plotly::layout(
      xaxis         = list(title = "", zeroline = FALSE, showline = FALSE, showticklabels = FALSE, showgrid = FALSE), 
      yaxis         = list(title = "", zeroline = FALSE, showline = FALSE, showticklabels = FALSE, showgrid = FALSE),
      colorway      = color,
      showlegend    = FALSE,
      plot_bgcolor  = background_color,
      paper_bgcolor = background_color,
      hoverlabel    = list(align = "left")
    )%>%
    # Associate with JS tooltip
    htmlwidgets::onRender(readLines(paste(script_path,"tooltip.js",sep="/"))) %>%
    # Generate the HTML bundle
    plotly::partial_bundle() %>%
    htmlwidgets::saveWidget(
      widget        = .,
      file          = configuration$output_file,
      selfcontained = FALSE,
      libdir        = configuration$lib_folder,
      background    = configuration$background_color
    )

}
