Class = require 'hump.class'
vector = require 'hump.vector'
camera = require 'hump.camera'
require 'gameobject'
require 'projectile'
require 'sprite'
require 'bounds'
require 'gameconf'
require 'collidable'

Player = Class
{
	name = "Player",
	inherits = {GameObject, Collidable},
	function(self, img)
		GameObject.construct(self, vector(30, screen.height / 2))
		Collidable.construct(self, "Player")
		self.tags = {Enemy = true, EnemyShot = true, Trigger =true}
		self.depth = 5
		self.sprite = Sprite(img)
		self.movespeed = 500
		self.mbx, self.mby = 96, 64
		self.movementBounds = Rectangle(vector(self.mbx, self.mby),
										vector((screen.width / 2) - self.mby * 2,
											   screen.height - self.mby * 2 - game.hud.vertSize))
		self.sprite.position = self.position
		self.bounds = self.sprite:getBoundingRect()
		self.bounds:shrink(vector(0, 64))
		self.boundsOffset = self.bounds.position - self.position

		self.ouch = false
		self.collPos = vector(0, 0)

		self.fireTime = 0.05
		self.fireTimer = 0.0
	end
}

function Player:init()
end

function Player:update(dt)
	if game.input.enabled then self:controls(dt) end

	self.position = self.position + self.velocity * dt

	self:constrainPosition()

	self:updateSprite()

	self.movementBounds.dimensions.y = screen.height - self.mby * 2 - game.hud.vertSize
end

function Player:controls(dt)
	self.velocity.x = game.scrollSpeed
	self.velocity.y = 0

	if love.keyboard.isDown("left") then
		self.velocity.x = self.velocity.x - self.movespeed
	end
	if love.keyboard.isDown("right") then
		self.velocity.x = self.velocity.x + self.movespeed
	end

	if love.keyboard.isDown("up") then
		self.velocity.y = self.velocity.y - self.movespeed
	end
	if love.keyboard.isDown("down") then
		self.velocity.y = self.velocity.y + self.movespeed
	end

	self:shooting(dt)
end

function Player:shooting(dt)
	if self.fireTimer > 0.0 then
		self.fireTimer = self.fireTimer - dt
	end

	if love.keyboard.isDown("z") and self.fireTimer <= 0.0 then
		gameObjects:register(Projectile(self.position + vector(self.bounds.dimensions.x / 2, 0), "PlayerShot"))
		self.fireTimer = self.fireTime
	end
end

function Player:constrainPosition()
	cx, cy = game.camera:pos()
	cx, cy = cx - screen.width / (2 * game.camera.scale), cy - screen.height / (2 * game.camera.scale)
	screenpos = self.position - vector(cx, cy)
	if screenpos.y < self.movementBounds:top() then
		self.position.y = self.movementBounds:top() + cy
	end
	if screenpos.y > self.movementBounds:bottom() then
		self.position.y = self.movementBounds:bottom() + cy
	end
	if screenpos.x < self.movementBounds:left() then
		self.position.x = self.movementBounds:left() + cx
	end
	if screenpos.x > self.movementBounds:right() then
		self.position.x = self.movementBounds:right() + cx
	end
end

function Player:updateSprite()
	self.sprite.position = self.position
	self.sprite.rotation = self.rotation
	self.sprite.scale = self.scale
	self.bounds.position = self.position + self.boundsOffset
end

function Player:draw()
	self.sprite:draw()

	if game.debug.on then
		self:debugDraw()
	end
end

function Player:debugDraw()
	if self.ouch then
		self.bounds:draw(255, 0, 0)
		love.graphics.circle("fill", self.collPos.x, self.collPos.y, 8)
	else
		self.bounds:draw(0, 255, 0)
	end

	game.camera:detach()
	self.movementBounds:draw(255, 255, 0)
	game.camera:attach()
end

function Player:onCollisionEnter(other, colPosition, colNormal)
	self.ouch = true
end

function Player:onCollisionStay(other, colPosition, colNormal)
	self.collPos = colPosition
end

function Player:onCollisionExit(other)
	self.ouch = false
end