.PHONY: clean, all

ASSRC = startup.S exceptions.S
ASOBJ = $(ASSRC:.S=.o)

CSRC = main.c interrupts.c timer.c
COBJ = $(CSRC:.c=.o)

APP = hw
EXEC = $(APP).out
BINARY = $(APP).bin

# Binary hex files in ihex format
INSTR_HEX = $(APP)_ts.hex
DATA_HEX = $(APP)_ds.hex
# Binary hex files in coffeehex format
INSTR_SIM_HEX = $(APP)_sim_ts.hex
DATA_SIM_HEX = $(APP)_sim_ds.hex

# Disassembly file
DUMPFILE = dump.S

CC = clang-coffee
LD = coffee-ld
GDB = coffee-gdb
OBJCOPY = coffee-objcopy
OBJDUMP = coffee-objdump

CFLAGS = -O0 -Wall -ffreestanding -DQEMU_VERSION -target coffee-tut-linux-gnu -c -g -integrated-as

LDSCRIPT = coffee.x
LIBRARIES =

QEMU = qemu-system-coffee
QEMU_FLAGS = -M petalogix-s3adsp1800 -m 128M -nographic
QEMU_LOG = qemu_log.txt

all:  $(INSTR_SIM_HEX) $(DATA_SIM_HEX) $(INSTR_HEX) $(DATA_HEX) $(BINARY)

run: $(BINARY)
	$(QEMU) -D $(QEMU_LOG) -d in_asm $(QEMU_FLAGS) -kernel $<

wait-debug: $(KERNEL)
	$(QEMU) $(QEMU_FLAGS) -kernel $< -S

debug: $(EXEC)
	$(GDB) -x gdb.script $<

$(INSTR_HEX): $(EXEC)
	$(OBJCOPY) --only-section=.text --adjust-vma -0x100000 -O ihex $< $@

$(DATA_HEX): $(EXEC)
	$(OBJCOPY) --only-section=.data -O ihex $< $@
	sed -i '/^:04000005/d' $@

$(INSTR_SIM_HEX): $(EXEC)
	$(OBJCOPY) --only-section=.text --adjust-vma -0x100000 -O coffeehex $< $@

$(DATA_SIM_HEX): $(EXEC)
	$(OBJCOPY) --only-section=.data -O coffeehex $< $@
	

$(BINARY): $(EXEC)
	$(OBJCOPY) -O binary $< $@

dump: $(EXEC)
	$(OBJDUMP) -S $< > $(DUMPFILE)


$(EXEC): $(ASOBJ) $(COBJ)
	$(LD) -T $(LDSCRIPT) -o $@ $^ $(LIBRARIES)

%.o: %.c
	$(CC) $(CFLAGS) -o $@ $<

%.o: %.S
	$(CC) $(CFLAGS) -o $@ $<

clean:
	rm -rf *.hex $(DUMPFILE) $(ASOBJ) $(COBJ) $(EXEC) $(BINARY) $(QEMU_LOG)
