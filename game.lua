-----------------------------------------------------------------------------------------
--
-- game.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

-- Timer
local spawnTimer
local resetTimer
local scoreEvent

-- Player
local dino

function scene:create( event )
	local sceneGroup = self.view

-- 변수 선언부 --
	-- BG
		local bgGroup = display.newGroup();
		local background = display.newRect(bgGroup, display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight )

		local sky = display.newImageRect(bgGroup, "Content/Sky.png", display.contentWidth, display.contentHeight)
		sky.x, sky.y = display.contentWidth/2, display.contentHeight/2

		local ground = display.newImageRect(bgGroup, "Content/Ground.png", display.contentWidth, 300)
		ground.x, ground.y = display.contentWidth/2, display.contentHeight-150

    -- UI
    	-- BGM
		local bgm = audio.loadStream( "Content/Audio/bgm.mp3" )
		local bgmPlayer = audio.play( bgm, { channel=1, loops=-1, fadein=5000 } )
		audio.setVolume( bgmPlayer , 1 )

		local soundOn = 1
		local bgmUI = {}
		bgmUI[0] = display.newImageRect("Content/on.png", 55, 55)
		bgmUI[0].x, bgmUI[0].y = 1240, 40
		bgmUI[0].alpha = 1
		bgmUI[1] = display.newImageRect("Content/off.png", 55, 55)
		bgmUI[1].x, bgmUI[1].y = 1240, 40
		bgmUI[1].alpha = 0

		-- Sound Effect
		local se = {}
		se.jump = audio.loadSound( "Content/Audio/jump.mp3" )
		se.down  = audio.loadSound( "Content/Audio/down.mp3" ) 
		se.collide = audio.loadSound( "Content/Audio/defeat.mp3" )
		se.button = audio.loadSound( "Content/Audio/button.mp3" ) 

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
	    local scoreUI = display.newText(score, display.contentWidth*0.25, display.contentHeight*0.15, 500, 100)
	    scoreUI.align = "right"
	    scoreUI:setFillColor(0)
	    scoreUI.size = 80

    -- DINO
		local dinoSheet = graphics.newImageSheet( "Content/Playerd.png", { width = 214, height = 217, numFrames = 6 })
		local sepuencesData =
		{
			{ name = "idle",	start = 1, count = 1 },
			{ name = "run",  	start = 1, count = 3, time = 400 },
			{ name = "jump", 	start = 4, count = 1, loopCount = 1, time = 1000 },
			{ name = "down", 	start = 5, count = 1, time = 400 },
			{ name = "collide", start = 6, count = 1 }
		}
		local dinoOutline = {}
		dinoOutline.idle = graphics.newOutline(2, dinoSheet, 1)
		dinoOutline.down = graphics.newOutline(2, dinoSheet, 5)

		dino = display.newSprite( dinoSheet, sepuencesData )
		dino.x, dino.y = display.contentWidth*0.2, display.contentHeight/2

	-- OBSTACLE
		local obstacleGroup = display.newGroup();
	    local obstacle = {}
		obstacle[1] = display.newImageRect(obstacleGroup, "Content/bone1.png", 69, 95)
		obstacle[2] = display.newImageRect(obstacleGroup, "Content/bone2.png", 131, 115)
		obstacle[3] = display.newImageRect(obstacleGroup, "Content/bone3.png", 117, 84)
		obstacle[4] = display.newImageRect(obstacleGroup, "Content/Ptero.png", 276, 119)

		local obstacleOutline = {}
		obstacleOutline[1] = graphics.newOutline(2, "Content/bone1.png")
		obstacleOutline[2] = graphics.newOutline(2, "Content/bone2.png")
		obstacleOutline[3] = graphics.newOutline(2, "Content/bone3.png")
		obstacleOutline[4] = graphics.newOutline(2, "Content/Ptero.png")

		for i = 1, 3, 1 do 
			obstacle[i].x, obstacle[i].y = display.contentWidth+200, display.contentHeight-280
		end
		obstacle[4].x, obstacle[4].y = display.contentWidth+200, 200

-- 함수 선언부 --
    -- UI
    	-- BGM
		local function soundToggle( ... )
			if soundOn == 1 then
				soundOn = 0
				bgmUI[0].alpha = 0
				bgmUI[1].alpha = 1
				audio.pause( bgmPlayer )
			else
				soundOn = 1
				bgmUI[0].alpha = 1
				bgmUI[1].alpha = 0
				audio.resume( bgmPlayer )
			end
		end
		bgmUI[0]:addEventListener("tap", soundToggle)
		bgmUI[1]:addEventListener("tap", soundToggle)

		-- PLAY
		local function gameResume( )
			audio.play( se.button )
			playUI[0].alpha = 0
			playUI[1].alpha = 1

			for i = 0, #UI do
				UI[i].alpha = 0
			end

			timer.resume( scoreEvent )
			dino:setSequence( "run" )
		    dino:play()

		    physics.start()
		    timer.resume( spawnTimer )
		    timer.resume( resetTimer )

		    Runtime:addEventListener( "key", onKeyJumpEvent )
			Runtime:addEventListener( "key", onKeyDownEvent )
			print("resume")
		end

		local function gamePause()
			audio.play( se.button )
			playUI[0].alpha = 1
			playUI[1].alpha = 0

			for i = 0, #UI do
				UI[i].alpha = 1
			end

		   	timer.pause( scoreEvent )			
			dino:setSequence( "idle" )
		    dino:pause()

		    physics.pause()
		    transition.cancelAll()
		    dino.y = display.contentHeight/2

		    timer.pause( spawnTimer )
		    timer.pause( resetTimer )

		 	Runtime:removeEventListener( "key", onKeyJumpEvent )
			Runtime:removeEventListener( "key", onKeyDownEvent )
			print("pause")
		end

		playUI[0]:addEventListener("tap", gameResume)
		playUI[1]:addEventListener("tap", gamePause)
		UI[1]:addEventListener("tap", gameResume)
		UI[2]:addEventListener("tap", gameResume) 

    -- SCORE
	    local function scoreUp( event )
	    	score = score + 1
	    	scoreUI.text = score
	    end

    -- DINO
	    local function dinoSpriteListener( event )
	    	if event.phase == "began" then
		    	if dino.sequence == "collide" then
		    		dino.alpha = 0.8
		    	end
	    	elseif event.phase == "ended" then
		    	dino:setSequence( "run" )
		    	dino:play()
	    	end
	    end
	    dino:addEventListener( "sprite", dinoSpriteListener )

	    -- 점프/슬라이드
	    local isJump = 0

	    local function dinoJumpEnd( event )
	    	isJump = 0
	    	dino:setSequence( "run" )
	    	dino:play()
		 	print("run")
	    end

	    local function dinoJumpDown( event )
	    	transition.to( dino, { time=1500,  y=(dino.y+200), onComplete = dinoJumpEnd } )
	    end

		function onKeyJumpEvent( event )
		 	if ( event.keyName == "space" ) and ( event.phase == "down" ) and (dino.y == display.contentHeight/2) then
		 		isJump = 1
		 		audio.play( se.jump )
		 		transition.to( dino, { time=300,  y=(dino.y-200), onComplete = dinoJumpDown } )
		 		dino:setSequence( "jump" )
		 		print("jump")
		    end
		end

		function onKeyDownEvent( event )
			if (isJump == 0) then
			 	if ( event.keyName == "down" ) and ( event.phase == "down" ) then -- 눌렀을 때
			 		audio.play( se.down )
			 		transition.pause( dino )
			 		dino:setSequence( "down" )
			 		dino.y = display.contentHeight/2

			 		physics.removeBody( dino )
			 		physics.addBody(dino, "static", { friction=0, outline=dinoOutline.down }) 
			 		print("down")
			    end
			    if ( event.keyName == "down" ) and ( event.phase == "up" ) then -- 눌렀다 뗄때
		 			dino:setSequence( "run" )
		 			physics.removeBody( dino )
			 		physics.addBody(dino, "static", { friction=0, outline=dinoOutline.idle }) 
		 			print("run")
		 		end
		 		dino:play()
		 	end
		end

		Runtime:addEventListener( "key", onKeyJumpEvent )
		Runtime:addEventListener( "key", onKeyDownEvent )

	-- OBSTACLE
		local cooltime
		local obs_idx

		function createObstacle()
			cooltime = math.random(1, 4)-- 0.5~2초 사이의 간격으로 스폰
			obs_idx = math.random(1, 4)	-- 1~5번 장애물 중 랜덤선택
			print("spawn time = "..cooltime)
			print("obstacle idx is "..obs_idx)
			spawnTimer = timer.performWithDelay(cooltime*500, spawnObstacle)
		end

		function deleteObstacle()			-- 다시 화면 밖으로(초기상태로)
			print("obstacle.x is out of screen")
			obstacle[obs_idx]:setLinearVelocity( 0, 0 )
			physics.removeBody(obstacle[obs_idx])
			obstacle[obs_idx].x = display.contentWidth+200
			createObstacle()
		end

		function spawnObstacle()
			print("spawn obstacle")
			physics.addBody( obstacle[obs_idx], "dynamic", { friction=0, outline=obstacleOutline[obs_idx] })
			obstacle[obs_idx]:setLinearVelocity( -500, 0 )	-- 장애물 이동
			resetTimer = timer.performWithDelay(5000, deleteObstacle)
		end

	-- 충돌 구현 
		local function onCollision( event ) 
		    if ( event.phase == "began" ) then
		    	audio.play( se.collide )
		        dino:setSequence( "collide" )
		 		print("collide")

		 		Runtime:removeEventListener( "key", onKeyJumpEvent )
				Runtime:removeEventListener( "key", onKeyDownEvent )
				Runtime:removeEventListener( "collision", onCollision )
		 		
		 		composer.setVariable( "score", score )
				composer.gotoScene( "end", { time=800, effect="crossFade" } )
		    end
		end

-- 함수 호출부 (게임 시작할때 호출하는 함수) --
	
	-- 장애물 이동에서 추가
	physics.start()
	physics.setGravity( 0, 0 )
	createObstacle()
	
	dino:setSequence( "run" )
	dino:play()

	physics.addBody(dino, "static", { friction=0, outline=dinoOutline.idle }) 
	Runtime:addEventListener( "collision", onCollision )

	-- 점수&애니메이션에서 추가
	scoreEvent = timer.performWithDelay( 250, scoreUp, 0 )

-- 레이어(sceneGroup) 정리 --
	sceneGroup:insert( bgGroup )
    sceneGroup:insert( scoreUI )
    sceneGroup:insert( dino )
    sceneGroup:insert( obstacleGroup )

   	for i = 0, #bgmUI do sceneGroup:insert( bgmUI[i] ) end
    for i = 0, #UI do sceneGroup:insert( UI[i] ) end
    for i = 0, #playUI do sceneGroup:insert( playUI[i] ) end
end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase

	if phase == "will" then
		dino:setSequence( "run" )
		dino:play()
	elseif phase == "did" then
		physics.start()
	end	
end

function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase

	if event.phase == "will" then
		dino:pause()
		audio.stop( 1 )
		timer.cancel( scoreEvent )
		timer.cancel( spawnTimer )
		timer.cancel( resetTimer )
	elseif phase == "did" then
		physics.pause()
		transition.cancelAll()
		composer.removeScene( "game" )
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
