# =============================================================================
# Minimal & Automated Makefile for STM32 Projects
# =============================================================================

# --- Toolchain & Project Definitions ---
PREFIX      = arm-none-eabi-
CC          = $(PREFIX)gcc
SIZE        = $(PREFIX)size
TARGET      = LED_Toggle
BUILD_DIR   = build

# --- Compiler and Linker Flags ---
CPU         = -mcpu=cortex-m33
MCU         = $(CPU) -mthumb
CFLAGS      = $(MCU) -Wall -O0 -g -std=c11 -DSTM32H563xx
LDFLAGS     = $(MCU) -TSTM32H563ZITX_FLASH.ld

# --- AUTOMATICALLY FIND SOURCE FILES ---
# List all the directories that contain your source files
C_SRC_DIRS = Core/Src Drivers/STM32H5xx_HAL_Driver/Src
ASM_SRC_DIRS = Core/Startup

# Use the 'wildcard' function to find all .c and .s files in those directories
C_SOURCES = $(foreach dir,$(C_SRC_DIRS),$(wildcard $(dir)/*.c))
ASM_SOURCES = $(foreach dir,$(ASM_SRC_DIRS),$(wildcard $(dir)/*.s))

# --- AUTOMATICALLY FIND INCLUDE PATHS ---
# Automatically create a list of include paths from the source directories
C_INCLUDES = $(foreach dir,$(C_SRC_DIRS),-I$(dir))
C_INCLUDES += -I./Core/Inc \
              -I./Drivers/CMSIS/Include \
              -I./Drivers/CMSIS/Device/ST/STM32H5xx/Include \
              -I./Drivers/STM32H5xx_HAL_Driver/Inc

# Add includes to the CFLAGS
CFLAGS += $(C_INCLUDES)

# --- Build Rules (Now fully automated) ---
# Create a list of object files in the build directory
OBJECTS = $(patsubst %.c,$(BUILD_DIR)/%.o,$(notdir $(C_SOURCES)))
OBJECTS += $(patsubst %.s,$(BUILD_DIR)/%.o,$(notdir $(ASM_SOURCES)))

# Tell 'make' where to find the source files for the object files
vpath %.c $(sort $(dir $(C_SOURCES)))
vpath %.s $(sort $(dir $(ASM_SOURCES)))

# --- Targets ---
all: $(BUILD_DIR)/$(TARGET).elf

$(BUILD_DIR)/$(TARGET).elf: $(OBJECTS)
	$(CC) $^ $(LDFLAGS) -o $@
	@echo "----------------"
	@echo "ELF file created: $@"
	$(SIZE) $@
	@echo "----------------"

$(BUILD_DIR)/%.o: %.c | $(BUILD_DIR)
	$(CC) -c $(CFLAGS) -o $@ $<

$(BUILD_DIR)/%.o: %.s | $(BUILD_DIR)
	$(CC) -c $(CFLAGS) -o $@ $<

$(BUILD_DIR):
	mkdir -p $@

clean:
	rm -rf $(BUILD_DIR)
	@echo "Build directory cleaned."

.PHONY: all clean
