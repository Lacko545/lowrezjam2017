local maid64 = require 'maid64/maid64'

local bullets = {}
local lasers  = {}

local enemies = {}

local t, shakeDuration, shakeMagnitude = 0, -1, 0

function startShake(duration, magnitude)
    t, shakeDuration, shakeMagnitude = 0, duration or 1, magnitude or 5
end

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

function spawn_bullet( x, y, dir, vel, color, t, lifetime)
	bullet = {}
	
	bullet.x = x
	bullet.y = y
	bullet.dir = dir
	bullet.velocity = vel
	
	bullet.lifetime = lifetime

	if(color == 'dark') then
		bullet.mesh = dark_bullet
	else    bullet.mesh = light_bullet end
	
	if t == nil then table.insert(bullets, bullet)
	else table.insert(t,bullet) end
end

function move( movables, dt )
	for i, obj in ipairs(movables) do
		obj.x = obj.x + obj.dir[1] * dt * obj.velocity
		obj.y = obj.y + obj.dir[2] * dt * obj.velocity
		if obj.lifetime ~= nil then
			obj.lifetime = obj.lifetime - dt
			if obj.lifetime <= 0 then
				table.remove(movables, i)
			end
		end
	end
end

function make_laser_generator( start, increment, period, color )
	local time = 0
	local col = 'light'

	return function ( dt )
		if time >= period then
			if color == 'light' or color == 'dark' then col = color
			elseif color == 'random' then 
				if math.random(100)%2 == 1 then
					col = 'dark'
				else 
					col = 'light'
				end
			elseif col == 'light' then col = 'dark'
			elseif col == 'dark' then col = 'light' end

			time = 0

			for i=1,64 do	
				spawn_bullet(   start[1] + i*increment[1], 
						start[2] + i*increment[2],
						{increment[2],-increment[1]},
						15,
						col,
						lasers
						)
			end
		else time = time + dt end
	end
end

function basic_gun(dir)
	if player.cooldown > 0 then return end
	spawn_bullet(player.x + math.floor(player.width/2), 
		     player.y + math.floor(player.height/2) ,
			dir, 70, player.state)
	player.cooldown = 0.1
end

function shot_gun(dir)
	if player.cooldown > 0 then return end
	for i = 1, 10 do
		spawn_bullet(player.x + math.floor(player.width/2), 
			     player.y + math.floor(player.height/2),
			     {dir[1] + math.random()/3, dir[2] + math.random()/3}, 
			     80, player.state,nil, 0.2 + math.random()/3)
	end

	startShake(0.1, 4)
	player.cooldown = 0.5
end

function player_update( dt )
	if player.cooldown > 0 then player.cooldown = player.cooldown - dt end
	
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
		player.shoot({0,-1})
	end
	if love.keyboard.isDown('down') then
		player.shoot({0,1})
	end
	if love.keyboard.isDown('left') then
		player.shoot({-1,0})
	end
	if love.keyboard.isDown('right') then
		player.shoot({1,0})
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
	elseif key == 'lctrl' then

		player.shoot = player.weapons[2]
	end
end

function love.load()
	love.window.setMode(320,320, {resizable=true,vsync=false, minwidth=200, minheight=200})
	maid64.setup(64)
	
	player = {
		width = 3,
		height = 3,
		velocity = 30,
		state = 'light',
		cooldown = 0,

		x = 4,
		y = 4,
		weapons = { basic_gun, shot_gun},
		shoot = basic_gun
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

	gen1 = make_laser_generator({64,0},{-1,0},1,'random')
	gen2 = make_laser_generator({64,64},{0,-1},math.pi,'a')

	gen3 = make_laser_generator({-1,64},{1,0},2,'a')
end

function love.update(dt)

	player_update(dt)

	gen1(dt)
	gen2(dt)
	gen3(dt)
	move(bullets, dt)
	move(lasers, dt)
	

	clean(bullets)
	clean(lasers)

	if t < shakeDuration then
		t = t + dt
	end
end

function love.draw()
	maid64.start()


	love.graphics.draw(background,0,0)

	love.graphics.draw(player.active_mesh, player.x,player.y)	
	for i, bullet in ipairs(bullets) do
		love.graphics.draw(bullet.mesh, bullet.x, bullet.y)
	end
	for i, bullet in ipairs(lasers) do
		love.graphics.draw(bullet.mesh, bullet.x, bullet.y)
	end
	
	
	if t < shakeDuration then
		local dx = love.math.random(-shakeMagnitude, shakeMagnitude)
		local dy = love.math.random(-shakeMagnitude, shakeMagnitude)
		love.graphics.translate(dx, dy)
	end


	maid64.finish()
end
