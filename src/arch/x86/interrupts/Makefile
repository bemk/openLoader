# compliler shizle
AS=nasm
ASFLAGS=-felf32 -I"../../../include/" $(FLAGS)
CC=gcc
CCFLAGS=-I"../../../include/" -c -m32 -nostdlib -nodefaultlibs -fno-stack-protector -fno-builtin -nostdinc $(FLAGS)

# targets
IDT=idt.o
IDT2=idt2.o
IRQ=irq.o
IRQ2=irq2.o
ISR=isr.o
ISR2=isr2.o
PIC=pic.o
PIT=pit.o

# sources

IDT_SRC=idt.asm
IDT2_SRC=idt.c
IRQ_SRC=irq.asm
IRQ2_SRC=irq.c
ISR_SRC=isr.asm
ISR2_SRC=isr.c
PIC_SRC=pic.c
PIT_SRC=pit.asm


.PHONY: all
all: $(IDT) $(IDT2) $(IRQ) $(IRQ2) $(ISR) $(ISR2) $(PIC) $(PIT)

$(IDT): $(IDT_SRC)
	$(AS) $(ASFLAGS) $(IDT_SRC) -o $(IDT)

$(IDT2): $(IDT2_SRC)
	$(CC) $(CCFLAGS) $(IDT2_SRC) -o $(IDT2)

$(IRQ): $(IRQ_SRC)
	$(AS) $(ASFLAGS) $(IRQ_SRC) -o $(IRQ)

$(IRQ2): $(IRQ2_SRC)
	$(CC) $(CCFLAGS) $(IRQ2_SRC) -o $(IRQ2)

$(ISR): $(ISR_SRC)
	$(AS) $(ASFLAGS) $(ISR_SRC) -o $(ISR)

$(ISR2): $(ISR2_SRC)
	$(CC) $(CCFLAGS) $(ISR2_SRC) -o $(ISR2)

$(PIC): $(PIC_SRC)
	$(CC) $(CCFLAGS) $(PIC_SRC) -o $(PIC)

$(PIT): $(PIT_SRC)
	$(AS) $(ASFLAGS) $(PIT_SRC) -o $(PIT)

.PHONY: clean
clean:
	rm -v *.o
