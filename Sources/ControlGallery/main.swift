import ui

// Initialize libui
var options = ui.InitOptions()
if let err = ui.initialize(options:&options) {
	print("Error initializing LibUI: \(err)")
}

// Menus cannot be created after the window is created, but we need a
// reference to the window in the click handlers, so the menus are built here,
// but the handlers are added later
var menu: ui.Menu;
var item: ui.MenuItem;

menu = ui.Menu(title:"File")
let openItem = menu.appendItem("Open")
let saveItem = menu.appendItem("Save")
let quitItem = menu.appendQuit()

menu = ui.Menu(title:"Edit")
item = menu.appendItem("Checkable Item", checkable:true)
item = menu.appendItem("Disabled Item")
item.disable()
menu.appendSeparator()
item = menu.appendPreferences()

menu = ui.Menu(title:"Help")
item = menu.appendItem("Help")
item = menu.appendAbout()

// Create the main window
let mainwin = ui.Window(title:"libui-swift Control Gallery", width:640, height:480, withMenu:false)
mainwin.margined = true
mainwin.on(closing: {
	ui.quit()
	return 0
})

// Add the menu item click handlers
openItem.on(clicked: {
	if let filename = ui.openFile(parent:mainwin) {
		ui.messageBox(parent:mainwin, title:"File Selected", description:filename)
	} else {
		ui.messageBox(parent:mainwin, title:"No file selected", description:"Don't be alarmed!")
	}

})

saveItem.on(clicked: {
	if let filename = ui.saveFile(parent:mainwin) {
		ui.messageBox(parent:mainwin, title:"File selected (don't worry, it's still there)", description:filename)
	} else {
		ui.messageBox(parent:mainwin, title:"No file selected", description:"Don't be alarmed!")
	}

})

ui.on(shouldQuit: {
	mainwin.destroy()
	return true
})

// Build all the controls and add them to the window
let vbox = ui.Box(.Vertical)
vbox.padded = true

let hbox = ui.Box(.Horizontal)
hbox.padded = true
vbox.append(hbox, stretchy:true)

var group = ui.Group(title:"Basic Controls")
group.margined = true
hbox.append(group)

var inner = ui.Box(.Vertical)
inner.padded = true
group.set(child:inner)

inner.append(ui.Button(text:"Button"))
inner.append(ui.Checkbox(text:"Checkbox"))

let entry = ui.Entry()
entry.text = "Entry"
inner.append(entry)

inner.append(ui.Label(text:"Label"))
inner.append(ui.Separator())
inner.append(ui.DateTimePicker(type:Picker.Date))
inner.append(ui.DateTimePicker(type:Picker.Time))
inner.append(ui.DateTimePicker(type:Picker.DateTime))
inner.append(ui.FontButton())
inner.append(ui.ColorButton())

let inner2 = ui.Box(.Vertical)
inner2.padded = true
hbox.append(inner2, stretchy:true)

group = ui.Group(title:"Numbers")
group.margined = true
inner2.append(group)

inner = ui.Box(.Vertical)
inner.padded = true
group.set(child:inner)

let spinbox = ui.Spinbox(min:0, max:100)
inner.append(spinbox)

let slider = ui.Slider(min:0, max:100)
inner.append(slider)

let progressbar = ui.ProgressBar()
inner.append(progressbar)

// Link the spinbox and slider together, and give their value to the progress bar
spinbox.on(changed: {
	slider.value = spinbox.value
	progressbar.set(value:spinbox.value)
})
slider.on(changed: {
	spinbox.value = slider.value
	progressbar.set(value:slider.value)
})

group = ui.Group(title:"Lists")
group.margined = true
inner2.append(group)

inner = ui.Box(.Vertical)
inner.padded = true
group.set(child:inner)

let cbox = ui.Combobox()
cbox.append(text:"Combobox Item 1")
cbox.append(text:"Combobox Item 2")
cbox.append(text:"Combobox Item 3")
inner.append(cbox)

let ecbox = ui.EditableCombobox()
ecbox.append(text:"Editable Item 1")
ecbox.append(text:"Editable Item 2")
ecbox.append(text:"Editable Item 3")
inner.append(ecbox)

// Adding the radio buttons causes the left column to stretch and the right
// column to be fixed, when it should be the other way around. I'm not sure the
// cause of this issue, but it seems it would be in libui
let rb = ui.RadioButtons()
rb.append(text:"Radio Button 1")
rb.append(text:"Radio Button 2")
rb.append(text:"Radio Button 3")
inner.append(rb, stretchy:true)

let tab = ui.Tab()
tab.append(name:"Page 1", child:ui.Box(.Horizontal))
tab.append(name:"Page 2", child:ui.Box(.Horizontal))
tab.append(name:"Page 3", child:ui.Box(.Horizontal))
inner2.append(tab, stretchy:true)

mainwin.set(child:vbox)
mainwin.margined = true

// Show the main window
mainwin.show()

// Start the main event loop
ui.main()
