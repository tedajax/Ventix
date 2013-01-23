Class = require 'hump.class'
Timer = require 'hump.timer'
require 'stack'
require 'queue'
require 'gameobject'
require 'collidable'
require 'collisionmanager'

GameObjectManager = Class
{
	function(self)
		self.objects = {}
		self.available = Stack()
		self.currentId = 1
		self.destroyQueue = Queue()

		if game.debug.on then
			self.debug = {
				objCount = 0
			}
		end
	end
}

function GameObjectManager:register(obj)
	if obj.id > 0 then return end
	obj.id = self:nextId()
	self.objects[obj.id] = obj
	if obj:is_a(Collidable) then
		collisionManager:register(obj)
	end
end

function GameObjectManager:unregister(id)
	if self.objects[id] then
		self.objects[id] = nil
		self.available:push(id)
	end
end

function GameObjectManager:find(id)
	return self.objects[id]
end

function GameObjectManager:nextId()
	if self.available:size() > 0 then
		return self.available:pop()
	else
		self.currentId = self.currentId + 1
		return self.currentId - 1
	end
end

function GameObjectManager:update(dt)
	for i, obj in pairs(self.objects) do
		if obj ~= nil then
			obj:update(dt)
			if obj.destroy then
				self.destroyQueue:push(obj.id)
			end
		end
	end

	while self.destroyQueue:size() > 0 do
		self:unregister(self.destroyQueue:pop())
	end

	if game.debug.on then
		self:updateDebug()
	end
end

function GameObjectManager:updateDebug()
	self.debug.objCount = self.currentId - self.available:size()
end

function GameObjectManager:draw()
	local orderedObjects = {};
	for i, obj in pairs(self.objects) do
		if obj ~= nil and not obj.hidden then
			table.insert(orderedObjects, obj)
		end
	end
	table.sort(orderedObjects, function(a, b) return a.depth > b.depth 	end)
	for i, v in ipairs(orderedObjects) do
		v:draw()
	end
end