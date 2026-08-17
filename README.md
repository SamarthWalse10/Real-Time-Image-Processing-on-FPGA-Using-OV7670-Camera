# Real-Time Image Processing on FPGA Using OV7670 Camera

## Project Overview
This repository contains a complete Register Transfer Level (RTL) implementation of a real-time image processing system deployed on a Nexys-4 DDR FPGA (Xilinx Artix-7). The system interfaces with an OV7670 camera module to capture 640x480 RGB444 video, processes the video stream through a hardware-accelerated 10-stage pipeline, and drives the output to a VGA monitor at a smooth 60 Frames Per Second (FPS). 

## Key Features
* **High-Resolution Real-Time Processing**: Achieves 640x480@60Hz video capture and display with minimal latency.
* **Hardware-Accelerated Computer Vision**: Implements convolution kernels and color space conversions entirely in hardware without the use of a soft-core processor.
* **Selectable Video Modes**: 
  * Raw RGB444 Passthrough
  * Grayscale Conversion
  * Sobel Edge Detection
  * Custom Kernel Sharpening
* **Dynamic Brightness Control**: Real-time pixel brightness adjustment using debounced FPGA push buttons.
* **Robust Clock Domain Crossing (CDC)**: Safely transfers video data between the 25 MHz camera domain and the 60 Hz VGA display domain using a dual-port BRAM buffer.

---

## System Architecture & Module Description

The system is highly modular, breaking down the complex task of video processing into distinct, specialized hardware blocks.

### 1. Top-Level Integration (`top.v`)
Acts as the central integration hub for the entire system. 
* Instantiates all sub-modules (camera capture, processing pipeline, BRAM, VGA controller).
* Manages clock domains, distributing the 25 MHz clock to both the camera logic and VGA logic.
* Routes user inputs (switches for mode selection, buttons for brightness control) to the processing pipeline.

### 2. Camera Configuration (`sccb_setup.v` & `sccb_write.v`)
The OV7670 requires specific register configurations to output the correct video format.
* Implements the I2C-like SCCB (Serial Camera Control Bus) protocol to initialize 75 camera registers at 400 kHz.
* Configures the camera for RGB444 mode, adjusts clock controls, and applies gamma settings.
* Utilizes a 3-phase write transmission cycle (Device Address, Register Address, Write Data).
* **Performance**: Completes the entire initialization sequence in just 2.625 ms (1,050 clock cycles).

### 3. Frame Capture (`ov7670_capture.v`)
Synchronizes with the camera's hardware signals to read incoming pixel data.
* Tracks the `VSYNC` (frame start) and `HREF` (row valid) signals.
* Captures 8-bit data chunks on the `PCLK` (pixel clock) edges during active `HREF` periods.
* Combines two consecutive 8-bit bytes into a single 12-bit RGB444 pixel (4 bits per color channel) and generates the corresponding write addresses for the memory buffer.

### 4. Memory Buffer (`bram_dual_port_12x307200.v`)
Handles the critical Clock Domain Crossing (CDC) between the input and output streams.
* Instantiates a dual-port Block RAM (BRAM) with 307,200 locations to store a full 640x480 frame.
* **Port A**: Written to by the camera capture module at 25 MHz.
* **Port B**: Read from by the VGA controller at 60 Hz.

### 5. VGA Controller (`vga_controller.v`)
Drives the external monitor using standard VGA timing protocols.
* Generates precise 640x480@60Hz timing signals based on a 25 MHz clock.
* Horizontal Timing: 800 total cycles (640 active, 16 front porch, 96 sync pulse, 48 back porch).
* Vertical Timing: 525 total lines (480 active, 10 front porch, 2 sync pulse, 33 back porch).
* Outputs `HSYNC`, `VSYNC`, and 12-bit RGB data to the monitor.

### 6. Support Modules (`clk_divider.v`, `debounce.v`, `line_buffer.v`)
* **`clk_divider.v`**: Derives the 25 MHz system clock from the Nexys-4's native 100 MHz oscillator.
* **`debounce.v`**: Filters mechanical bounce from physical button presses, enforcing a 20ms stabilization period before registering an input.
* **`line_buffer.v`**: Stores 3 consecutive rows of pixel data simultaneously, which is mathematically required to perform 3x3 matrix convolutions on the video stream.

---

## Image Processing Pipeline
The core of this project is the `rgb444_processing_pipelined_bram_linebuffer.v` module. To maintain a 60 FPS throughput, the mathematical operations are distributed across a deeply pipelined, 10-stage architecture.

### Pipeline Operations
1. **Dynamic Brightness Control**: Applies a signed offset to the raw R, G, and B channels before further processing, dynamically clamping values to prevent overflow/underflow.
2. **Grayscale Conversion**: Converts the 12-bit RGB data to luminance using fixed-point arithmetic:
   $Y = 0.299R + 0.587G + 0.114B$
3. **Sobel Edge Detection**: Utilizes 3x3 convolution kernels to approximate the derivative of the image, highlighting sharp intensity changes (edges).

   $$G_x = \begin{bmatrix} -1 & 0 & 1 \cr -2 & 0 & 2 \cr -1 & 0 & 1 \end{bmatrix}, G_y = \begin{bmatrix} -1 & -2 & -1 \cr 0 & 0 & 0 \cr 1 & 2 & 1 \end{bmatrix}$$
   
   The final gradient magnitude is computed as $G = \sqrt{G_x^2 + G_y^2}$ using a hardware lookup table (`sqrt_mem`) for the square root.

4. **Custom Sharpening**: Applies a spatial high-pass filter using a custom 3x3 kernel to enhance local contrast and sharpen the image.

   $$K = \begin{bmatrix} 0 & -1 & 0 \cr -1 & 5 & -1 \cr 0 & -1 & 0 \end{bmatrix}$$

---

## Synthesis & Implementation Results
The design was synthesized and implemented on the Xilinx Artix-7 (xc7a100t) FPGA using Xilinx Vivado. The highly pipelined architecture ensures minimal logic utilization while maintaining strict timing constraints for real-time video.

### Resource Utilization
| Resource | Used | Available | Utilization |
| :--- | :--- | :--- | :--- |
| **LUTs** | 1335 | 63,400 | 2.10% |
| **Flip-Flops** | 941 | 126,800 | 0.74% |
| **BRAM** | 124.5 | 135 | 92.22% |

*(Note: BRAM utilization is high due to the necessity of storing a full 640x480 frame on-chip for smooth cross-domain playback.)*

### Power Consumption
| Power Metric | Value (Watts) |
| :--- | :--- |
| **Total On-Chip Power** | 0.136 W |
| **Static Power** | 0.103 W |
| **Dynamic Power** | 0.033 W |

*(The system operates with extreme power efficiency, making it highly suitable for embedded vision and IoT applications.)*

---

## Results
*(Create an `images` folder in your repository, upload your exported frames from the report, and update the links below to display them).*

* **Raw RGB444 Frame:**
<img width="1310" height="780" alt="Screenshot 2026-08-18 024917" src="https://github.com/user-attachments/assets/fdb8948e-0644-4ebb-98e7-5fd9fd9aa728" />
&nbsp;

* **Processed Grayscale Frame:**
<img width="1373" height="818" alt="Screenshot 2026-08-18 025036" src="https://github.com/user-attachments/assets/902d1ed9-94a3-4ce2-9742-02a70865aedc" />
&nbsp;

* **Processed Sobel Edge Detected Frame:**
<img width="1309" height="777" alt="Screenshot 2026-08-18 024943" src="https://github.com/user-attachments/assets/916ac63f-cf5b-4530-8b59-83b97d01aee9" />
&nbsp;

* **Processed Sharpened Frame:**
<img width="1311" height="777" alt="Screenshot 2026-08-18 025008" src="https://github.com/user-attachments/assets/9fbf943a-b7b8-4c5e-bd38-a14c7f13baf4" />
&nbsp;


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
