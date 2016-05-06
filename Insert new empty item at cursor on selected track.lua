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
item_UNSELECT_ALL_ITEMS = 40289
loop_points_SET_START_POINT = 40222
loop_points_SET_END_POINT = 40223
loop_points_REMOVE_LOOP_POINT_SELECTION = 40634
MOVE_EDIT_CURSOR_FORWARD_ONE_MEASURE = 41042
INSERT_EMPTY_ITEM = 40142
action_WAIT_100MS_BEFORE_NEXT_ACTION = 2009

itemSize = 1

selTracks = reaper.CountSelectedTracks(0) 
selItems = reaper.CountSelectedMediaItems(0)
position = reaper.GetCursorPosition()

window = {width = 300, height = 240, title = "New items creation", font = "Arial"}
display = {ox = 0, oy = 0, width = 50, height = 50, fontsize = 50}
btnOK = {ox = 0, oy = 0, width = 50, height = 30, fontsize = 30, text = "OK"}
slider = {ox = 0, oy = 0, width = 250, height = 30}
cursor = {ox = 0, oy = 0, width = 20, height = 50, min = 1, max = 50}
interval = {horizontal = 0, vertical = 0}
mouse = {ox = 0, oy = 0, cursorclick = false, btnOKclick = false, step = slider.width / cursor.max}

-----------------------------------------------------------------------
function init_window()
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
  update_value()
end

------------------------------------------------------------------------------------
-- update item size value
function update_value()
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
function main()

  -- mouse cursor on OK button ?
  if check_mouse_cursor(btnOK.ox, btnOK.oy, btnOK.width, btnOK.height) == true then
    if (gfx.mouse_cap & 1 == 1) and (mouse.cursorclick == false) then
      mouse.btnOKclick = true 
      create_Empty_Item()
      reaper.atexit(gfx.quit)
    end   
  end
   
  -- mouse cursor on slider cursor ?
  if check_mouse_cursor(cursor.ox, cursor.oy, cursor.width, cursor.height) == true then
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
  update_value() 

  --resultat = reaper.ShowMessageBox("click", "", 0)
  gfx.update()
  if mouse.btnOKclick == false then
    reaper.defer(main) 
  end
  
end

-- checks if mouse cursor is inside limits
function check_mouse_cursor(ox, oy, width, height)
    --resultat = reaper.ShowMessageBox("runloop", "", 0)
  local retour = false
  if gfx.mouse_x >= ox and gfx.mouse_x <= (ox + width) then
    if gfx.mouse_y >= oy and gfx.mouse_y <= (oy + height) then
      retour = true
    end
  end
  return retour
end
------------------------------------------------------------------------------------
-- creates empty item(s) from the actual cursor position on the selected track(s) 
function create_Empty_Item()
  if selTracks > 0 then

    if selItems > 0 then
      reaper.Main_OnCommandEx(item_UNSELECT_ALL_ITEMS, 0)
    end

    reaper.Main_OnCommandEx(loop_points_SET_START_POINT, 0)
  
    for i = 1, itemSize do
      reaper.Main_OnCommandEx(MOVE_EDIT_CURSOR_FORWARD_ONE_MEASURE, 0)
      reaper.Main_OnCommandEx(action_WAIT_100MS_BEFORE_NEXT_ACTION, 0)
    end
    reaper.Main_OnCommandEx(loop_points_SET_END_POINT, 0)
    reaper.Main_OnCommandEx(INSERT_EMPTY_ITEM, 0)
    reaper.Main_OnCommandEx(loop_points_REMOVE_LOOP_POINT_SELECTION, 0)

  else
    a = reaper.ShowMessageBox("No item will be created for there's no track selection.", "Track selection error", 0)
  end
end

-----------------------------------------------------------------------
init_window()
main()
-----------------------------------------------------------------------
