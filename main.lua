function love.load()
    -- Initialize your game here
    love.graphics.setDefaultFilter("linear", "linear")
    --
    -- Window dimensions
    windowWidth = love.graphics.getWidth()
    windowHeight = love.graphics.getHeight()
    
    -- Grid configuration
    gridSize = 3  -- 3x3 grid
    boxSize = 50  -- size of each box
    spacing = 3  -- space between boxes
    
    -- Calculate total grid dimensions
    totalWidth = (boxSize * gridSize) + (spacing * (gridSize - 1))
    totalHeight = totalWidth  -- same for height since it's a square grid
    
    -- Calculate starting position to center the grid
    startX = (windowWidth - totalWidth) / 2
    startY = (windowHeight - totalHeight) / 2

    -- Create table to store colors for each box
    colors = {}
    for i = 1, gridSize * gridSize do
        colors[i] = {
            love.math.random(),  -- red
            love.math.random(),  -- green
            love.math.random()   -- blue
        }
    end

    scale = 1
    targetScale = 1
    zoomSpeed = 5  -- Controls zoom sensitivity
    zoomVelocity = 0
    friction = 4    -- How quickly zoom momentum slows down
    springBack = 0  -- How quickly zoom returns to stable state

    minScale = math.min(windowWidth / totalWidth, windowHeight / totalHeight) * 0.1
    -- maxScale = math.min(windowWidth / boxSize, windowHeight / boxSize)
    maxScale = math.min(windowWidth / totalWidth, windowHeight / totalHeight)
end

function love.mousepressed(x, y, button)
    local wx, wy = love.graphics.inverseTransformPoint(x, y)
    
    -- Check if click is inside any box
    local clickedBox = false
    for row = 0, gridSize - 1 do
        for col = 0, gridSize - 1 do
            local bx = startX + (col * (boxSize + spacing))
            local by = startY + (row * (boxSize + spacing))
            
            if wx >= bx and wx <= bx + boxSize and
               wy >= by and wy <= by + boxSize then
                -- Change single box color
                local index = row * gridSize + col + 1
                colors[index] = {
                    love.math.random(),
                    love.math.random(),
                    love.math.random()
                }
                clickedBox = true
                break
            end
        end
    end
    
    -- If clicked outside, change all colors
    if not clickedBox then
        for i = 1, gridSize * gridSize do
            -- In mousepressed function, replace the random color generation with:
            colors[i] = {
                love.math.random(0.5, 1),  -- red range from 50-100%
                love.math.random(0, 0.3),  -- low green for reddish tint
                love.math.random(0, 0.3)   -- low blue for reddish tint
            }
        end
    end
end

function love.wheelmoved(x, y)
    -- y is positive when scrolling up, negative when scrolling down
    -- scale = math.max(0.1, scale + y * 0.1 * zoomSpeed)
    zoomVelocity = zoomVelocity + y * 0.1 * zoomSpeed
    targetScale = scale
end

function love.update(dt)
    -- Game logic goes here
    -- dt is delta time between frames
   
    if love.keyboard.isDown('up') then
        zoomVelocity = zoomVelocity + dt * zoomSpeed
        targetScale = scale
    elseif love.keyboard.isDown('down') then
        zoomVelocity = zoomVelocity - dt * zoomSpeed
        targetScale = scale
    end

    -- Apply zoom velocity
    scale = scale + zoomVelocity * dt
    
    -- Apply friction and spring back
    -- zoomVelocity = zoomVelocity * (1 - friction * dt)
    
    -- Spring back to target scale
    local scaleDiff = targetScale - scale
    zoomVelocity = zoomVelocity + scaleDiff * springBack * dt
    -- Apply friction
    zoomVelocity = zoomVelocity * (1 - friction * dt)

    -- Clamp scale between min and max
    scale = math.max(minScale, math.min(maxScale, scale))
    -- Stop velocity if we hit bounds
    if scale == minScale and zoomVelocity < 0 or scale == maxScale and zoomVelocity > 0 then
        zoomVelocity = 0
    end
end

function love.draw()
    -- Drawing code goes here
   
    -- Set origin to screen center
    love.graphics.push()
    love.graphics.translate(windowWidth/2, windowHeight/2)
    love.graphics.scale(scale)
    love.graphics.translate(-windowWidth/2, -windowHeight/2)

    -- Draw the grid
    for row = 0, gridSize - 1 do
        for col = 0, gridSize - 1 do
            -- Calculate position for each box
            local x = startX + (col * (boxSize + spacing))
            local y = startY + (row * (boxSize + spacing))
    
            -- Get color index for this box
            local index = row * gridSize + col + 1
            -- Draw the box
            love.graphics.setColor(colors[index])
            love.graphics.rectangle("fill", x, y, boxSize, boxSize, 15) -- 10 is the corner radius
            love.graphics.setColor(1, 1, 1)  -- Reset color to white
        end
    end

   love.graphics.pop()
end

-- Handle window resize
function love.resize(w, h)
    windowWidth = w
    windowHeight = h
    -- Recalculate starting position
    startX = (windowWidth - totalWidth) / 2
    startY = (windowHeight - totalHeight) / 2

    -- Recalculate scale bounds on resize
    minScale = math.min(windowWidth / totalWidth, windowHeight / totalHeight) * 0.1
    maxScale = math.min(windowWidth / totalWidth, windowHeight / totalHeight)
    -- maxScale = math.min(windowWidth / boxSize, windowHeight / boxSize)
    scale = math.max(minScale, math.min(maxScale, scale))
end
