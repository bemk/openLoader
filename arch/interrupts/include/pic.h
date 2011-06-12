/*
 *   PIC header
 *   Copyright (C) 2011  Michel Megens
 *
 *   This program is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <sys/stdlib.h>

#ifndef __H_PIC
void pic_remap(uint32_t set1, uint32_t set2);
void pic_init();

#define GEBL_PIC1_COMMAND 0x20
#define GEBL_PIC2_COMMAND 0x21

#define GEBL_PIC1_DATA 0xa0
#define GEBL_PIC2_DATA 0xa1
#endif