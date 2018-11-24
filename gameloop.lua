function tablelength(T) -- Stolen code to find length of table
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end


function onGround() --Check if player is on the ground
  if (player.y > player.defaultY - 4) then
    return true
  else
    return false
  end
end

function handleDx() --All the work involving the horizontal movement of the player

  if onGround() then -- WHEN ON THE GROUND
    if (lplayer.dx < 0) and (player.dx + friction*dt < 0) then
      player.dx = player.dx + friction*dt
    elseif (player.dx > 0) and (player.dx - friction*dt > 0 ) then
      player.dx = player.dx - friction*dt
    else
      player.dx = 0
    end
  end

  if not(onGround()) then
    if (player.dx < 0) and (player.dx + airFriction*dt < 0) then
      player.dx = dx + airFriction*dt
    elseif (player.dx > 0) and (player.dx - airFriction*dt > 0 ) then
      player.dx = player.dx - airFriction*dt
    else
      player.dx = 0
    end
  end
end



function createEnemy()
  if createEnemyTimer < 0 then
    side = math.floor(math.random()*2)
    if side == 0 then
      newEnemy = { x = -20, dx = 150, y = love.graphics:getHeight() - scale*enemyRunImgs[1]:getHeight()}
    else
      newEnemy = { x = love.graphics:getWidth() + 20, dx = -150, y = love.graphics:getHeight() - scale*enemyRunImgs[1]:getHeight()}
    end

    table.insert(enemies, newEnemy)
    createEnemyTimer = createEnemyTimerMax
    print("Enemy Created")
  end
end

function updateVariables(dt)
  --This just changes how often the player can shoot. Change canShootTimerMax to change how often to shoot
  canShootTimer = canShootTimer - 5*dt
  if (canShootTimer < 0) then
    canShoot = true
    canShootTimer = canShootTimerMax
  end

  --This is the exact same as canShootTimer but about creating enemies
  createEnemyTimer = createEnemyTimer - 5*dt
end

function removeSkulls() -- Handling the deletion of skulls off screen

  for i, skull in ipairs(skulls) do
    if (skull.x < -25) or (skull.x > love.graphics:getWidth() + 25) then
      table.remove(skulls, i)
    end

  end
end

function collisionDetection()
  --COLLISION DETECTION

  --SKULLS & ENEMIES DETECTION
    for i, skull in ipairs(skulls) do
      for j, enemy in ipairs(enemies) do
        if ((skull.x - enemy.x > -10) and (skull.x - enemy.x < 10) and (skull.y - enemy.y > -5) and (skull.y - enemy.y < 75)) then
          table.remove(skulls, i)
          table.remove(enemies, j)
          score = score + 10
        end
      end
    end

    --ENEMIES AND PLAYER DETECTION

    if player.isAlive then
      for i, enemy in ipairs(enemies) do
        if player.facing == "right" then

          if ((enemy.x - player.x > -30) and (enemy.x - player.x < 80) and (player.y - enemy.y > -1*player.height + jumpHandicap) and (player.y - enemy.y < player.height- jumpHandicap)) then
            table.remove(enemies, i)

            player.isAlive = false
          end


        elseif player.facing == "left" then

          if ((enemy.x - player.x > -80) and (enemy.x - player.x < 30) and (player.y - enemy.y > -1*player.height + jumpHandicap) and (player.y - enemy.y < player.height- jumpHandicap)) then
            table.remove(enemies, i)

            player.isAlive = false
          end

        end
      end
    end
end


function handleMovement(dt) --All the work involving the horizontal movement of everything

  if onGround() then -- WHEN ON THE GROUND
    if (player.dx < 0) and (player.dx + friction*dt < 0) then
      player.dx = player.dx + friction*dt
    elseif (player.dx > 0) and (player.dx - friction*dt > 0 ) then
      player.dx = player.dx - friction*dt
    else
      player.dx = 0
    end
  end

  if not(onGround()) then -- WHEN NOT ON THE GROUND
    if (player.dx < 0) and (player.dx + airFriction*dt < 0) then
      player.dx = player.dx + airFriction*dt
    elseif (player.dx > 0) and (player.dx - airFriction*dt > 0 ) then
      player.dx = player.dx - airFriction*dt
    else
      player.dx = 0
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
  player.dy = player.dy + gravity*dt
  player.x = player.x + player.dx*dt
  player.y = player.y - player.dy*dt

--End of Handling DX
end
