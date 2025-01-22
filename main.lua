---@diagnostic disable: duplicate-set-field

function love.load()
	love.window.setVSync(0)
	love.graphics.setBackgroundColor(0.50, 0.50, 0.75)
	love.window.setTitle("LoveFlow Demo")

	local loveflow = require("src.loveflow")

	LOGGER = require("src.lib.loggy")

	ARCH = loveflow.newArch()
	ARCH.showDebugInfo(true)

	PLAYER = {
		x = (love.graphics.getWidth() / 2) - (50 / 2),
		y = (love.graphics.getHeight() / 2) - (50 / 2),
		w = 50,
		h = 50,
		speed = 400,
		locked = false,
		handler = function(_, event)
			local dt = DELTA_TIME
			if event.type == "move" and PLAYER.locked == false then
				if event.up then
					PLAYER.y = PLAYER.y - PLAYER.speed * dt
				elseif event.down then
					PLAYER.y = PLAYER.y + PLAYER.speed * dt
				elseif event.left then
					PLAYER.x = PLAYER.x - PLAYER.speed * dt
				elseif event.right then
					PLAYER.x = PLAYER.x + PLAYER.speed * dt
				end

				local bounds = event.bounds
				if bounds.up then
					PLAYER.y = bounds.up_correct
				end
				if bounds.down then
					PLAYER.y = bounds.down_correct
				end
				if bounds.left then
					PLAYER.x = bounds.left_correct
				end
				if bounds.right then
					PLAYER.x = bounds.right_correct
				end
			end
			if event.type == "toggle_lock" then
				PLAYER.locked = not PLAYER.locked
			end
		end,
	}
	MOVEMENT = ARCH.bus:newPublisher("Movement controller")
	PLAYER.sub = ARCH.bus:newSubscriber("Player subscriber"):subscribe(MOVEMENT)

	PUBLISH_COUNT = 0
	DELTA_TIME = 0

	KEYBINDS_STR = [[
Escape = quit
f = lock player
e = print movement info table (requires open console/terminal)
  ]]

	CURRENT_TIME = 0
	LAST_PUBLISH_TIME = 0
	PUBLISH_DT = 0

	GLOBAL_COUNTER = 0
end

function love.update(dt)
	DELTA_TIME = dt

	-- time elapsed and time elapsed from last publish --
	CURRENT_TIME = CURRENT_TIME + dt
	PUBLISH_DT = CURRENT_TIME - LAST_PUBLISH_TIME

	ARCH:updateAll()

	if IsMoving() and not PLAYER.locked then
		MOVEMENT:publish({
			type = "move",
			up = love.keyboard.isDown("w"),
			down = love.keyboard.isDown("s"),
			left = love.keyboard.isDown("a"),
			right = love.keyboard.isDown("d"),
			bounds = {
				up = PLAYER.y < 0,
				up_correct = 0,
				down = PLAYER.y > (love.graphics.getHeight() - PLAYER.h),
				down_correct = love.graphics.getHeight() - PLAYER.h,
				left = PLAYER.x < 0,
				left_correct = 0,
				right = PLAYER.x > (love.graphics.getWidth() - PLAYER.w),
				right_correct = love.graphics.getWidth() - PLAYER.w,
			},
		})
		PUBLISH_COUNT = PUBLISH_COUNT + 1

		LAST_PUBLISH_TIME = CURRENT_TIME
	end
	if IsMoving() and PLAYER.locked then
		LOGGER.error("Can't move, player is locked")
	end

	PLAYER.sub:handleEvents(ARCH.bus, PLAYER.handler)

	INFO_STRING = ([[
FPS: %s
PUBLISH COUNT: %s
TIME ELAPSED: %s
LAST PUBLISHED: %s
TIME ELAPSED SINCE PUBLISH: %s

%s
  ]]):format(
		love.timer.getFPS(),
		PUBLISH_COUNT,
		ShortenNumber(CURRENT_TIME, 4),
		ShortenNumber(LAST_PUBLISH_TIME, 4),
		ShortenNumber(PUBLISH_DT, 4),
		KEYBINDS_STR
	)
end

function love.draw()
	love.graphics.setColor(0.75, 0.25, 0.25)
	love.graphics.rectangle("fill", PLAYER.x, PLAYER.y, PLAYER.w, PLAYER.h)

	love.graphics.setColor(0, 0, 0, 0.5)
	love.graphics.rectangle("fill", 0, 0, 400, 130)
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.print(INFO_STRING)
end

function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	elseif key == "f" then
		MOVEMENT:publish({ type = "toggle_lock" })
	elseif key == "e" then
		LOGGER.PrintTable({
			type = "move",
			up = love.keyboard.isDown("w"),
			down = love.keyboard.isDown("s"),
			left = love.keyboard.isDown("a"),
			right = love.keyboard.isDown("d"),
			bounds = {
				up = PLAYER.y < 0,
				up_correct = 0,
				down = PLAYER.y > (love.graphics.getHeight() - PLAYER.h),
				down_correct = love.graphics.getHeight() - PLAYER.h,
				left = PLAYER.x < 0,
				left_correct = 0,
				right = PLAYER.x > (love.graphics.getWidth() - PLAYER.w),
				right_correct = love.graphics.getWidth() - PLAYER.w,
			},
		})
	end
end

function IsMoving()
	local isDown = love.keyboard.isDown
	return isDown("w") or isDown("a") or isDown("s") or isDown("d")
end

function ShortenNumber(num, decimals)
	-- 0 can't be shortened
	if num == 0 then
		return 0
	end

	num = num * 1.0
	num = tostring(num)

	-- get whole and decimal part of number
	local splitted = SplitString(num, ".")
	local whole_part, decimal_part = splitted[1], splitted[2]

	-- avoid errors
	if decimals > #decimal_part then
		decimals = #decimal_part
	elseif decimals < 1 then
		decimals = 1
	end

	-- return shortened number
	return tonumber(whole_part .. "." .. decimal_part:sub(1, decimals))
end

-- https://stackoverflow.com/a/7615129
function SplitString(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t = {}
	for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
		table.insert(t, str)
	end
	return t
end
