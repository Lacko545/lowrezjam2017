maid64 = require 'maid64/maid64'

bullets = {}

light = {203,219,252}
dark =  {217,87,99}

dark_bullet = love.graphics.newMesh({  {1,0,0,0,dark[1],dark[2],dark[3],255},
					{1,1,0,0,dark[1],dark[2],dark[3],255},
					{0,1,0,0,dark[1],dark[2],dark[3],255},
					{0,0,0,0,dark[1],dark[2],dark[3],255}})

light_bullet = love.graphics.newMesh({ {1,0,0,0,light[1],light[2],light[3],255},
					{1,1,0,0,light[1],light[2],light[3],255},
					{0,1,0,0,light[1],light[2],light[3],255},
					{0,0,0,0,light[1],light[2],light[3],255}})

function clean(objects)
	for i, obj in ipairs(objects) do
		if obj.x < 0 or obj.x > 64 or
		   obj.y < 0 or obj.y > 64 then
			table.remove(objects, i)
		end

	end
end

function spawn_bullet( x, y, dir, vel, color )
	bullet = {}
	
	bullet.x = x
	bullet.y = y
	bullet.dir = dir
	bullet.velocity = vel
	if(color == 'dark') then
		bullet.mesh = dark_bullet
	else    bullet.mesh = light_bullet end

	table.insert(bullets,bullet)
end

function move( movables, dt )
	for i, obj in ipairs(movables) do
		obj.x = obj.x + obj.dir[1] * dt * obj.velocity
		obj.y = obj.y + obj.dir[2]*dt*obj.velocity
	end
end

function collide(collidables)
	for i, obj in ipairs(collidables) do
		
	end
end

function make_laser_generator( start, increment, period, color )

	local time = 0

	return function ( dt )
		if time >= period then
			time = 0

			for i=1,64 do	
				spawn_bullet(   start[1] + i*increment[1], 
						start[2] + i*increment[2],
						{increment[2],-increment[1]},
						30,
						color
						)
			end
		else time = time + dt end
	end
end

function player_update( dt )

	if love.keyboard.isDown('w') then
		player.y = player.y - dt*player.velocity
	end
	if love.keyboard.isDown('s') then
		player.y = player.y + dt*player.velocity
		
	end
	if love.keyboard.isDown('d') then
		player.x = player.x + dt*player.velocity
		
	end
	if love.keyboard.isDown('a') then
		player.x = player.x - dt*player.velocity
	end

	if love.keyboard.isDown('up') then
		spawn_bullet(player.x + math.floor(player.width/2), 
			     player.y + math.floor(player.height/2) ,
				{0,-1}, 40, player.state)
	end
	if love.keyboard.isDown('down') then
		spawn_bullet(player.x + math.floor(player.width/2), 
			     player.y + math.floor(player.height/2) ,
				{0,1}, 40, player.state )
	end
	if love.keyboard.isDown('left') then
		spawn_bullet(player.x + math.floor(player.width/2), 
			     player.y + math.floor(player.height/2) ,
				{-1,0}, 40, player.state)
	end
	if love.keyboard.isDown('right') then
		spawn_bullet(player.x + math.floor(player.width/2), 
			     player.y + math.floor(player.height/2) ,
				{1,0}, 40, player.state)
	end
end


function love.keypressed(key)
	if key == 'space' then
		if player.state == 'light' then
			player.active_mesh = player.mesh_dark
			player.state = 'dark'
		else
			player.state = 'light'
			player.active_mesh = player.mesh_light
		end
	end
end

function love.load()
	love.window.setMode(320,320, {resizable=true,vsync=false, minwidth=200, minheight=200})
	maid64.setup(64)
	
	player = {
		width = 3,
		height = 3,
		velocity = 25,
		state = 'light',

		x = 4,
		y = 4,
	}

	background = maid64.newImage('bg1.png')

		
	player.mesh_light = love.graphics.newMesh({
			{0,0, 0,0, light[1],light[2],light[3], 255},
			{player.width,0, 0,0, light[1],light[2],light[3], 255},
			{player.width,player.height, 0,0, light[1],light[2],light[3], 255},
			{0,player.height, 0,0,light[1],light[2],light[3], 255}
	})
	player.mesh_dark = love.graphics.newMesh({
			{0,0, 0,0, dark[1],dark[2],dark[3], 255},
			{player.width,0, 0,0, dark[1],dark[2],dark[3], 255},
			{player.width,player.height, 0,0, dark[1],dark[2],dark[3], 255},
			{0,player.height, 0,0, dark[1],dark[2],dark[3], 255}
	})
	player.active_mesh = player.mesh_light

	gen1 = make_laser_generator({64,0},{-1,0},3,'light')
	gen2 = make_laser_generator({64,64},{0,-1},4,'dark')
	gen3 = make_laser_generator({64,0},{-1,0},2,'dark')
end

function love.update(dt)

	player_update(dt)

	gen1(dt)
	gen2(dt)
	gen3(dt)

	move(bullets, dt)
	
	collide( bullets )
	collide( player )

	clean(bullets)
end

function love.draw()
	maid64.start()
	love.graphics.draw(background,0,0)

	love.graphics.draw(player.active_mesh, player.x,player.y)	
	for i, bullet in ipairs(bullets) do
		love.graphics.draw(bullet.mesh, bullet.x, bullet.y)
	end
	

	maid64.finish()
end
