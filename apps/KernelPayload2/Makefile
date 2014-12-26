CFLAGS = -T kernelpayload.ld -mthumb -DARM_MATH_CM4=true  -fdata-sections
#CFLAGS = -T kernelpayload.ld -mthumb -DARM_MATH_CM4=true  -fdata-sections -ffunction-sections -mlong-calls -g3 -mcpu=cortex-m4 -fno-strict-aliasing -std=gnu99 -ffunction-sections -fdata-sections -nostartfiles
CFLAGS += -ffunction-sections -mlong-calls -g3 -mcpu=cortex-m4 -fno-strict-aliasing
CFLAGS += -std=gnu99 -ffunction-sections -fdata-sections
CFLAGS += -nostartfiles
all:
#	arm-none-eabi-gcc -Wa,-a,-ad $(CFLAGS) main.c interface.c > main.lst
	arm-none-eabi-gcc -o main.elf $(CFLAGS) main.c interface.c
