function love.load()
    pause = false
    local n,m = 32,32
    frame1 = {n=n,m=m}
    for i=1,n do
        frame1[i] = {}
    end
    frame2 = {n=n,m=m}
    for i=1,n do
        frame2[i] = {}
    end
    griddata = frame1
    for j=6,m do
        griddata[16][j]=1
    end
    griddata[16][1]=1
    griddata[15][2]=1
    griddata[17][2]=2
    griddata[15][3]=1
    griddata[17][3]=3
    griddata[15][4]=1
    griddata[17][4]=1
    griddata[15][5]=1
    griddata[17][5]=1
    timeaccu = 0
    timestep = 0.25
    iHover,jHover = 0,0
end

function love.update(dt)
    local x,y = love.mouse.getPosition()
    local w,h = love.graphics.getDimensions()
    local n,m = griddata.n,griddata.m
    local l,k = math.min(w,h) , math.max(n,m)
    local X,Y = x-(w-l)/2 , y-(h-l)/2
    local i,j = math.ceil(X*n/l) , math.ceil(Y*m/l)
    iHover,jHover = i,j
    if love.mouse.isDown(1,2) then
        if i>=1 and j>=1 and i<=n and j<=m then
            if love.mouse.isDown(1) then
                if griddata[i][j]==nil then griddata[i][j]=1 end
            elseif love.mouse.isDown(2) then
                if griddata[i][j]~=nil then griddata[i][j]=nil end
            end
        end
    end
    if not pause then timeaccu = timeaccu + dt end
    if timeaccu < timestep then return end
    timeaccu = timeaccu-timestep
    local read,write = frame1,frame2
    if griddata == frame2 then read,write = frame2,frame1 end
    for i=1,read.n do
        for j=1,read.m do
            write[i][j] = read[i][j]
            if read[i][j] then
                if read[i][j]==3 then
                    write[i][j]=1
                elseif read[i][j]==2 then
                    write[i][j]=3
                elseif read[i][j]==1 then
                    local heads = 0
                    for u=-1,1 do
                        for v=-1,1 do
                            if i+u>=1 and i+u<=read.n then
                                if read[i+u][j+v]==2 then heads=heads+1 end
                            end
                        end
                    end
                    if heads==1 or heads==2 then write[i][j]=2 end
                end
            end
        end
    end
    griddata = write
end

function love.draw()
    local pauseStr = 'Press space to pause simulation.'
    if pause then pauseStr = 'Press space to UNPAUSE simulation.' end
    love.graphics.setColor(1,1,1)
    love.graphics.print('Scroll to advance simulation.\n' .. pauseStr)
    for i=1,griddata.n do
        for j=1,griddata.m do
            if griddata[i][j] then
                local value = griddata[i][j]
                love.graphics.setColor(0,0,0)
                if value==1 then
                    love.graphics.setColor(0,1,1)
                elseif value==2 then
                    love.graphics.setColor(1,0,1)
                elseif value==3 then
                    love.graphics.setColor(1,1,0)
                end
                local n,m = griddata.n,griddata.m
                local w,h = love.graphics.getDimensions()
                local l,k = math.min(w,h) , math.max(n,m)
                local x,y = (i-1)*l/n + (w-l)/2 , (j-1)*l/m + (h-l)/2
                love.graphics.rectangle( 'fill', x, y, l/k, l/k )
            end
        end
    end
    if iHover>=1 and jHover>=1 and iHover<=griddata.n and jHover<=griddata.m then
        local i,j = iHover,jHover
        local n,m = griddata.n,griddata.m
        local w,h = love.graphics.getDimensions()
        local l,k = math.min(w,h) , math.max(n,m)
        local x,y = (i-1)*l/n + (w-l)/2 , (j-1)*l/m + (h-l)/2
        love.graphics.setColor(0.5,0.5,0.5)
        love.graphics.rectangle( 'line', x, y, l/k, l/k )
    end
end 

function love.mousepressed( x, y, button, istouch, presses )
    local n,m = griddata.n,griddata.m
    local w,h = love.graphics.getDimensions()
    local l,k = math.min(w,h) , math.max(n,m)
    local X,Y = x-(w-l)/2 , y-(h-l)/2
    local i,j = math.ceil(X*n/l) , math.ceil(Y*m/l)
    if i<1 or j<1 or i>n or j>n then return end
    if button==1 then
        if griddata[i][j] then 
            griddata[i][j] = 1+(griddata[i][j] % 3)
        end
    elseif button==2 then
        griddata[i][j] = nil
    end
end

function love.keypressed( key, scancode, isrepeat )
    if key=='space' then pause = not pause end
end

function love.wheelmoved(x,y)
    timeaccu = timeaccu + timestep
end