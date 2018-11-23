debug = true
--Turn to false at release lol
scale = 3

player = { x = 0, y = 0, state = "idle", idleImg = null, idleImgs = {}, runImgs = {}, width = 0, height = 0, facing = "right"}
dy = 0
dx = 0
defaultY = 0
staffImg = null

gravity = -1800

skulls = {}
newSkull = null
skullImg = null


runFrame = 1
idleFrame = 1

friction = 500
airFriction = 100
runSpeed = 4

canShootTimerMax = 3
canShootTimer = canShootTimerMax
canShoot = true

enemies = {}
newEnemy = null
enemyIdleImgs = {}
enemyRunImgs = {}
createEnemyTimerMax = 9
createEnemyTimer = createEnemyTimerMax
createEnemy = false

jumpHandicap = 50
enemyTurnDistance = 80

function tablelength(T) -- Stolen code to find length of table
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end


function onGround() --Check if player is on the ground
  if (player.y > defaultY - 4) then
    return true
  else
    return false
  end
end

function handleDx() --All the work involving the horizontal movement of the player

  if onGround() then -- WHEN ON THE GROUND
    if (dx < 0) and (dx + friction*dt < 0) then
      dx = dx + friction*dt
    elseif (dx > 0) and (dx - friction*dt > 0 ) then
      dx = dx - friction*dt
    else
      dx = 0
    end
  end

  if not(onGround()) then
    if (dx < 0) and (dx + airFriction*dt < 0) then
      dx = dx + airFriction*dt
    elseif (dx > 0) and (dx - airFriction*dt > 0 ) then
      dx = dx - airFriction*dt
    else
      dx = 0
    end
  end
end

--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function love.load(arg)
  player.idleImg = love.graphics.newImage('assets/player.png')
  player.x = love.graphics:getWidth()/2
  player.y = love.graphics:getHeight() - player.idleImg:getHeight() * scale
  player.width = player.idleImg:getWidth() * scale
  player.height = player.idleImg:getHeight() * scale
  defaultY = player.y --This is storing a value for the original height so that it can be referenced later
  staffImg = love.graphics.newImage('assets/redStaff.png')
  skullImg = love.graphics.newImage('assets/skull.png')

  --LOADING PICTURES
  for i = 0,3,1 do -- this loop sticks all the running images in a nice table for later
    table.insert(player.runImgs, love.graphics.newImage('assets/run' .. i  .. '.png'))
  end

  for i = 0,3,1 do -- this loop loads all the idle images
    table.insert(player.idleImgs, love.graphics.newImage('assets/idle' .. i  .. '.png'))
  end

  for i = 0,3,1 do -- this loop loads all the  elf idle images
    table.insert(enemyIdleImgs, love.graphics.newImage('assets/elfIdle' .. i  .. '.png'))
  end

  for i = 0,3,1 do -- this loop loads all the elf running images
    table.insert(enemyRunImgs, love.graphics.newImage('assets/elfRun' .. i  .. '.png'))
  end

--End of Load
end

--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function love.draw()

--DRAWING THE PLAYER
  if (player.facing == "right") then
    if (dx ~= 0)  and (player.y > defaultY - 3) then --This checks if the horizontal speed is not zero and the player is low enough
      love.graphics.draw(player.runImgs[math.floor((runFrame/runSpeed)+1.0)], player.x, player.y, 0, scale)

      if (runFrame < (4*runSpeed -1)) then --If runFrame is not at max, then increment. otherwise reset it
        runFrame = runFrame + 1
      else
        runFrame = 1
      end

    else
      --This happens when not running
      love.graphics.draw(player.idleImgs[math.floor((runFrame/runSpeed)+1.0)], player.x, player.y, 0, scale)

      if (runFrame < (4*runSpeed -1)) then --If runFrame is not at max, then increment. otherwise reset it
        runFrame = runFrame + 1
      else
        runFrame = 1
      end

    end
  elseif (player.facing == "left") then
    if (dx ~= 0) and (player.y > defaultY - 3) then -- same as before, but horizontally flipped
      love.graphics.draw(player.runImgs[math.floor((runFrame/runSpeed)+1.0)], player.x, player.y, 0, -1*scale, scale)

      if (runFrame < (4*runSpeed -1)) then --If runFrame is not at max, then increment. otherwise reset it
        runFrame = runFrame + 1           --Run frame represents the index of the runImgs table so that the character
      else                                  -- tabs through each frame and is animated nice
        runFrame = 1
      end

    else
      --This happens when not running
      love.graphics.draw(player.idleImgs[math.floor((runFrame/runSpeed)+1.0)], player.x, player.y, 0, -1*scale, scale)

      if (runFrame < (4*runSpeed -1)) then --If runFrame is not at max, then increment. otherwise reset it
        runFrame = runFrame + 1
      else
        runFrame = 1
      end

    end
  end
--FINISHED DRAWING THE PLAYER



--DRAWING THE STAFF
  if (player.facing == "left") then
    love.graphics.draw(staffImg, player.x-player.width -5, player.y + 30 - math.floor(runFrame/2), 0, 0.5*scale)
  else if (player.facing == "right") then
    love.graphics.draw(staffImg, player.x+player.width - 9, player.y + 30 - math.floor(runFrame/2), 0, 0.5*scale)
  end
  end

  --DRAWING ALL SKULLS
  for i, skull in ipairs(skulls) do
    if (skull.dx < 0) then
      love.graphics.draw(skullImg, skull.x, skull.y, skull.rotation, scale)
    else
      love.graphics.draw(skullImg, skull.x, skull.y, skull.rotation, -1*scale, scale)
    end
  end

  --DRAWING THE ENEMIES
  for i, enemy in ipairs(enemies) do
    if (enemy.dx > 0) then
      love.graphics.draw(enemyRunImgs[math.floor((runFrame/runSpeed)+1.0)], enemy.x, enemy.y, 0, scale)
    else
      love.graphics.draw(enemyRunImgs[math.floor((runFrame/runSpeed)+1.0)], enemy.x, enemy.y, 0, -1*scale, scale)
    end
  end

--End of Draw

-- print() -- For debug reasons
end

function love.update(dt)

  --Handles the quitting of the game
  if love.keyboard.isDown('escape') then
    love.event.quit()
  end


  --Rightward movement stuff
  if love.keyboard.isDown('right', 'd') then

    if (player.facing == "left") then
      player.x = player.x - player.width
    end

    player.facing = "right"

    if (player.x < love.graphics.getWidth() - 2.0*player.width ) then
      dx = 200
    end
  end

  --Leftward movement stuff
  if love.keyboard.isDown('left', 'a') then

    if (player.facing == "right") then
      player.x = player.x + player.width
    end


    player.facing = "left"
    if (player.x >  player.width) then
      dx = -200
    end
  end

  --Jumping
  if love.keyboard.isDown('up', 'w') then
    if ((player.y > defaultY - 4)) then
      dy = 700
    end
  end


  --Shooting, creating new skulls
  if love.keyboard.isDown('space') and canShoot then
    newSkull = { x = null, y = player.y, dx = null, rotation = 0}

    --positive dx if facing right, negative if Left
    --Then changing the position also so that is appears on the right side of the character
    if (player.facing == "right") then
      newSkull.x = player.x + 70
      newSkull.dx = 350
    elseif (player.facing == "left") then
      newSkull.x = player.x - 80
      newSkull.dx = -350
    end

    table.insert(skulls, newSkull)
    canShoot = false
  end

  --Creating Enemies
  if createEnemy == true then
    side = math.floor(math.random()*2)
    if side == 0 then
      newEnemy = { x = -20, dx = 150, y = love.graphics:getHeight() - scale*enemyRunImgs[1]:getHeight()}
    else
      newEnemy = { x = love.graphics:getWidth() + 20, dx = -150, y = love.graphics:getHeight() - scale*enemyRunImgs[1]:getHeight()}
    end

    table.insert(enemies, newEnemy)
    createEnemy = false
    print("Enemy Created")
  end


  --If the player is found to be too low, like off screen low, then the player is reverted back to original height, "reset"
  if ((player.y >= defaultY) and (dy < 0)) then
    dy = 0
    player.speed = originalSpeed
    player.y = defaultY
  end


  function handleMovement() --All the work involving the horizontal movement of everything

    if onGround() then -- WHEN ON THE GROUND
      if (dx < 0) and (dx + friction*dt < 0) then
        dx = dx + friction*dt
      elseif (dx > 0) and (dx - friction*dt > 0 ) then
        dx = dx - friction*dt
      else
        dx = 0
      end
    end

    if not(onGround()) then -- WHEN NOT ON THE GROUND
      if (dx < 0) and (dx + airFriction*dt < 0) then
        dx = dx + airFriction*dt
      elseif (dx > 0) and (dx - airFriction*dt > 0 ) then
        dx = dx - airFriction*dt
      else
        dx = 0
      end
    end


    --"AI" turning if the the player is the opposite direction of movement
    for i, enemy in ipairs(enemies) do
      if enemy.dx < 0 then
        if (player.x - enemy.x > enemyTurnDistance) then
          enemy.dx = enemy.dx * -1
          enemy.x = enemy.x - enemyRunImgs[1]:getWidth()
        end
      elseif enemy.dx > 0 then
        if (player.x - enemy.x < -1*enemyTurnDistance) then
          enemy.dx = enemy.dx * -1
          enemy.x = enemy.x + enemyRunImgs[1]:getWidth()
        end
      end
    end

    for i, skull in ipairs(skulls) do --handle skull Dx's
      skull.x = skull.x + skull.dx * dt
    end

    for i, enemy in ipairs(enemies) do --handle enemy Dx's
      enemy.x = enemy.x + enemy.dx * dt
    end

    --Updating the X and Y values of player with the dx and dy values
    dy = dy + gravity*dt
    player.x = player.x + dx*dt
    player.y = player.y - dy*dt

  --End of Handling DX
  end

--COLLISION DETECTION

--SKULLS & ENEMIES DETECTION
  for i, skull in ipairs(skulls) do
    for j, enemy in ipairs(enemies) do
      if ((skull.x - enemy.x > -10) and (skull.x - enemy.x < 10) and (skull.y - enemy.y > -5) and (skull.y - enemy.y < 75)) then
        table.remove(skulls, i)
        table.remove(enemies, j)
      end
    end
  end

  --ENEMIES AND PLAYER DETECTION
  for i, enemy in ipairs(enemies) do
    if player.facing == "right" then

      if ((enemy.x - player.x > -30) and (enemy.x - player.x < 80) and (player.y - enemy.y > -1*player.height + jumpHandicap) and (player.y - enemy.y < player.height- jumpHandicap)) then
        table.remove(enemies, i)

        --Define a function and stuff that handles death

        print("ZOINKS SCOOB")
      end


    elseif player.facing == "left" then

      if ((enemy.x - player.x > -80) and (enemy.x - player.x < 30) and (player.y - enemy.y > -1*player.height + jumpHandicap) and (player.y - enemy.y < player.height- jumpHandicap)) then
        table.remove(enemies, i)

        --Define a function and stuff that handles death


        print("ZOINKS SCOOB")
      end

    end
  end

  --END OF COLLISION DETECTION

  function removeSkulls() -- Handling the deletion of skulls off screen

    for i, skull in ipairs(skulls) do
      if (skull.x < -25) or (skull.x > love.graphics:getWidth() + 25) then
        table.remove(skulls, i)
      end

    end

  end

  --Adjusting dx
  handleMovement()

  --removing removeSkulls
  removeSkulls()







  --This just changes how often the player can shoot. Change canShootTimerMax to change how often to shoot
  canShootTimer = canShootTimer - 5*dt
  if (canShootTimer < 0) then
    canShoot = true
    canShootTimer = canShootTimerMax
  end

  --This is the exact same as canShootTimer but about creating enemies
  createEnemyTimer = createEnemyTimer - 5*dt
  if (createEnemyTimer < 0) then
    createEnemy = true
    createEnemyTimer = createEnemyTimerMax
  end

--End of Update
end
