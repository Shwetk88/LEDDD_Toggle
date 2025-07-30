# =============================================================================
# Makefile for STM32H563xx Project (LED_Toggle)
# =============================================================================

# --- Toolchain Definitions ---
# Define the prefix for your ARM GCC toolchain
PREFIX = arm-none-eabi-

# Define the actual compiler, linker, etc.
CC = $(PREFIX)gcc
AS = $(PREFIX)as
OBJCOPY = $(PREFIX)objcopy
OBJDUMP = $(PREFIX)objdump
SIZE = $(PREFIX)size

# --- Project Definitions ---
# The name of your final output files (without extension)
TARGET = LED_Toggle
# The directory where build output will be placed
BUILD_DIR = build

# --- Compiler and Linker Flags ---
# CPU specific flags
CPU = -mcpu=cortex-m33
MCU = $(CPU) -mthumb

# C compiler flags
# -Wall: Show all warnings
# -O0: No optimization (best for debugging)
# -g: Generate debugging information
# -std=c11: Use the C11 standard
# -DSTM32H563xx: Define the device macro
CFLAGS = $(MCU) -Wall -O0 -g -std=c11 -DSTM32H563xx

# Include directories for header files (-I)
C_INCLUDES = -I./Core/Inc \
             -I./Drivers/CMSIS/Include \
             -I./Drivers/CMSIS/Device/ST/STM32H5xx/Include \
             -I./Drivers/STM32H5xx_HAL_Driver/Inc

# Add includes to the CFLAGS
CFLAGS += $(C_INCLUDES)

# Linker flags
# -T: Specify the linker script
LDFLAGS = $(MCU) -TSTM32H563ZITX_FLASH.ld

# --- Source Files ---
# List all of your C source (.c) files here
C_SOURCES = Core/Src/main.c \
            Core/Src/stm32h5xx_it.c \
            Core/Src/system_stm32h5xx.c \
            Core/Src/stm32h5xx_hal_msp.c \
            Core/Src/syscalls.c \
            Core/Src/sysmem.c \
            Drivers/STM32H5xx_HAL_Driver/Src/stm32h5xx_hal.c \
            Drivers/STM32H5xx_HAL_Driver/Src/stm32h5xx_hal_cortex.c \
            Drivers/STM32H5xx_HAL_Driver/Src/stm32h5xx_hal_dma.c \
            Drivers/STM32H5xx_HAL_Driver/Src/stm32h5xx_hal_dma_ex.c \
            Drivers/STM32H5xx_HAL_Driver/Src/stm32h5xx_hal_exti.c \
            Drivers/STM32H5xx_HAL_Driver/Src/stm32h5xx_hal_flash.c \
            Drivers/STM32H5xx_HAL_Driver/Src/stm32h5xx_hal_flash_ex.c \
            Drivers/STM32H5xx_HAL_Driver/Src/stm32h5xx_hal_gpio.c \
            Drivers/STM32H5xx_HAL_Driver/Src/stm32h5xx_hal_pwr.c \
            Drivers/STM32H5xx_HAL_Driver/Src/stm32h5xx_hal_pwr_ex.c \
            Drivers/STM32H5xx_HAL_Driver/Src/stm32h5xx_hal_rcc.c \
            Drivers/STM32H5xx_HAL_Driver/Src/stm32h5xx_hal_rcc_ex.c

# List all of your Assembly source (.s) files here
ASM_SOURCES = Core/Startup/startup_stm32h563zitx.s

# --- Build Rules ---
# Automatically create a list of object files (.o) from the source files
OBJECTS = $(addprefix $(BUILD_DIR)/,$(notdir $(C_SOURCES:.c=.o)))
vpath %.c $(sort $(dir $(C_SOURCES)))

OBJECTS += $(addprefix $(BUILD_DIR)/,$(notdir $(ASM_SOURCES:.s=.o)))
vpath %.s $(sort $(dir $(ASM_SOURCES)))

# The default rule, executed when you just run "make"
all: $(BUILD_DIR)/$(TARGET).elf

# Rule to link the final .elf file from all the object files
$(BUILD_DIR)/$(TARGET).elf: $(OBJECTS)
	$(CC) $(OBJECTS) $(LDFLAGS) -o $@
	@echo "----------------"
	@echo "ELF file created: $@"
	$(SIZE) $@
	@echo "----------------"

# Rule to compile .c files into .o object files
$(BUILD_DIR)/%.o: %.c | $(BUILD_DIR)
	$(CC) -c $(CFLAGS) -o $@ $<

# Rule to assemble .s files into .o object files
$(BUILD_DIR)/%.o: %.s | $(BUILD_DIR)
	$(CC) -c $(CFLAGS) -o $@ $<

# Rule to create the build directory
$(BUILD_DIR):
	mkdir -p $@

# --- Clean Rule ---
# Rule to remove all build artifacts
clean:
	rm -rf $(BUILD_DIR)
	@echo "Build directory cleaned."

# --- Phony Targets ---
# Tells make that "all" and "clean" are not actual files
.PHONY: all clean
