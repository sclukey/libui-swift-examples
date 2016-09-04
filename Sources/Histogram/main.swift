import ui

// Get a random integer function
#if os(Linux)
import Glibc
func rand(max:Int) -> Int {
	return Int(random() % (max + 1))
}
#else
import Darwin
func rand(max:Int) -> Int {
	return Int(arc4random_uniform(UInt32(max)))
}
#endif

// MARK: Global definitions

// These are the margins of the histogram off the border of the area
let xoffLeft:Double = 20
let yoffTop:Double = 20
let xoffRight:Double = 20
let yoffBottom:Double = 20

// This is the size of the circle that is shown when hovering over a data point
let pointRadius:Double = 5

// Some basic color definitions
let ColorWhite:UInt32 = 0xFFFFFF
let ColorBlack:UInt32 = 0x000000
let ColorDodgerBlue:UInt32 = 0x1E90FF

// These are the spinboxes with the data points
var datapoints:[ui.Spinbox] = []

// This indicates the point that is currently under the cursor (-1 if none)
var currentPoint:Int = -1

// MARK: Helper Functions

// Sets `brush` to a color defined by an unsigned integer (usually a Hex number).
func setSolidBrush(brush:inout ui.DrawBrush, color:UInt32, alpha:Double) -> Void {
	brush.type = .Solid

	brush.r = Double((color >> 16) & 0xFF) / 256
	brush.g = Double((color >>  8) & 0xFF) / 256
	brush.b = Double( color        & 0xFF) / 256
	brush.a = alpha
}

// Return the locations of the points based on the spinbox values
func pointLocations(width:Double, height:Double) -> (xs:[Double], ys:[Double]) {
	var xincr:Double
	var yincr:Double
	var n:Int

	var xs:[Double] = Array(repeating:0, count:10)
	var ys:[Double] = Array(repeating:0, count:10)

	xincr = width / 9
	yincr = height / 100

	for i in 0..<10 {
		// Get the point value
		n = datapoints[i].value
		n = 100 - n

		xs[i] = xincr * Double(i)
		ys[i] = yincr * Double(n)
	}

	return (xs, ys)
}

// Draw the graph's line, optionally closing the loop
func constructGraph(size:(width:Double, height:Double), extend:Bool) -> ui.DrawPath {
	let path = ui.DrawPath(fillMode:.Winding)

	let (xs, ys) = pointLocations(width:size.width, height:size.height)

	path.newFigure(at:(xs[0], ys[0]))
	for i in 1..<xs.count {
		path.lineTo(point:(xs[i], ys[i]))
	}

	if extend {
		path.lineTo(point:(size.width, size.height))
		path.lineTo(point:(0, size.height))
		path.closeFigure()
	}

	path.end()
	return path
}

// Figure out how big the graph is
func getGraphSize(client:(width:Double, height:Double)) -> (width:Double, height:Double) {
	let graphWidth:Double = client.width - xoffLeft - xoffRight
	let graphHeight:Double = client.height - yoffTop - yoffBottom

	return (graphWidth, graphHeight)
}

// Check if a given point is within `pointRadius` from the test point
func inLocation(point:(x:Double, y:Double), testPoint test:(x:Double, y:Double)) -> Bool {
	let x = point.x - xoffLeft
	let y = point.y - yoffTop

	return (x >= test.x - pointRadius) &&
	       (x <= test.x + pointRadius) &&
	       (y >= test.y - pointRadius) &&
	       (y <= test.y + pointRadius)
}


// MARK: main

// Initialize libui
var options = ui.InitOptions()
if let err = ui.initialize(options:&options) {
	print("Error initializing LibUI: \(err)")
}

// Create the main window
let mainwin = ui.Window(title:"libui-swift Histogram Example", width:640, height:480, withMenu:false)
mainwin.margined = true

// Quit the program when this window closes
mainwin.on(closing: {
	ui.quit()
	return 0
})

// Add the spinboxes and color picker
let hbox = ui.Box(.Horizontal)
hbox.padded = true
mainwin.set(child:hbox)

let vbox = ui.Box(.Vertical)
vbox.padded = true
hbox.append(vbox)

// Build the datapoints
for i in 0...9 {
	datapoints.append(ui.Spinbox(min:0, max:100))
	datapoints[i].value = rand(max:100)
	vbox.append(datapoints[i])
}

// Build a brush so we can set the color of the brush to Dodger Blue so we can
// set the value of the color button to Dodger Blue
var brush = ui.DrawBrush()
let colorButton = ui.ColorButton()
setSolidBrush(brush:&brush, color:ColorDodgerBlue, alpha:1.0);
colorButton.color = (brush.r, brush.g, brush.b, brush.a)
vbox.append(colorButton)


// Add the Area that will hold the graph
let handler = ui.AreaHandler()
let histogram = ui.Area(handler:handler);
hbox.append(histogram, stretchy:true)


// MARK: Event Handler

// Redraw when the selected color changes
colorButton.on(changed: {
	histogram.queueRedrawAll()
})

// Redraw when any of the data points change
for spinbox in datapoints {
	spinbox.on(changed: {
		histogram.queueRedrawAll()
	})
}

// Handle redrawing
handler.on(draw: { (area:Area, drawParams:DrawParams) in
	var brush = ui.DrawBrush()

	// Create the white background
	var path = ui.DrawPath(fillMode:.Winding)
	setSolidBrush(brush:&brush, color:ColorWhite, alpha:1.0);
	path.addRectangle(at:(0, 0), withSize:(drawParams.areaWidth, drawParams.areaHeight))
	path.end()
	path.fill(withBrush:brush, inContext:drawParams.context)

	let graphSize = getGraphSize(client:(drawParams.areaWidth, drawParams.areaHeight));

	let strokeParams = ui.StrokeParams()

	strokeParams.cap = .Flat
	strokeParams.join = .Miter
	strokeParams.thickness = 2
	strokeParams.miterLimit = ui.DefaultMiterLimit

	// Draw the axes
	setSolidBrush(brush:&brush, color:ColorBlack, alpha:1.0);
	path = ui.DrawPath(fillMode:.Winding)
	path.newFigure(at:(xoffLeft, yoffTop))
	path.lineTo(point:(xoffLeft, yoffTop + graphSize.height))
	path.lineTo(point:(xoffLeft + graphSize.width, yoffTop + graphSize.height))
	path.end()
	path.stroke(withBrush:brush, andStroke:strokeParams, inContext:drawParams.context)

	// Transform the coordinate space so (0, 0) is the top-left corner of the graph
	let matrix = ui.DrawMatrix()
	matrix.setIdentity()
	matrix.translate(origin:(xoffLeft, yoffTop))
	drawParams.context.transform(matrix:matrix)

	// Get the color for the graph itself and set up the brush
	let graphColor = colorButton.color
	brush.type = .Solid
	brush.r = graphColor.red
	brush.g = graphColor.green
	brush.b = graphColor.blue

	// Draw the graph, extended so it wraps around to the bottom and fills the
	// whole thing
	path = constructGraph(size:graphSize, extend:true);
	brush.a = graphColor.alpha / 2;
	path.fill(withBrush:brush, inContext:drawParams.context)

	// Draw just the line, at full opacity this time
	path = constructGraph(size:graphSize, extend:false);
	brush.a = graphColor.alpha;
	path.stroke(withBrush:brush, andStroke:strokeParams, inContext:drawParams.context)

	// Draw a large circle on the point the mouse is hovering over
	if currentPoint != -1 {
		let (xs, ys) = pointLocations(width:graphSize.width, height:graphSize.height)

		path = ui.DrawPath(fillMode:.Winding)
		path.newFigureWithArc(center: (xs[currentPoint], ys[currentPoint]),
		                      radius: pointRadius,
		                      startAngle: 0,
		                      sweep: 2 * Double.pi,
		                      negative: false)

		path.end()
		path.fill(withBrush:brush, inContext:drawParams.context)
	}
})

// When the mouse moves in the graph Area, check if it is over a data point
// and take note of which one
handler.on(mouseEvent: { (area:Area, mouseEvent:MouseEvent) in
	let graphSize = getGraphSize(client:(mouseEvent.areaWidth, mouseEvent.areaHeight));
	let (xs, ys) = pointLocations(width:graphSize.width, height:graphSize.height)

	let lastPoint = currentPoint
	currentPoint = -1
	for i in 0..<10 {
		if inLocation(point:(mouseEvent.x, mouseEvent.y), testPoint:(xs[i], ys[i])) {
			currentPoint = i
			break
		}
	}

	// Only cause a redraw if there has been a change
	if currentPoint != lastPoint {
		area.queueRedrawAll()
	}
})


// Show the window and start the main event loop
mainwin.show()
ui.main()

// This crashes inside libui
// ui.uninit()
