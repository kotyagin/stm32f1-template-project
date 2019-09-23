# General Target Settings
TARGET = stm32f1-template-project
SRCS = main.c

# Toolchain & Utils
CC		= arm-none-eabi-gcc
OBJCOPY = arm-none-eabi-objcopy
SIZE 	= arm-none-eabi-size
STFLASH	= st-flash
STUTIL	= st-util
OPENOCD	= openocd

# STM32Cube Path
STM32CUBE 		= ${STM32CUBE_PATH}
STM32_STARTUP 	= $(STM32CUBE)/Drivers/CMSIS/Device/ST/STM32F1xx/Source/Templates/gcc/startup_stm32f103xb.s
STM32_SYSINIT	= $(STM32CUBE)/Drivers/CMSIS/Device/ST/STM32F1xx/Source/Templates/system_stm32f1xx.c
STM32_LDSCRIPT 	= $(STM32CUBE)/Drivers/CMSIS/Device/ST/STM32F1xx/Source/Templates/gcc/linker/STM32F103XB_FLASH.ld

STM32_INCLUDES	+= -I$(STM32CUBE)/Drivers/CMSIS/Core/Include
STM32_INCLUDES	+= -I$(STM32CUBE)/Drivers/CMSIS/Core_A/Include
STM32_INCLUDES	+= -I$(STM32CUBE)/Drivers/CMSIS/Device/ST/STM32F1xx/Include

CFLAGS_DEFINES = -DSTM32F103xB
CFLAGS_CPUFLAGS = -mthumb -mcpu=cortex-m3
CFLAGS_WARNINGS = -Wall -pedantic
CFLAGS_OPTIMIZATION = -O3
CFLAGS_DEBUG = -ggdb
CFLAGS = $(CFLAGS_DEFINES) $(STM32_INCLUDES) $(CFLAGS_CPUFLAGS) $(CFLAGS_WARNINGS) $(CFLAGS_OPTIMIZATION) $(CFLAGS_DEBUG) 

LDFLAGS = -T$(STM32_LDSCRIPT) --specs=nosys.specs

OBJS = $(SRCS:.c=.o) $(STM32_SYSINIT:.c=.o) $(STM32_STARTUP:.s=.o)

all: $(TARGET).hex size

$(TARGET).hex: $(TARGET).elf
	@$(OBJCOPY) -Oihex $(TARGET).elf $(TARGET).hex

$(TARGET).elf: $(OBJS)
	@$(CC) $(LDFLAGS) $^ -o $@

%.o: %.c
	@$(CC) $(CFLAGS) -c $< -o $@

%.o: %.s
	@$(CC) $(AFLAGS) -c $< -o $@

.PHONY: flash
flash: all
	@$(STFLASH) --format ihex write $(TARGET).hex

.PHONY: size
size:
	@$(SIZE) $(TARGET).elf

.PHONY: clean
clean:
	rm -f $(OBJS)
