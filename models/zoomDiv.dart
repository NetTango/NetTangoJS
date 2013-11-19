import 'dart:html';

Element e1, e2, e3, e4;
String zoomedClass = "";

void main() {
  e1 = document.querySelector("#test1");
  e1.classes.add("test1");
  e2 = document.querySelector("#test2");
  e2.classes.add("test2");
  e3 = document.querySelector("#test3");
  e3.classes.add("test3");
  e4 = document.querySelector("#test4");
  e4.classes.add("test4");
  
  e1.onMouseDown.listen( zoomIt );
  e2.onMouseDown.listen( zoomIt );
  e3.onMouseDown.listen( zoomIt );
  e4.onMouseDown.listen( zoomIt );
}


void zoomIt( MouseEvent event ) {
  zoomedClass = event.target.id;
  Element e = document.querySelector("#"+zoomedClass);
  e.classes.remove("part");
  e.classes.remove(zoomedClass);
  e.classes.add("whole");
  e.onMouseDown.listen(unZoom);
  e.removeEventListener("mousedown", zoomIt);
}

void unZoom(MouseEvent event) {
  Element currentBig = document.querySelector("#"+zoomedClass);
  currentBig.classes.remove("whole");
  currentBig.classes.add(zoomedClass);
  currentBig.classes.add("part");
  currentBig.onMouseDown.listen(zoomIt);
  zoomedClass = "";
  currentBig.removeEventListener("mousedown", unZoom);
}