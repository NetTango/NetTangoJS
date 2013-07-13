/*
 * NetTango
 * Northwestern University
 *
 * This project was funded in part by the National Science Foundation.
 * Any opinions, findings and conclusions or recommendations expressed in this
 * material are those of the author(s) and do not necessarily reflect the views
 * of the National Science Foundation (NSF).
 */
part of NetTango;


void setHtmlOpacity(String id, num opacity) {
  Element el = document.query("#${id}");
  if (el != null) {
    el.style.opacity = "$opacity";
  }
}


num getHtmlOpacity(String id) {
  Element el = document.query("#${id}");
  if (el != null) {
    String o = el.style.opacity;
    if (o == null || o == '') {
      return 1.0;
    } else {
      return double.parse(o);
    }
  }
}


void setHtmlText(String id, String message) {
  Element el = document.query("#${id}");
  if (el != null) {
    el.innerHtml = message;
  }
}


void setHtmlVisibility(String id, bool visible) {
  Element el = document.query("#${id}");
  if (el != null) {
    el.style.visibility = visible ? "visible" : "hidden";
  }
}


/**
 * Binds a click event to a button or other HTML element
 */
void bindClickEvent(String id, Function callback) {
  Element el = document.query("#${id}");
  if (el != null) {
    el.onTouchEnd.listen(callback);    
    el.onClick.listen(callback);
  }
}


void showStatusMessage(String message) {
  setHtmlText("status", message);
  setHtmlOpacity("status", 1.0);
}


void hideStatusMessage() {
  setHtmlOpacity("status", 0.0);
}
