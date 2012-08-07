local use_luaevent = metronome and require "core.configmanager".get("*", "core", "use_libevent");

if use_luaevent then
	use_luaevent = pcall(require, "luaevent.core");
	if not use_luaevent then
		log("error", "libevent not found, falling back to select()");
	end
end

local server;

if use_luaevent then
	server = require "net.server_event";

	-- Overwrite signal.signal() because we need to ask libevent to
	-- handle them instead
	local ok, signal = pcall(require, "util.signal");
	if ok and signal then
		local _signal_signal = signal.signal;
		function signal.signal(signal_id, handler)
			if type(signal_id) == "string" then
				signal_id = signal[signal_id:upper()];
			end
			if type(signal_id) ~= "number" then
				return false, "invalid-signal";
			end
			return server.hook_signal(signal_id, handler);
		end
	end
else
	server = require "net.server_select";
end

-- require "net.server" shall now forever return this,
-- ie. server_select or server_event as chosen above.
return server;
