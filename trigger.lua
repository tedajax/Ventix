Class = require 'hump.class'
vector = require 'hump.vector'
Signal = require 'hump.signal'
require 'collidable'
require 'gameconf'

Trigger = Class
{
	name = "Trigger",
	inherits = {GameObject, Collidable},
	function(self, enter, x, y, w, h, exit, stay)
		GameObject.construct(self)
		Collidable.construct(self, "Trigger")
		self.bounds.position = vector(x or 0, y or 0)
		self.bounds.dimensions = vector(w or 5, h or screen.height)
		self.tags = { Player = true }
		self.depth = 1
		self.enter = enter or 'onTriggerEnter'
		self.stay = stay or 'onTriggerStay'
		self.exit = exit or 'onTriggerExit'
	end
}

function Trigger:onCollisionEnter(other, position, normal)
	if self.enter then Signal.emit(self.enter, self.id) end
end

function Trigger:onCollisionStay(other, position, normal)
	if self.stay then Signal.emit(self.stay, self.id) end
end

function Trigger:onCollisionExit(other, position, normal)
	if self.exit then Signal.emit(self.exit, self.id) end
end

function Trigger:draw()
	if game.debug.on then
		self.bounds:draw(0, 255, 0)
	end
end