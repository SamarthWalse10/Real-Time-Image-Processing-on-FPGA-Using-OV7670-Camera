# Real-Time Image Processing on FPGA Using OV7670 Camera[cite: 1, 4]

## Project Overview
This repository contains a complete Register Transfer Level (RTL) implementation of a real-time image processing system deployed on a Nexys-4 DDR FPGA (Xilinx Artix-7)[cite: 1, 4, 5]. The system interfaces with an OV7670 camera module to capture 640x480 RGB444 video, processes the video stream through a hardware-accelerated 10-stage pipeline, and drives the output to a VGA monitor at a smooth 60 Frames Per Second (FPS)[cite: 1, 4, 5, 11]. 

## Key Features
* **High-Resolution Real-Time Processing**: Achieves 640x480@60Hz video capture and display with minimal latency[cite: 1, 4, 5].
* **Hardware-Accelerated Computer Vision**: Implements convolution kernels and color space conversions entirely in hardware without the use of a soft-core processor[cite: 1, 4, 5, 11].
* **Selectable Video Modes**: 
  * Raw RGB444 Passthrough[cite: 1, 4, 11]
  * Grayscale Conversion[cite: 1, 4, 11]
  * Sobel Edge Detection[cite: 1, 4, 11]
  * Custom Kernel Sharpening[cite: 1, 4, 11]
* **Dynamic Brightness Control**: Real-time pixel brightness adjustment using debounced FPGA push buttons[cite: 1, 4, 11].
* **Robust Clock Domain Crossing (CDC)**: Safely transfers video data between the 25 MHz camera domain and the 60 Hz VGA display domain using a dual-port BRAM buffer[cite: 1, 4, 5].

---

## System Architecture & Module Description

The system is highly modular, breaking down the complex task of video processing into distinct, specialized hardware blocks.

### 1. Top-Level Integration (`top.v`)
Acts as the central integration hub for the entire system[cite: 1, 4]. 
* Instantiates all sub-modules (camera capture, processing pipeline, BRAM, VGA controller)[cite: 1, 4, 14].
* Manages clock domains, distributing the 25 MHz clock to both the camera logic and VGA logic[cite: 1, 4, 14].
* Routes user inputs (switches for mode selection, buttons for brightness control) to the processing pipeline[cite: 1, 4, 14].

### 2. Camera Configuration (`sccb_setup.v` & `sccb_write.v`)
The OV7670 requires specific register configurations to output the correct video format[cite: 4, 5].
* Implements the I²C-like SCCB (Serial Camera Control Bus) protocol to initialize 75 camera registers at 400 kHz[cite: 4, 5, 12, 13].
* Configures the camera for RGB444 mode, adjusts clock controls, and applies gamma settings[cite: 1, 4, 5, 12].
* Utilizes a 3-phase write transmission cycle (Device Address, Register Address, Write Data)[cite: 1, 5, 13].
* **Performance**: Completes the entire initialization sequence in just 2.625 ms (1,050 clock cycles)[cite: 1, 5].

### 3. Frame Capture (`ov7670_capture.v`)
Synchronizes with the camera's hardware signals to read incoming pixel data[cite: 4, 5, 10].
* Tracks the `VSYNC` (frame start) and `HREF` (row valid) signals[cite: 5, 10].
* Captures 8-bit data chunks on the `PCLK` (pixel clock) edges during active `HREF` periods[cite: 1, 5, 10].
* Combines two consecutive 8-bit bytes into a single 12-bit RGB444 pixel (4 bits per color channel) and generates the corresponding write addresses for the memory buffer[cite: 1, 4, 5, 10].

### 4. Memory Buffer (`bram_dual_port_12x307200.v`)
Handles the critical Clock Domain Crossing (CDC) between the input and output streams[cite: 1, 4, 5, 6].
* Instantiates a dual-port Block RAM (BRAM) with 307,200 locations to store a full 640x480 frame[cite: 1, 4, 5, 6].
* **Port A**: Written to by the camera capture module at 25 MHz[cite: 1, 4, 6].
* **Port B**: Read from by the VGA controller at 60 Hz[cite: 1, 4, 6].

### 5. VGA Controller (`vga_controller.v`)
Drives the external monitor using standard VGA timing protocols[cite: 4, 5, 15].
* Generates precise 640x480@60Hz timing signals based on a 25 MHz clock[cite: 1, 4, 5, 15].
* Horizontal Timing: 800 total cycles (640 active, 16 front porch, 96 sync pulse, 48 back porch)[cite: 1, 15].
* Vertical Timing: 525 total lines (480 active, 10 front porch, 2 sync pulse, 33 back porch)[cite: 1, 15].
* Outputs `HSYNC`, `VSYNC`, and 12-bit RGB data to the monitor[cite: 1, 4, 15].

### 6. Support Modules
* **`clk_divider.v`**: Derives the 25 MHz system clock from the Nexys-4's native 100 MHz oscillator[cite: 1, 4, 7].
* **`debounce.v`**: Filters mechanical bounce from physical button presses, enforcing a 20ms stabilization period before registering an input[cite: 1, 4, 8].
* **`line_buffer.v`**: Stores 3 consecutive rows of pixel data simultaneously, which is mathematically required to perform 3x3 matrix convolutions on the video stream[cite: 1, 4, 9].

---

## Image Processing Pipeline
The core of this project is the `rgb444_processing_pipelined_bram_linebuffer.v` module[cite: 1, 4, 11]. To maintain a 60 FPS throughput, the mathematical operations are distributed across a deeply pipelined, 10-stage architecture[cite: 1, 4, 11].

### Pipeline Operations
1. **Dynamic Brightness Control**: Applies a signed offset to the raw R, G, and B channels before further processing, dynamically clamping values to prevent overflow/underflow[cite: 1, 4, 11].
2. **Grayscale Conversion**: Converts the 12-bit RGB data to luminance using fixed-point arithmetic[cite: 1, 4, 5, 11]. 
   $$Y=0.299R+0.587G+0.114B$$
3. **Sobel Edge Detection**: Utilizes 3x3 convolution kernels to approximate the derivative of the image, highlighting sharp intensity changes (edges)[cite: 1, 4, 5, 11]. 
   $$G_x=\begin{bmatrix}-1&0&1\\-2&0&2\\-1&0&1\end{bmatrix}, G_y=\begin{bmatrix}-1&-2&-1\\0&0&0\\1&2&1\end{bmatrix}$$
   The final gradient magnitude is computed as $G=\sqrt{G_x^2+G_y^2}$ using a hardware lookup table (`sqrt_mem`) for the square root[cite: 5, 11].
4. **Custom Sharpening**: Applies a spatial high-pass filter using a custom 3x3 kernel to enhance local contrast and sharpen the image[cite: 1, 4, 5, 11].
   $$K=\begin{bmatrix}0&-1&0\\-1&5&-1\\0&-1&0\end{bmatrix}$$

---

## Synthesis & Implementation Results
The design was synthesized and implemented on the Xilinx Artix-7 (xc7a100t) FPGA using Xilinx Vivado[cite: 5]. The highly pipelined architecture ensures minimal logic utilization while maintaining strict timing constraints for real-time video[cite: 4, 5].

### Resource Utilization
| Resource | Used | Available | Utilization |
| :--- | :--- | :--- | :--- |
| **LUTs** | 1335 | 63,400 | 2.10% |
| **Flip-Flops** | 941 | 126,800 | 0.74% |
| **BRAM** | 124.5 | 135 | 92.22% |
*(Note: BRAM utilization is high due to the necessity of storing a full 640x480 frame on-chip for smooth cross-domain playback.)*[cite: 4, 5]

### Power Consumption
| Power Metric | Value (Watts) |
| :--- | :--- |
| **Total On-Chip Power** | 0.136 W |
| **Static Power** | 0.103 W |
| **Dynamic Power** | 0.033 W |
*(The system operates with extreme power efficiency, making it highly suitable for embedded vision and IoT applications.)*[cite: 4, 5]

---

## Repository Structure

```text
├── src/
│   ├── top.v                                            # Top-level integration
│   ├── sccb_setup.v / sccb_write.v                      # I2C/SCCB Camera Configuration
│   ├── ov7670_capture.v                                 # Frame capture & reconstruction
│   ├── rgb444_processing_pipelined_bram_linebuffer.v    # 10-stage processing pipeline
│   ├── bram_dual_port_12x307200.v                       # Dual-port frame buffer
│   ├── vga_controller.v                                 # VGA timing generation
│   ├── clk_divider.v                                    # Clock management
│   ├── debounce.v                                       # Push-button noise filtering
│   └── line_buffer.v                                    # Convolution row buffer
├── sim/
│   ├── top_tb.v                                         # Full system testbench
│   ├── sccb_setup_tb.v / sccb_write_tb.v                # Configuration testbenches
│   ├── ov7670_capture_tb.v                              # Capture logic testbench
│   ├── rgb444_processing_pipelined_tb.v                 # Pipeline and filter testbench
│   ├── bram_dual_port_12x307200_tb.v                    # Memory testbench
│   ├── vga_controller_tb.v                              # Timing testbench
│   ├── clk_divider_tb.v
│   ├── debounce_tb.v
│   └── line_buffer_tb.v
├── constraints/
│   └── Nexys-4-DDR-Master.xdc                           # Physical pin mappings
└── bitstream/
    └── Group_7_EE560_Bitstream.bit                      # Compiled bitstream for direct deployment
