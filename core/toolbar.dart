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
    if (model.isPaused) {
      model.play(1);
    } else {
      model.pause();
    }   
  }

  
  void update() {
    Element el = document.query("$id #tick-count");
    if (el != null) {
      el.innerHtml = "tick: ${model.ticks}";
    }
    ButtonElement button = document.query("$id #play-button");
    if (button != null) {
      bool paused = button.style.backgroundImage.contains('images/play.png');
      if (model.isPaused && !paused) {
        button.style.backgroundImage = "url('images/play.png')";
      } else if (!model.isPaused && paused) {
        button.style.backgroundImage = "url('images/pause.png')";
      }
    }
  }
}