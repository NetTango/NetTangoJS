import 'dart:html';

Element e1, e2, e3, e4;
String biggedClass = "";

void main() {
  
  print("hi");
  e1 = document.querySelector("#test1");
  e1.style.visibility= "visible";
  e1.classes.add("test1");
  e2 = document.querySelector("#test2");
  e2.style.visibility= "visible";
  e2.classes.add("test2");
  e3=document.querySelector("#test3");
  e3.style.visibility= "visible";
  e3.classes.add("test3");
  e4=document.querySelector("#test4");
  e4.style.visibility= "visible";
  e4.classes.add("test4");
  print("there");
  
  e1.onMouseDown.listen( zoomIt );
  e2.onMouseDown.listen( zoomIt );
  e3.onMouseDown.listen( zoomIt );
  e4.onMouseDown.listen( zoomIt );
}


void zoomIt( MouseEvent event ) {
  biggedClass = event.target.id;
  Element e = document.querySelector("#"+biggedClass);
  e.classes.remove("part");
  e.classes.remove(biggedClass);
  e.classes.add("whole");
  e.onMouseDown.listen(unZoom);
  e.removeEventListener("mousedown", zoomIt);
}

void unZoom(MouseEvent event) {
  Element currentBig = document.querySelector("#"+biggedClass);
  currentBig.classes.remove("whole");
  currentBig.classes.add("part");
  currentBig.classes.add(biggedClass);
  currentBig.onMouseDown.listen(zoomIt);
  biggedClass = "";
  currentBig.removeEventListener("mousedown", unZoom);
}