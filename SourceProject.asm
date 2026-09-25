INCLUDE Irvine32.inc

.data
	str1 BYTE "=== PAC MAN GAME ===", 0
	str2 BYTE "Please enter your name: ", 0
	str3 BYTE " Play Game ", 0
	str4 BYTE " Level 0", 0
	str5 BYTE " Game Instructions ", 0
	str6 BYTE " Game History ", 0
	str7 BYTE " Exit ", 0
	str8 BYTE " Continue ", 0
	str9 BYTE " Game Instructions ", 0
	str10 BYTE " Return to Main Menu ", 0
	str11 BYTE "=== MAIN MENU ===", 0
	str12 BYTE "=== GAME PAUSED ===", 0
	str13 BYTE "Username: ", 0
	str14 BYTE "Score: ", 0
	str15 BYTE "Lives: ", 0
	str16 BYTE "=== LEVEL 0", 0
	str17 BYTE " ===", 0
	str18 BYTE "=== GAME OVER ===", 0
	str19 BYTE "CONGRATULATIONS! YOU WON", 0
	str20 BYTE "BETTER LUCK NEXT TIME!", 0
	str21 BYTE "=== INSTRUCTIONS ===", 0
	str22 BYTE "1) Move upwards using 'w'.", 0
	str23 BYTE "2) Move downards using 's'.", 0
	str24 BYTE "3) Move left using 'a'.", 0
	str25 BYTE "4) Move right using 'd'.", 0
	str26 BYTE "5) Press 'p' to pause the game.", 0
	str27 BYTE "6) Avoid ghosts.", 0
	str28 BYTE "7) Start from easy levels to adapt.", 0
	Space BYTE " ", 0
	Score WORD 0
	Lives BYTE 3
	Level BYTE 3
	TopLimit BYTE 4
	BottomLimit BYTE 29
	LeftLimit BYTE 3
	RightLimit BYTE 117
	Pallets BYTE 3600 DUP('.')
	Username BYTE 50 DUP(?)
	UsernameLength BYTE ?
	PacmanX BYTE 60
	PacmanY BYTE 16
	PacmanPower BYTE 0
	GhostX1 BYTE 60 
	GhostY1	BYTE 5
	GhostX2	BYTE 60
	GhostY2	BYTE 28
	GhostX3 BYTE 23
	GhostY3 BYTE 28
	GhostX4 BYTE 4
	GhostY4 BYTE 16
	GhostX5 BYTE 116
	GhostY5 BYTE 16
	PacmanCX BYTE 60
	PacmanCY BYTE 16
	GhostCX1 BYTE 60 
	GhostCY1 BYTE 5
	GhostCX2 BYTE 60
	GhostCY2 BYTE 28
	GhostCX3 BYTE 23
	GhostCY3 BYTE 28
	GhostCX4 BYTE 4
	GhostCY4 BYTE 16
	GhostCX5 BYTE 116
	GhostCY5 BYTE 16
	WallX1 BYTE 25
	WallY1 BYTE 16
	WallX2 BYTE 25
	WallY2 BYTE 16
	WallX3 BYTE 60
	WallY3 BYTE 24
	WallX4 BYTE 45
	WallY4 BYTE 23
	WallX5 BYTE 45 
	WallY5 BYTE 24
	GuardX1 BYTE 0
	GuardY1 BYTE 0
	GuardX2 BYTE 0
	GuardY2 BYTE 0
	PowerPalletX BYTE 0
	PowerPalletY BYTE 0
	PowerActive BYTE 0
	GameStarted BYTE 0
	GameOver BYTE 0
	StepMoves WORD 0
	PowerMoves BYTE 5
	GuardDirection BYTE 0
	GameLost BYTE 0
	GameWon BYTE 0
	NeedRedraw BYTE 1				; 1 = next frame must be a full redraw (game start / after pause)
	PrevPacmanX BYTE 0				; where Pacman / ghosts were LAST drawn,
	PrevPacmanY BYTE 0				; so that cell can be erased when they move
	PrevGhostX1 BYTE 0
	PrevGhostY1 BYTE 0
	PrevGhostX2 BYTE 0
	PrevGhostY2 BYTE 0
	PrevGhostX3 BYTE 0
	PrevGhostY3 BYTE 0
	PrevGhostX4 BYTE 0
	PrevGhostY4 BYTE 0
	PrevGhostX5 BYTE 0
	PrevGhostY5 BYTE 0
	filename BYTE "Scores.txt", 0
	fileHandle HANDLE ?
	fileContents BYTE 2000 DUP(?)			; whole history file, read back in for the History screen
	ScoreString BYTE 5 DUP(?)
	RecordBuf BYTE 80 DUP(?)				; one "name - score (Level n)" line being built
	RecordLen DWORD 0
	ExistingLen DWORD 0
	TotalLen DWORD 0
	sepDash BYTE " - ", 0
	sepLevel BYTE " (Level ", 0
	str29 BYTE "=== GAME HISTORY ===", 0
	str30 BYTE "No games played yet.", 0

.code

main PROC
	call Randomize
	call WelcomeScreen
	EndGame:
	mov al, 0
	mov GameStarted, al
	mov GameOver, al
	call ResetPallets
	Menu:
	call MenuScreen
	; PlayGame
	cmp bl, 1
	je PlayGame
	; SetLevel: level is already set by Left/Right inside MenuScreen, nothing more to do
	cmp bl, 2
	je Menu
	; Instructions
	cmp bl, 3
	je ShowInstructions
	; History
	cmp bl, 4
	je ShowHistory
	; Exit
	cmp bl, 5
	je Down
	jmp Menu

	ShowInstructions:
	call InstructionScreen
	jmp Menu

	ShowHistory:
	call HistoryScreen
	jmp Menu
	; call PauseScreen
	
	PlayGame:
	mov Level, bh
	call CoordinateSet
	mov al, 1
	mov PowerMoves, 0
	mov GameStarted, al
	mov NeedRedraw, 1
	GameLoop:
		cmp GameOver, 1
		je EndGame
		cmp GameWon, 1
		je GameFinished
		cmp GameLost, 1
		je GameFinished
		cmp Level, 3
		jne Skip1
		; call MoveGhosts								; Commented For Now
		call AddPowerPallet
		Skip1:
		cmp PacmanPower, 0
		jbe Skip2
		dec PacmanPower
		Skip2:
		cmp NeedRedraw, 0
		je Refresh
		call GameLayout					; full draw (Clrscr + map): only at game start / after pause
		call DrawSprites
		mov NeedRedraw, 0
		jmp Drawn
		Refresh:
		call UpdateScreen				; every other move: only touch the cells that changed
		Drawn:
		call MovePacman
		call MoveGhosts
		dec PowerMoves
		inc StepMoves
		call CheckLose
		call CheckWin
		call CheckCollision
		jmp GameLoop

	GameFinished:
	call EndScreen					; show the result screen
	call WriteFileAs				; record this game (name, score, level) in Scores.txt
	jmp EndGame
	
	Down:
	call Clrscr
	call DumpRegs
	exit

main ENDP

InstructionScreen PROC
	mov eax, White (Black * 16)
	call SetTextColor
	call Clrscr
	mov dh, 3
	mov dl, 50
	call Gotoxy
	mov eax, Blue (Black * 16)
	call SetTextColor
	mov edx, offset str21
	call WriteString
	mov dh, 7
	mov dl, 45
	call Gotoxy
	mov eax, White (Black * 16)
	call SetTextColor
	mov edx, offset str22
	call WriteString
	mov dh, 10
	mov dl, 45
	call Gotoxy
	mov eax, White (Black * 16)
	call SetTextColor
	mov edx, offset str23
	call WriteString
	mov dh, 13
	mov dl, 45
	call Gotoxy
	mov eax, White (Black * 16)
	call SetTextColor
	mov edx, offset str24
	call WriteString
	mov dh, 16
	mov dl, 45
	call Gotoxy
	mov eax, White (Black * 16)
	call SetTextColor
	mov edx, offset str25
	call WriteString
	mov dh, 19
	mov dl, 45
	call Gotoxy
	mov eax, White (Black * 16)
	call SetTextColor
	mov edx, offset str26
	call WriteString
	mov dh, 22
	mov dl, 45
	call Gotoxy
	mov eax, White (Black * 16)
	call SetTextColor
	mov edx, offset str27
	call WriteString
	mov dh, 25
	mov dl, 45
	call Gotoxy
	mov eax, White (Black * 16)
	call SetTextColor
	mov edx, offset str28
	call WriteString
	call ReadChar
	ret

InstructionScreen ENDP

WelcomeScreen PROC
	mov eax, White (Black * 16)
	call SetTextColor
	call Clrscr
	mov edx, 0
	mov dh, 3
	mov dl, 50
	call Gotoxy
	mov eax, Blue (Black * 16)
	call SetTextColor
	mov edx, offset str1
	call WriteString
	mov edx, 0
	mov dh, 10
	mov dl, 45
	call Gotoxy
	mov eax, White (Black * 16)
	call SetTextColor
	mov edx, offset str2
	call WriteString
	mov edx, offset Username
	mov ecx, sizeof Username
	call ReadString
	mov UsernameLength, al
	mov dh, 12
	mov dl, 45
	call Gotoxy
	; call WaitMsg
	ret

WelcomeScreen ENDP

MenuScreen PROC
	mov bl, 1
	mov bh, 1
	Top:
	mov eax, White (Black * 16)
	call SetTextColor
	call Clrscr
	mov eax, Blue (Black * 16)
	call SetTextColor
	mov dh, 3
	mov dl, 53
	call Gotoxy
	mov edx, offset str11
	call WriteString
	mov dh, 9
	mov dl, 55
	call Gotoxy
	mov eax, White (Black * 16)
	call SetTextColor
	cmp bl, 1
	je Color
	Option1:
	mov edx, offset str3
	call WriteString
	mov dh, 12
	mov dl, 56
	call Gotoxy
	mov eax, White (Black * 16)
	call SetTextColor
	cmp bl, 2
	je Color
	Option2:
	mov edx, offset str4
	call WriteString
	mov eax, 0
	mov al, bh
	call WriteDec
	mov edx, offset Space
	call WriteString
	mov dh, 15
	mov dl, 52
	call Gotoxy
	mov eax, White (Black * 16)
	call SetTextColor
	cmp bl, 3
	je Color
	Option3:
	mov edx, offset str5
	call WriteString
	mov dh, 18
	mov dl, 54
	call Gotoxy
	mov eax, White (Black * 16)
	call SetTextColor
	cmp bl, 4
	je Color
	Option4:
	mov edx, offset str6
	call WriteString
	mov dh, 21
	mov dl, 58
	call Gotoxy
	mov eax, White (Black * 16)
	call SetTextColor
	cmp bl, 5
	je Color
	Option5:
	mov edx, offset str7
	call WriteString
	call ReadChar
	; Enter key
	cmp al, 13
	je Select
	; Up
	cmp al, 'w'
	je Up
	; Down
	cmp al, 's'
	je Down
	cmp bl, 2
	jne Top
	; Left
	cmp al, 'a'
	je Left
	; Right
	cmp al, 'd'
	je Right
	jmp Top

	Color:
	mov eax, White (Blue * 16)
	call SetTextColor
	cmp bl, 1
	je Option1
	cmp bl, 2
	je Option2
	cmp bl, 3
	je Option3
	cmp bl, 4
	je Option4
	cmp bl, 5
	je Option5
	jmp Top

	Up:
		dec bl
		cmp bl, 0
		je BL0
		jmp Top
	BL0:
		mov bl, 5
		jmp Top

	Down:
		inc bl
		cmp bl, 6
		je BL6
		jmp Top
	BL6:
		mov bl, 1
		jmp Top
	
	Left:
		dec bh
		cmp bh, 0
		je BH0
		jmp Top
	BH0:
		mov bh, 3
		jmp Top
	
	Right:
		inc bh
		cmp bh, 4
		je BH4
		jmp Top
	BH4:
		mov bh, 1
		jmp Top

	Select:
	mov eax, White (Black * 16)
	call SetTextColor
	call Clrscr
	ret

MenuScreen ENDP

PauseScreen PROC
	push eax
	push ebx
	push edx
	mov bl, 1
	Top:
	mov eax, White (Black * 16)
	call SetTextColor
	call Clrscr
	mov eax, Blue (Black * 16)
	call SetTextColor
	mov dh, 3
	mov dl, 51
	call Gotoxy
	mov edx, offset str12
	call WriteString
	mov dh, 10
	mov dl, 55
	call Gotoxy
	mov eax, White (Black * 16)
	call SetTextColor
	cmp bl, 1
	je Color
	Option1:
	mov edx, offset str8
	call WriteString
	mov dh, 13
	mov dl, 51
	call Gotoxy
	mov eax, White (Black * 16)
	call SetTextColor
	cmp bl, 2
	je Color
	Option2:
	mov edx, offset str9
	call WriteString
	mov dh, 16
	mov dl, 50
	call Gotoxy
	mov eax, White (Black * 16)
	call SetTextColor
	cmp bl, 3
	je Color
	Option3:
	mov edx, offset str10
	call WriteString
	call ReadChar
	; Enter key
	cmp al, 13
	je Select
	; Up
	cmp al, 'w'
	je Up
	; Down
	cmp al, 's'
	je Down
	jmp Top

	Color:
	mov eax, White (Blue * 16)
	call SetTextColor
	cmp bl, 1
	je Option1
	cmp bl, 2
	je Option2
	cmp bl, 3
	je Option3
	jmp Top

	Up:
		dec bl
		cmp bl, 0
		je BL0
		jmp Top
	BL0:
		mov bl, 3
		jmp Top

	Down:
		inc bl
		cmp bl, 4
		je BL3
		jmp Top
	BL3:
		mov bl, 1
		jmp Top

	Select:
		cmp bl, 1
		je Continue
		cmp bl, 2
		je instruct
		cmp bl, 3
		je Menu
		
	instruct:
	call InstructionScreen
	jmp Top

	Menu:
	mov al, 1
	mov GameOver, al
	jmp Continue

	Continue:
	mov eax, White (Black * 16)
	call SetTextColor
	call Clrscr
	mov NeedRedraw, 1				; pause screen wiped the game screen -> full redraw
	pop edx
	pop ebx
	pop eax
	ret

PauseScreen ENDP

EndScreen PROC
	mov eax, White (Black * 16)
	call SetTextColor
	call Clrscr
	mov edx, 0
	mov dh, 3
	mov dl, 50
	call Gotoxy
	mov eax, Blue (Black * 16)
	call SetTextColor
	mov edx, offset str18
	call WriteString
	cmp GameLost, 1
	je LostMessage
	jmp WonMessage

	LostMessage:
	mov dh, 6
	mov dl, 48
	call Gotoxy
	mov eax, Green (Black * 16)
	call SetTextColor
	mov edx, offset str20
	call WriteString
	jmp Scores

	WonMessage:
	mov dh, 6
	mov dl, 46
	call Gotoxy
	mov eax, Green (Black * 16)
	call SetTextColor
	mov edx, offset str19
	call WriteString
	jmp Scores

	Scores:
	mov dh, 10
	mov dl, 52
	call Gotoxy
	mov eax, White (Black * 16)
	call SetTextColor
	mov edx, offset str13
	call WriteString
	mov edx, offset Username
	call WriteString
	mov dh, 12
	mov dl, 55
	call Gotoxy
	mov eax, White (Black * 16)
	call SetTextColor
	mov edx, offset str14
	call WriteString
	movzx eax, Score
	call WriteDec
	mov dh, 15
	mov dl, 46
	call Gotoxy
	call WaitMsg
	jmp Back

	Back:
	ret

EndScreen ENDP

RemoveInitialPallets PROC
	mov edi, offset Pallets
	mov eax, 0
	mov al, 120
	mul bh
	add edi, eax
	mov eax, 0
	mov al, bl
	add edi, eax
	mov al, ' '
	mov [edi], al
	ret

RemoveInitialPallets ENDP

CoordinateSet PROC
	mov bh, PacmanY
	mov bl, PacmanX
	call RemoveInitialPallets
	mov bh, GhostY1
	mov bl, GhostX1
	call RemoveInitialPallets
	mov bh, GhostY2
	mov bl, GhostX2
	call RemoveInitialPallets
	mov bh, GhostY3
	mov bl, GhostX3
	call RemoveInitialPallets
	mov bh, GhostY4
	mov bl, GhostX4
	call RemoveInitialPallets
	mov bh, GhostY5
	mov bl, GhostX5
	call RemoveInitialPallets
	
	cmp Level, 2
	jae Level2
	jmp Back

	Level2:
	mov al, 100
	mov GhostCX2, al
	mov GhostX2, al
	mov al, 20
	mov GhostCX3, al
	mov GhostX3, al
	
	Back:
	ret

CoordinateSet ENDP

SetCoordinates PROC
	cmp Level, 2
	jae Level2
	jmp Back

	Level2:
	mov al, 100
	mov GhostCX2, al
	mov GhostX2, al
	mov al, 20
	mov GhostCX3, al
	mov GhostX3, al
	
	Back:
	ret

SetCoordinates ENDP

InnerWalls PROC
	mov eax, blue (Black * 16)
	call SetTextColor
	; WallL1
	mov dh, WallY1
	mov dl, WallX1
	mov edi, offset Pallets
	mov eax, 0
	mov al, 120
	mul dh
	add edi, eax
	mov eax, 0
	mov al, dl
	add edi, eax
	call Gotoxy
	mov ecx, 20
	WallL1:
		mov al, '-'
		mov [edi], al
		inc edi
		call WriteChar
		loop WallL1

	; WallR1
	mov dh, WallY1
	mov dl, PacmanCX
	add dl, 17
	mov edi, offset Pallets
	mov eax, 0
	mov al, 120
	mul dh
	add edi, eax
	mov eax, 0
	mov al, dl
	add edi, eax
	call Gotoxy
	mov ecx, 20
	WallR1:
		mov al, '-'
		mov [edi], al
		inc edi
		call WriteChar
		loop WallR1

	; WallLU2
	mov dh, WallY2
	mov dl, WallX2
	inc dh
	call Gotoxy
	mov ecx, 5
	WallLU2:
		mov edi, offset Pallets
		mov eax, 0
		mov al, 120
		mul dh
		add edi, eax
		mov eax, 0
		mov al, dl
		add edi, eax
		mov al, '|'
		mov [edi], al
		call WriteChar
		inc dh
		call Gotoxy
		loop WallLU2

	; WallLD2
	mov dh, WallY2
	mov dl, WallX2
	dec dh
	call Gotoxy
	mov ecx, 5
	WallLD2:
		mov edi, offset Pallets
		mov eax, 0
		mov al, 120
		mul dh
		add edi, eax
		mov eax, 0
		mov al, dl
		add edi, eax
		mov al, '|'
		mov [edi], al
		call WriteChar
		dec dh
		call Gotoxy
		loop WallLD2

	; WallRU1
	mov dh, WallY2
	mov dl, PacmanCX
	add dl, 36
	inc dh
	call Gotoxy
	mov ecx, 5
	WallRU2:
		mov edi, offset Pallets
		mov eax, 0
		mov al, 120
		mul dh
		add edi, eax
		mov eax, 0
		mov al, dl
		add edi, eax
		mov al, '|'
		mov [edi], al
		call WriteChar
		inc dh
		call Gotoxy
		loop WallRU2

	; WallRD1
	mov dh, WallY2
	mov dl, PacmanCX
	add dl, 36
	dec dh
	call Gotoxy
	mov ecx, 5
	WallRD2:
		mov edi, offset Pallets
		mov eax, 0
		mov al, 120
		mul dh
		add edi, eax
		mov eax, 0
		mov al, dl
		add edi, eax
		mov al, '|'
		mov [edi], al
		call WriteChar
		dec dh
		call Gotoxy
		loop WallRD2

	mov al, Level
	cmp al, 1
	je Back

	; Wall3
	mov dh, WallY3
	mov dl, WallX3
	call Gotoxy
	mov ecx, 6
	Wall3:
		mov edi, offset Pallets
		mov eax, 0
		mov al, 120
		mul dh
		add edi, eax
		mov eax, 0
		mov al, dl
		add edi, eax
		mov al, '|'
		mov [edi], al
		call WriteChar
		inc dh
		call Gotoxy
		loop Wall3

	; Wall4
	mov dh, WallY4
	mov dl, WallX4
	mov edi, offset Pallets
	mov eax, 0
	mov al, 120
	mul dh
	add edi, eax
	mov eax, 0
	mov al, dl
	add edi, eax
	call Gotoxy
	mov ecx, 31
	Wall4:
		mov al, '-'
		mov [edi], al
		inc edi
		call WriteChar
		loop Wall4

	; WallL5
	mov dh, WallY5
	mov dl, WallX5
	call Gotoxy
	mov ecx, 2
	WallL5:
		mov edi, offset Pallets
		mov eax, 0
		mov al, 120
		mul dh
		add edi, eax
		mov eax, 0
		mov al, dl
		add edi, eax
		mov al, '|'
		mov [edi], al
		call WriteChar
		inc dh
		call Gotoxy
		loop WallL5

	; WallR5
	mov dh, WallY5
	mov dl, WallX5
	add dl, 30
	call Gotoxy
	mov ecx, 2
	WallR5:
		mov edi, offset Pallets
		mov eax, 0
		mov al, 120
		mul dh
		add edi, eax
		mov eax, 0
		mov al, dl
		add edi, eax
		mov al, '|'
		mov [edi], al
		call WriteChar
		inc dh
		call Gotoxy
		loop WallR5

	Back:
	ret

InnerWalls ENDP

GameLayout PROC
	call Clrscr
	call SetPallets
	mov eax, Green (Black * 16)
	call SetTextColor
	mov eax, 0
	; Basic Info
	; Username
	mov dh, 0
	mov dl, LeftLimit
	call Gotoxy
	mov edx, offset str13
	call WriteString
	mov edx, offset Username
	call WriteString
	; Score
	mov dh, 1
	mov dl, LeftLimit
	call Gotoxy
	mov edx, offset str14
	call WriteString
	mov ax, Score
	call WriteDec
	; Lives
	mov dh, 2
	mov dl, LeftLimit
	call Gotoxy
	mov edx, offset str15
	call WriteString
	mov eax, 0
	mov al, Lives
	call WriteDec
	; Level
	mov dh, 3
	mov dl, 53
	call Gotoxy
	mov edx, offset str16
	call WriteString
	movzx eax, Level
	call WriteDec
	mov edx, offset str17
	call WriteString

	; InnerWalls
	pushad
	call InnerWalls
	popad

	; Pacman's cage (Pacman himself is drawn by DrawSprites)
	call PacmanCage

	; Ghost-1/2
	pushad
	mov cl, 1
	mov bl, GhostCX1
	mov bh, GhostCY1
	call GhostCage
	mov cl, 2
	mov bl, GhostCX2
	mov bh, GhostCY2
	call GhostCage
	popad

	mov al, Level
	cmp al, 2
	jb Boundaries

	; Ghost3
	pushad
	mov cl, 3
	mov bl, GhostCX3
	mov bh, GhostCY3
	call GhostCage
	popad

	mov al, Level
	cmp al, 3
	jne Boundaries

	; Ghost-4/5
	pushad
	mov cl, 4
	mov bl, GhostCX4
	mov bh, GhostCY4
	call GhostCage
	mov cl, 5
	mov bl, GhostCX5
	mov bh, GhostCY5
	call GhostCage
	popad

	Boundaries:
	mov eax, Blue (Black * 16)
	call SetTextColor

	; LeftWall
	mov dh, TopLimit
	mov dl, LeftLimit
	call Gotoxy
	movzx ecx, BottomLimit
	sub ecx, 3
	Left:
		mov edi, offset Pallets
		mov eax, 0
		mov al, 120
		mul dh
		add edi, eax
		mov eax, 0
		mov al, dl
		add edi, eax
		mov al, '|'
		mov [edi], al
		call WriteChar
		inc dh
		call Gotoxy
		loop Left
	
	; RightWall
	mov dh, TopLimit
	mov dl, RightLimit
	call Gotoxy
	movzx ecx, BottomLimit
	sub ecx, 3
	Right:
		mov edi, offset Pallets
		mov eax, 0
		mov al, 120
		mul dh
		add edi, eax
		mov eax, 0
		mov al, dl
		add edi, eax
		mov al, '|'
		mov [edi], al
		call WriteChar
		inc dh
		call Gotoxy
		loop Right

	; TopWall
	mov dh, TopLimit
	mov dl, LeftLimit
	mov edi, offset Pallets
	mov eax, 0
	mov al, 120
	mul dh
	add edi, eax
	mov eax, 0
	mov al, dl
	add edi, eax
	call Gotoxy
	movzx ecx, RightLimit
	sub ecx, 2
	Top:
		mov al, '-'
		mov [edi], al
		inc edi
		call WriteChar
		loop Top
	
	; BottomWall
	mov dh, BottomLimit
	mov dl, LeftLimit
	mov edi, offset Pallets
	mov eax, 0
	mov al, 120
	mul dh
	add edi, eax
	mov eax, 0
	mov al, dl
	add edi, eax
	call Gotoxy
	movzx ecx, RightLimit
	sub ecx, 2
	Bottom:
		mov al, '-'
		mov [edi], al
		inc edi
		call WriteChar
		loop Bottom

	mov eax, White (Black * 16)
	call SetTextColor
	ret

GameLayout ENDP

; ------------------------------------------------------------------
; UpdateScreen
; Replaces the per-move call to GameLayout. Nothing is cleared and the
; map is NOT reprinted. Only what changed since the last frame is
; overwritten in place:
;   1) the cells Pacman / the ghosts just left
;   2) the power pallet
;   3) Score and Lives
;   4) Pacman and the ghosts at their new cells
; ------------------------------------------------------------------
UpdateScreen PROC
	pushad

	; 1) Erase: put back what the map holds under each old sprite position
	mov bl, PrevPacmanX
	mov bh, PrevPacmanY
	call DrawCell
	mov bl, PrevGhostX1
	mov bh, PrevGhostY1
	call DrawCell
	mov bl, PrevGhostX2
	mov bh, PrevGhostY2
	call DrawCell
	mov bl, PrevGhostX3
	mov bh, PrevGhostY3
	call DrawCell
	mov bl, PrevGhostX4
	mov bh, PrevGhostY4
	call DrawCell
	mov bl, PrevGhostX5
	mov bh, PrevGhostY5
	call DrawCell

	; 2) Power pallet (AddPowerPallet only changes the map, it does not draw)
	cmp PowerActive, 0
	je NoPower
	mov bl, PowerPalletX
	mov bh, PowerPalletY
	call DrawCell
	NoPower:

	; 3) Score
	mov eax, Green (Black * 16)
	call SetTextColor
	mov dh, 1
	mov dl, LeftLimit
	call Gotoxy
	mov edx, offset str14
	call WriteString
	movzx eax, Score
	call WriteDec
	mov al, ' '						; wipe leftovers if the number got shorter
	call WriteChar
	mov al, ' '
	call WriteChar
	; Lives
	mov dh, 2
	mov dl, LeftLimit
	call Gotoxy
	mov edx, offset str15
	call WriteString
	movzx eax, Lives
	call WriteDec
	mov al, ' '
	call WriteChar
	mov al, ' '
	call WriteChar

	; 4) Pacman and ghosts at their new cells
	call DrawSprites

	popad
	ret

UpdateScreen ENDP

; ------------------------------------------------------------------
; DrawSprites
; Draws Pacman and the ghosts on top of the map and remembers where
; they are, so UpdateScreen can erase those cells on the next move.
; Used by both the full redraw and UpdateScreen.
; ------------------------------------------------------------------
DrawSprites PROC
	pushad

	; Pacman
	mov eax, Yellow (Black * 16)
	call SetTextColor
	mov dh, PacmanY
	mov dl, PacmanX
	mov cl, '('
	call PutSprite

	; Ghost1
	mov eax, red (Black * 16)
	call SetTextColor
	mov dh, GhostY1
	mov dl, GhostX1
	mov cl, 'T'
	call PutSprite

	; Ghost2
	mov eax, Brown (Black * 16)
	call SetTextColor
	mov dh, GhostY2
	mov dl, GhostX2
	mov cl, 'T'
	call PutSprite

	cmp Level, 2
	jb Finish

	; Ghost3
	mov eax, lightmagenta (Black * 16)
	call SetTextColor
	mov dh, GhostY3
	mov dl, GhostX3
	mov cl, 'T'
	call PutSprite

	cmp Level, 3
	jne Finish

	; Ghost4
	mov eax, lightgray (Black * 16)
	call SetTextColor
	mov dh, GhostY4
	mov dl, GhostX4
	mov cl, 'T'
	call PutSprite

	; Ghost5
	mov eax, lightgreen (Black * 16)
	call SetTextColor
	mov dh, GhostY5
	mov dl, GhostX5
	mov cl, 'T'
	call PutSprite

	Finish:
	call SavePositions
	mov eax, White (Black * 16)
	call SetTextColor
	mov dh, 0						; park the cursor in an empty corner
	mov dl, 0
	call Gotoxy
	popad
	ret

DrawSprites ENDP

; ------------------------------------------------------------------
; PutSprite
; Draws one character in the colour that is already set.
; Input: dh = Y, dl = X, cl = character
; Draws nothing when the position is off the map. Otherwise a failed
; Gotoxy would print the character at the old cursor position and
; leave stray characters behind (nothing clears them any more).
; ------------------------------------------------------------------
PutSprite PROC
	cmp dl, 120
	jae Back
	cmp dh, 30
	jae Back
	call Gotoxy
	mov al, cl
	call WriteChar
	Back:
	ret

PutSprite ENDP

; ------------------------------------------------------------------
; DrawCell
; Redraws ONE map cell from the Pallets array.   Input: bl = X, bh = Y
; A sprite is "erased" by drawing whatever the map holds underneath it
; (pallet, power pallet, blank or wall) - no Clrscr needed.
; ------------------------------------------------------------------
DrawCell PROC
	cmp bl, 120						; ignore anything outside the 120 x 30 map
	jae Back
	cmp bh, 30
	jae Back
	pushad
	movzx eax, bh
	imul eax, 120
	movzx ecx, bl
	add eax, ecx
	mov edi, offset Pallets
	add edi, eax					; edi -> Pallets[Y * 120 + X]
	mov eax, Green (Black * 16)
	cmp BYTE PTR [edi], '-'
	je IsWall
	cmp BYTE PTR [edi], '|'
	jne SetColour
	IsWall:
	mov eax, Blue (Black * 16)
	SetColour:
	call SetTextColor
	mov dh, bh
	mov dl, bl
	call Gotoxy
	mov al, [edi]
	call WriteChar
	popad
	Back:
	ret

DrawCell ENDP

; ------------------------------------------------------------------
; SavePositions
; Remembers where Pacman and the ghosts are drawn right now.
; ------------------------------------------------------------------
SavePositions PROC
	push eax
	mov al, PacmanX
	mov PrevPacmanX, al
	mov al, PacmanY
	mov PrevPacmanY, al
	mov al, GhostX1
	mov PrevGhostX1, al
	mov al, GhostY1
	mov PrevGhostY1, al
	mov al, GhostX2
	mov PrevGhostX2, al
	mov al, GhostY2
	mov PrevGhostY2, al
	mov al, GhostX3
	mov PrevGhostX3, al
	mov al, GhostY3
	mov PrevGhostY3, al
	mov al, GhostX4
	mov PrevGhostX4, al
	mov al, GhostY4
	mov PrevGhostY4, al
	mov al, GhostX5
	mov PrevGhostX5, al
	mov al, GhostY5
	mov PrevGhostY5, al
	pop eax
	ret

SavePositions ENDP

PacmanCage PROC
	mov eax, Blue (Black * 16)
	call SetTextColor

	; Wall3
	mov dh, PacmanCY
	mov dl, PacmanCX
	sub dl, 6
	sub dh, 3
	mov ecx, 7
	call Gotoxy
	Wall3:
		mov edi, offset Pallets
		mov eax, 0
		mov al, 120
		mul dh
		add edi, eax
		mov eax, 0
		mov al, dl
		add edi, eax
		mov al, '|'
		mov [edi], al
		call WriteChar
		inc dh
		call Gotoxy
		loop Wall3

	; Wall4
	mov dh, PacmanCY
	mov dl, PacmanCX
	add dl, 6
	sub dh, 3
	mov ecx, 7
	call Gotoxy
	Wall4:
		mov edi, offset Pallets
		mov eax, 0
		mov al, 120
		mul dh
		add edi, eax
		mov eax, 0
		mov al, dl
		add edi, eax
		mov al, '|'
		mov [edi], al
		call WriteChar
		inc dh
		call Gotoxy
		loop Wall4

	; Wall1
	mov dh, PacmanCY
	mov dl, PacmanCX
	sub dl, 6
	sub dh, 3
	mov ecx, 13
	mov edi, offset Pallets
	mov eax, 0
	mov al, 120
	mul dh
	add edi, eax
	mov eax, 0
	mov al, dl
	add edi, eax
	call Gotoxy
	Wall1:
		mov al, '-'
		mov [edi], al
		inc edi
		call WriteChar
		loop Wall1

	; Wall2
	mov dh, PacmanCY
	mov dl, PacmanCX
	sub dl, 6
	add dh, 3
	mov ecx, 13
	mov edi, offset Pallets
	mov eax, 0
	mov al, 120
	mul dh
	add edi, eax
	mov eax, 0
	mov al, dl
	add edi, eax
	call Gotoxy
	Wall2:
		mov al, '-'
		mov [edi], al
		inc edi
		call WriteChar
		loop Wall2

	; Gate1
	mov dh, PacmanCY
	mov dl, PacmanCX
	sub dl, 6
	sub dh, 1
	mov ecx, 3
	call Gotoxy
	Gate1:
		mov edi, offset Pallets
		mov eax, 0
		mov al, 120
		mul dh
		add edi, eax
		mov eax, 0
		mov al, dl
		add edi, eax
		mov al, ' '
		mov [edi], al
		call WriteChar
		inc dh
		call Gotoxy
		loop Gate1

	; Gate2
	mov dh, PacmanCY
	mov dl, PacmanCX
	add dl, 6
	sub dh, 1
	mov ecx, 3
	call Gotoxy
	Gate2:
		mov edi, offset Pallets
		mov eax, 0
		mov al, 120
		mul dh
		add edi, eax
		mov eax, 0
		mov al, dl
		add edi, eax
		mov al, ' '
		mov [edi], al
		call WriteChar
		inc dh
		call Gotoxy
		loop Gate2

	mov al, Level
	cmp al, 3
	jb Back

	; Gate3
	mov dh, PacmanCY
	mov dl, PacmanCX
	sub dl, 1
	sub dh, 3
	mov ecx, 3
	mov edi, offset Pallets
	mov eax, 0
	mov al, 120
	mul dh
	add edi, eax
	mov eax, 0
	mov al, dl
	add edi, eax
	call Gotoxy
	Gate3:
		mov al, ' '
		mov [edi], al
		inc edi
		call WriteChar
		loop Gate3

	; Gate4
	mov dh, PacmanCY
	mov dl, PacmanCX
	sub dl, 1
	add dh, 3
	mov ecx, 3
	mov edi, offset Pallets
	mov eax, 0
	mov al, 120
	mul dh
	add edi, eax
	mov eax, 0
	mov al, dl
	add edi, eax
	call Gotoxy
	Gate4:
		mov al, ' '
		mov [edi], al
		inc edi
		call WriteChar
		loop Gate4

	Back:
	ret

PacmanCage ENDP

GhostCage PROC
	mov eax, Blue (Black * 16)
	call SetTextColor
	
	cmp cl, 1
	je GhostOne
	cmp cl, 2
	je GhostTwo
	cmp cl, 3
	je GhostThree
	cmp cl, 4
	je GhostFour
	cmp cl, 5
	je GhostFive

	GhostOne:
	mov dh, bh
	mov dl, bl
	sub dl, 6
	mov ecx, 3
	call Gotoxy
	Ghost1Wall1:
		mov edi, offset Pallets
		mov eax, 0
		mov al, 120
		mul dh
		add edi, eax
		mov eax, 0
		mov al, dl
		add edi, eax
		mov al, '|'
		mov [edi], al
		call WriteChar
		inc dh
		call Gotoxy
		loop Ghost1Wall1
	
	mov dh, bh
	mov dl, bl
	add dl, 6
	mov ecx, 3
	call Gotoxy
	Ghost1Wall2:
		mov edi, offset Pallets
		mov eax, 0
		mov al, 120
		mul dh
		add edi, eax
		mov eax, 0
		mov al, dl
		add edi, eax
		mov al, '|'
		mov [edi], al
		call WriteChar
		inc dh
		call Gotoxy
		loop Ghost1Wall2

	mov dh, bh
	mov dl, bl
	sub dl, 6
	add dh, 3
	mov ecx, 13
	mov edi, offset Pallets
	mov eax, 0
	mov al, 120
	mul dh
	add edi, eax
	mov eax, 0
	mov al, dl
	add edi, eax
	call Gotoxy
	Ghost1Wall3:
		mov al, '-'
		mov [edi], al
		inc edi
		call WriteChar
		loop Ghost1Wall3

	mov dh, bh
	mov dl, bl
	sub dl, 1
	add dh, 3
	mov ecx, 3
	mov edi, offset Pallets
	mov eax, 0
	mov al, 120
	mul dh
	add edi, eax
	mov eax, 0
	mov al, dl
	add edi, eax
	call Gotoxy
	Ghost1Gate:
		mov al, ' '
		mov [edi], al
		inc edi
		call WriteChar
		loop Ghost1Gate
	jmp back

	GhostTwo:
	mov dh, bh
	mov dl, bl
	sub dl, 6
	mov ecx, 3
	call Gotoxy
	Ghost2Wall1:
		mov edi, offset Pallets
		mov eax, 0
		mov al, 120
		mul dh
		add edi, eax
		mov eax, 0
		mov al, dl
		add edi, eax
		mov al, '|'
		mov [edi], al
		call WriteChar
		dec dh
		call Gotoxy
		loop Ghost2Wall1
	
	mov dh, bh
	mov dl, bl
	add dl, 6
	mov ecx, 3
	call Gotoxy
	Ghost2Wall2:
		mov edi, offset Pallets
		mov eax, 0
		mov al, 120
		mul dh
		add edi, eax
		mov eax, 0
		mov al, dl
		add edi, eax
		mov al, '|'
		mov [edi], al
		call WriteChar
		dec dh
		call Gotoxy
		loop Ghost2Wall2

	mov dh, bh
	mov dl, bl
	sub dl, 6
	sub dh, 3
	mov ecx, 13
	mov edi, offset Pallets
	mov eax, 0
	mov al, 120
	mul dh
	add edi, eax
	mov eax, 0
	mov al, dl
	add edi, eax
	call Gotoxy
	Ghost2Wall3:
		mov al, '-'
		mov [edi], al
		inc edi
		call WriteChar
		loop Ghost2Wall3

	mov dh, bh
	mov dl, bl
	sub dl, 1
	sub dh, 3
	mov ecx, 3
	mov edi, offset Pallets
	mov eax, 0
	mov al, 120
	mul dh
	add edi, eax
	mov eax, 0
	mov al, dl
	add edi, eax
	call Gotoxy
	Ghost2Gate:
		mov al, ' '
		mov [edi], al
		inc edi
		call WriteChar
		loop Ghost2Gate
	jmp back

	GhostThree:
	mov dh, bh
	mov dl, bl
	sub dl, 6
	mov ecx, 3
	call Gotoxy
	Ghost3Wall1:
		mov edi, offset Pallets
		mov eax, 0
		mov al, 120
		mul dh
		add edi, eax
		mov eax, 0
		mov al, dl
		add edi, eax
		mov al, '|'
		mov [edi], al
		call WriteChar
		dec dh
		call Gotoxy
		loop Ghost3Wall1
	
	mov dh, bh
	mov dl, bl
	add dl, 6
	mov ecx, 3
	call Gotoxy
	Ghost3Wall2:
		mov edi, offset Pallets
		mov eax, 0
		mov al, 120
		mul dh
		add edi, eax
		mov eax, 0
		mov al, dl
		add edi, eax
		mov al, '|'
		mov [edi], al
		call WriteChar
		dec dh
		call Gotoxy
		loop Ghost3Wall2

	mov dh, bh
	mov dl, bl
	sub dl, 6
	sub dh, 3
	mov ecx, 13
	mov edi, offset Pallets
	mov eax, 0
	mov al, 120
	mul dh
	add edi, eax
	mov eax, 0
	mov al, dl
	add edi, eax
	call Gotoxy
	Ghost3Wall3:
		mov al, '-'
		mov [edi], al
		inc edi
		call WriteChar
		loop Ghost3Wall3

	mov dh, bh
	mov dl, bl
	sub dl, 1
	sub dh, 3
	mov ecx, 3
	mov edi, offset Pallets
	mov eax, 0
	mov al, 120
	mul dh
	add edi, eax
	mov eax, 0
	mov al, dl
	add edi, eax
	call Gotoxy
	Ghost3Gate:
		mov al, ' '
		mov [edi], al
		inc edi
		call WriteChar
		loop Ghost3Gate
	jmp back

	GhostFour:
	mov dh, bh
	mov dl, bl
	sub dh, 3
	mov ecx, 6
	mov edi, offset Pallets
	mov eax, 0
	mov al, 120
	mul dh
	add edi, eax
	mov eax, 0
	mov al, dl
	add edi, eax
	call Gotoxy
	Ghost4Wall1:
		mov al, '-'
		mov [edi], al
		inc edi
		call WriteChar
		loop Ghost4Wall1
	
	mov dh, bh
	mov dl, bl
	add dh, 3
	mov ecx, 6
	mov edi, offset Pallets
	mov eax, 0
	mov al, 120
	mul dh
	add edi, eax
	mov eax, 0
	mov al, dl
	add edi, eax
	call Gotoxy
	Ghost4Wall2:
		mov al, '-'
		mov [edi], al
		inc edi
		call WriteChar
		loop Ghost4Wall2

	mov dh, bh
	mov dl, bl
	add dl, 6
	sub dh, 3
	mov ecx, 7
	call Gotoxy
	Ghost4Wall3:
		mov edi, offset Pallets
		mov eax, 0
		mov al, 120
		mul dh
		add edi, eax
		mov eax, 0
		mov al, dl
		add edi, eax
		mov al, '|'
		mov [edi], al
		call WriteChar
		inc dh
		call Gotoxy
		loop Ghost4Wall3

	mov dh, bh
	mov dl, bl
	sub dh, 1
	add dl, 6
	mov ecx, 3
	call Gotoxy
	Ghost4Gate:
		mov edi, offset Pallets
		mov eax, 0
		mov al, 120
		mul dh
		add edi, eax
		mov eax, 0
		mov al, dl
		add edi, eax
		mov al, ' '
		mov [edi], al
		call WriteChar
		inc dh
		call Gotoxy
		loop Ghost4Gate
	jmp back

	GhostFive:
	mov dh, bh
	mov dl, bl
	sub dh, 3
	sub dl, 6
	mov ecx, 6
	mov edi, offset Pallets
	mov eax, 0
	mov al, 120
	mul dh
	add edi, eax
	mov eax, 0
	mov al, dl
	add edi, eax
	call Gotoxy
	Ghost5Wall1:
		mov al, '-'
		mov [edi], al
		inc edi
		call WriteChar
		loop Ghost5Wall1
	
	mov dh, bh
	mov dl, bl
	add dh, 3
	sub dl, 6
	mov ecx, 6
	mov edi, offset Pallets
	mov eax, 0
	mov al, 120
	mul dh
	add edi, eax
	mov eax, 0
	mov al, dl
	add edi, eax
	call Gotoxy
	Ghost5Wall2:
		mov al, '-'
		mov [edi], al
		inc edi
		call WriteChar
		loop Ghost5Wall2

	mov dh, bh
	mov dl, bl
	sub dl, 6
	sub dh, 3
	mov ecx, 7
	call Gotoxy
	Ghost5Wall3:
		mov edi, offset Pallets
		mov eax, 0
		mov al, 120
		mul dh
		add edi, eax
		mov eax, 0
		mov al, dl
		add edi, eax
		mov al, '|'
		mov [edi], al
		call WriteChar
		inc dh
		call Gotoxy
		loop Ghost5Wall3

	mov dh, bh
	mov dl, bl
	sub dh, 1
	sub dl, 6
	mov ecx, 3
	call Gotoxy
	Ghost5Gate:
		mov edi, offset Pallets
		mov eax, 0
		mov al, 120
		mul dh
		add edi, eax
		mov eax, 0
		mov al, dl
		add edi, eax
		mov al, ' '
		mov [edi], al
		call WriteChar
		inc dh
		call Gotoxy
		loop Ghost5Gate
	jmp back

	back:
	ret

GhostCage ENDP

SetPallets PROC
	mov eax, green (Black * 16)
	call SetTextColor
	mov edi, offset Pallets
	mov ecx, 30
	mov dl, 0
	mov dh, 0
	call Gotoxy
	Outer:
		push ecx
		mov ecx, 120
		call Gotoxy
		Inner:	
			cmp dh, 4
			jb Blank
			cmp ecx, 118
			jae Blank
			cmp ecx, 2
			jbe Blank
			Back:
			mov al, [edi]
			inc edi
			call WriteChar
			loop Inner
		inc dh
		pop ecx
		loop Outer
	jmp Down
	
	Blank:
	mov al, ' '
	mov [edi], al
	jmp Back

	Down:
	ret

SetPallets ENDP

MovePacman PROC
	call ReadChar
	mov cl, al
	mov dh, PacmanY
	mov dl, PacmanX
	mov edi, offset Pallets
	mov eax, 0
	mov al, 120
	cmp cl, 'w'
	je Up
	cmp cl, 's'
	je Down
	cmp cl, 'a'
	je Left
	cmp cl, 'd'
	je Right
	cmp cl, 'p'
	je PauseScr
	jmp Back
	Move:
	mul dh
	add edi, eax
	mov eax, 0
	mov al, dl
	add edi, eax
	mov al, [edi]
	cmp al, ' '
	je Allow
	cmp al, '.'
	je AddScore
	cmp al, '*'
	je AddBonusScore
	jmp Back

	PauseScr:
	call PauseScreen
	jmp Back

	Up:
	dec dh
	jmp Move

	Down:
	inc dh
	jmp Move

	Left:
	dec dl
	jmp Move

	Right:
	inc dl
	jmp Move

	AddScore:
	mov ax, Score
	add ax, 5
	mov Score, ax
	mov al, ' '
	mov [edi], al
	jmp Allow

	AddBonusScore:
	mov ax, Score
	add ax, 25
	mov Score, ax
	mov al, ' '
	mov [edi], al
	mov PowerActive, 0
	mov PacmanPower, 10
	jmp Allow

	Allow:
	cmp cl, 'w'
	je MoveUp
	cmp cl, 's'
	je MoveDown
	cmp cl, 'a'
	je MoveLeft
	cmp cl, 'd'
	je MoveRight
	jmp Back

	MoveUp:
	mov al, PacmanY
	dec al
	mov PacmanY, al
	jmp Back

	MoveDown:
	mov al, PacmanY
	inc al
	mov PacmanY, al
	jmp Back

	MoveLeft:
	mov al, PacmanX
	dec al
	mov PacmanX, al
	jmp Back

	MoveRight:
	mov al, PacmanX
	inc al
	mov PacmanX, al
	jmp Back

	Back:
	ret

MovePacman ENDP

BasicMovement PROC
	mov cl, 0
	mov dh, bh
	mov dl, bl
	mov edi, offset Pallets
	mov eax, 0
	mov al, 120
	mul dh
	add edi, eax
	mov eax, 0
	mov al, dl
	add edi, eax
	cmp bh, PacmanY
	je ChaseCol
	cmp bl, PacmanX
	je ChaseRow
	jmp MoveRandom

	ChaseRow:
	cmp bh, PacmanY
	jb MoveDown
	ja MoveUp
	jmp MoveRandom

	ChaseCol:
	cmp bl, PacmanX
	jb MoveRight
	ja MoveLeft
	jmp MoveRandom

	MoveDown:
	add edi, 120
	mov al, [edi]
	sub edi, 120
	cmp al, ' '
	je AllowDown
	cmp al, '.'
	je AllowDown
	cmp al, '*'
	je AllowDown
	jmp MoveRandom

	MoveUp:
	sub edi, 120
	mov al, [edi]
	add edi, 120
	cmp al, ' '
	je AllowUp
	cmp al, '.'
	je AllowUp
	cmp al, '*'
	je AllowUp
	jmp MoveRandom

	MoveLeft:
	dec edi
	mov al, [edi]
	inc edi
	cmp al, ' '
	je AllowLeft
	cmp al, '.'
	je AllowLeft
	cmp al, '*'
	je AllowLeft
	jmp MoveRandom

	MoveRight:
	inc edi
	mov al, [edi]
	dec edi
	cmp al, ' '
	je AllowRight
	cmp al, '.'
	je AllowRight
	cmp al, '*'
	je AllowRight
	jmp MoveRandom

	AllowDown:
	inc bh
	jmp Back

	AllowUp:
	dec bh
	jmp Back

	AllowLeft:
	dec bl
	jmp Back

	AllowRight:
	inc bl
	jmp Back

	MoveRandom:
	inc cl
	cmp cl, 100
	jae Back
	mov eax, 4
	call RandomRange
	cmp eax, 0
	je MoveLeft
	cmp eax, 1
	je MoveUp
	cmp eax, 2
	je MoveRight
	cmp eax, 3
	je MoveDown

	Back:
	ret

BasicMovement ENDP

MediateMovement PROC
	mov dh, bh
	mov dl, bl
	mov edi, offset Pallets
	mov eax, 0
	mov al, 120
	mul dh
	add edi, eax
	mov eax, 0
	mov al, dl
	add edi, eax
	cmp bh, PacmanY
	jb MoveDown
	ja MoveUp
	MRow:
	cmp bl, PacmanX
	jb MoveRight
	ja MoveLeft
	jmp MRand

	MoveDown:
	add edi, 120
	mov al, [edi]
	sub edi, 120
	cmp al, ' '
	je AllowDown
	cmp al, '.'
	je AllowDown
	cmp al, '*'
	je AllowDown
	jmp MRow

	MoveUp:
	sub edi, 120
	mov al, [edi]
	add edi, 120
	cmp al, ' '
	je AllowUp
	cmp al, '.'
	je AllowUp
	cmp al, '*'
	je AllowUp
	jmp MRow

	MoveLeft:
	dec edi
	mov al, [edi]
	inc edi
	cmp al, ' '
	je AllowLeft
	cmp al, '.'
	je AllowLeft
	cmp al, '*'
	je AllowLeft
	jmp MRand

	MoveRight:
	inc edi
	mov al, [edi]
	dec edi
	cmp al, ' '
	je AllowRight
	cmp al, '.'
	je AllowRight
	cmp al, '*'
	je AllowRight
	jmp MRand

	AllowDown:
	inc bh
	jmp Back

	AllowUp:
	dec bh
	jmp Back

	AllowLeft:
	dec bl
	jmp Back

	AllowRight:
	inc bl
	jmp Back

	MRand:
	call BasicMovement
	jmp Back

	Back:
	ret

MediateMovement ENDP

ToughMovement PROC
	mov dh, bh
	mov dl, bl
	mov edi, offset Pallets
	mov eax, 0
	mov al, 120
	mul dh
	add edi, eax
	mov eax, 0
	mov al, dl
	add edi, eax
	cmp bh, PacmanY
	jb MoveDown
	ja MoveUp
	MRow:
	cmp bl, PacmanX
	jb MoveRight
	ja MoveLeft
	jmp MRand

	MoveDown:
	add edi, 120
	mov al, [edi]
	sub edi, 120
	cmp al, ' '
	je AllowDown
	cmp al, '.'
	je AllowDown
	cmp al, '*'
	je AllowDown
	jmp MRow

	MoveUp:
	sub edi, 120
	mov al, [edi]
	add edi, 120
	cmp al, ' '
	je AllowUp
	cmp al, '.'
	je AllowUp
	cmp al, '*'
	je AllowUp
	jmp MRow

	MoveLeft:
	dec edi
	mov al, [edi]
	inc edi
	cmp al, ' '
	je AllowLeft
	cmp al, '.'
	je AllowLeft
	cmp al, '*'
	je AllowLeft
	mov ah, 1
	cmp al, 1
	jne MoveRight
	jmp MRand

	MoveRight:
	inc edi
	mov al, [edi]
	dec edi
	cmp al, ' '
	je AllowRight
	cmp al, '.'
	je AllowRight
	cmp al, '*'
	je AllowRight
	mov al, 1
	cmp ah, 1
	jne MoveLeft
	jmp MRand

	AllowDown:
	inc bh
	jmp Back

	AllowUp:
	dec bh
	jmp Back

	AllowLeft:
	dec bl
	jmp Back

	AllowRight:
	inc bl
	jmp Back

	MRand:
	call BasicMovement
	jmp Back

	Back:
	ret

ToughMovement ENDP

MoveGuard PROC
	mov dh, bh
	mov dl, bl
	mov edi, offset Pallets
	mov eax, 0
	mov al, 120
	mul dh
	add edi, eax
	mov eax, 0
	mov al, dl
	add edi, eax
	cmp GuardX1, 0
	je SetGuard
	jmp move

	SetGuard:
	mov ecx, 10
	mov esi, edi
	WayColR:
		mov al, [edi]
		cmp al, ' '
		je Next1
		cmp al, '.'
		je Next1
		cmp al, '*'
		je Next1
		jmp Fail1
		Next1:
		inc edi
		loop WayColR
	jmp SetColR
	Fail1:
	mov edi, esi
	mov ecx, 10
	WayColL:
		mov al, [edi]
		cmp al, ' '
		je Next2
		cmp al, '.'
		je Next2
		cmp al, '*'
		je Next2
		jmp Fail2
		Next2:
		dec edi
		loop WayColL
	jmp SetColL
	Fail2:
	mov edi, esi
	mov ecx, 10
	WayRowU:
		mov al, [edi]
		cmp al, ' '
		je Next3
		cmp al, '.'
		je Next3
		cmp al, '*'
		je Next3
		jmp Fail3
		Next3:
		sub edi, 120
		loop WayRowU
	jmp SetRowU
	Fail3:
	mov edi, esi
	mov ecx, 10
	WayRowD:
		mov al, [edi]
		cmp al, ' '
		je Next4
		cmp al, '.'
		je Next4
		cmp al, '*'
		je Next4
		jmp Fail4
		Next4:
		add edi, 120
		loop WayRowD
	jmp SetRowD
	Fail4:
	mov dx, 0
	jmp Back

	SetColR:
	mov GuardX1, bl
	mov GuardY1, bh
	mov al, bl
	add al, 9
	mov GuardX2, al
	mov GuardY2, bh
	mov GuardDirection, 3
	jmp move

	SetColL:
	mov GuardX1, bl
	mov GuardY1, bh
	mov al, bl
	sub al, 9
	mov GuardX2, al
	mov GuardY2, bh
	mov GuardDirection, 2
	jmp move
	
	SetRowU:
	mov GuardX1, bl
	mov GuardY1, bh
	mov al, bh
	sub al, 9
	mov GuardX2, bl
	mov GuardY2, al
	mov GuardDirection, 0
	jmp move

	SetRowD:
	mov GuardX1, bl
	mov GuardY1, bh
	mov al, bh
	add al, 9
	mov GuardX2, bl
	mov GuardY2, al
	mov GuardDirection, 1
	jmp move

	move:
	mov edi, offset Pallets			; edi -> the guard's own cell
	movzx eax, bh
	imul eax, 120
	add edi, eax
	movzx eax, bl
	add edi, eax
	mov esi, edi					; esi -> the cell it wants to step into
	cmp GuardDirection, 0
	je PeekUp
	cmp GuardDirection, 1
	je PeekDown
	cmp GuardDirection, 2
	je PeekLeft
	cmp GuardDirection, 3
	je PeekRight
	jmp Back

	PeekUp:
	sub esi, 120
	jmp Peek
	PeekDown:
	add esi, 120
	jmp Peek
	PeekLeft:
	dec esi
	jmp Peek
	PeekRight:
	inc esi

	Peek:
	mov al, [esi]
	cmp al, ' '
	je Walk
	cmp al, '.'
	je Walk
	cmp al, '*'
	je Walk
	mov GuardX1, 0					; blocked: drop this patrol, chase normally this move
	mov dx, 0						; and plan a new patrol on the next move
	jmp Back

	Walk:
	cmp GuardDirection, 0
	je Up
	cmp GuardDirection, 1
	je Down
	cmp GuardDirection, 2
	je Left
	cmp GuardDirection, 3
	je Right
	jmp Back

	Up:
	dec bh
	mov al, GuardY1					; turn round at the upper end of the patrol
	cmp al, GuardY2
	jbe UpEnd
	mov al, GuardY2
	UpEnd:
	cmp bh, al
	je DirectionDown
	jmp Back

	Down:
	inc bh
	mov al, GuardY1					; turn round at the lower end
	cmp al, GuardY2
	jae DownEnd
	mov al, GuardY2
	DownEnd:
	cmp bh, al
	je DirectionUp
	jmp Back

	Left:
	dec bl
	mov al, GuardX1					; turn round at the left end
	cmp al, GuardX2
	jbe LeftEnd
	mov al, GuardX2
	LeftEnd:
	cmp bl, al
	je DirectionRight
	jmp Back

	Right:
	inc bl
	mov al, GuardX1					; turn round at the right end
	cmp al, GuardX2
	jae RightEnd
	mov al, GuardX2
	RightEnd:
	cmp bl, al
	je DirectionLeft
	jmp Back

	DirectionLeft:
	mov GuardDirection, 2
	jmp Back

	DirectionRight:
	mov GuardDirection, 3
	jmp Back

	DirectionUp:
	mov GuardDirection, 0
	jmp Back

	DirectionDown:
	mov GuardDirection, 1
	jmp Back

	Back:
	ret

MoveGuard ENDP

MoveGhosts PROC
	cmp Level, 1
	je BasicMove
	cmp Level, 2
	je Mediate
	cmp Level, 3
	je Tough
	jmp Back

	BasicMove:
	mov bl, GhostX1
	mov bh, GhostY1
	call BasicMovement
	mov GhostX1, bl
	mov GhostY1, bh
	mov bl, GhostX2
	mov bh, GhostY2
	call BasicMovement
	mov GhostX2, bl
	mov GhostY2, bh
	jmp Back

	Mediate:
	mov bl, GhostX1
	mov bh, GhostY1
	call MediateMovement
	mov GhostX1, bl
	mov GhostY1, bh
	mov bl, GhostX2
	mov bh, GhostY2
	call MediateMovement
	mov GhostX2, bl
	mov GhostY2, bh
	mov bl, GhostX3
	mov bh, GhostY3
	call MediateMovement
	mov GhostX3, bl
	mov GhostY3, bh
	jmp Back

	Tough:
	mov bl, GhostX1
	mov bh, GhostY1
	cmp StepMoves, 20
	jae Guard
	NotSkip:
	call ToughMovement
	Skip:
	mov GhostX1, bl
	mov GhostY1, bh
	mov bl, GhostX2
	mov bh, GhostY2
	call ToughMovement
	mov GhostX2, bl
	mov GhostY2, bh
	mov bl, GhostX3
	mov bh, GhostY3
	call ToughMovement
	mov GhostX3, bl
	mov GhostY3, bh
	mov bl, GhostX4
	mov bh, GhostY4
	call ToughMovement
	mov GhostX4, bl
	mov GhostY4, bh
	mov bl, GhostX5
	mov bh, GhostY5
	call ToughMovement
	mov GhostX5, bl
	mov GhostY5, bh
	jmp Back

	Guard:
	call MoveGuard
	cmp dx, 0
	je NotSkip
	jmp Skip

	Back:
	call SeparateGhosts
	ret

MoveGhosts ENDP

SeparateGhosts PROC
	; Ghost 1-Ghost 2-5
    mov al, GhostX1
    cmp al, GhostX2
    jne NG1_2
    mov ah, GhostY1
    cmp ah, GhostY2
    je CollideG1
	NG1_2:
    cmp al, GhostX3
    jne NG1_3
    mov ah, GhostY1
    cmp ah, GhostY3
    je CollideG1
	NG1_3:
    cmp al, GhostX4
    jne NG1_4
    mov ah, GhostY1
    cmp ah, GhostY4
    je CollideG1
	NG1_4:
    cmp al, GhostX5
    jne NG1_5
    mov ah, GhostY1
    cmp ah, GhostY5
    je CollideG1
	NG1_5:

    ; Ghost 2-Ghost 3-5
    mov al, GhostX2
    cmp al, GhostX3
    jne NG2_3
    mov ah, GhostY2
    cmp ah, GhostY3
    je CollideG2
	NG2_3:
    cmp al, GhostX4
    jne NG2_4
    mov ah, GhostY2
    cmp ah, GhostY4
    je CollideG2
	NG2_4:
    cmp al, GhostX5
    jne NG2_5
    mov ah, GhostY2
    cmp ah, GhostY5
    je CollideG2
	NG2_5:

    ; Ghost 3-Ghost 4-5
    mov al, GhostX3
    cmp al, GhostX4
    jne NG3_4
    mov ah, GhostY3
    cmp ah, GhostY4
    je CollideG3
	NG3_4:
    cmp al, GhostX5
    jne NG3_5
    mov ah, GhostY3
    cmp ah, GhostY5
    je CollideG3
	NG3_5:

    ; Ghost 4-Ghost 5
    mov al, GhostX4
    cmp al, GhostX5
    jne NG4_5
    mov ah, GhostY4
    cmp ah, GhostY5
    je CollideG4
	NG4_5:

    jmp Back

	CollideG1:
    mov bl, GhostX1
	mov bh, GhostY1
	call BasicMovement
    mov GhostX1, bl
    mov GhostY1, bh
    jmp Back

	CollideG2:
    mov bl, GhostX2
	mov bh, GhostY2
	call BasicMovement
    mov GhostX2, bl
    mov GhostY2, bh
    jmp Back

	CollideG3:
	mov bl, GhostX3
	mov bh, GhostY3
	call BasicMovement
    mov GhostX3, bl
    mov GhostY3, bh
    jmp Back

	CollideG4:
    mov bl, GhostX4
	mov bh, GhostY4
	call BasicMovement
    mov GhostX4, bl
    mov GhostY4, bh
    jmp Back

	Back:
	ret

SeparateGhosts ENDP

AddPowerPallet PROC
	cmp PowerMoves, 0
	jbe CheckActive
	jmp Back

	CheckActive:
	cmp PowerActive, 0
	je AddPower
	jmp Back

	AddPower:
	mov PowerMoves, 15
	Again:
	mov eax, 0
	mov al, 110
	call RandomRange
	add al, 5
	mov dl, al
	mov eax, 0
	mov al, 22
	call RandomRange
	add al, 5
	mov dh, al
	mov edi, offset Pallets
	mov eax, 0
	mov al, 120
	mul dh
	add edi, eax
	mov eax, 0
	mov al, dl
	add edi, eax
	mov al, [edi]
	cmp al, ' '
	je SetPower
	cmp al, '.'
	je SetPower
	jmp Again

	SetPower:
	cmp dl, GhostX1
	je CheckY
	cmp dl, GhostX2
	je CheckY
	cmp dl, GhostX3
	je CheckY
	cmp dl, GhostX4
	je CheckY
	cmp dl, GhostX5
	je CheckY
	cmp dl, PacmanX
	je CheckY
	Set:
	mov PowerPalletX, dl
	mov PowerPalletY, dh
	mov al, '*'
	mov [edi], al
	mov PowerActive, 1
	jmp Back

	CheckY:
	cmp dh, GhostX1
	je Again
	cmp dh, GhostX2
	je Again
	cmp dh, GhostX3
	je Again
	cmp dh, GhostX4
	je Again
	cmp dh, GhostX5
	je Again
	cmp dh, PacmanX
	je Again
	jmp Set

	Back:
	ret

AddPowerPallet ENDP

CheckCollision PROC
	mov al, PacmanX
	mov ah, PacmanY
	cmp al, GhostX1
	je CheckG1
	OG2:
	cmp al, GhostX2
	je CheckG2
	OG3:
	cmp Level, 2
	jb Back
	cmp al, GhostX3
	je CheckG3
	OG4:
	cmp Level, 3
	jne Back
	cmp al, GhostX4
	je CheckG4
	OG5:
	cmp al, GhostX5
	je CheckG5
	jmp Back

	CheckG1:
	cmp ah, GhostY1
	je CollideG1
	jmp OG2

	CheckG2:
	cmp ah, GhostY2
	je CollideG2
	jmp OG3

	CheckG3:
	cmp ah, GhostY3
	je CollideG3
	jmp OG4

	CheckG4:
	cmp ah, GhostY4
	je CollideG4
	jmp OG5

	CheckG5:
	cmp ah, GhostY5
	je CollideG5
	jmp Back

	CollideG1:
	cmp PacmanPower, 0
	jnbe resetG1
	dec Lives
	resetG1:
	mov GhostX1, 60 
	mov GhostY1, 5
	jmp Back

	CollideG2:
	cmp PacmanPower, 0
	jnbe resetG2
	dec Lives
	resetG2:
	mov GhostX2, 60 
	mov GhostY2, 28
	call SetCoordinates
	jmp Back

	CollideG3:
	cmp PacmanPower, 0
	jnbe resetG3
	dec Lives
	resetG3:
	mov GhostX3, 23 
	mov GhostY3, 28
	jmp Back

	CollideG4:
	cmp PacmanPower, 0
	jnbe resetG4
	dec Lives
	resetG4:
	mov GhostX4, 4
	mov GhostY4, 16
	jmp Back

	CollideG5:
	cmp PacmanPower, 0
	jnbe resetG5
	dec Lives
	resetG5:
	mov GhostX5, 116
	mov GhostY5, 16
	jmp Back

	Back:
	ret

CheckCollision ENDP

CheckLose PROC
	cmp Lives, 0
	jbe lost
	mov GameLost, 0
	jmp Back

	lost:
	mov GameLost, 1
	jmp back

	Back:
	ret

CheckLose ENDP

CheckWin PROC
	mov ecx, lengthof Pallets
	mov edi, offset Pallets
	traverse:
		mov al, [edi]
		inc edi
		cmp al, '.'
		je NotWon
		loop traverse

	mov GameWon, 1
	jmp Back

	NotWon:
	mov GameWon, 0
	jmp Back

	Back:
	ret

CheckWin ENDP

; ------------------------------------------------------------------
; Itoa
; Converts the WORD value in ax to decimal ASCII digits, written to
; [edi] onward (no leading zeros, no terminator). Returns edi advanced
; past the last digit written.
; ------------------------------------------------------------------
Itoa PROC
	push eax
	push ebx
	push ecx
	push edx
	movzx eax, ax
	mov ebx, 10
	xor ecx, ecx					; number of digits pushed so far
	cmp eax, 0
	jne Split
	mov BYTE PTR [edi], '0'
	inc edi
	jmp Done
	Split:
		xor edx, edx
		div ebx						; eax /= 10, edx = next digit (low to high)
		push edx
		inc ecx
		cmp eax, 0
		jne Split
	Emit:
		pop edx
		add dl, '0'
		mov [edi], dl
		inc edi
		loop Emit
	Done:
	pop edx
	pop ecx
	pop ebx
	pop eax
	ret

Itoa ENDP

; ------------------------------------------------------------------
; WriteFileAs
; Appends one line to Scores.txt for the game that just finished:
;   "<name> - <score> (Level <n>)" + CRLF
; Irvine32 has no append mode, so the existing file is read into
; fileContents, the new record is added after it, and the whole
; buffer is written back with CreateOutputFile (which truncates).
; ------------------------------------------------------------------
WriteFileAs PROC
	pushad

	; ---- build the new record in RecordBuf
	mov edi, offset RecordBuf
	mov esi, offset Username
	movzx ecx, UsernameLength
	cmp ecx, 0
	je NoName
	CopyName:
		mov al, [esi]
		mov [edi], al
		inc esi
		inc edi
		loop CopyName
	NoName:
	mov esi, offset sepDash
	call CopyStr0
	mov ax, Score
	call Itoa
	mov esi, offset sepLevel
	call CopyStr0
	movzx ax, Level
	call Itoa
	mov al, ')'
	mov [edi], al
	inc edi
	mov al, 13
	mov [edi], al
	inc edi
	mov al, 10
	mov [edi], al
	inc edi
	mov eax, edi
	sub eax, offset RecordBuf
	mov RecordLen, eax

	; ---- read whatever is already in the file, if anything
	mov edx, offset filename
	call OpenInputFile
	cmp eax, INVALID_HANDLE_VALUE
	je NoExisting
	mov fileHandle, eax
	mov edx, offset fileContents
	mov ecx, 2000
	sub ecx, RecordLen				; leave room for the new record
	call ReadFromFile
	mov ExistingLen, eax			; save the byte count before CloseFile overwrites eax
	mov eax, fileHandle
	call CloseFile
	jmp Append
	NoExisting:
	mov ExistingLen, 0

	; ---- append the new record after the existing content
	Append:
	mov edi, offset fileContents
	add edi, ExistingLen
	mov esi, offset RecordBuf
	mov ecx, RecordLen
	CopyRec:
		mov al, [esi]
		mov [edi], al
		inc esi
		inc edi
		loop CopyRec

	; ---- write the whole thing back
	mov eax, ExistingLen
	add eax, RecordLen
	mov TotalLen, eax
	mov edx, offset filename
	call CreateOutputFile
	mov fileHandle, eax
	cmp eax, INVALID_HANDLE_VALUE
	je Back
	mov ecx, TotalLen
	mov edx, offset fileContents
	call WriteToFile
	mov eax, fileHandle			; WriteToFile overwrites eax with a byte count, not the handle
	call CloseFile

	Back:
	popad
	ret

	; Copies the 0-terminated string at esi to [edi], advancing edi past it.
	CopyStr0:
		mov al, [esi]
		cmp al, 0
		je CopyStr0Done
		mov [edi], al
		inc edi
		inc esi
		jmp CopyStr0
	CopyStr0Done:
	ret

WriteFileAs ENDP

; ------------------------------------------------------------------
; HistoryScreen
; Shows every line ever written to Scores.txt by WriteFileAs.
; ------------------------------------------------------------------
HistoryScreen PROC
	pushad
	mov eax, White (Black * 16)
	call SetTextColor
	call Clrscr
	mov dh, 3
	mov dl, 50
	call Gotoxy
	mov eax, Blue (Black * 16)
	call SetTextColor
	mov edx, offset str29
	call WriteString

	mov edx, offset filename
	call OpenInputFile
	cmp eax, INVALID_HANDLE_VALUE
	je NoHistory

	mov fileHandle, eax
	mov edx, offset fileContents
	mov ecx, 1999						; leave room for the terminating 0
	call ReadFromFile
	mov edi, offset fileContents	; save the byte count before CloseFile overwrites eax
	add edi, eax
	mov BYTE PTR [edi], 0
	mov eax, fileHandle
	call CloseFile

	mov dh, 7
	mov dl, 40
	call Gotoxy
	mov eax, White (Black * 16)
	call SetTextColor
	mov edx, offset fileContents
	call WriteString
	jmp Dismiss

	NoHistory:
	mov dh, 7
	mov dl, 45
	call Gotoxy
	mov eax, White (Black * 16)
	call SetTextColor
	mov edx, offset str30
	call WriteString

	Dismiss:
	mov dh, 25
	mov dl, 45
	call Gotoxy
	call ReadChar
	popad
	ret

HistoryScreen ENDP

ResetPallets PROC
	mov Score, 0
	mov Lives, 3
	mov StepMoves, 0
	mov PowerMoves, 5
	mov PowerPalletX, 0
	mov PowerPalletY, 0
	mov PowerActive, 0
	mov GuardDirection, 0
	mov GuardX1, 0
	mov GuardY1, 0
	mov GuardX2, 0
	mov GuardY2, 0
	mov PacmanX, 60
	mov PacmanY, 16
	mov PacmanPower, 0
	mov GhostX1, 60 
	mov GhostY1, 5
	mov GhostX2, 60
	mov GhostY2, 28
	mov GhostX3, 23
	mov GhostY3, 28
	mov GhostX4, 4
	mov GhostY4, 16
	mov GhostX5, 116
	mov GhostY5, 16
	mov GhostCX2, 60
	mov GhostCY2, 28
	mov GameLost, 0
	mov GameWon, 0
	mov ecx, lengthof Pallets
	mov edi, offset Pallets
	mov al, '.'
	traverse:
		mov [edi], al
		inc edi
		loop traverse
	ret
	
ResetPallets ENDP

END main