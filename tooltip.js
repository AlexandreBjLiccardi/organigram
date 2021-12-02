/*
  When an event is fired, due to a node click on graph, the generic function "firePres" is launched.
  This function is already defined in the HTML part of the project (org_resp.js) and manages individual data for each node / person.
*/function(el) {
  el.on('plotly_click', function(d) {
   if( d.points[0].customdata!=null)firePres(JSON.parse( d.points[0].customdata)["unique_code"][0]);
  });}
