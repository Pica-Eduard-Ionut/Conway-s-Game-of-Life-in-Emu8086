# Conway's Game of Life in emu8086 Assembly

## Overview
Conway's Game of Life is a cellular automaton devised by John Horton Conway in 1970. It is a zero-player game, meaning its evolution is determined by its initial state, requiring no further input. The game is implemented in emu8086 assembly for a project in Computer Architecture. It uses interrupts to handle text-based graphical output and simulate the game's evolution based on simple rules.

## Project Description

### Rules
- **Underpopulation:** Any live cell with fewer than two live neighbours dies.
- **Survival:** Any live cell with two or three live neighbours lives on to the next generation.
- **Overpopulation:** Any live cell with more than three live neighbours dies.
- **Reproduction:** Any dead cell with exactly three live neighbours becomes a live cell.

### Program Logic
The game uses page 0 and page 1 for double-buffering. It simulates the game's evolution on one page while displaying the result on the other page.

### Interrupts:
- `INT 10h / AH = 2`: Set cursor position.
- `INT 10h / AH = 08h`: Read character and attribute at cursor.
- `INT 10h / AH = 09h`: Write character and attribute at cursor.
- `INT 10h / AH = 07h`: Scroll down window to clear the screen.

The program runs in an infinite loop that:
1. Checks page 0 and writes to page 1.
2. Checks page 1 and writes to page 0.
3. Switches back and forth between pages to simulate the continuous evolution of the game.

## Key Functions
- **Set Cursor:** Moves the cursor to a specified position on the screen.
- **Set Color:** Writes the "alive" and "dead" cells on the screen using specific attributes (ASCII character 178 for alive, 0 for dead).
- **Search Neighbors:** Counts the number of live neighbors around a given cell to apply the game rules.

## Code Walkthrough

### Setup
- Set graphical mode using `MOV AL, 03h` and `INT 10h`. This configures the terminal to an 80x25 text mode display.
- Initialize the game board with a glider pattern by setting specific pixels as "alive."

### Game Logic
- The game evolves in generations. Each cell checks its neighbors to determine if it will live, die, or be born based on the rules mentioned.
- The program alternates between pages (page 0 and page 1) to store the current and next generation of cells.

### Main Loop
1. **Check Page 0:** Iterate through the grid and check each cell's neighbors. Based on the neighbor count, determine the next state of the cell.
2. **Write Results to Page 1:** After checking Page 0, write the updated states to Page 1.
3. **Clear Page 0:** After the check is complete, clear Page 0 and swap to Page 1.
4. **Repeat:** The program then loops back, continuing the simulation.

## Procedures
- **setCursor:** Moves the cursor to a specific position on the screen.
- **setColorAlive:** Sets the display character and color for an "alive" cell.
- **setColorDead:** Sets the display character and color for a "dead" cell.
- **searchNeighborsPG0** and **searchNeighborsPG1:** These procedures check the 8 neighbors of a given cell on page 0 or page 1 to count the number of live neighbors. They are used to apply the game's rules to each cell.
- **clearPage:** Clears the screen for the current page using `INT 10h / AH = 07h`.
- **changePage0** and **changePage1:** These procedures switch between Page 0 and Page 1, enabling double-buffering.

## Conclusion
This project demonstrates how to simulate Conway's Game of Life using low-level assembly code. By leveraging basic graphical output and interrupt handling, the game evolves over time, adhering to Conway's simple rules of cellular automata. The program runs continuously until terminated and updates the display in real-time.
