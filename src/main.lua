function love.load()
    pause = false
    zoom = 5*12
    pxPerCell = 2^(zoom/12)
    frame1 = {}
    frame2 = {}
    griddata = frame1
    for j=6,math.floor(love.graphics.getHeight()/pxPerCell) do
        griddata[16 .. ' ' .. j]={x=16,y=j,value=1}
    end
    griddata[16 .. ' ' .. 1]={x=16,y=1,value=1}
    griddata[15 .. ' ' .. 2]={x=15,y=2,value=1}
    griddata[17 .. ' ' .. 2]={x=17,y=2,value=2}
    griddata[15 .. ' ' .. 3]={x=15,y=3,value=1}
    griddata[17 .. ' ' .. 3]={x=17,y=3,value=3}
    griddata[15 .. ' ' .. 4]={x=15,y=4,value=1}
    griddata[17 .. ' ' .. 4]={x=17,y=4,value=1}
    griddata[15 .. ' ' .. 5]={x=15,y=5,value=1}
    griddata[17 .. ' ' .. 5]={x=17,y=5,value=1}
    timeaccu = 0
    timestep = 0.25
    iHover,jHover = 0,0
    offsetX,offsetY = 0,0
end

function love.update(dt)
    local x,y = love.mouse.getPosition()
    local i,j = ScreenToCoord(x,y)
    local hoverKey = i..' '..j
    iHover,jHover = i,j
    if love.mouse.isDown(1) then
        if griddata[hoverKey]==nil then 
           griddata[hoverKey]={x=i,y=j,value=1}
        end
    elseif love.mouse.isDown(2) then
        frame1[hoverKey] = nil
        frame2[hoverKey] = nil
    end
    if not pause then timeaccu = timeaccu + dt end
    if timeaccu < timestep then return end
    timeaccu = timeaccu-timestep
    local read,write = frame1,frame2
    if griddata == frame2 then read,write = frame2,frame1 end
    for cellkey , cell in pairs(read) do
        local i,j,value = cell.x,cell.y,cell.value
        local key = i .. ' ' .. j
        if cellkey ~= key then 
            cell = nil 
        else
            if write[key] == nil then
            write[key] = {}
            end
            write[key].x = i
            write[key].y = j
            write[key].value = value
            if     value == 3 then 
            write[key].value = 1
            elseif value == 2 then 
            write[key].value = 3
            elseif value == 1 then 
            local heads = 0
            for u=-1,1 do
                for v=-1,1 do
                    local k = i+u .. ' ' .. j+v
                    if read[k] ~= nil then  
                        if read[k].value==2 then heads=heads+1 end 
                    end
                end
            end
            if heads==1 or heads==2 then write[key].value=2 end
            end
        end
    end
    griddata = write
end

function love.draw()
    local w,h = love.graphics.getDimensions()
    local pxwidth = pxPerCell
    for _ , square in pairs(griddata) do 
        local i,j,value = square.x,square.y,square.value
        love.graphics.setColor(0,0,0)
        if value==1 then
            love.graphics.setColor(0,1,1)
        elseif value==2 then
            love.graphics.setColor(1,0,1)
        elseif value==3 then
            love.graphics.setColor(1,1,0)
        end
        local x,y = CoordToScreen(i,j)
        if x+pxwidth>=1 and x<=w and y+pxwidth>=1 and y<=h then
           love.graphics.rectangle( 'fill', x, y, pxwidth, pxwidth )
        end
    end
    do
        local x,y = CoordToScreen(iHover,jHover)
        love.graphics.setColor(0.5,0.5,0.5)
        love.graphics.rectangle( 'line', x, y, pxwidth, pxwidth )
    end
    for n=0,1 do 
        local x,y = CoordToScreen(n,n)
        love.graphics.setColor(0.5,0.5,0.5)
        if 1<=x and x<=w then love.graphics.line(x,0,x,h) end
        if 1<=y and y<=h then love.graphics.line(0,y,w,y) end
    end
    local pauseStr = 'Press space to pause simulation.'
    if pause then pauseStr = 'Press space to UNPAUSE simulation.' end
    local hoverStr = iHover .. ',' .. jHover .. '\n'
    if griddata[iHover .. ' ' .. jHover] ~= nil then 
        hoverStr = hoverStr ..
        'x=' .. griddata[iHover .. ' ' .. jHover].x .. '\n' .. 
        'y=' .. griddata[iHover .. ' ' .. jHover].y .. '\n' ..
        'state=' .. griddata[iHover .. ' ' .. jHover].value
    end
    love.graphics.setColor(1,1,1)
    love.graphics.print(
        'Hold mouse 3 to pan, scroll to zoom.\n' ..
        pauseStr .. '\n' ..
        'Hold space and scroll to advance simulation.\n\n' .. hoverStr 
    )
end 

function love.mousepressed( x, y, button, istouch, presses )
    local i,j = ScreenToCoord(x,y)
    local key = i..' '..j
    if button==1 then
        if griddata[key]==nil then 
           griddata[key]={x=i,y=j,value=1}
        else
           griddata[key].value = 1+(griddata[key].value % 3)
        end
    elseif button==2 then
        frame1[key] = nil
        frame2[key] = nil
    end
end

function love.mousemoved( x, y, dx, dy, istouch )
    if love.mouse.isDown(3) then offsetX,offsetY = offsetX+dx,offsetY+dy end
end

function love.keypressed( key, scancode, isrepeat )
    if key=='space' then pause = not pause end
end

function love.wheelmoved(x,y)
    if love.keyboard.isDown('space') then
       timeaccu = timeaccu + timestep
    else
       local before = zoom
       local after = math.max(0,zoom-y)
       local scale = 2^((after-before)/12)
       local hoverX , hoverY = love.mouse.getPosition()
       zoom = after
       offsetX = hoverX + (offsetX-hoverX)*scale
       offsetY = hoverY + (offsetY-hoverY)*scale
       pxPerCell = 2^(zoom/12)
    end
end

function ScreenToCoord(x,y)
    local w,h = love.graphics.getDimensions()
    local l = math.min(w,h)
    local X,Y = x-offsetX , y-offsetY
    local i,j = math.ceil(X/pxPerCell) , math.ceil(Y/pxPerCell)
    if i==0 then i=0 end 
    if j==0 then j=0 end
   return i,j
end

function CoordToScreen(i,j)
    local w,h = love.graphics.getDimensions()
    local l = math.min(w,h)
    local x,y = (i-1)*pxPerCell + offsetX , (j-1)*pxPerCell + offsetY
   return x,y 
end
