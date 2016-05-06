--[[
 * ReaScript Name: Insert new empty item at cursor on selected track
 * Description: See title
 * Instructions: - Place edit cursor where you need your new item to begin
                 - Select the dedicated track for your item
                 - Select the number of measures you need with the slider, then OK
 * Author: BenF
 * Author URI: 
 * Repository: 
 * Repository URI: 
 * File URI: 
 * Licence: GPL v3
 * Forum Thread: Script: Script name
 * Forum Thread URI: http://forum.cockos.com/***.html
 * REAPER: 5.18
 * Extensions: None
 * Version: 1.0
]]-- 

--[[
 * Changelog:
 * v1.0 (2016-05-06)
  + Initial Release
]]--

----------------------------------------------------------------------------------
-- variables definition
itemSize = 1

selTracks = reaper.CountSelectedTracks(0) 
selItems = reaper.CountSelectedMediaItems(0)

window = {width = 300, height = 240, title = "New items creation", font = "Arial"}
display = {ox = 0, oy = 0, width = 50, height = 50, fontsize = 50}
btnOK = {ox = 0, oy = 0, width = 50, height = 30, fontsize = 30, text = "OK"}
slider = {ox = 0, oy = 0, width = 250, height = 30}
cursor = {ox = 0, oy = 0, width = 20, height = 50, min = 1, max = 50}
interval = {horizontal = 0, vertical = 0}
mouse = {ox = 0, oy = 0, cursorclick = false, btnOKclick = false, step = slider.width / cursor.max}
---------------------------------------------------------------------------------
-- ************
-- * X-RAYM's * 
-- ************
function CreateTextItem(track, position, length, text, color)
    
  local item = reaper.AddMediaItemToTrack(track)
  
  reaper.SetMediaItemInfo_Value(item, "D_POSITION", position)
  reaper.SetMediaItemInfo_Value(item, "D_LENGTH", length)
  
  if text then
    reaper.ULT_SetMediaItemNote(item, text)
  end
  if color then
    reaper.SetMediaItemInfo_Value(item, "I_CUSTOMCOLOR", color)
  end
  return item
end

function GetPlayOrEditCursorPos()
  local play_state = reaper.GetPlayState()
  local cursor_pos
  if play_state == 1 then
    cursor_pos = reaper.GetPlayPosition()
  else
    cursor_pos = reaper.GetCursorPosition()
  end
  return cursor_pos
end

-- *********************
-- * X-RAYM's modified * 
-- *********************
function GetMeasureLength(measure_begin) -- from edit cursor or play position
  local retval, measures, cml, fullbeats, cdenom = reaper.TimeMap2_timeToBeats(0, measure_begin)
  local current_measure = reaper.TimeMap2_beatsToTime(0, fullbeats)
  local next_measure = reaper.TimeMap2_beatsToTime(0, fullbeats + cml)
  return next_measure - current_measure
end

-- ****************
-- * X-RAYM's end * 
-- ****************

-----------------------------------------------------------------------
function CreateItemOnEachTrack()
  local length = 0
  local cursor_pos = GetPlayOrEditCursorPos()
  -- defines creation zone limits
  for i = 0, itemSize - 1 do
    length = length + GetMeasureLength(cursor_pos)
    cursor_pos = cursor_pos + length
  end
  
  -- create an item on each track
  for i = 0 , selTracks - 1 do
    track = reaper.GetSelectedTrack(0, i)
    CreateTextItem(track, position, length)
  end
end

-----------------------------------------------------------------------
function InitWindow()
-- init values
  interval.horizontal = (window.width - display.width - btnOK.width) / 3
  interval.vertical = (window.height - display.height - slider.height) / 3
  slider.width = slider.width + cursor.width - 5
  slider.ox = (window.width - slider.width) / 2
  slider.oy = interval.vertical
  cursor.ox = slider.ox
  cursor.oy = interval.vertical + (slider.height / 2) - (cursor.height / 2)
  cursor.min = slider.ox
  cursor.max = slider.ox + slider.width - cursor.width
  display.ox = interval.horizontal
  display.oy = (2 * interval.vertical) + slider.height
  btnOK.ox = (2 * interval.horizontal) + display.width
  btnOK.oy = display.oy + (display.height / 2) - (btnOK.height / 2)
  
-- window creation
  gfx.init(window.title, window.width, window.height)
  UpdateGUI()
end

------------------------------------------------------------------------------------
-- update item size value
function UpdateGUI()
  -- slider creation
  gfx.set(1, 0, 0, 0.8)
  gfx.rect(slider.ox, slider.oy, slider.width, slider.height, false)
  -- cursor creation
  gfx.set(1, 1, 0, 0.8)
  gfx.roundrect(cursor.ox, cursor.oy, cursor.width, cursor.height, 2)
  -- value display creation
  gfx.set(1, 1, 1, 0.8)
  gfx.rect(display.ox, display.oy, display.width, display.height, true)
  -- OK button creation
  gfx.set(0.8, 1, 1, 0.9)
  gfx.rect(btnOK.ox, btnOK.oy, btnOK.width, btnOK.height, true)
  -- OK in button
  gfx.set(0, 0, 0, 0.8)
  gfx.setfont(1, window.font, btnOK.fontsize, "b")
  gfx.x = btnOK.ox + 7
  gfx.y = btnOK.oy + 1
  gfx.drawstr(btnOK.text)
  -- value
  gfx.setfont(1, window.font, display.fontsize, "b")
  if itemSize < 10 then
    gfx.x = display.ox + 25
  else
    gfx.x = display.ox + 1
  end
  gfx.y = display.oy
  gfx.drawnumber(itemSize, 0)
end

------------------------------------------------------------------------------------
-- manages mouse
function Main()
  --aa = GetCurrentMeasureLength()
  
  -- mouse cursor on OK button ?
  if CheckMouseCursor(btnOK.ox, btnOK.oy, btnOK.width, btnOK.height) == true then
    if (gfx.mouse_cap & 1 == 1) and (mouse.cursorclick == false) then
      mouse.btnOKclick = true 
      CreateItemOnEachTrack()
      reaper.atexit(gfx.quit)
    end   
  end
   
  -- mouse cursor on slider cursor ?
  if CheckMouseCursor(cursor.ox, cursor.oy, cursor.width, cursor.height) == true then
    if gfx.mouse_cap & 1 == 1 then
      if mouse.cursorclick == false then 
        mouse.cursorclick = true 
      end
    end
  end
  
  if mouse.cursorclick == true then
    if gfx.mouse_cap & 1 == 0 then
      mouse.cursorclick = false
    end
  end
  
  -- sets the cursor to its new position
  if mouse.cursorclick == true then
    mouse.ox = gfx.mouse_x
    newpos = mouse.ox - cursor.width / 2
    if newpos < cursor.min then
      cursor.ox = cursor.min
    elseif newpos > cursor.max then
      cursor.ox = cursor.max
    else
      cursor.ox = newpos
    end
    itemSize = math.floor(((cursor.ox - slider.ox) / mouse.step) + 1)
  end
  UpdateGUI() 

  --resultat = reaper.ShowMessageBox("click", "", 0)
  gfx.update()
  if mouse.btnOKclick == false then
    reaper.defer(Main) 
  end
  
end

-- checks if mouse cursor is inside limits
function CheckMouseCursor(ox, oy, width, height)
    --resultat = reaper.ShowMessageBox("runloop", "", 0)
  local retour = false
  if gfx.mouse_x >= ox and gfx.mouse_x <= (ox + width) then
    if gfx.mouse_y >= oy and gfx.mouse_y <= (oy + height) then
      retour = true
    end
  end
  return retour
end

-----------------------------------------------------------------------
InitWindow()
position = GetPlayOrEditCursorPos()
Main()
-----------------------------------------------------------------------
