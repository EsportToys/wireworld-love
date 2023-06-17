local griddata = {}

    for j=6,math.floor(love.graphics.getHeight()/32) do
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



return griddata