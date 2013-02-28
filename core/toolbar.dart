/*
 * NetTango
 * Northwestern University
 * michael-horn@northwestern.edu
 * Copyright 2013, Michael S. Horn and Uri Wilensky
 *
 * This project was funded in part by the National Science Foundation.
 * Any opinions, findings and conclusions or recommendations expressed in this
 * material are those of the author(s) and do not necessarily reflect the views
 * of the National Science Foundation (NSF).
 */
part of NetTango;


class Toolbar {

  
  Model model; // used to control the model
  String id; // html id for toolbar div tag

   
  Toolbar(this.model) {
    
    id = "div#${model.id}-toolbar";
    
    ButtonElement button;
    
    button = document.query("$id #play-button");
    if (button != null) button.onClick.listen((evt) => playPause());
            
    button = document.query("$id #fastforward-button");
    if (button != null) button.onClick.listen((evt) => model.fastForward());
      
    button = document.query("$id #stepforward-button");
    if (button != null) button.onClick.listen((evt) => model.stepForward());
      
    button = document.query("$id #restart-button");
    if (button != null) button.onClick.listen((evt) => model.restart());
  }
  
  
  void playPause() {
    ButtonElement el = document.query("$id #play-button");
    if (model.isPaused) {
      model.play(1);
      if (el != null) el.style.backgroundImage = "url('images/pause.png')";
    } else {
      model.pause();
      if (el != null) el.style.backgroundImage = "url('images/play.png')";
    }   
  }

  
  void update() {
    Element el = document.query("$id #tick-count");
    if (el != null) {
      el.innerHtml = "tick: ${model.ticks}";
    }    
  }
}