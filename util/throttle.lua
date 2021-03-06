-- * Metronome IM *
--
-- This file is part of the Metronome XMPP server and is released under the
-- ISC License, please see the LICENSE file in this source package for more
-- information about copyright and licensing.
--
-- As per the sublicensing clause, this file is also MIT/X11 Licensed.
-- ** Copyright (c) 2011-2012, Matthew Wild

local gettime = require "socket".gettime;
local setmetatable = setmetatable;
local floor = math.floor;

module "throttle"

local throttle = {};
local throttle_mt = { __index = throttle };

function throttle:update()
	local newt = gettime();
	local elapsed = newt - self.t;
	self.t = newt;
	local balance = floor(self.rate * elapsed) + self.balance;
	if balance > self.max then
		self.balance = self.max;
	else
		self.balance = balance;
	end
	return self.balance;
end

function throttle:peek(cost)
	cost = cost or 1;
	return self.balance >= cost or self:update() >= cost;
end

function throttle:poll(cost, split)
	if self:peek(cost) then
		self.balance = self.balance - cost;
		return true;
	else
		local balance = self.balance;
		if split then
			self.balance = 0;
		end
		return false, balance, (cost-balance);
	end
end

function create(max, period)
	return setmetatable({ rate = max / period, max = max, t = 0, balance = max }, throttle_mt);
end

return _M;
