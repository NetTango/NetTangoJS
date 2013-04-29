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


class Plot {
  
  String id;         // <div> tag id where this plot will appear
  String title = ""; // title of this plot
  String labelX;     // x-axis label
  num minX;          // minimum x-value
  num maxX;          // maximum x-value
  num minY;          // minimum y-value
  num maxY;          // maximum y-value
  
  num width = 200;   // window width
  num height = 200;  // window height
  
  List<Pen> pens = new List<Pen>();
  List rows = new List();  // list of data rows

  
  Plot(this.id);
  
  
//----------------------------------------------------------------------------
// Adding a pen adds a data line to the plot
//----------------------------------------------------------------------------
  void addPen(Pen pen) {
    pens.add(pen);
  }
  
  
//----------------------------------------------------------------------------
// Clears the plot
//----------------------------------------------------------------------------
  void clear() {
    rows.clear();
  }
  
  
//----------------------------------------------------------------------------
// Update the plot display with new data row
//----------------------------------------------------------------------------
  void update(int tick) {
    
    List<num> row = new List<num>();
    row.add(tick);
    for (Pen pen in pens) {
      row.add(pen.getDataPoint(tick));
    }
    rows.add(row);
    autoScale(row);

    // plot window <div> dimensions
    Element container = document.query("#$id");
    width = container.clientWidth;
    height = container.clientHeight;
    
    var plot = new svg.SvgSvgElement();
    plot.attributes = { "width": "$width", "height": "$height", "version": "1.1" };
    plot.nodes.add(_drawWindow());
    plot.nodes.add(_drawXAxis());
    plot.nodes.add(_drawYAxis());
    plot.nodes.add(_drawTitle());
    plot.nodes.add(_drawDataLines());
    container.nodes.clear();
    container.nodes.add(plot);
  }

  
//----------------------------------------------------------------------------
// Auto scale 
//----------------------------------------------------------------------------
  void autoScale(List<num> row) {
    
    if (minX == null || minX > row[0]) minX = row[0];
    
    if (maxX == null) {
      maxX = row[0] + 10;
    } else if (maxX < row[0] * 1.2) {
      maxX *= 2;
    }
    
    for (int i=1; i<row.length; i++) {
      if (minY == null || minY > row[i]) minY = row[i];
      if (maxY == null) {
        maxY = row[i] * 1.2;
      } else if (maxY < row[i] * 1.2) {
        maxY = row[i] * 1.5;
      }
    }
  }

  
//----------------------------------------------------------------------------
// Draw plot window outline
//----------------------------------------------------------------------------
  svg.SvgElement _drawWindow() {

    svg.RectElement rect = new svg.RectElement();
    num x = plotToScreenX(minX);
    num w = plotToScreenX(maxX) - x;
    num y = plotToScreenY(maxY);
    num h = plotToScreenY(minY) - y;
    rect.attributes = {
      "fill": "white",
      "fill-opacity" : "0.7",
      "x": "$x", "y": "$y", "width": "$w", "height": "$h" };
    return rect;
  }

  
//----------------------------------------------------------------------------
// Draw data lines
//----------------------------------------------------------------------------
  svg.GElement _drawDataLines() {
    svg.GElement g = new svg.GElement();
    for (int p=0; p<pens.length; p++) {
      Pen pen = pens[p];
      
      var line = new svg.PolylineElement();
      line.attributes = {
        "stroke" : pen.color,
        "stroke-width" : "2",
        "fill": "none" };
    
      String points = "";
      for (List row in rows) {
        num x = plotToScreenX(row[0]);
        num y = plotToScreenY(row[p+1]);
        points = points + "$x,$y ";
      }
      line.attributes["points"] = points;
      g.nodes.add(line);
    }
    return g;
  }
  
  
//----------------------------------------------------------------------------
// Draw plot title
//----------------------------------------------------------------------------
  svg.TextElement _drawTitle() {
    var t = new svg.TextElement();
    t.text = title;
    t.attributes = {
      "x" : "${plotToScreenX(minX)}", "y" : "30",
      "font-weight" : "bold",
      "text-anchor" : "start",
      "font-size" : "12pt"
    };
    return t;
  }


//----------------------------------------------------------------------------
// Generate y-axis labels
//----------------------------------------------------------------------------  
  svg.GElement _drawYAxis() {
    num stepY = (maxY - minY) / 4;
    var labels = new svg.GElement();
    labels.attributes = {
        "font-size" : "11pt",
        "text-anchor" : "end",
        "fill" : "black"
    };
    
    // y-labels
    for (num i=minY; i<=maxY; i += stepY) {
      num x1 = plotToScreenX(minX);
      num x2 = plotToScreenX(maxX);
      num y1 = plotToScreenY(i);
      
      var yLabel = new svg.TextElement();
      yLabel.text = "${i.toInt()}";
      yLabel.attributes = { "x" : "${x1 - 10}", "y" : "${y1 + 5}" };
      labels.nodes.add(yLabel);
      
      var line = new svg.LineElement();
      line.attributes = { "x1": "$x1", "y1": "$y1", "x2": "$x2", "y2": "$y1", "stroke": "#999" };
      labels.nodes.add(line);
    }
    
    return labels;
  }
  
  
//----------------------------------------------------------------------------
// Generate x-axis labels
//----------------------------------------------------------------------------  
  svg.GElement _drawXAxis() {
    num stepX = (maxX - minX) / 4;
    svg.GElement labels = new svg.GElement();
    labels.attributes = {
        "font-size" : "11pt",
        "text-anchor" : "middle",
        "fill" : "black"
    };
    
    // x-axis label
    if (labelX != null) {
      var t = new svg.TextElement();
      t.text = labelX;
      t.attributes = {
        "x" : "${plotToScreenX((minX + maxX) / 2)}",
        "y" : "${plotToScreenY(minY) + 36}",
        "font-weight" : "bold",
      };
      labels.nodes.add(t);
    }
    
    // x-labels
    for(num i=minX + stepX; i<=maxX; i += stepX) {
      var xLabel = new svg.TextElement();
      xLabel.text = "${i.toInt()}";
      xLabel.attributes = {
        "x": "${plotToScreenX(i)}",
        "y": "${plotToScreenY(minY) + 15}",
      };
      labels.nodes.add(xLabel);
    }
    return labels;
  }
  
  
//----------------------------------------------------------------------------
// Convert plot to screen coordinates
//----------------------------------------------------------------------------
  num plotToScreenX(num px) {
    num scaleX = (width - 100) / (maxX - minX);
    return ((px - minX) * scaleX).toInt() + 50.5;
  }
  
  num plotToScreenY(num py) {
    num scaleY = (height - 100) / (maxY - minY);
    return (height - 50.5) - ((py - minY) * scaleY).toInt();
  }
}


/**
 * Data Pen for drawing plots
 */
class Pen {
  
  String color;
  String name;
  var updater = null;  
  
  Pen(this.name, this.color);
  
  
  num getDataPoint(int tick) {
    if (updater != null) {
      return updater(tick);
    } else {
      return 0;
    }
  }
}