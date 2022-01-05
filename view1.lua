-----------------------------------------------------------------------------------------
--
-- view1.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

function scene:create( event )
	local sceneGroup = self.view

-- 변수 선언부 --

	-- BG
		local BGUI = display.newGroup();
		local background = display.newRect(BGUI, display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight )
		local w,h = display.contentWidth, display.contentHeight/2

		local sky = display.newImageRect(BGUI, "Content/Sky.png", display.contentWidth, display.contentHeight)
		sky.x, sky.y = display.contentWidth/2, display.contentHeight/2

		local ground = display.newImageRect(BGUI, "Content/Ground.png", display.contentWidth, 300)
		ground.x, ground.y = display.contentWidth/2, display.contentHeight-150

    -- UI

    	-- BGM
		local music = audio.loadStream( "Content/music1.ogg" )
		local bgMusic
		local soundOn = 0
		local bgmUI = {}
		bgmUI[0] = display.newImageRect("Content/on.png", 55, 55)
		bgmUI[0].x, bgmUI[0].y = 1240, 40
		bgmUI[0].alpha = 0
		bgmUI[1] = display.newImageRect("Content/off.png", 55, 55)
		bgmUI[1].x, bgmUI[1].y = 1240, 40

		-- PLAY
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

    -- SCORE
	    local score = 0
	    local showScore = display.newText(score, display.contentWidth*0.25, display.contentHeight*0.15, 500, 100)
	    showScore.align = "right"
	    showScore:setFillColor(0)
	    showScore.size = 80

	    local scoreEvent

    -- DINO
		local dino_sheet = graphics.newImageSheet( "Content/Player.png", { width = 240, height = 240, numFrames = 6 })
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

	-- OBSTACLE
		local obstacleGroup = display.newGroup();
	    local obstacle = {}
		obstacle[1] = display.newImageRect(obstacleGroup, "Content/bone1.png", 69, 95)
		obstacle[2] = display.newImageRect(obstacleGroup, "Content/bone2.png", 131, 115)
		obstacle[3] = display.newImageRect(obstacleGroup, "Content/bone3.png", 117, 84)
		obstacle[4] = display.newImageRect(obstacleGroup, "Content/Ptero.png", 276, 119)

		for i = 1, 3, 1 do 
			obstacle[i].x, obstacle[i].y = display.contentWidth+200, display.contentHeight-280
		end
		obstacle[4].x, obstacle[4].y = display.contentWidth+200, 250

		-- Timer
		local spawnTimer
		local resetTimer

		local cooltime
		local obs_idx


-- 함수 선언부 --

    -- UI

    	-- BGM
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

		-- PLAY
		local function tapPlay( ... )
			playUI[0].alpha = 0
			playUI[1].alpha = 1

			for i = 0, #UI do
				UI[i].alpha = 0
			end

			-- 점수&애니메이션에서 추가 ☆
			timer.resume(scoreEvent)
			dino:setSequence( "run" )
		    dino:play()

		    -- 장애물 이동에서 추가 ☆
		    physics.start()
		    timer.resume(spawnTimer)
		    timer.resume(resetTimer)
		end

		local function tapStop( ... )
			playUI[0].alpha = 1
			playUI[1].alpha = 0

			for i = 0, #UI do
				UI[i].alpha = 1
			end

			-- 점수&애니메이션에서 추가 ☆
		   	timer.resume(scoreEvent)			
			dino:setSequence( "stand" )
		    dino:play()

		   	-- 장애물 이동에서 추가 ☆
		    physics.pause()
		    timer.pause(spawnTimer)
		    timer.pause(resetTimer)
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

    -- SCORE
	    local function scoreUp ( event )
	    	score = score + 1
	    	showScore.text = score
	    end

    -- DINO
	    local function dino_spriteListenr( event )
	    	if event.phase == "began" then
		    	if dino.sequence == "hurt" then
		    		dino.alpha = 0.8
		    	end
	    	elseif event.phase == "ended" then
		    	dino:setSequence( "run" )
		    	dino:play()
	    	end
	    end
	    dino:addEventListener( "sprite", dino_spriteListenr )

	    -- 점프/슬라이드
	    local function playerDown( event )
	    	transition.to( dino, { time=500,  y=(dino.y+150) } )
	    end

		local function onKeyJumpEvent( event )
		 	if ( event.keyName == "space" ) and ( event.phase == "down" ) and (dino.y == h) then
		 		transition.to( dino, { time=500,  y=(dino.y-150), onComplete = playerDown } )
		 		dino:setSequence( "jump" )
		 		print("jump")
		    end
		end

		local function onKeySlideEvent( event )
		 	if ( event.keyName == "down" ) and ( event.phase == "down" ) then
		 		transition.pause( dino )
	    		dino.y = display.contentHeight*0.5
		 		dino:setSequence( "slide" )
		 		print("slide")
		    end
		    if ( event.keyName == "down" ) and ( event.phase == "up" ) then
	 			dino:setSequence( "run" )
	 		end
	 		dino:play()
		end

		Runtime:addEventListener( "key", onKeyJumpEvent )
		Runtime:addEventListener( "key", onKeySlideEvent )

	-- OBSTACLE
		function obs_start()
			cooltime = math.random(1, 4)--0.5~2초 사이의 간격으로 스폰
			obs_idx = math.random(1, 4)--1~5번 장애물 중 랜덤선택
			print("spawn time = "..cooltime)
			print("obstacle idx is "..obs_idx)

			spawnTimer = timer.performWithDelay(cooltime*500, spawn_obstacle)
		end

		function obs_reset()--다시 화면 밖으로(초기상태로)
			print("obstacle.x is out of screen")

			obstacle[obs_idx]:setLinearVelocity( 0, 0 )
			physics.removeBody(obstacle[obs_idx])
			obstacle[obs_idx].x = display.contentWidth+200

			obs_start()
		end

		function spawn_obstacle ()
			print("spawn obstacle")

			physics.addBody( obstacle[obs_idx], "dynamic" )
			obstacle[obs_idx]:setLinearVelocity( -500, 0 )--장애물 이동

			resetTimer = timer.performWithDelay(4000, obs_reset)
		end


-- 함수 호출부 (게임 시작할때 호출하는 함수) --
	-- 점수&애니메이션에서 추가
	scoreEvent = timer.performWithDelay( 250, scoreUp, 0 )
	
	dino:setSequence( "run" )
	dino:play()

	-- 장애물 이동에서 추가
	obs_start()

	physics.start()
	physics.setGravity( 0, 0 )


-- 레이어(sceneGroup) 정리 --
	sceneGroup:insert( BGUI )
    sceneGroup:insert( showScore )
    sceneGroup:insert( dino )
    sceneGroup:insert( obstacleGroup )

   	for i = 0, #bgmUI do sceneGroup:insert( bgmUI[i] ) end
    for i = 0, #UI do sceneGroup:insert( UI[i] ) end
    for i = 0, #playUI do sceneGroup:insert( playUI[i] ) end
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
