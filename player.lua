player = { x = 0, y = 0, dx = 0, dy = 0, defaultY = 0, facing = "right", isAlive = true}
skulls = {}

player.runImgs = {}
for i = 0,3,1 do -- this loop sticks all the running images in a nice table for later
  table.insert(player.runImgs, love.graphics.newImage('assets/run' .. i  .. '.png'))
end

player.idleImgs = {}
for i = 0,3,1 do -- this loop loads all the idle images
  table.insert(player.idleImgs, love.graphics.newImage('assets/idle' .. i  .. '.png'))
end

player.width = player.runImgs[1]:getWidth()*scale
player.height = player.runImgs[1]:getHeight()*scale

player.x = love.graphics:getWidth()/2
player.y = love.graphics:getHeight() - player.height
player.defaultY = player.y

player.runFrame = 1

--Staff and Skull Imgs
player.staffImg = love.graphics.newImage('assets/redStaff.png')
player.skullImg = love.graphics.newImage('assets/skull.png')

function movePlayerRight()
  if (player.facing == "left") then
    player.x = player.x - player.width
  end

  player.facing = "right"

  if (player.x < love.graphics.getWidth() - 2.0*player.width ) then
    player.dx = 200
  end
end

function movePlayerLeft()
  if (player.facing == "right") then
    player.x = player.x + player.width
  end
  player.facing = "left"
  if (player.x >  player.width) then
    player.dx = -200
  end
end

function playerJump()
  if ((player.y > player.defaultY - 4)) then
    player.dy = 700
  end
end

function playerShoot()

  newSkull = { x = null, y = player.y, dx = null, rotation = 0}

  --positive dx if facing right, negative if Left
  --Then changing the position also so that is appears on the right side of the character
  if (player.facing == "right") then
    newSkull.x = player.x + 70
    newSkull.dx = 450
  elseif (player.facing == "left") then
    newSkull.x = player.x - 80
    newSkull.dx = -450
  end

  table.insert(skulls, newSkull)
  canShoot = false
end

function checkPlayerY() --This makes sure the player doesnt stoop off the bottom a lil bit
  if ((player.y >= player.defaultY) and (player.dy < 0)) then
    player.dy = 0
    player.speed = originalSpeed
    player.y = player.defaultY
  end
end

return player
