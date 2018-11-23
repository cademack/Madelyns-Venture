--Configuration
function love.conf(t)
  t.title = "Madelyn's Venture" --The title of the window the game is in (string)
  t.version = "11.1"     --Love version
  t.window.width = 900  --we want the game long and thin
  t.window.height = 600

  --Windows debugging
  t.console = true
end
