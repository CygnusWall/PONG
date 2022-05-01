-- https://github.com/Uldev/push
push = require "push"

-- https://github.com/vrld/hump/blob/master/class.lua
Class = require "class"

-- user defined classes
require "Paddle"

require "Ball"

-- declaring constants
WINDOW_WIDTH = 1366
WINDOW_HEIGHT = 768

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

WINNING_SCORE = 10

PADDLE_SPEED = 200
SPEED_FACTOR = 1.03

-- color variables
r = 255
g = 255
b = 255

--Runs at startup
function love.load()

	-- gives us that retro pixelated look
	love.graphics.setDefaultFilter('nearest', 'nearest')

	love.window.setTitle('Pong')

	-- generates a random number based on the current time
	math.randomseed(os.time())

	smallFont = love.graphics.newFont('font.ttf', 8)
	scoreFont = love.graphics.newFont('font.ttf', 32)

	sounds = {
		['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
		['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static'),
		['score'] = love.audio.newSource('sounds/score.wav', 'static')
	}

	push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT,{
		fullscreen = true,
		resizable = true, 
		vsync = true,
	})

	-- paddle positions
	player1 = Paddle(10, 30, 5, 20)
	player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)

	-- making the ball object at the center using the constructor
	ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4, 255, 255, 255)

	--we will use this to determine the behavior between render and update
	gameState = 'start'
end
 
player1Score = 0
player2Score = 0

-- declaring serving player so it shows up at the start of the match
servingPlayer = 1

function love.keypressed(key)
	-- keys can be accessed by string name
	if key == 'escape' then
		love.event.quit()

	elseif key == 'enter' or key == 'return' or key == 'q' then
		if gameState == 'start' then
			if player1Score >= WINNING_SCORE or player2Score >= WINNING_SCORE then
				resetGame()
				gameState = 'play'
			else
				gameState = 'play'
			end
		else
			gameState = 'start'
			ball:reset(servingPlayer)
		end
	end
end

function love.draw()
	-- begin rendering at virtual resolution
	push:apply('start')

	function love.update(dt)

		-- player 1 movement
		if love.keyboard.isDown('w') then
			-- add negative paddle speed to current Y scaled by deltatime
			player1.dy = -PADDLE_SPEED
			-- updating the player's position
			player1:update(dt)

		elseif love.keyboard.isDown('s') then
			-- add postitive paddle speed to current Y scaled by deltatime
			player1.dy = PADDLE_SPEED
			-- updating the player's position
			player1:update(dt)
		end
		
		-- player 2 movement
		if love.keyboard.isDown('up') then
			-- add negative paddle speed to current Y scaled by deltatime
			player2.dy = -PADDLE_SPEED
			-- updating the player's position
			player2:update(dt)

		elseif love.keyboard.isDown('down') then
			-- add postitive paddle speed to current Y scaled by deltatime
			player2.dy = PADDLE_SPEED
			-- updating the player's position
			player2:update(dt)
		end

		--
		-- gamestates
				
		if gameState == 'serve' then
			ball.dy = math.random(-50, 50)
			if servingPlayer == 1 then
				ball.dx = math.random(140, 200)
				gameState = 'start'
			else 
				ball.dx = -math.random(140, 200)
				gameState = 'start'
			end
		
		elseif gameState == 'play' then
			-- updating the ball's position
			ball:update(dt)

			-- detect ball collision with paddles, reversing dx if true and 
			-- slightly increasing it, then altering the dy based on the thickness of the paddle
			if ball:collides(player1) then
				--speeding up the ball by 3% everytime it is deflected by a player
				ball.dx = -ball.dx * SPEED_FACTOR
				ball.x = player1.x + 5
				ball.r = math.random(0, 255)
				ball.g = math.random(0, 255)
				ball.b = math.random(0, 255)
				sounds['paddle_hit']:play()

				-- keep velocity going in the same direction but randomize it
				if ball.dy < 0 then 
					ball.dy = -math.random(10, 150)
				else
					ball.dy = math.random(10, 150)
				end

			end 

			if ball:collides(player2) then
				--speeding up the ball by 3% everytime it is deflected by a player
				ball.dx = -ball.dx * SPEED_FACTOR
				ball.x = player2.x - 4
				ball.r = math.random(0, 255)
				ball.g = math.random(0, 255)
				ball.b = math.random(0, 255)
				sounds['paddle_hit']:play()

				-- keep velocity going in the same direction but randomize it
				if ball.dy < 0 then 
					ball.dy = -math.random(10, 150)
				else
					ball.dy = math.random(10, 150)
				end

			end

			-- detect upper and lower screen boundary collision and reverse if collision occurs
			if ball.y <= 0 then
				ball.y = 0
				ball.dy = -ball.dy
				ball.r = math.random(0, 255)
				ball.g = math.random(0, 255)
				ball.b = math.random(0, 255)
				sounds['wall_hit']:play()
			end
			 
			if ball.y >= VIRTUAL_HEIGHT - 4 then
				ball.y = VIRTUAL_HEIGHT - 4
				ball.dy = - ball.dy
				ball.r = math.random(0, 255)
				ball.g = math.random(0, 255)
				ball.b = math.random(0, 255)
				sounds['wall_hit']:play()
			end

		end

	
		-- updating the score
		if ball.x > VIRTUAL_WIDTH then
			player2Score = player2Score + 1
			ball:reset()
			servingPlayer = 2
			gameState = 'serve'
			sounds['score']:play()
			
		elseif ball.x < 0 then
			player1Score = player1Score + 1
			ball:reset()
			servingPlayer = 1
			gameState = 'serve'
			sounds['score']:play()
		end 

	end

	-- RENDERING
	-- setting the background color
	love.graphics.clear(0, 0, 200, 255)

	love.graphics.setFont(scoreFont)
	love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 + 12, VIRTUAL_HEIGHT / 3)
	love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 - 28, VIRTUAL_HEIGHT / 3)

	if player1Score >= WINNING_SCORE then
		love.graphics.setFont(smallFont)
		love.graphics.printf('Player 1 Wins!!!', 0, 50, VIRTUAL_WIDTH, 'center')
		servingPlayer = 1

	elseif player2Score >= WINNING_SCORE then
		love.graphics.setFont(smallFont)
		love.graphics.printf('Player 2 Wins!!!', 0, 50, VIRTUAL_WIDTH, 'center')
		servingPlayer = 2
	end

	-- gamestates but for rendering
	if gameState == 'start' then
		love.graphics.setFont(smallFont)
		love.graphics.printf('HELLO PONG!', 0, 20, VIRTUAL_WIDTH, 'center')
		love.graphics.printf('Press ENTER to begin', 0, 40, VIRTUAL_WIDTH, 'center')
	elseif gameState == 'play' then
		if servingPlayer == 1 then
			love.graphics.setFont(smallFont)
			love.graphics.printf("Player 1's serve", 0, 20, VIRTUAL_WIDTH, 'center')
		elseif servingPlayer == 2 then
			love.graphics.setFont(smallFont)
			love.graphics.printf("Player 2's serve", 0, 20, VIRTUAL_WIDTH, 'center')
		end
	end

	player1:render()
	player2:render()	

	ball:render(r, g, b)

	displayFPS()

	push:apply('end')
end

-- user defined functions
function displayFPS()
	love.graphics.setFont(smallFont)
	love.graphics.setColor(0, 255, 0, 255)
	love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
end

function resetGame()
	player1Score = 0
	player2Score = 0
end

function love.resize(w, h)
	push:resize(w,h)
end