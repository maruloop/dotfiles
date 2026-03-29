---
name: draw-flow-diagram-excellence
description: Analyzes code flow for a given class and method name, then generates a Mermaid flowchart diagram to visualize the execution path
---

# draw-flow-diagram-excellence Skill

## Overview
Automatically analyzes method/function flows in code and generates Mermaid-format flowchart diagrams for visualization.

## Usage

```
/draw-flow-diagram <className> <methodName>
```

### Examples
```
/draw-flow-diagram UserService authenticate
/draw-flow-diagram OrderProcessor processOrder
```

## Input Parameters
- **className**: Name of the target class to analyze (required)
- **methodName**: Name of the target method to analyze (required)

## How It Works

### 1. Locate Code
- Search the codebase for the specified class name and method name
- Identify the exact method definition location

### 2. Analyze Flow
- Trace the control flow within the method
  - Conditional statements (if/else)
  - Loops (for/while)
  - Method calls
  - Branches and returns
- Track dependencies and calling sequences
- Identify external method invocations

### 3. Generate Mermaid Diagram
- Convert analysis results to Mermaid flowchart syntax
- Node types with color coding:
  - **Start/End nodes** (🟢 Green): Entry and exit points of the method
  - **Method calls** (🔵 Blue): Function/method invocations
  - **Conditional branches** (🟡 Yellow): Decision points (if/else, switch)
  - **Process steps** (🟣 Purple): General processing or operations
  - **Loop structures** (🟣 Purple): Iterative operations
- Edges: Control flow paths with labels

### 4. Return Results
- Present generated Mermaid code
- Format ready for direct rendering

## Output Format

```mermaid
flowchart TD
    Start([Start]) --> A[Method Call]
    A --> B{Condition?}
    B -->|Yes| C[Process 1]
    B -->|No| D[Process 2]
    C --> End([End])
    D --> End

    classDef startEnd fill:#90EE90,stroke:#228B22,stroke-width:2px,color:#000
    classDef methodCall fill:#87CEEB,stroke:#4682B4,stroke-width:2px,color:#000
    classDef condition fill:#FFD700,stroke:#FF8C00,stroke-width:2px,color:#000
    classDef process fill:#DDA0DD,stroke:#9932CC,stroke-width:2px,color:#000

    class Start,End startEnd
    class A methodCall
    class B condition
    class C,D process
```

## Limitations
- Complex methods display main flow path only
- External library calls are simplified
- Recursive calls are explicitly marked

## Related Commands
- Search for classes: Use Glob/Grep tools
- Deep code analysis: Use Read tool to examine full method details
