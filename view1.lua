-----------------------------------------------------------------------------------------
--
-- view1.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

-- Timer
local spawnTimer
local resetTimer
local scoreEvent

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
		local bgMusic = audio.play(music, { channel=1, loops=-1, fadein=5000 })
		audio.setVolume( bgMusic , 1 )

		local soundOn = 1
		local bgmUI = {}
		bgmUI[0] = display.newImageRect("Content/on.png", 55, 55)
		bgmUI[0].x, bgmUI[0].y = 1240, 40
		bgmUI[0].alpha = 1
		bgmUI[1] = display.newImageRect("Content/off.png", 55, 55)
		bgmUI[1].x, bgmUI[1].y = 1240, 40
		bgmUI[1].alpha = 0

		-- 효과음
		local jumpSound  = audio.loadSound( "Content/Audio/Jump.wav" ) 
		local dieSound  = audio.loadSound( "Content/Audio/Die.wav" ) 
		local landSound  = audio.loadSound( "Content/Audio/Land.wav" ) 
		local buttonSound = audio.loadSound( "Content/Audio/Button.wav" ) 

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

	    

    -- DINO
		local dino_sheet = graphics.newImageSheet( "Content/Playerd.png", { width = 214, height = 217, numFrames = 6 })
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
		obstacle[4].x, obstacle[4].y = display.contentWidth+200, 200

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
				audio.pause(bgMusic)
			else
				soundOn = 1
				bgmUI[0].alpha = 1
				bgmUI[1].alpha = 0
				audio.resume( bgMusic)
			end
		end
		bgmUI[0]:addEventListener("tap", soundONOFF)
		bgmUI[1]:addEventListener("tap", soundONOFF)

		-- PLAY
		local function tapPlay( ... )
			
			audio.play( buttonSound )
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

			audio.play( buttonSound )
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

		local function tapX( ... ) -- 굳이 없어도될듯??
			for i = 0, #UI do
				UI[i].alpha = 0
			end
		end

		playUI[0]:addEventListener("tap", tapPlay)
		playUI[1]:addEventListener("tap", tapStop)
		UI[1]:addEventListener("tap", tapPlay)
		UI[2]:addEventListener("tap", tapPlay) 

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
	    local isJump = 0

	    local function endJump( event )
	    	isJump = 0
	    	dino:setSequence( "run" )
	    	dino:play()
		 	print("run")
	    end

	    local function playerDown( event )
	    	transition.to( dino, { time=1500,  y=(dino.y+200), onComplete = endJump } )
	    end	    

		local function onKeyJumpEvent( event )
		 	if ( event.keyName == "space" ) and ( event.phase == "down" ) and (dino.y == h) then
		 		isJump = 1
		 		audio.play( jumpSound )
		 		transition.to( dino, { time=300,  y=(dino.y-200), onComplete = playerDown } )
		 		dino:setSequence( "jump" )
		 		print("jump")
		    end
		end

		local function onKeySlideEvent( event )
			if (isJump == 0) then
			 	if ( event.keyName == "down" ) and ( event.phase == "down" ) then -- 눌렀을 때
			 		audio.play( landSound )
			 		transition.pause( dino )
		    		dino.y = dino.y + 50
			 		dino:setSequence( "slide" )
			 		print("slide")
			    end
			    if ( event.keyName == "down" ) and ( event.phase == "up" ) then -- 눌렀다 뗄때
			    	dino.y = dino.y - 50
		 			dino:setSequence( "run" )
		 			print("run")
		 		end
		 		dino:play()
		 	end
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

			physics.addBody( obstacle[obs_idx], "dynamic", {friction=0})
			obstacle[obs_idx]:setLinearVelocity( -500, 0 )--장애물 이동
			resetTimer = timer.performWithDelay(4000, obs_reset)
		end

	-- 충돌 구현 
		local function onCollision( event ) 
		    if ( event.phase == "began" ) then
		    	audio.play( dieSound )
		        dino:setSequence( "hurt" )
		 		print("hurt")

		 		Runtime:removeEventListener( "key", onKeyJumpEvent )
				Runtime:removeEventListener( "key", onKeySlideEvent )
				Runtime:removeEventListener( "collision", onCollision )
		 		
		 		composer.setVariable( "score", score )
				composer.gotoScene( "end", { time=800, effect="crossFade" } )
		    end
		end

-- 함수 호출부 (게임 시작할때 호출하는 함수) --
	

	-- 장애물 이동에서 추가
	physics.start()
	physics.setGravity( 0, 0 )
	obs_start()
	
	dino:setSequence( "run" )
	dino:play()
	physics.addBody(dino, "static", {friction=0})

	
	 
	Runtime:addEventListener( "collision", onCollision )

	-- 점수&애니메이션에서 추가
	scoreEvent = timer.performWithDelay( 250, scoreUp, 0 )

	

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

	if event.phase == "will" then
		timer.cancel( scoreEvent )
		timer.cancel( spawnTimer )
		timer.cancel( resetTimer )
	elseif phase == "did" then
		physics.pause()
		audio.stop( 1 )
		composer.removeScene( "view1" )
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
