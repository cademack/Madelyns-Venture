

debug = true
--Turn to false at release lol
scale = 3



gravity = -1800

createEnemyTimerMax = 9
createEnemyTimer = createEnemyTimerMax

require("gameloop")


runFrame = 1

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


jumpHandicap = 50
enemyTurnDistance = 80

score = 0

font = love.graphics.newFont("font.ttf", 64)



--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function love.load(arg)

  player = require("player")


  font = love.graphics.newFont("font.ttf", 64)
  love.graphics.setFont(font)




  --LOADING PICTURES


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
  if player.isAlive == true then

    if (player.facing == "right") then
      if (player.dx ~= 0)  and (player.y > player.defaultY - 3) then --This checks if the horizontal speed is not zero and the player is low enough
        love.graphics.draw(player.runImgs[math.floor((player.runFrame/runSpeed)+1.0)], player.x, player.y, 0, scale)

      else
        --This happens when not running
        love.graphics.draw(player.idleImgs[math.floor((player.runFrame/runSpeed)+1.0)], player.x, player.y, 0, scale)

      end
    elseif (player.facing == "left") then
      if (player.dx ~= 0) and (player.y > player.defaultY - 3) then -- same as before, but horizontally flipped
        love.graphics.draw(player.runImgs[math.floor((player.runFrame/runSpeed)+1.0)], player.x, player.y, 0, -1*scale, scale)

      else
        --This happens when not running
        love.graphics.draw(player.idleImgs[math.floor((player.runFrame/runSpeed)+1.0)], player.x, player.y, 0, -1*scale, scale)

      end
    end

  end
--FINISHED DRAWING THE PLAYER


--DRAWING THE STAFF
  if (player.facing == "left" and player.isAlive) then
    love.graphics.draw(player.staffImg, player.x-player.width -5, player.y + 30 - math.floor(player.runFrame/2), 0, 0.5*scale)
  else if (player.facing == "right") and player.isAlive then
    love.graphics.draw(player.staffImg, player.x+player.width - 9, player.y + 30 - math.floor(player.runFrame/2), 0, 0.5*scale)
  end
  end

  --DRAWING ALL SKULLS
  for i, skull in ipairs(skulls) do
    if (skull.dx < 0) then
      love.graphics.draw(player.skullImg, skull.x, skull.y, skull.rotation, scale)
    else
      love.graphics.draw(player.skullImg, skull.x, skull.y, skull.rotation, -1*scale, scale)
    end
  end

  --DRAWING THE ENEMIES
  for i, enemy in ipairs(enemies) do
    if (enemy.dx > 0) then
      love.graphics.draw(enemyRunImgs[math.floor((player.runFrame/runSpeed)+1.0)], enemy.x, enemy.y, 0, scale)
    else
      love.graphics.draw(enemyRunImgs[math.floor((player.runFrame/runSpeed)+1.0)], enemy.x, enemy.y, 0, -1*scale, scale)
    end
  end

  if (player.runFrame < (4*runSpeed -1)) then --If runFrame is not at max, then increment. otherwise reset it
    player.runFrame = player.runFrame + 1
  else
    player.runFrame = 1
  end

  --Drawing death/respawn stuff
  if not(player.isAlive) then
    love.graphics.print("Press R to Restart!", 100, 200, 0, 1, 1)
  end


  --Drawing score
  love.graphics.print("Score: " .. score, love.graphics:getWidth() - 250, 100, 0, .5, .5)

-- print() -- For debug reasons

--End of Draw

end

function love.update(dt)

  --Handles the quitting of the game
  if love.keyboard.isDown('escape') then
    love.event.quit()
  end


  --Rightward movement stuff
  if love.keyboard.isDown('right', 'd') then
    movePlayerRight()
  end

  --Leftward movement stuff
  if love.keyboard.isDown('left', 'a') then
    movePlayerLeft()
  end

  --Jumping
  if love.keyboard.isDown('up', 'w') then
    playerJump()
  end


  --Shooting, creating new skulls
  if love.keyboard.isDown('space') and canShoot and player.isAlive then
    playerShoot()
  end

  --Handles Restarting
  if love.keyboard.isDown('r') and not(player.isAlive) then
    player.isAlive = true
    for i, enemy in ipairs(enemies) do
      table.remove(enemies, i)
      player.x = love.graphics:getWidth()/2
      player.y = player.defaultY
      score = 0
    end
  end


  --Creating Enemies
  createEnemy()


  --If the player is found to be too low, like off screen low, then the player is reverted back to original height, "reset"
  checkPlayerY()

  collisionDetection()

  --Adjusting dx
  handleMovement(dt)

  --removing removeSkulls
  removeSkulls()

  updateVariables(dt)

--End of Update
end
