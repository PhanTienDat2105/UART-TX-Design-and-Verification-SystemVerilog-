# UART Transmitter (UART TX) in SystemVerilog

This project implements a basic UART Transmitter using SystemVerilog. Accompanying the RTL source code is an Object-Oriented Programming (OOP) based verification environment (Testbench) utilizing randomization, mailboxes, and automated checkers with SystemVerilog Assertions (SVA).

## 🚀 Key Features

* **Transmission Protocol:** 1 Start bit (Logic 0), 8 Data bits, 1 Stop bit (Logic 1), No Parity bit.
* **FSM Design:** Finite State Machine with 4 distinct states (IDLE, START, DATA, STOP).
* **Control Signals:** Includes a `busy` flag to indicate active data transmission, preventing data overwrite before the current transaction completes.
* **Testbench Environment (Verification):**
    * Utilizes a Class-based (OOP) architecture to generate stimulus.
    * Uses a `mailbox` for seamless communication between the `generator` and `driver`.
    * Implements constraint-driven randomization to generate test data.
* **SystemVerilog Assertions (SVA):** Integrates concurrent assertions to continuously monitor and verify UART protocol integrity during simulation.

## 📐 I/O Port Description

| Port Name | Direction | Width | Description |
| :--- | :---: | :---: | :--- |
| `clk` | Input | 1 bit | System Clock |
| `rst` | Input | 1 bit | Active-High Reset signal |
| `data_in` | Input | 8 bits | Parallel input data to be transmitted |
| `valid` | Input | 1 bit | Asserts that `data_in` is valid to initiate transmission |
| `tx` | Output | 1 bit | Serial transmission line |
| `busy` | Output | 1 bit | Busy flag (1 = transmitting, 0 = idle) |

## 🧠 Finite State Machine (FSM) Design

The module operates based on a 4-state FSM:
1.  **IDLE:** The standby state. The `tx` line is held high (1). When `valid` goes high, it transitions to START.
2.  **START:** Initiates the transmission frame. The `tx` line is pulled low (0) for one clock cycle.
3.  **DATA:** Shifts and transmits the 8 data bits sequentially from LSB to MSB.
4.  **STOP:** Concludes the transmission frame. The `tx` line is pulled high (1). The FSM then returns to IDLE.

## 🧪 Testbench & Assertions

The testbench is robustly designed with an OOP architecture and Mailboxes:
* `uart_txn`: A transaction class containing randomized data.
* `generator`: A class that generates random data packets and pushes them into the mailbox.
* `driver`: A task that fetches transactions from the mailbox and drives the signals into the DUT (Design Under Test).

**SystemVerilog Assertions (SVA) included for automated error checking:**
* `p_idle_tx_high`: Ensures that when the system is not busy (`!busy`), the `tx` line remains high (Idle state).
* `p_valid_to_busy`: Verifies that the `valid` signal successfully triggers the `busy` flag on the next clock cycle.
* `p_start_bit`: Ensures that exactly when transmission begins (as `busy` transitions from 0 to 1), the START bit (`tx` = 0) is driven.
* `p_transmission_finish`: Guarantees that the transmission does not hang (timeout) and concludes (busy drops to 0) within a specified timeframe after a `valid` signal.

## 📈 Simulation Waveform
<img width="1567" height="381" alt="image" src="https://github.com/user-attachments/assets/5aa610e3-362f-47e9-b842-71f8249be865" />

<img width="1623" height="423" alt="image" src="https://github.com/user-attachments/assets/c2a160f4-b30e-4e82-8ec0-67e21bcb64e2" />

