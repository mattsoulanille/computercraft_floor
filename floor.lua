--Builds floors of specified width and length of a desired pattern

function _in(val, tab)
   -- determines if a value is in a table
   -- WHY is this not builtin?!?!
   for index, value in ipairs (tab) do
      if value == val then
	 return true
      end
   end
   return false
end

-- if not os.loadAPI("apis/lama") then
--    print("Please install the lama api")
--    print("pastebin get q45K18dv lama-installer")
-- end

args = {...}

forward = args[1]
sideways = args[2]

if (not forward) or (not sideways) then
   print("Usage: floor [forward distance] [sideways distance] <pattern = \"none\"> <Ceiling instead of floor = false> <left instead of right = false>")
   print("Put Fuel wherever. Block 1 in 1st slot, block 2 in 2rd. Place extra stacks randomly in the inventory.")
   return
end

pattern = args[3] or "none"
ceiling = (args[4] == "true") or false
go_left = (args[5] == "true") or false

total_blocks = forward * sideways

position = {0,0}
direction = 0


print("Placing " .. tostring(total_blocks) .. " blocks")


block_1 = turtle.getItemDetail(1)
block_2 = turtle.getItemDetail(2)

if block_1 == nil or block_2 == nil then
   print "missing blocks"
   return
end

block_1 = block_1["name"]
block_2 = block_2["name"]

function knight(x,y)
   -- makes the pretty knight move pattern of blocks
   -- returns true if the block should be the special one
   return (x + 3 * y) % 5 == 0
end

function checker(x,y)
   -- checker pattern
   return (x + y) % 2 == 0
end



--lama.set(0,100,0,lama.side.north)

active_slots = {2,3}
fuel_names = {"minecraft:coal", "Railcraft:fuel.coke"}


function get_block(name)
   for i=1,16,1 do
      local item_detail = turtle.getItemDetail(i)
      if item_detail ~= nil and item_detail["name"] == name then
	 return i
      end
   end
   return false
end

function get_first_block()
   if turtle.getItemDetail(active_slots[1]) ~= block_1 then
      return get_block(block_1)
   else
      return active_slots[1]
   end
end

function get_second_block()
   if turtle.getItemDetail(active_slots[2]) ~= block_2 then
      return get_block(block_2)
   else
      return active_slots[2]
   end
end
   
patterns = {}
patterns["knight"] = knight
patterns["checker"] = checker
patterns["none"] = function () return false end


function get_fuel_slot()
   -- returns the first slot containing a fuel item
   for i=1,16,1 do
      local item_detail = turtle.getItemDetail(i)
      if item_detail ~= nil and _in(item_detail["name"], fuel_names) then
	 return i
      end
   end
   return false
end

function place_block()
   local x,z = position[1], position[2]
   if patterns[pattern](x,z) then

      local selection = get_second_block()
      while not selection do
	 print("out of "..block_2)
	 sleep(4)
	 local selection = get_second_block()
      end
      turtle.select(selection)

   else

      local selection = get_first_block()
      while not selection do
	 print("out of "..block_1)
	 sleep(4)
	 local selection = get_first_block()
      end
      turtle.select(selection)

   end
   
   if ceiling then
      while not turtle.placeUp() do
	 sleep(2)
	 print("can't place block")
      end
   else
      while not turtle.placeDown() do
	 sleep(2)
	 print("can't place block")
      end
   end
   
end

-- function travel()
--    local success, reason = lama.forward()
--    while not success do
--       if reason == "fuel" then
-- 	 turtle.select(get_fuel_slot())
-- 	 lama.refuel(1)
--       end
--       success, reason = lama.forward()
--    end
-- end


function travel()
   while not turtle.forward() do
      if turtle.getFuelLevel() < 80 then
	 local fuel_slot = get_fuel_slot()

	 while not fuel_slot do
	    print("No Fuel")
	    sleep(2)
	    fuel_slot = get_fuel_slot()
	 end
	 turtle.select(fuel_slot)
	 turtle.refuel()
      else
	 print("Stuck")
	 sleep(5)
      end
   end
   
   if direction == 0 then position[1] = position[1] + 1
   elseif direction == 1 then position[2] = position[2] + 1
   elseif direction == 2 then position[1] = position[1] - 1
   elseif direction == 3 then position[2] = position[2] - 1
   end

end

function turnRight()
   if turtle.turnRight() then
      direction = (direction + 1) % 4
      return true
   end
   return false
end

function turnLeft()
   if turtle.turnLeft() then
      direction = (direction - 1 + 4) % 4
      return true
   end
   return false
end   
   
function do_row()
   -- places a row of floor
   for i=1,forward-1,1 do
      place_block()
      travel()
   end
   place_block()
end

function do_turn()
   if direction == 0 then
      if go_left then
	 turnLeft()
	 travel()
	 turnLeft()
      else
	 turnRight()
	 travel()
	 turnRight()
      end
   elseif direction == 2 then
      if go_left then
	 turnRight()
	 travel()
	 turnRight()
      else
	 turnLeft()
	 travel()
	 turnLeft()
      end
   end
end

for i=1,sideways,1 do
   do_row()
   do_turn()
end
