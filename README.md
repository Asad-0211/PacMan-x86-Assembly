# PacMan-x86-Assembly

A fully playable console-based Pac-Man clone built in x86 Assembly using the Irvine32 library.

## Demo
<video src="demo.mp4" controls></video>

## Overview
This project is a fully functional graphical UI within the console, featuring a main menu, instruction screen, pause functionality, and a persistent game history that reads and writes player scores to a local `Scores.txt` file.

## Gameplay Mechanics
*   Navigate the maze using standard `WASD` controls.
*   Collect standard pallets (`.`) and power pallets (`*`) to increase your score.
*   Avoid dynamically moving ghosts. 
*   The game scales in difficulty across 3 levels, adjusting ghost pathfinding from basic random movement to aggressive, calculated tracking based on the player's X and Y coordinates.

## Prerequisites
*   Visual Studio 2019 (Community Edition).
*   The "Desktop development with C++" workload installed.
*   The Irvine32 library downloaded and extracted to your local storage (e.g., `C:\Irvine`).

## Setup & Execution
1. Open Visual Studio 2019 and create a new **Empty Project (C++)**.
2. In the Solution Explorer, right-click "Source Files", select **Add > New Item**, and create a new C++ file but manually change the extension to `.asm` (e.g., `SourceProject.asm`). Paste the repository code into this file.
3. Right-click your project name in the Solution Explorer, select **Build Dependencies > Build Customizations**, and check the box for **masm**.
4. Right-click the project again and go to **Properties**. Navigate to **Linker > General > Additional Library Directories**, edit it, and paste the exact folder path to your Irvine library.
5. In the same Properties window, navigate to **Linker > Input > Additional Dependencies**, type `irvine32.lib`, and hit OK.
6. Right-click your `SourceProject.asm` file directly, go to **Properties > General > Item Type**, and select **Microsoft Macro Assembler** from the dropdown. Apply the changes.
7. A new "Microsoft Macro Assembler" menu will appear on the left of that properties window. Select it, go to **Include Paths**, and paste the path to your Irvine directory one last time. 
8. Click OK, build the solution, and click **Local Windows Debugger** to run the game.
