IFNDEF CONTRA_INC
include contra_api.inc

WinMain		PROTO :DWORD, :DWORD, :DWORD, :DWORD 
SoundProc   PROTO
OpeningSoundProc	PROTO


InitGame    PROTO
LoadImageSeries PROTO : DWORD, : BYTE,  : DWORD,  : DWORD
LoadImageResources PROTO 
PaintBackground PROTO :DWORD
PaintLoading PROTO :DWORD
PaintObjects PROTO :DWORD
PaintObject PROTO :DWORD, :DWORD

HandleEvents PROTO
ContraTakeAction PROTO
StaticRobotsTakeAction PROTO
DynamicRobotsTakeAction PROTO
TowerTakeAction PROTO
BossTakeAction PROTO

OpenFire   PROTO  :PTR Bullets, :PTR Hero
BulletsMove PROTO

UnicodeStr	PROTO :DWORD,:DWORD
StrConcat	PROTO :PTR BYTE,:PTR BYTE
isHeroOutofScreen PROTO :PTR Hero

DISPLAY_SCALE EQU 2

IDR_WAVE1 EQU 104
IDR_WAVE3 EQU 110
.data
;============================== resources declarment=============\

 IMAGETYPE_BMP db "bmp", 0  
 IMAGETYPE_PNG db "png", 0
 
 backgroundFile db "Res\\map\\map_stage1.bmp",0
 contraLoadingImage1 db "Res\\opening.png",0
 contraOverImage1 db "Res\\gameover.png",0
 contraWinImage1	db	"Res\\gamewin.png",0

 bossFile db "Res\\boss\\boss.png", 0
 playerMoveRightFiles db "Res\\player\\player_right",0
 playerMoveLeftFiles db "Res\\player\\player_left", 0
 playerJumpRightFiles db "Res\\player\\player_jump_right", 0
 playerJumpLeftFiles db "Res\\player\\player_jump_left", 0
 playerDieRightFiles db "Res\\player\\player_die_right", 0
 playerDieLeftFiles db "Res\\player\\player_die_left", 0
 playerStandRightFile db "Res\\player\\player_stand_right.png", 0
 playerStandLeftFile db "Res\\player\\player_stand_left.png", 0
 playerCrawlRightFile db "Res\\player\\player_down_right.png", 0
 playerCrawlLeftFile db "Res\\player\\player_down_left.png", 0
 playerSwimShootRightFile db "Res\\player\\player_water_right1.png", 0
 playerSwimRightFile db "Res\\player\\player_water_right2.png", 0
 playerSwimLeftFile db "Res\\player\\player_water_left2.png", 0
 playerSwimShootLeftFile db "Res\\player\\player_water_left1.png", 0
 playerFallRightFile db "Res\\player\\player_fall_right.png", 0
 playerFallLeftFile db "Res\\player\\player_fall_left.png", 0
 playerDiveFile db "Res\\player\\player_dive.png", 0
 
 playerShootLeftUpFiles db "Res\\player\\player_leftup", 0
 playerShootUpLeftFiles db "Res\\player\\player_upleft", 0
 playerShootUpRightFiles db "Res\\player\\player_upright", 0
 playerShootLeftDownFiles db "Res\\player\\player_leftdown", 0
 playerShootRightUpFiles db "Res\\player\\player_rightup", 0
 playerShootRightDownFiles db "Res\\player\\player_rightdown", 0

 bulletFiles  db "Res\\bullet\\bullet", 0
 towerFiles db "Res\\barbette\\barbette", 0
 towerShowupFiles db "Res\\barbette\\barbette_showup", 0
 towerBoomFiles db "Res\\barbette\\barbette_die_", 0
 bridgeBoomFiles db "Res\\other\\bridge_boom_", 0

 staticRobotShootRightFiles db "Res\\npc\\npc1_right", 0
 staticRobotShootRightDownFiles db "Res\\npc\\npc1_rightdown", 0
 staticRobotShootRightUpFiles db "Res\\npc\\npc1_rightup", 0
 staticRobotShootLeftFiles db "Res\\npc\\npc1_left", 0
 staticRobotShootLeftDownFiles db "Res\\npc\\npc1_leftdown", 0
 staticRobotShootLeftUpFiles db "Res\\npc\\npc1_leftup", 0
 staticRobotDieRightFiles db "Res\\npc\\npc1_die_right", 0
 staticRobotDieLeftFiles db  "Res\\npc\\npc1_die_left", 0

 dynamicRobotRunRightFiles db "Res\\npc\\npc2_right", 0
 dynamicRobotJumpRightFile db "Res\\npc\\npc2_jump_right.png", 0
 dynamicRobotDieRightFiles db "Res\\npc\\npc2_die_right", 0
 dynamicRobotRunLeftFiles db "Res\\npc\\npc2_left", 0
 dynamicRobotJumpLeftFile db "Res\\npc\\npc2_jump_left.png", 0
 dynamicRobotDieLeftFiles db "Res\\npc\\npc2_die_left", 0

;============================== Window Params =========
 ClassName db "WinClass", 0
 AppName db "Contra", 0 

;=============================== Game params ===========
 contra Hero <>
 boss Hero <>
 background Background <>
 contraBullets Bullets <>
 enemyBullets Bullets <>
 dynamicRobotQueue Robots <>
 staticRobotQueue Robots <>
 towerQueue Robots <>
 eventQueue Events <>
 bridges    Bridge 2 dup(<>)

 clock		DWORD	0
 wndstart	DWORD	0
 wndover	DWORD	0
 wndwin		DWORD	0
 ;=============================  Window and View Handles ========
 hInstance HINSTANCE ?
 
 
 hBackgroundImage dd ?
 hContraLoadingImage1 dd ?
 hContraOverImage1 dd ?
 hContraWinImage1	dd	?

 hBossImage dd   ?
 hPlayerCrawlRightImage dd ?
 hPlayerCrawlLeftImage dd ?
 hPlayerStandRightImage dd ?
 hPlayerStandLeftImage dd ?
 hPlayerSwimLeftImage dd ?
 hPlayerSwimRightImage dd ?
 hPlayerSwimShootRightImage dd ?
 hPlayerSwimShootLeftImage dd ?
 hPlayerFallRightImage dd ?
 hPlayerFallLeftImage dd ?
 hPlayerDiveImage dd ?

 hPlayerShootUpLeftImages dd 2 dup (?) 
 hPlayerShootUpRightImages dd 2 dup (?) 
 hPlayerShootLeftDownImages dd 3 dup (?)
 hPlayerShootLeftUpImages dd 3 dup (?)
 hPlayerShootRightDownImages dd 3 dup (?)
 hPlayerShootRightUpImages dd 3 dup (?)
 hPlayerMoveRightImages dd 6 dup (?)
 hPlayerMoveLeftImages dd 6 dup (?)
 hPlayerJumpRightImages dd 4 dup (?)
 hPlayerJumpLeftImages dd 4 dup (?)
 hPlayerDieRightImages dd 7 dup (?)
 hPlayerDieLeftImages dd 7 dup (?)

 hStaticRobotShootRightImages dd 2 dup (?)
 hStaticRobotShootRightUpImages dd 2 dup (?)
 hStaticRobotShootRightDownImages dd 2 dup (?)
 hStaticRobotShootLeftImages dd 2 dup (?)
 hStaticRobotShootLeftUpImages dd 2 dup (?)
 hStaticRobotShootLeftDownImages dd 2 dup (?)
 hStaticRobotDieLeftImages dd 4	 dup (?)
 hStaticRobotDieRightImages dd 4 dup (?)

 hDynamicRobotRunRightImages dd 5 dup (?)
 hDynamicRobotJumpRightImage dd ?
 hDynamicRobotDieRightImages dd 4 dup (?)
 hDynamicRobotRunLeftImages dd 5 dup (?)
 hDynamicRobotJumpLeftImage dd ?
 hDynamicRobotDieLeftImages dd 4 dup (?)

 hTowerImages dd 12 dup (?)
 hTowerShowupImages dd 4 dup (?)
 hTowerBoomImages dd 3 dup (?)

 hBridgeBoomImages dd 4 dup (?)

 hBulletImages dd 9 dup (?)

 hMusic dd ?

 ;==============  Thread Handles
 dwThreadID DWORD ?
 hBGMThread DWORD ?
 hRunThread DWORD ?
 ;==============  Others
 keyState BYTE 256 dup (?)
 token DWORD ?
 startupinput GdiplusStartupInput<?>


 ENDIF