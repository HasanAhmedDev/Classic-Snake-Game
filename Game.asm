[org 0x0100]
jmp start


timercount: dw 0
speed: dw 8
Randomforfood: dw 4
timertick: dw 0
minutes: dw 3
seconds: dw 60
RandomLoc: dw 1214
movement: dw 3
Snake: times 240 dw 0
SnakeLength: dw 0
Boundary: times 222 dw 0
lives: dw 3
lifelost: dw 0
Str1: db 'Lives:'
str1len: dw 6
Str2: db 'Time:'
str2len: dw 5
Str3: db ':'
str3len: dw 1
Str4: db 'Snake Length:'
str4len: dw 13
Str5: db 'Rem Lives:'
str5len: dw 10
winnermsg: db 'Congratulations.You Won!'
lengthwinnermsg: dw 24
loosermsg: db 'You Loose!'
lengthloosermsg: dw 10


settlespeed:
push bp
mov bp,sp                         ;decreases the speed to half
pusha

cmp word[speed],8
je sub1
cmp word[speed],4
je sub2
cmp word[speed],2
je sub3
jmp stopspeed

sub1:
sub word[speed],4
jmp stopspeed


sub2:
sub word[speed],2
jmp stopspeed


sub3:
sub word[speed],2
jmp stopspeed

stopspeed:
mov word[timercount],0
popa
pop bp
ret


winnercheck:
push bp
mov bp,sp                        ;Check that if snake has reached his full length
pusha

cmp word[SnakeLength],240
je winneryes


popa
pop bp
ret


winneryes:
call clrscr
push 2150
push winnermsg
push word[lengthwinnermsg]
call printstr

infinite1:
jmp infinite1



soundfunction:
push bp
mov bp,sp
pusha

mov al, 182         ; Prepare the speaker for the
out 43h, al         ;  note.                         
mov ax, 1715        ; Frequency number (in decimal)
                                ;  for middle C.
out 42h, al         ; Output low byte.                         ;soundfunction when snake eats fruit
mov al, ah          ; Output high byte.
out 42h, al 
in  al, 61h         ; Turn on note (get value from
                                ;  port 61h).
or  al, 00000011b   ; Set bits 1 and 0.
out 61h, al         ; Send new value.
mov bx, 25         ; Pause for duration of note.
.pause1:
 mov cx, 999
.pause2:
 dec cx
 jne .pause2
 dec bx
 jne .pause1
 in al, 61h         ; Turn off note (get value from
                                ;  port 61h).
 and al, 11111100b   ; Reset bits 1 and 0.
 out 61h, al    

 popa
 pop bp 
 ret

soundfunction1:

push bp
mov bp,sp
pusha

mov al, 182         ; Prepare the speaker for the
out 43h, al         ;  note.
mov ax, 9121        ; Frequency number (in decimal)       ;soundfunction when snake crashes
                                ;  for middle C.
out 42h, al         ; Output low byte.
mov al, ah          ; Output high byte.
out 42h, al 
in  al, 61h         ; Turn on note (get value from
                                ;  port 61h).
or  al, 00000011b   ; Set bits 1 and 0.
out 61h, al         ; Send new value.
mov bx, 120         ; Pause for duration of note.
.pause1:
 mov cx, 9999
.pause2:
 dec cx
 jne .pause2
 dec bx
 jne .pause1
 in al, 61h         ; Turn off note (get value from
                                ;  port 61h).
 and al, 11111100b   ; Reset bits 1 and 0.
 out 61h, al    

 popa
 pop bp 
 ret


initializetimer:
push bp
mov bp,sp
pusha

mov word[minutes],3                 ;reset the timer vars to 4 minutes
mov word[seconds],60

popa
pop bp
ret



showstats:
push bp
mov bp,sp
pusha

push 3840
push Str1
push word[str1len]
call printstr
push 3854
push word[lives]
call printnum
push 3960                            ;Show all the needed stats on the bottom of screen
push Str2
push word[str2len]
call printstr
push 3970
push word[minutes]
call printnum
push 3972
push Str3
push word[str3len]
call printstr
push 3974
push word[seconds]
call printnum
push 3914
push Str4
push word[str4len]
call printstr
push 3940
push word[SnakeLength]
call printnum
push 3874
push Str5
push word[str5len]
mov ax,3
mov bx,[lifelost]
sub ax,bx
push 3894
push ax
call printnum



call printstr




popa
pop bp
ret


printnum: 
push bp
mov bp, sp
pusha
mov ax, 0xb800
mov es, ax ; point es to video base
mov ax, [bp+4] ; load number in ax
mov bx, 10 ; use base 10 for division
mov cx, 0 ; initialize count of digits
nextdigit: mov dx, 0 ; zero upper half of dividend
div bx ; divide by 10
add dl, 0x30 ; convert digit into ascii value
push dx ; save ascii value on stack
inc cx ; increment count of values
cmp ax, 0 ; is the quotient zero
jnz nextdigit ; if no divide it again
mov di, [bp+6]
nextpos: pop dx ; remove a digit from the stack
mov dh, 0x07 ; use normal attribute
mov [es:di], dx ; print char on screen
add di, 2 ; move to next screen location
loop nextpos ; repeat for all digits on stack
mov word[es:di],0x0720
popa
pop bp
ret 4





printstr:
push bp
mov bp, sp
pusha
mov ax, 0xb800
mov es, ax ; point es to video base
mov di, [bp+8] ; point di to top left column
mov si, [bp+6] ; point si to string
mov cx, [bp+4] ; load length of string in cx
mov ah, 0x07 ; normal attribute fixed in al

nextchar: mov al, [si] ; load next char of string
mov [es:di], ax ; show this char on screen
add di, 2 ; move to next screen location
add si, 1 ; move to next char in string
loop nextchar ; repeat the operation cx times
popa
pop bp
ret 6


increasesnakelength:
push bp
mov bp,sp
pusha

mov ax,[SnakeLength]
mov bx,2
mul bx
mov dx,0
mov bx,ax                                 ;increase the snake length by 4 characters depending upon direction
cmp word[movement],0
je increasefordown
cmp word[movement],1
je increaseforup
cmp word[movement],2
je increaseforleft
cmp word[movement],3
je increaseforright
jmp endofheadandfoodcheck

increasefordown:
add word[SnakeLength],4
mov ax,[Snake+bx-2]
sub ax,160
mov word[Snake+bx],ax
sub ax,160
mov word[Snake+bx+2],ax
sub ax,160
mov word[Snake+bx+4],ax
sub ax,160
mov word[Snake+bx+6],ax
jmp endincreasing


increaseforup:
add word[SnakeLength],4
mov ax,[Snake+bx-2]
add ax,160
mov word[Snake+bx],ax
add ax,160
mov word[Snake+bx+2],ax
add ax,160
mov word[Snake+bx+4],ax
add ax,160
mov word[Snake+bx+6],ax
jmp endincreasing

increaseforleft:
add word[SnakeLength],4
mov ax,[Snake+bx-2]
add ax,2
mov word[Snake+bx],ax
add ax,2
mov word[Snake+bx+2],ax
add ax,2
mov word[Snake+bx+4],ax
add ax,2
mov word[Snake+bx+6],ax
jmp endincreasing

increaseforright:
add word[SnakeLength],4
mov ax,[Snake+bx-2]
sub ax,2
mov word[Snake+bx],ax
sub ax,2
mov word[Snake+bx+2],ax
sub ax,2
mov word[Snake+bx+4],ax
sub ax,2
mov word[Snake+bx+6],ax
jmp endincreasing

endincreasing:
popa
pop bp
ret

checkheadandfood:
push bp
mov bp,sp
pusha

mov ax,[Snake]
mov bx,[RandomLoc]
cmp ax,bx                                                       ;check if the head and food are on same location
je headandfoodsame
jmp endofheadandfoodcheck

headandfoodsame:
call soundfunction
call increasesnakelength
call Randchecker
call putfood

endofheadandfoodcheck:
popa
pop bp
ret



putfood:
push bp
mov bp,sp
pusha
push 0xb800
pop es

mov ax,[RandomLoc]
mov dx,0                          ;Put food on the screen on RandomLoc from 4 choices of foods
mov bx,2
div bx
mov dx,0
mov bx,4
div bx
mov ax,dx
mov dx,0

cmp ax,0
je food1
cmp ax,1
je food2
cmp ax,2
je food3
cmp ax,3
je food4


food1:
mov di,[RandomLoc]
mov word[es:di],0x072A
jmp endofputfood


food2:
mov di,[RandomLoc]
mov word[es:di],0x0724
jmp endofputfood

food3:
mov di,[RandomLoc]
mov word[es:di],0x0723
jmp endofputfood

food4:
mov di,[RandomLoc]
mov word[es:di],0x0740
jmp endofputfood

endofputfood:
popa
pop bp
ret




RandomLocGenerator:
push bp
mov bp,sp
pusha

mov ax,[RandomLoc]
mov bx,9
mul bx
mov dx,0
add ax,57                              ;Generate random location by performing number of opertions on previous loc and save it
mov bx,3520
div bx
mov cx,dx
mov ax,dx
mov dx,0
mov bx,2
div bx
cmp dx,0
jne oddtoeven
jmp endofrand

oddtoeven:
add cx,1

endofrand:
mov[RandomLoc],cx
popa
pop bp
ret


Randchecker:
push bp
mov bp,sp
pusha

Repeat:

call RandomLocGenerator
mov ax,[RandomLoc]               ;check if the random location is not on snake or on boundary. if so call again RandomLocGenerator
mov cx,[SnakeLength]
mov bx,0

checkforsnake:
cmp ax,[Snake+bx]
je Repeat
add bx,2
loop checkforsnake

mov cx,222
mov bx,0

checkforboundary:
cmp ax,[Boundary+bx]
je Repeat
add bx,2
loop checkforboundary

popa
pop bp
ret




headcheck:
push bp
mov bp,sp
pusha

mov ax,[Snake]
mov bx,2
mov cx,[SnakeLength]
sub cx,1                             ;checks if head touches the boundary or itself, returns 1 if so.

selfcheck:
cmp ax,[Snake+bx]
je headmatch
add bx,2
loop selfcheck

mov cx,222
mov bx,0

boundarycheck:
cmp ax,[Boundary+bx]
je headmatch
add bx,2
loop boundarycheck

mov word[bp+4],0
endofheadcheck:
popa
pop bp
ret

headmatch:
mov word[bp+4],1
jmp endofheadcheck



BoundaryInitialize:
push bp
mov bp,sp
pusha

mov cx,80
mov di,0
mov bx,0

upper:                               ;initialize boundary array
mov word[Boundary+bx],di
add di,2
add bx,2
loop upper

mov cx,23
mov di,0
leftbound:
mov word[Boundary+bx],di
add di,160
add bx,2
loop leftbound

mov cx,23
mov di,158
rightbound:
mov word[Boundary+bx],di
add di,160
add bx,2
loop rightbound

mov cx,80
mov di,3520
downbound:
mov word[Boundary+bx],di
add di,2
add bx,2
loop downbound

mov cx,4
mov di,510
hurdle1:
mov word[Boundary+bx],di
add di,2
add bx,2
loop hurdle1

mov cx,4
mov di,600
hurdle2:
mov word[Boundary+bx],di
add di,2
add bx,2
loop hurdle2

mov cx,4
mov di,3070
hurdle3:
mov word[Boundary+bx],di
add di,2
add bx,2
loop hurdle3

mov cx,4
mov di,3160
hurdle4:
mov word[Boundary+bx],di
add di,2
add bx,2
loop hurdle4



popa
pop bp
ret


drawboundary:
push bp
mov bp,sp
pusha

push 0xb800                      ;printing boundary on screen from array
pop es
mov bx,0
mov cx,222

printboundary:
mov di,[Boundary+bx]
mov word[es:di],0x6320
add bx,2
loop printboundary


popa
pop bp
ret




startsnake:
mov word[SnakeLength],20
push bp
mov bp,sp
pusha

mov bx,0                          ;initialize the snake to first 20 characters for start of game
mov di,2170

mov cx,20

initializesnake:
mov [Snake+bx],di
add bx,2
sub di,2
loop initializesnake

popa
pop bp
ret



clrscr:			
pusha
push es

mov ax, 0xb800
mov es, ax
xor di,di
mov ax,0x0720
mov cx,2000

cld
rep stosw
			
pop es
popa
ret

drawsnake:
push bp
mov bp,sp
pusha

push 0xb800
pop es
mov cx,[SnakeLength]
mov di,[Snake]
mov bx,2                           ;print snake on screen using array of snake


mov word[es:di],0x4520
sub cx,1

mov di,[Snake+bx]

printsnake:
mov word[es:di],0x1820
add bx,2
mov di,[Snake+bx]
loop printsnake



popa
pop bp
ret

movesnake:
push bp
mov bp,sp
pusha

mov cx,[SnakeLength]
sub cx,1
mov ax,cx
mov bx,2
mul bx
mov bx,ax
mov di,[Snake+bx]                 ;depending upon movement shift the snake all array to new locations and put a blank at tail

push 0xb800
pop es
mov word[es:di],0x0720

mov ax,[movement]
cmp ax,0
je movedown
cmp ax,1
je moveup
cmp ax,2
je moveleft
cmp ax,3
je moveright

movedown:
mov cx,[SnakeLength]
sub cx,1
mov ax,cx
mov bx,2
mul bx
mov bx,ax

downlogic:
mov ax,[Snake+bx-2]
mov [Snake+bx],ax
sub bx,2
loop downlogic

add word[Snake],160
jmp stopmove



moveup:
mov cx,[SnakeLength]
sub cx,1
mov ax,cx
mov bx,2
mul bx
mov bx,ax


uplogic:
mov ax,[Snake+bx-2]
mov [Snake+bx],ax
sub bx,2
loop uplogic

sub word[Snake],160
jmp stopmove

moveleft:
mov cx,[SnakeLength]
sub cx,1
mov ax,cx
mov bx,2
mul bx
mov bx,ax


leftlogic:
mov ax,[Snake+bx-2]
mov [Snake+bx],ax
sub bx,2
loop leftlogic

sub word[Snake],2
jmp stopmove

moveright:
mov cx,[SnakeLength]
sub cx,1
mov ax,cx
mov bx,2
mul bx
mov bx,ax


rightlogic:
mov ax,[Snake+bx-2]
mov [Snake+bx],ax
sub bx,2
loop rightlogic

add word[Snake],2
jmp stopmove

stopmove:
popa
pop bp
ret




kbisr:	
pusha
push cs
pop ds

in al, 0x60
cmp al,0x4B                        ;check key press and set the movement variable
je movementleft
cmp al,0x4D
je movementright
cmp al,0x48
je movementup
cmp al,0x50
je movementdown

stopkbisr:
mov al, 0x20
out 0x20, al
popa
iret

movementleft:
cmp word[movement],3
je stopkbisr
mov word[movement],2
jmp  stopkbisr

movementright:
cmp word[movement],2
je stopkbisr
mov word[movement],3
jmp  stopkbisr

movementup:
cmp word[movement],0
je stopkbisr
mov word[movement],1
jmp  stopkbisr

movementdown:
cmp word[movement],1
je stopkbisr
mov word[movement],0
jmp  stopkbisr


timerisr:
pusha
push cs
pop ds


mov ax,[speed]
cmp ax,[timercount]                ;in timer isr call all the function according to speed
jne speednotreached
mov word[timercount],0
call putfood
call movesnake
call drawsnake
call checkheadandfood
call drawboundary
call showstats
push 0
call headcheck
pop ax
cmp ax,1
je headbite
call winnercheck


speednotreached:
cmp word[speed],0                ;check if speed is  not zero the increase tickcount
jne increasespeedtimer
continuetimer:
cmp word[timertick],18          ;if its one second past then manage the time variables
je timemanagement
inc word[timertick]

stoptimer:
mov al,0x20
out 0x20,al
popa
iret

increasespeedtimer:
inc word[timercount]
jmp continuetimer

timemanagement:
dec word[seconds]
cmp word[seconds],0               ;manages the seconds and minutes variable
jne normal
cmp word[minutes],0
je notnormal

normal:
mov word[timertick],0
cmp word[seconds],0
je resetseconds
jmp stoptimer

resetseconds:
call settlespeed                 ;when one minute is passed half the speed and manages seconds
dec word[minutes]
mov word[seconds],60
jmp stoptimer

notnormal:
inc word[lifelost]
cmp word[lifelost],3            ;if 4 minutes passed user loose one life
je gameendaslooser
call initializetimer
jmp stoptimer


headbite:
call soundfunction1
mov word[movement],3
inc word[lifelost]            ;when head touces snake or boundary, one life lost and reset the snake if lives are available
cmp word[lifelost],3
je gameendaslooser
call clrscr
call startsnake
;call initializetimer
jmp stoptimer


gameendaslooser:
call clrscr
push 2150
push loosermsg                     ;display loosing message
push word[lengthloosermsg]
call printstr

infinite:
jmp infinite





start:

call clrscr
call startsnake
call drawsnake
call BoundaryInitialize
call drawboundary
call putfood


xor ax, ax
mov es, ax



cli
mov word[es:0x8*4], timerisr
mov word[es:0x8*4 + 2], cs           ;hooking
mov word[es:0x9*4], kbisr
mov word[es:0x9*4 + 2], cs
sti




mov ax,0x4c00
int 21h

