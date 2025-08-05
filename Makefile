# =============================================================================
# Makefile for STM32H563xx Project (LED_Toggle)
# =============================================================================

# --- Toolchain Definitions ---
PREFIX = arm-none-eabi-
CC = $(PREFIX)gcc
OBJCOPY = $(PREFIX)objcopy
SIZE = $(PREFIX)size

# --- Project Definitions ---
TARGET = LED_Toggle
BUILD_DIR = build

# --- Compiler and Linker Flags ---
CPU = -mcpu=cortex-m33
MCU = $(CPU) -mthumb
CFLAGS = $(MCU) -Wall -O0 -g -std=c11 -DSTM32H563xx
C_INCLUDES = -I./Core/Inc \
             -I./Drivers/CMSIS/Include \
             -I./Drivers/CMSIS/Device/ST/STM32H5xx/Include \
             -I./Drivers/STM32H5xx_HAL_Driver/Inc
CFLAGS += $(C_INCLUDES)

# MODIFIED: Added the linker flag to generate a .map file
LDFLAGS = $(MCU) -TSTM32H563ZITX_FLASH.ld -Wl,-Map=$(BUILD_DIR)/$(TARGET).map

# --- Source Files ---
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
ASM_SOURCES = Core/Startup/startup_stm32h563zitx.s

# --- Build Rules ---
OBJECTS = $(addprefix $(BUILD_DIR)/,$(notdir $(C_SOURCES:.c=.o)))
vpath %.c $(sort $(dir $(C_SOURCES)))
OBJECTS += $(addprefix $(BUILD_DIR)/,$(notdir $(ASM_SOURCES:.s=.o)))
vpath %.s $(sort $(dir $(ASM_SOURCES)))

all: $(BUILD_DIR)/$(TARGET).elf $(BUILD_DIR)/$(TARGET).hex

$(BUILD_DIR)/$(TARGET).elf: $(OBJECTS)
	$(CC) $(OBJECTS) $(LDFLAGS) -o $@
	@echo "----------------"
	@echo "ELF file created: $@"
	$(SIZE) $@
	@echo "----------------"

$(BUILD_DIR)/$(TARGET).hex: $(BUILD_DIR)/$(TARGET).elf
	$(OBJCOPY) -O ihex $< $@
	@echo "HEX file created: $@"

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
