Ball = Class{}

-- constructor
function Ball:init(x, y, width, height, r, g, b)
	self.x = x
	self.y = y
	self.width = width
	self.height = height
	self.r = r
	self.g = g
	self.b = b

	self.dx = math.random(2) == 1 and 100 or -100
	self.dy = math.random(-50 , 50)
end

function Ball:reset(servingPlayer)
	self.x = VIRTUAL_WIDTH / 2 - 2
	self.y = VIRTUAL_HEIGHT / 2 - 2 

	-- sending the ball off in a random direction
	self.dx = math.random(2) == 1 and 100 or -100
	self.dy = math.random(-50 , 50)
end

function Ball:update(dt)
	self.x = self.x + self.dx * dt
	self.y = self.y + self.dy * dt
end

function Ball:render(r, g, b)
	love.graphics.setColor(self.r / 255, self.g / 255, self.b / 255, 255)
	love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end

function Ball:collides(paddle)
	-- compares current x of the ball to the paddle to see if they have collided, in a nutshell
	if self.x > paddle.x + paddle.width or paddle.x > self.x + self.width then 
		return false
	end

	-- compares current y of the ball to the paddle to see if they have collided, in a nutshell
	if self.y > paddle.y + paddle.height or paddle.y > self.y + self.height then 
		return false
	end

	return true
end

