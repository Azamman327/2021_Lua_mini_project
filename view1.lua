-----------------------------------------------------------------------------------------
--
-- view1.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

function scene:create( event )
	local sceneGroup = self.view

	local BGUI = display.newGroup();

	local background = display.newRect(BGUI, display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight )
	local w,h = display.contentWidth, display.contentHeight/2

	physics.start()
    physics.setGravity( 0, 0 )

	local sky = display.newImageRect(BGUI, "Content/sky.png", display.contentWidth, display.contentHeight)
	sky.x, sky.y = display.contentWidth/2, display.contentHeight/2

	local ground = display.newImageRect(BGUI, "Content/ground.png", display.contentWidth, 300)
	ground.x, ground.y = display.contentWidth/2, display.contentHeight-150

    local score = 0
    local showScore = display.newText(score, display.contentWidth*0.25, display.contentHeight*0.15, 500, 100)
    showScore.align = "right"
    showScore:setFillColor(0)
    showScore.size = 80

    local function scoreUp ( event )
    	score = score + 1
    	showScore.text = score
    end

	local music = audio.loadStream( "Content/music1.ogg" )
	local bgMusic
	local soundOn = 0
	local bgmUI = {}
	bgmUI[0] = display.newImageRect("Content/on.png", 55, 55)
	bgmUI[0].x, bgmUI[0].y = 1240, 40
	bgmUI[0].alpha = 0
	bgmUI[1] = display.newImageRect("Content/off.png", 55, 55)
	bgmUI[1].x, bgmUI[1].y = 1240, 40

	local playUI = {}
	playUI[0] = display.newImageRect("Content/play.png", 55, 55)
	playUI[0].x, playUI[0].y = 1180, 40
	playUI[0].alpha = 0
	playUI[1] = display.newImageRect("Content/stop.png", 55, 55)
	playUI[1].x, playUI[1].y = 1180, 40

	local UI = {}
	UI[0] = display.newRect(640, 360, 600, 300)
	UI[0]:setFillColor(0.5)
	UI[1] = display.newImage("Content/start.png") 
	UI[1].x, UI[1].y = 640, 400
	UI[2] = display.newImageRect("Content/x.png", 30, 30)
	UI[2].x, UI[2].y = 920, 230

	for i = 0, #UI do
		UI[i].alpha = 0
	end

	local dino_sheet = graphics.newImageSheet( "Content/player.png", { width = 240, height = 240, numFrames = 6 })
	local sepuencesData =
	{
		{ name = "stand",start = 1, count = 1},
		{ name = "run",  start = 1, count = 3, time = 400 },
		{ name = "jump", start = 4, count = 1, loopCount = 1, time = 1000},
		{ name = "slide", start = 5, count = 1, time = 400},
		{ name = "hurt", start = 6, count = 1}
	}

	local dino = display.newSprite( dino_sheet, sepuencesData )
	dino.x, dino.y = display.contentWidth*0.2, display.contentHeight*0.5

    local obstacle = {}
	obstacle[1] = display.newImageRect("Content/bone1.png", 69, 95)
	obstacle[2] = display.newImageRect("Content/bone2.png", 131, 115)
	obstacle[3] = display.newImageRect("Content/bone3.png", 117, 84)
	obstacle[4] = display.newImageRect("Content/Ptero.png", 276, 119)

	for i = 1, 3, 1 do 
		obstacle[i].x, obstacle[i].y = display.contentWidth+200, display.contentHeight-280
	end
	obstacle[4].x, obstacle[4].y = display.contentWidth+200, 250


	local cooltime
	local obs_idx

    local function dino_spriteListenr( event )
    	if event.phase == "began" then
    		--if dino.sequence == "jump" then

	    	--else
	    	if dino.sequence == "hurt" then
	    		dino:setFillColor(0.75, 0.5, 0.5)
	    		timer.cancel( scoreEvent )
	    		--display.remove( jumpButton )
	    	end
    	elseif event.phase == "ended" then
	    	dino:setSequence( "run" )
	    	dino:play()
    	end
    end
    dino:addEventListener( "sprite", dino_spriteListenr )

	local function soundONOFF( ... )
		if soundOn == 1 then
			soundOn = 0
			bgmUI[0].alpha = 0
			bgmUI[1].alpha = 1
			audio.stop(bgMusic)
		else
			soundOn = 1
			bgmUI[0].alpha = 1
			bgmUI[1].alpha = 0
			bgMusic = audio.play(music, { channel=1, loops=-1, fadein=5000 })
		end
	end
	bgmUI[0]:addEventListener("tap", soundONOFF)
	bgmUI[1]:addEventListener("tap", soundONOFF)

	local function tapPlay( ... )
		playUI[0].alpha = 0
		playUI[1].alpha = 1

		soundOn = 0
		soundONOFF()

		for i = 0, #UI do
			UI[i].alpha = 0
		end

		scoreEvent = timer.performWithDelay( 250, scoreUp, 0 )
		dino:setSequence( "run" )
	    dino:play()
	end

	local function tapStop( ... )
		playUI[0].alpha = 1
		playUI[1].alpha = 0

		soundOn = 1
		soundONOFF()

		for i = 0, #UI do
			UI[i].alpha = 1
		end

		timer.cancel( scoreEvent )
		dino:setSequence( "stand" )
	    dino:play()
	end

	local function tapX( ... )
		for i = 0, #UI do
			UI[i].alpha = 0
		end
	end

	playUI[0]:addEventListener("tap", tapPlay)
	playUI[1]:addEventListener("tap", tapStop)
	UI[1]:addEventListener("tap", tapPlay)
	UI[2]:addEventListener("tap", tapX)

	-- 장애물과 충돌했을 때
	-- dino:setSequence( "hurt" )
	-- dino:play()
	-- composer.setVariable("score", score)
	-- composer.gotoScene("end")

    local function playerDown( event )
    	transition.to( dino, { time=500,  y=(dino.y+150) } )
    end

	local function onKeyJumpEvent( event )
	 	if ( event.keyName == "space" ) and ( event.phase == "down" ) and (dino.y == h) then
	 		transition.to( dino, { time=500,  y=(dino.y-150), onComplete = playerDown } )
	 		dino:setSequence( "jump" )
	    	dino:play()
	 		print("jump")
	    end
	end

	local function onKeySlideEvent( event )
	 	if ( event.keyName == "down" ) and ( event.phase == "down" ) then
	 		dino:setSequence( "slide" )
	 		print("slide")
	    end
	    if ( event.keyName == "down" ) and ( event.phase == "up" ) then
 			dino:setSequence( "run" )
	 		dino:play()
 		end
	end

	Runtime:addEventListener( "key", onKeyJumpEvent )
	Runtime:addEventListener( "key", onKeySlideEvent )

	function start()
		cooltime = math.random(1, 4)--0.5~2초 사이의 간격으로 스폰
		obs_idx = math.random(1, 4)--1~5번 장애물 중 랜덤선택
		print("spawn time = "..cooltime)
		print("obstacle idx is "..obs_idx)
		timer.performWithDelay(cooltime*500, spawn_obstacle)
	end

	function obs_reset()--다시 화면 밖으로(초기상태로)
		print("obstacle.x is out of screen")

		obstacle[obs_idx]:setLinearVelocity( 0, 0 )
		physics.removeBody(obstacle[obs_idx])
		obstacle[obs_idx].x = display.contentWidth+200

		start()
	end

	function spawn_obstacle ()
		print("spawn obstacle")

		physics.addBody( obstacle[obs_idx], "dynamic" )
		obstacle[obs_idx]:setLinearVelocity( -500, 0 )--장애물 이동

		timer.performWithDelay(4000, obs_reset)
	end
	
	start()
	tapPlay()

	sceneGroup:insert( BGUI )
	
    for i = 0, #bgmUI do sceneGroup:insert( bgmUI[i] ) end
    for i = 0, #UI do sceneGroup:insert( UI[i] ) end
    for i = 0, #playUI do sceneGroup:insert( playUI[i] ) end

    sceneGroup:insert( showScore )
    sceneGroup:insert( dino )
end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	physics.start()

	if phase == "will" then
	elseif phase == "did" then

	end	
end

function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase
	physics.phase()

	if event.phase == "will" then
	elseif phase == "did" then

	end
end

function scene:destroy( event )
	local sceneGroup = self.view
	physics.stop()
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene
