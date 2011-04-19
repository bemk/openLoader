;
;    Test the drive. Is it ready to read an image from?
;    Copyright (C) 2011 Michel Megens
;
;    This program is free software: you can redistribute it and/or modify
;    it under the terms of the GNU General Public License as published by
;    the Free Software Foundation, either version 3 of the License, or
;    (at your option) any later version.
;
;    This program is distributed in the hope that it will be useful,
;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;    GNU General Public License for more details.
;
;    You should have received a copy of the GNU General Public License
;    along with this program.  If not, see <http://www.gnu.org/licenses/>.
;

;
; Usage:
; mov dx, <drive>
; call resetdrive
;
resetdrive:
	mov cx, 5

.start:
	xor ah, ah ; function 0 = reset
	mov dl, 0x80 ;pop dx ; drive 0 = floppy
	int 0x13
	jnc .loadimage

	dec cx
	cmp cx, 0x0
	jne .start

.fail: ; failed to load, error code in al
	mov al, 0x01
	ret

.loadimage:
	mov ax, 0x1
	mov es, ax
	mov bx, 0x1000

.startload:
	mov		ah, 0x02				; function 2
	mov		al, 1					; read 1 sector
	mov		ch, 1					; we are reading the second sector past us, so its still on track 1
	mov		cl, 2					; sector to read (The second sector)
	mov		dh, 0					; head number
	mov		dl, 0x80					; drive number. Remember Drive 0 is floppy drive.
	int		0x13					; call BIOS - Read the sector
;	jc		.loadimage
	ret