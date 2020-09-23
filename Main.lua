local GUI = require("GUI")
local system = require("System")
local color = require("Color")
local event = require("event")
local filesystem = require("filesystem")
if not component.isAvailable("tape_drive") then
  GUI.alert("no tape drive")
  window:remove()
else
  tape = component.get("tape_drive")
end

local settings = {}

local version = "v1.3"

local function loadSettings()
  if (filesystem.exists("/Users/dart/Application data/TAPAMP/Config.cfg")) then
    settings = filesystem.readTable("/Users/" .. system.getUser() .. "/Application data/TAPAMP/Config.cfg")
  else
    settings["volume"] = 0.5
    settings["speed"] = 3
    settings["window_posx"] = 50 
    settings["window_posy"] = 70  
  end
end

loadSettings()
--GUI.alert(settings["volume"])
local function getTapeName()
  if (tape.getLabel() == nil) then
    return "No tape"
  else
    if (string.len(tape.getLabel()) > 0) then
      return tape.getLabel()
    else
      return "No name"
    end
  end
end
  
local function setSpeedByComboboxId(id)
  if (id == 1) then
       tape.setSpeed(0.25)
  end
  if (id == 2) then
     tape.setSpeed(0.5)
  end
  if (id == 3) then
     tape.setSpeed(1)
  end
  if (id == 4) then
     tape.setSpeed(1.5)
  end
  if (id == 5) then
     tape.setSpeed(2)
  end
end

local function getTapePos()
  if (tape.getPosition() == 0.0) then 
    return 0
  else
    return tape.getPosition() / tape.getSize() * 100
  end
end 

local workspace, window, menu = system.addWindow(GUI.titledWindow(1, 1, 60, 14, "TAPAMP"))

--window.x = settings["window_posx"] Not work
--window.y = settings["window_posy"]

window.actionButtons.maximize:remove()

local function renameTape()
  local renameTapePanel = window:addChild(GUI.panel(1, 2, window.width, window.height, 0x262626))
  local renameTapeInput = window:addChild(GUI.input(3, 4, 57, 3, 0xEEEEEE, 0x555555, 0x999999, 0xFFFFFF, 0x2D2D2D, '' , "New tape name"))
  local renameTapeOkButton = window:addChild(GUI.button(3, 9, 7, 3, 0xFFFFFF, 0x555555, 0x880000, 0xFFFFFF, "OK"))
  local renameTapeCancelButton = window:addChild(GUI.button(11, 9, 7, 3, 0xFFFFFF, 0x555555, 0x880000, 0xFFFFFF, "Cancel"))
  
   renameTapeOkButton.onTouch =
    function()
      tape.setLabel(renameTapeInput.text)
      renameTapePanel:remove()
      renameTapeInput:remove()
      renameTapeOkButton:remove()
      renameTapeCancelButton:remove()
    end
    
  renameTapeCancelButton.onTouch = 
    function()
      renameTapePanel:remove()
      renameTapeInput:remove()
      renameTapeOkButton:remove()
      renameTapeCancelButton:remove()
    end
end


window:addChild(GUI.panel(1, 2, 60, 14, 0x9992BF))
window:addChild(GUI.panel(4, 3, 18, 5, 0x000000))
window:addChild(GUI.panel(24, 3, 34, 1, 0x000000))

local contextMenu = menu:addContextMenuItem("Cassette")
contextMenu:addItem("Rename tape").onTouch = function() renameTape() end
contextMenu:addSeparator()

local layout = window:addChild(GUI.layout(1, 1, window.width, window.height, 1, 1))

window:addChild(GUI.text(56, 14, 0x111111, version))

local casseteLabel = window:addChild(GUI.text(25, 3, 0x33DB40, "Cassette Label"))

casseteLabel.text = getTapeName()

local tapePosSlider = window:addChild(GUI.slider(4, 9, 54, 0xFFC940, 0x0, 0xFFFFFF, 0xAAAAAA, 0, 100, 50, false))

tapePosSlider.value = getTapePos()

tapePosSlider.onValueChanged = function()
  tape.seek((tape.getSize() / 100 * tapePosSlider.value) - tape.getPosition())
end

window:addChild(window:addChild(GUI.text(24, 5, 0x000000, "Speed:")))

tape.setSpeed(1) --temporary solution, need to implement settings in appdata

local tapeSpeedcomboBox = window:addChild(GUI.comboBox(32, 5, 10, 1, 0xEEEEEE, 0x2D2D2D, 0xCCCCCC, 0x888888))
tapeSpeedcomboBox:addItem("0.25x")
tapeSpeedcomboBox:addItem("0.5x")
tapeSpeedcomboBox:addItem("1x").onTouch = function() end
tapeSpeedcomboBox:addItem("1.5x")
tapeSpeedcomboBox:addItem("2x")
tapeSpeedcomboBox.selectedItem = settings["speed"]
setSpeedByComboboxId(settings["speed"]) --temporary solution, need to implement settings in appdata

tapeSpeedcomboBox.onItemSelected = 
  function(speed) 
    setSpeedByComboboxId(speed)
  end

window:addChild(window:addChild(GUI.text(24, 7, 0x000000, "Volume:")))

local tapeVolumeSlider = window:addChild(GUI.slider(32, 7, 26, 0xFF9240, 0x0, 0xFFFFFF, 0xAAAAAA, 0, 100, settings["volume"] * 100, false))

tapeVolumeSlider.onValueChanged = function()
  tape.setVolume(tapeVolumeSlider.value / 100)
end
 
tape.setVolume(settings["volume"]) --temporary solution, need to implement settings in appdata

local tapeRewindButton = window:addChild(GUI.button(4, 11, 8, 3, 0xFFFFFF, 0x555555, 0x880000, 0xFFFFFF, "<<"))

tapeRewindButton.onTouch = function()
  tape.stop()
  tape.seek(-tape.getSize())
end

local tapePlayButton = window:addChild(GUI.button(4+8+1, 11, 8, 3, 0xFFFFFF, 0x555555, 0x880000, 0xFFFFFF, "|>"))

tapePlayButton.onTouch = function()
  casseteLabel.text = getTapeName()
  if tape.getState() == "PLAYING" then
  else
    tape.play()
  end
end

local tapePauseButton = window:addChild(GUI.button(4+8*2+1*2, 11, 8, 3, 0xFFFFFF, 0x555555, 0x880000, 0xFFFFFF, "||"))

tapePauseButton.onTouch = function()
  if tape.getState() == "STOPPED" then
    else
      tape.stop()
  end
end

local tapeRewindFlashButton = window:addChild(GUI.button(4+8*3+1*3, 11, 8, 3, 0xFFFFFF, 0x555555, 0x880000, 0xFFFFFF, ">>"))

tapeRewindFlashButton.onTouch = function()
  tape.seek(tape.getSize())
end

--local tapeRepeatMode = window:addChild(GUI.button(4+35+1*6, 12, 8, 1, 0xFFFFFF, 0x555555, 0x880000, 0xFFFFFF, "Repeat"))
--local tapeRepeatMode = window:addChild(GUI.button(4+35+1*6, 12, 8, 1, 0xFFFFFF, 0x555555, 0x880000, 0xFFFFFF, "Repeat"))
--tapeRepeatMode.switchMode = true

local handlerUpdate = event.addHandler(function() Update() end, 0.5)

window.actionButtons.close.onTouch = function()  onClose(handlerUpdate, window) end

function Update()
  tapePosSlider.value = getTapePos()
end

local function saveSettings()
  settings["volume"] = tapeVolumeSlider.value / 100
  settings["speed"] = tapeSpeedcomboBox.selectedItem
  settings["window_posx"] = window.x 
  settings["window_posy"] = window.y 
  
  filesystem.writeTable("/Users/" .. system.getUser() .. "/Application data/TAPAMP/Config.cfg", settings)
end

function onClose(_handlerUpdate, _window)
  event.removeHandler(_handlerUpdate)
  _window:remove()
  saveSettings()
end

workspace:draw()
