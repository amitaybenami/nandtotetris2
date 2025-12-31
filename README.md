# Jack Compiler & VM Translator (Nand2Tetris Part II)

A comprehensive implementation of the software stack for the **Hack** computer architecture, developed as part of the "Principles of Programming Languages" course. This project involves building a full compiler and Virtual Machine (VM) translator for the **Jack** programming language.

**Developed by:** Amitay Ben-Ami

---

## 🔗 Project Context: Nand2Tetris
This project follows the curriculum of the world-renowned **Nand2Tetris** course. The program guides students through the process of building a modern computer system from the ground up—starting from basic NAND gates and culminating in a high-level language compiler and operating system.

More information can be found at the official website: [www.nand2tetris.org](https://www.nand2tetris.org/)

---

## 💡 The Challenge: Self-Learning "Ring"
A unique constraint of this project was the requirement to use an unfamiliar programming language. I was assigned **Ring**, a dynamic language I had no prior experience with. I independently mastered the language's syntax and features to build complex architectural tools, demonstrating high adaptability and rapid technical self-learning.

## 🛠️ Project Components

### 1. Jack Compiler (Projects 10 & 11)
A two-stage compiler that translates high-level Jack code into VM instructions:
* **Tokenizer:** Performs lexical analysis, breaking source code into language tokens.
* **Recursive-Descent Parser:** Analyzes the syntactic structure of the language.
* **Symbol Table:** Manages identifier scopes (class and subroutine levels).
* **Code Generator (VMWriter):** Produces backend VM code for the Hack platform.

### 2. VM Translator (Projects 7 & 8)
Translates VM code into Hack Assembly language, handling:
* **Stack Arithmetic:** Implementation of logical and arithmetic operations.
* **Memory Access:** Managing different memory segments (local, static, argument, etc.).
* **Program Flow:** Branching and function calling protocols (nested calls, recursion).

### 3. Application Layer (Project 9)
Developed a functional **Snake Game** in the Jack language to verify the entire software stack, from the high-level code down to the binary execution.

---

## 🚀 Key Skills Demonstrated
* **Compiler Construction:** Lexical analysis, parsing, and code generation.
* **System Architecture:** Deep understanding of stack-based machines and memory management.
* **Rapid Adaptability:** Learning a new programming language (Ring) from scratch to deliver a production-grade project.
* **Problem Solving:** Implementing complex recursive algorithms and low-level translation logic.

---

## 🛠️ Tech Stack
* **Implementation Language:** Ring
* **Source Language:** Jack (High-level)
* **Target Language:** VM Code / Hack Assembly
