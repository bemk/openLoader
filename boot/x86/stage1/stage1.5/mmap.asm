;
;    Get the system memory map from the bios and store it in a global constant.
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

%include "boot/mmap.h"

getmemorymap:
	mov ax, GEBL_MMAP_SEG
	mov es, ax
	xor di, di

	and eax, 0xffff
	shl eax, 4 ; eax * 16
	movzx ebx, di
	add eax, ebx
	mov [mmr], eax
jmp cmos
; 	
; The memory map returned from bios int 0xe820 is a complete system map, it will be given to the bootloader kernel for little editing
; 
mm_e820:
	push bp
	xor bp, bp ; entry counter
	mov eax, 0xe820
	xor ebx, ebx
	mov ecx, 0x18
	mov edx, GEBL_SMAP
	push edx
	mov [es:di+20], dword GEBL_ACPI ; acpi 3.x compatibility
	int 0x15
	pop edx	; restore magic number

	jc .failed
	cmp eax, edx ; magic word should also be in eax after interrupt
	jne .failed
	test ebx, ebx ; ebx = 0 means the list is only 1 entry long = worthless
	jz .failed
	jmp .addentry

.getentry:
	mov eax, 0xe820
	mov ecx, 0x18
	mov edx, GEBL_SMAP
	push edx
	mov [es:di+20], dword GEBL_ACPI
	int 0x15
	pop edx

	jc .done ; carriage means end of list
	cmp eax, edx
	jne .failed

.addentry:
	jcxz .skipentry ; entries with length 0 are compleet bullshit
	add di, 24
	inc bp

.skipentry:
	test ebx, ebx ;
	jnz .getentry

.done:
	mov [mmr+4], bp
	pop bp
	clc	; clear carry flag
	ret
.failed:
	pop bp
	jmp mm_e801
	stc
	ret

;
; This memory map will contain 4 entries. See doc/mmap.txt for more information.
;
mm_e801:
	xor di, di
	mov ax, GEBL_MMAP_SEG
	mov es, ax
	call lowmmap
	jc .failed
	push .midmem
	jmp .next

.midmem:
	mov ax, 0xe801
	int 0x15
	jc .failed
	push bx		; save bx and dx for the high mem entry
	push dx

	and ecx, 0xffff	; clear upper 16 bits
	shl ecx, 10
	mov [es:di], dword GEBL_EXT_BASE
	mov [es:di+8], ecx		;dword (0x3c00<<10)
	mov [es:di+16], byte GEBL_USABLE_MEM
	mov [es:di+20], byte GEBL_ACPI
	jecxz .useax
	push .highmem
	jmp .next
.useax:
	and eax, 0xffff
	shl eax, 10
	mov [es:di+8], eax
	push .highmem
	jmp .next

.highmem:
	pop dx
	pop bx

	and edx, 0xffff
	shl edx, 16	; edx * 1024 * 64
	mov [es:di], dword GEBL_HIGH_BASE
	mov [es:di+8], edx
	mov [es:di+16],	byte GEBL_USABLE_MEM	; type -> usable
	mov [es:di+20], byte GEBL_ACPI	; acpi 3.0 compatible

	test edx, edx	
	jz .usebx
	jmp .done

.usebx:
	and ebx, 0xffff
	shl ebx, 16
	test ebx, ebx
	jz .failed
	mov [es:di+8], ebx
	jmp .done
.next:
	add di, 0x18
	jmp copy_empty_entry

.failed:
	jmp mm_88
	stc
	ret

.done:
	mov [mmr+4], word 0x4	; 2x low mem + mid mem + high mem = 4 entries
	clc
	ret

; 
; This is a function from the dinosaur time, it it used on verry old PC's when all other methods to get a memory map fail. If this
; fails to, the bootloader will cry to the user, and tell him to buy a new pc.
; 
mm_88:
	xor di, di	; set segment:offset of the buffer, just to be sure
	mov ax, GEBL_MMAP_SEG
	mov es, ax

	call lowmmap	; get a lowmmap
	jc .failed
	push .highmem
	jmp .nxtentry
.highmem:
	mov ax, 0x8800
	int 0x15
	jc .failed
	and eax, 0xffff
	shl eax, 10

	mov [es:di], dword 0x00100000	; base
	mov [es:di+8], eax
	mov [es:di+16], dword GEBL_USABLE_MEM	; free memory
	mov [es:di+20], dword GEBL_ACPI	; acpi 3.0
	jmp .done

.nxtentry:
	add di, 0x18
	jmp copy_empty_entry

.failed:
	stc
	ret
.done:
	mov [mmr+4], word 0x3
	clc
	ret

cmos:
	xor di, di
	mov ax, GEBL_MMAP_SEG
	mov es, ax

	call lowmmap
	jc .failed
	push .highmem
	jmp .next

.highmem:
	mov al, GEBL_CMOS_LOW_ORDER_REGISTER
	out GEBL_CMOS_OUTPUT, al	; tell the cmos we want to read the high memory
	xor ax, ax
	in al, GEBL_CMOS_INPUT ; get the low bytes
	push ax

	mov al, GEBL_CMOS_HIGH_ORDER_REGISTER
	out GEBL_CMOS_OUTPUT, al
	xor ax, ax
	in al, GEBL_CMOS_INPUT

	pop dx
	shl ax, 8
	or ax, dx

	and eax, 0xffff
	shl eax, 10

	mov [es:di], dword 0x00100000	; base
	mov [es:di+8], eax
	mov [es:di+16], dword GEBL_USABLE_MEM	; free memory
	mov [es:di+20], dword GEBL_ACPI	; acpi 3.0
	jmp .done

.next:
	add di, 0x18
	jmp copy_empty_entry

.failed:
	stc
	ret
.done:
	mov [mmr+4], word 0x3
	clc
	ret

;
; This routine makes a memory map of the low memory (memory < 1M)
;
lowmmap:
; low available memory
	call copy_empty_entry
	xor ax, ax
	int 0x12	; get low memory size

	jc .failed	; if interrupt 0x12 is not support, its really really over..
	and eax, 0xffff	; clear upper 16  bits
	shl eax, 10	; convert to bytes
	push eax	; save for later
	mov [es:di], dword GEBL_LOW_BASE
	mov [es:di+8], eax
	mov [es:di+16], dword GEBL_USABLE_MEM
	mov [es:di+20], dword GEBL_ACPI	; acpi 3.0 compatible entry
	push .lowres
	add di, 0x18
	jmp copy_empty_entry

.lowres:
; low reserver memory
	pop eax
	and edx, 0xffff
	mov edx, (1 << 20)
	sub edx, eax

	mov [es:di], eax
	mov [es:di+8], edx	; length (in bytes)
	mov [es:di+16], dword GEBL_RESERVED_MEM	; reserverd memory
	mov [es:di+20], dword GEBL_ACPI		; also this entry is acpi 3.0 compatible
	jmp .done

.failed:
	stc
	ret
.done:
	clc
	ret

; 
; This routine copies an empty memory map to the location specified by es:di
; 
copy_empty_entry:	; this subroutine copies an emty memory map to the location specified by es:di
	cld	; just to be sure that di gets incremented
	mov si, mmap_entry
	mov cx, 0xc
	rep movsw	; copy copy copy!
	sub di, 0x18	; just to make addressing esier
	ret
; now there is an empty entry at [es:di]