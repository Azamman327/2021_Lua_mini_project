-----------------------------------------------------------------------------------------
--
-- start.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()
local widget = require( "widget" )

function scene:create( event )
	local sceneGroup = self.view
	
	local background = display.newRect(640, 360, 1280, 720)

	-- 시작
	local function playGame()
		composer.gotoScene("game")
	end
	local startUI = widget.newButton({ defaultFile = "Content/start.png", overFile = "Content/start_over.png",
		x = display.contentWidth/2, y = display.contentHeight/2+100, onRelease = playGame })

	sceneGroup:insert(background)
	sceneGroup:insert(startUI)

end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
	elseif phase == "did" then
	end	
end

function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if event.phase == "will" then
	elseif phase == "did" then
	end
end

function scene:destroy( event )
	local sceneGroup = self.view
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene