# UART Communication Protocol – Verilog

A Verilog-based implementation of the **Universal Asynchronous Receiver-Transmitter (UART)** communication protocol, including RTL design, simulation, functional verification, and loopback testing.

##  Project Overview

UART is a widely used asynchronous serial communication protocol for transferring data between digital systems.

This project implements UART **transmitter (TX)** and **receiver (RX)** modules using Verilog HDL and verifies their operation through dedicated testbenches and simulation.

The project also includes a **UART loopback test**, where transmitted data is directly fed back to the receiver to verify end-to-end communication.

##  Objectives

* Design a UART transmitter using Verilog HDL.
* Design a UART receiver using Verilog HDL.
* Implement UART serial data transmission and reception.
* Verify TX and RX functionality using simulation.
* Perform UART loopback testing.
* Analyze simulation waveforms using GTKWave.
* Maintain the complete RTL and verification environment using Git/GitHub.

##  UART Frame Format

The UART frame used in this project consists of:

```text
Idle | Start | Data Bits | Stop
  1  |   0   |  8 bits   |  1
```

The communication is asynchronous, meaning no separate clock signal is transmitted along with the data.

## Project Architecture

```text
             ┌─────────────────┐
             │   UART TX       │
             │  Verilog RTL    │
             └────────┬────────┘
                      │
                      │ Serial Data
                      ▼
             ┌─────────────────┐
             │   UART RX       │
             │  Verilog RTL    │
             └────────┬────────┘
                      │
                      ▼
                Received Data
```

### Loopback Verification

```text
        ┌──────────┐
        │ UART TX  │
        └────┬─────┘
             │
             │ tx_serial
             ▼
        ┌──────────┐
        │ UART RX  │
        └────┬─────┘
             │
             ▼
        rx_data / rx_valid
```

##  Repository Structure

```text
UART-Communication-Protocol-Verilog/
│
├── rtl/
│   ├── uart_tx.v
│   └── uart_rx.v
│
├── tb/
│   ├── uart_tx_tb.v
│   ├── uart_rx_tb.v
│   ├── uart_loopback_tb.v
│   └── uart_simulation_tb.v
│
├── simulation/
│   ├── uart_tx.vcd
│   ├── uart_tx.vvp
│   ├── uart_rx.vcd
│   ├── uart_rx.vvp
│   ├── uart_simulation.vcd
│   └── uart_simulation.vvp
│
├── .gitignore
├── LICENSE
└── README.md
```

##  Verification

The design is verified using multiple testbenches:

### UART Transmitter

The TX testbench verifies serial transmission of data according to the configured UART frame format.

### UART Receiver

The RX testbench verifies correct detection of:

* Start bit
* Data bits
* Stop bit
* Received byte
* `rx_valid` indication

### UART Loopback

The loopback test connects the transmitter output directly to the receiver input:

```text
TX → Serial Line → RX
```

This verifies the complete transmit-and-receive path.

## Simulation

The project uses **Icarus Verilog** for compilation and simulation.

Example TX simulation:

```bash
iverilog -o simulation/uart_tx.vvp rtl/uart_tx.v tb/uart_tx_tb.v
vvp simulation/uart_tx.vvp
```

Example RX simulation:

```bash
iverilog -o simulation/uart_rx.vvp rtl/uart_rx.v tb/uart_rx_tb.v
vvp simulation/uart_rx.vvp
```

The generated `.vcd` files can be opened using **GTKWave**:

```bash
gtkwave simulation/uart_tx.vcd
```

or:

```bash
gtkwave simulation/uart_rx.vcd
```

##  Verification Result

The UART receiver was successfully verified by transmitting the ASCII character:

```text
A = 0x41
```

The simulation confirmed successful reception of the expected data.

The loopback testbench provides additional end-to-end verification of the UART communication path.

## Tools & Technologies

| Category                | Technology     |
| ----------------------- | -------------- |
| HDL                     | Verilog        |
| Simulation              | Icarus Verilog |
| Waveform Analysis       | GTKWave        |
| Version Control         | Git            |
| Repository              | GitHub         |
| Development Environment | MSYS2 UCRT64   |

## Concepts Demonstrated

* RTL Design
* Finite State Machines
* Serial Communication
* UART Protocol
* Clock and Baud-Rate Handling
* Digital System Verification
* Testbench Development
* Waveform Analysis
* Loopback Testing
* Git/GitHub Workflow

## Future Enhancements

Possible extensions include:

* Configurable baud rate
* Configurable data width
* Parity-bit support
* Multiple stop-bit configurations
* FIFO-based buffering
* Error detection and reporting
* FPGA hardware implementation
* Formal verification

## Author

**Vemuri Vidhya Madhavi**

Electronics and Communication Engineering
Interested in VLSI, Digital Design, Verilog, and Embedded Systems.

## License

This project is licensed under the terms provided in the repository's `LICENSE` file.
