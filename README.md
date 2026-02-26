# Capstone Project

## Energy-Efficient Near-Memory Systolic Accelerator with On-Chip Weight Compression for Edge AI Applications


----------------------------------------------------------------------------------------------------------------

<details>
 <summary><b>
Week 1:</b> The functional simulation of the systolic core integrated with the weight matrix and SRAM was successfully completed.</summary>

## 1.Updates
## Current Progress

During this week, the functional simulation of the systolic core integrated with the weight matrix and SRAM was successfully completed. The proper multiply-accumulate operation of the 4x4 weight-stationary systolic Processing Element (PE) array was confirmed. The SRAM's compressed weights were successfully retrieved, decompressed, and streamed into the PEs. Simulation was used to validate the movement of activation data and partial sum propagation across the systolic array. The simulation results confirmed that the systolic core and memory subsystem interacted correctly by matching the predicted matrix multiplication outputs.

### Challenges Faced

Ensuring correct synchronization between SRAM read operations and systolic data flow was a key challenge. Handling timing alignment between weight decompression and PE loading required careful control logic. Debugging partial sum mismatches in early simulations also required detailed waveform analysis to verify data propagation across clock cycles.

### Next Steps

In the next phase, the focus will be on integrating the activation routing logic and output SRAM for complete end-to-end data flow. Additional test cases with larger matrices and different weight patterns will be simulated. Clock-gating techniques will also be explored to reduce power consumption in idle PEs.

## 2.Project Idea

The project focuses on designing a near-memory systolic accelerator optimized for energy-efficient edge-AI inference. By combining weight-stationary dataflow with on-chip INT8 weight compression and localized SRAM banks, the design significantly reduces memory bandwidth and power consumption. The accelerator is fully synthesizable and scalable, making it suitable for ASIC feasibility studies and FPGA prototyping.

## 3.Simulation/Schematic

<img width="932" height="281" alt="image" src="https://github.com/user-attachments/assets/244d9cfb-751c-4b5a-a628-aa23828eb0e5" />


<img width="982" height="520" alt="image" src="https://github.com/user-attachments/assets/d5f2143c-0b78-42e2-92ba-48f9afc0a62f" />


<img width="966" height="350" alt="image" src="https://github.com/user-attachments/assets/45a03b82-d3a8-46d4-93bf-2cea733a2df4" />

## 5.Analysis
Provide analysis or interpretation of results:

### Key Findings:
•	SRAM-integrated weight loading works correctly with systolic timing.


•	Weight-stationary dataflow minimizes repeated SRAM accesses.

### Insights / Learnings
•	Precise control of read-enable and load signals is critical for systolic correctness.


•	Early SRAM modelling simplifies later synthesis and integration.


•	Waveform-level debugging is essential for validating systolic architectures.

### Improvements / Modifications Needed
•	Add clock-gating for inactive PEs to reduce dynamic power.


•	Extend simulations to cover corner cases and stress conditions.

</details>

-----------------------------------------------------------------------------------------------------------------------------------------------------

<details>
 <summary><b>
Week 2:</b> The successful completion of the memory subsystems' integration with the compute logic.</summary>

## 1.Updates
## Current Progress

This week witnessed the successful completion of the memory subsystems' integration with the compute logic. To create exact control over the distribution and routing of input data, the Activation Buffer and Activation Router were combined. In order to verify accurate weight parameter retrieval and real-time decoding, the Compressed Weight SRAM and Decompressor were simultaneously connected to the system. To confirm matrix multiplication, functional simulations were run and the entire 4x4 systolic array was instantiated. The smooth data flow from the buffers and decompressors into the array was verified by these simulations, leading to successful multiply-accumulate operations and precise output generation that matched theoretical expectations.

### Challenges Faced

It was challenging to achieve exact synchronization between the Decompressor output and the Activation Router because pipeline stalls were occasionally caused by variable latency in the decompression logic. It took several iterations to control the handshake signals between the systolic array and the Activation Buffer so that no data was lost during backpressure events. Furthermore, it was difficult to identify the source of data mismatches during full 4x4 array simulation, requiring careful waveform analysis to differentiate between computation errors and routing errors within individual PEs.

### Next Steps

A top-level FSM will be implemented to coordinate the entire execution pipeline, from memory access to result writeback, in the subsequent phase, which focuses on full system bring-up. In order to improve power efficiency during idle cycles, design optimizations like clock-gating will be incorporated concurrently. After that, comprehensive functional testing will be used to confirm the system's robustness and make sure the hardware outputs precisely match the golden reference model.

## 2.Project Idea

The project focuses on designing a near-memory systolic accelerator optimized for energy-efficient edge-AI inference. By combining weight-stationary dataflow with on-chip INT8 weight compression and localized SRAM banks, the design significantly reduces memory bandwidth and power consumption. The accelerator is fully synthesizable and scalable, making it suitable for ASIC feasibility studies and FPGA prototyping.

## 3.Simulation/Schematic

<img width="932" height="495" alt="image" src="https://github.com/user-attachments/assets/f18a990d-8a8b-4a08-8e86-fc891bf6c09f" />


<img width="932" height="495" alt="image" src="https://github.com/user-attachments/assets/708ab595-1c14-4a75-a013-c12a45ce8c9c" />


<img width="930" height="387" alt="image" src="https://github.com/user-attachments/assets/97c6ef89-3294-4e3b-83b1-ac4bccb9d679" />

## 5.Analysis
Provide analysis or interpretation of results:

### Key Findings
•	Bandwidth Efficiency: The Compressed Weight SRAM reduced bandwidth usage while maintaining full throughput.


•	Data Integrity: Simulation confirmed bit-exact accuracy for partial sums propagating across all 16 PEs.


•	Synchronization: The memory subsystem successfully meets the strict timing "heartbeat" of the systolic array.


### Insights / Learnings
•	Pipeline Sensitivity: Even single-cycle mismatches in memory readout can severely disrupt weight-stationary flow.


•	Dynamic Routing: Dynamic flow control is essential; static scheduling cannot handle variable data delays effectively.


•	Modular Debugging: Isolating the memory and compute blocks for initial testing significantly accelerated the full integration.


### Improvements / Modifications Needed
•	Latency Masking: Implement pre-fetch buffers between the Decompressor and PEs to prevent array stalls.


•	Flow Control: Add robust "ready/valid" backpressure signals to the Activation Router to prevent data loss.


•	Control Logic: Refine the FSM state transitions to better handle corner cases in partial sum output.

</details>

--------------------------------------------------------------------------------------------------------------------------------------------------------------------

<details>
 <summary><b>
Week 3:</b> The successful completion of the finite state machine starts in the IDLE state, where it waits for a start signal.</summary>

## 1.Updates
## Current Progress

The finite state machine starts in the IDLE state, where it waits for a start signal. Upon receiving the start signal, the FSM transitions to the Fetch-addr state. In the Fetch-addr state, the address is prepared and the FSM immediately moves to the Fetch data state. During the Fetch data state, the weight data is loaded into weig_dat with a value of w32, and the activation register act_reg is updated with act_out. If the address value equals 4'd15, the FSM transitions to the Execute state; otherwise, it loops back to the Fetch-addr state to continue fetching data. In the Execute state, the computation is performed, and once execution is completed and the count reaches 7, the FSM transitions to the Capture state. The Capture state handles the capture of the execution results, after which the FSM moves to the Done state. Finally, in the Done state, the FSM returns to the IDLE state, where it waits for the next start signal.


<img width="468" height="850" alt="image" src="https://github.com/user-attachments/assets/8f9beaf3-8df9-4de9-b27d-d296c0e9dd9c" />


### Challenges

•	Timing Issue:
Maintaining proper timing between consecutive FSM states is challenging, as delays in data fetch or execution can lead to setup and hold time violations. Ensuring that register updates and state transitions occur within a single clock cycle requires careful timing analysis and synchronization.


•	Clock-Gating:
Implementing clock gating is challenging because improper gating can cause missed state transitions or incorrect data capture. The clock must be gated in a controlled manner to reduce power consumption while still guaranteeing that all critical FSM operations remain correctly synchronized with the system clock.

### Next Steps

•	Perform synthesis of the design using Cadence Genus to obtain a gate-level implementation.
•	Generate and analyze area, timing, and power (PPA) reports to evaluate design efficiency.
•	Prepare the final project report, presentation slides, detailed documentation, and benchmarking results for performance comparison and evaluation.

## Python Reference Model:

<img width="910" height="398" alt="image" src="https://github.com/user-attachments/assets/1036432a-67ec-4315-a40f-38f271314596" />


A Python-based golden reference model was developed to closely mirror the RTL datapath and provide a hardware-faithful validation platform. The model is entirely integer-based, implementing INT8 weight quantization with power-of-two layer scaling, INT32 intermediate computation, and INT64 accumulation, while deliberately avoiding floating-point arithmetic. Functional testing was carried out using real 4×4 integer matrices for activations and weights. For each test case, the model produced both a full-precision reference result and a quantized systolic result using INT8 weights, and these outputs were compared to measure numerical deviation across fixed layer scales of 1, 2, 4, 8, and 16 to study precision–efficiency trade-offs.
The results show that for a layer scale of 1, the quantized systolic output exactly matches the reference, confirming correct datapath functionality and FSM operation. As the layer scale increases, quantization introduces bounded and predictable error, clearly illustrating the expected accuracy versus memory-efficiency trade-off in near-memory INT8 architectures. These observations validate the architectural decision to store weights in INT8 format with near-memory expansion to INT32, demonstrating that reduced-precision memory can still support correct systolic computation while significantly reducing memory bandwidth. Overall, the Python model successfully completes the Week-3 system bring-up objective by enabling end-to-end functional verification of the proposed architecture.

## 2.Project Idea: 

The project focuses on designing a near-memory systolic accelerator optimized for energy-efficient edge-AI inference. By combining weight-stationary dataflow with on-chip INT8 weight compression and localized SRAM banks, the design significantly reduces memory bandwidth and power consumption. The accelerator is fully synthesizable and scalable, making it suitable for ASIC feasibility studies and FPGA prototyping.

## 3.Schematic/Simulations


<img width="932" height="495" alt="image" src="https://github.com/user-attachments/assets/20a19a1e-7c84-410a-aae5-d782eb50d7dd" />


<img width="932" height="495" alt="image" src="https://github.com/user-attachments/assets/fb8d491d-ee0c-4470-8b18-e969fff5d21e" />


<img width="930" height="387" alt="image" src="https://github.com/user-attachments/assets/3d79f4cf-2ca0-4238-afd8-780a8b77d328" />

## 4.Analysis

Provide analysis or interpretation of results:
### Key Findings

•	The FSM provides a clear and deterministic flow from data fetching to execution and completion.

•	Each state has a dedicated function, ensuring orderly sequencing and easy control.

•	Conditional transitions based on address and count guarantee correct execution timing.

### Insights / Learnings

•	Proper state separation simplifies complex control logic in digital systems.

•	FSM looping efficiently handles repeated data access operations.

•	Precise transition conditions are essential for reliable hardware behavior.

### Improvements / Modifications Needed

•	Parameterize fixed limits to improve flexibility and scalability.

•	Add error-handling or synchronization mechanisms for robustness.

•	Optimize performance by overlapping or pipelining operations.

</details>

----------------------------------------------------------------------------------------------------------------------------------------------------------------------

<details>
 <summary><b>
Week 4:</b> The successful completion of the Synthesis, with Cadence Genus, Generate area/timing/power reports</summary>

## Current Progress

Synthesizing a design with Cadence Genus involves a systematic progression from high-level RTL to a technology-mapped gate-level netlist, with each stage offering a deeper look into the physical feasibility of your hardware. Once you have loaded your technology libraries and RTL, the elaboration and syn_generic phases create a basic structure, but the true progress is measured after syn_map and syn_opt. By generating area, timing, and power reports at this stage, you gain a multi-dimensional view of your design's health: the timing report identifies critical paths and "slack" to ensure the logic functions at the required clock frequency, the area report tallies cell counts and total square microns to ensure the design fits the physical footprint, and the power report estimates the thermal and battery impact of both switching activity and leakage. Successfully synthesizing the design means balancing these three pillars—often referred to as PPA (Power, Performance, and Area)—to reach a point where timing is "closed" (zero or positive slack).


## Check_design

![WhatsApp Image 2026-02-07 at 3 27 07 PM](https://github.com/user-attachments/assets/b306c224-3c5e-43ad-af6f-e3f1e0fde26f)


## Synthesis

<img width="1280" height="702" alt="Screenshot from 2026-02-07 14-58-58" src="https://github.com/user-attachments/assets/ede7f152-1c6d-4860-807e-7f2949f6e148" />

</details>

---------------------------------------------------------------------------------------------
