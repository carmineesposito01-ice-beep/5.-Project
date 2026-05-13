---
name: sysml-v2-programming
description: SysML v2 language reference and coding patterns — structure, behaviour, requirements, views. Focused exclusively on SysML v2 (NOT v1.x).
version: 2.0.0
---

# SysML v2 Programming Guide

> **IMPORTANT — version alignment:** SysML v2 is a completely new language (not an evolution of SysML v1.x).
> It uses a textual, KerML-based syntax. Do NOT apply UML/SysML v1 concepts (Blocks, BDD, IBD, SDs) here.
> The canonical renderer is SysIDE (VS Code extension) or SysON (web-based).

---

## File Organization

A well-structured SysML v2 project separates concerns across three files:

| File | Purpose |
|---|---|
| `StandardLibrary.sysml` | Custom types, enums, metadata defs, viewpoint/view defs — reusable across projects |
| `ComponentDefinitions.sysml` | All `part def`, `port def`, `item def`, `action def`, `state def`, `requirement def` — **pure definitions, no values** |
| `SystemConfiguration.sysml` | Top-level configuration package with four structured sub-packages (see below) |

### SystemConfiguration.sysml Package Structure

```sysml
package MySystem {
    private import StandardLibrary::**;
    private import ComponentDefinition::*;

    package Structure      { ... }   // decomposizione a blocchi, porte, connessioni
    package Behaviour      { ... }   // use case, action flow, state machine
    package Requirements   { ... }   // requirement usages, satisfy, allocate
    package Analysis       { ... }   // analisi (trade study, performance, safety)
    package Verification   { ... }   // verification case, verify
    package View_Viewpoint { ... }   // view e viewpoint
    package ProjectInfo    { ... }   // info qualitative: team, stakeholder, tool, lifecycle
}
```

Ogni package è **indipendente e cross-referenziabile**: `Verification` può referenziare elementi di `Requirements` e `Structure`; `Analysis` può referenziare elementi di `Behaviour` e `Structure`.

---

### StandardLibrary.sysml — Sub-package struttura

```
StandardLibrary
├── Metadata_Definitions       // metadata def: RequirementStatus, AnalysisInfo, ViewRendering
├── Attribute_Definitions      // attribute def custom specializzati da QuantityValue/TimeValue/...
├── Enum_Definitions           // enum def per stati, tipi, classificazioni
├── Message_Definitions        // item def per messaggi e strutture dati
├── Stakeholders_Definitions   // item def Stakeholder, TeamMember
├── Tool_Definitions           // item def SoftwareTool
├── Lifecycle_Definitions      // item def Phase, Gate, Lifecycle; occurrence def PassageEvent, IterationEvent, InternalOccurrence
├── Viewpoint_Definitions      // viewpoint def (EngineerViewpoint, StakeholderViewpoint, SystemViewpoint, ...)
└── ViewDefinitions            // view def (UseCaseView, ActionFlowView, StateView, RequirementView, ...)
```

---

## Import System

```sysml
// Standard SysML/KerML libraries — always private
private import ScalarValues::*;
private import Quantities::*;
private import MeasurementReferences::*;
private import ISQ::*;          // International System of Quantities
private import SI::*;           // SI units (m, s, kg, Hz, W, ...)
private import Time::*;         // optional — adds TimeValue, Duration

// Import everything from a package recursively (use sparingly)
private import MyLibrary::**;

// Import only top-level names from a package
private import MyLibrary::*;

// Re-export to callers of this package
public import ComponentDefinition::*;
```

---

## Core Keywords Reference

| Keyword | Meaning |
|---|---|
| `part def` / `part` | Physical or logical component (definition vs usage) |
| `attribute def` / `attribute` | Typed property |
| `item def` / `item` | Flowing data structure (messages, payloads) |
| `port def` / `port` | Interaction point on a part |
| `connection def` / `connection` | Binding between ports or parts |
| `action def` / `action` | Behavior step |
| `state def` / `state` | State machine state |
| `use case def` / `use case` | Functional use case |
| `requirement def` / `requirement` | Requirement |
| `viewpoint def` / `viewpoint` | Named stakeholder concern |
| `view def` / `view` | Concrete view instance |
| `enum def` | Enumeration type |
| `metadata def` | Annotation schema |
| `library package` | Package that can be imported by others |
| `constraint def` | Boolean constraint |

### Key Operators

| Operator | Meaning |
|---|---|
| `:>` | Specialization — subtype inherits from supertype |
| `:>>` | Redefinition — overrides an inherited feature |
| `::` | Qualified name separator (package path) |
| `[*]` | Multiplicity — zero or more |
| `[1..*]` | Multiplicity — one or more |
| `in` / `out` / `inout` | Port / parameter direction |
| `ref` | Reference usage (not owned) |
| `#` | Metadata annotation |
| `@` | Metadata application |

---

## Structure Package

### Part Definitions

```sysml
// DEFINITION — in ComponentDefinitions.sysml
part def Sensor {
    doc /* Raw definition without values. */
    attribute samplingRate : Real;      // comment shows expected value & unit
    attribute accuracy : Real;          // m

    in port  dataIn  : SignalPort;
    out port dataOut : SignalPort;
}

// USAGE — in SystemConfiguration.sysml > package Structure
part mySensor : Sensor {
    attribute :>> samplingRate = 100.0 [Hz];
    attribute :>> accuracy     = 0.05 [m];
}
```

### Attribute Definitions and SI Units

```sysml
// Custom attribute def — specialized from a standard quantity type
attribute def ClockFrequency :> QuantityValue { }
attribute def LatencyValue   :> TimeValue { }

// Composite attribute def
attribute def Performance :> QuantityValue {
    attribute maxThroughput : QuantityValue;
    attribute latency       : TimeValue;
}

// Usage with SI units: [prefix*unit]
attribute :>> clockFreq   = 100 [mega*Hz];
attribute :>> latency     = 10  [nano*s];
attribute :>> distance    = 1.5 [m];
attribute :>> power       = 15.0 [W];
attribute :>> temperature = 70  [C];    // celsius
```

### Port Definitions

```sysml
// DEFINITION
port def DataPort {
    in  item received : MyMessage;
    out item sent     : MyMessage;
}

// In a part def — direction is from the part's perspective
part def Router {
    in  port inputA  : DataPort;
    out port outputB : DataPort;
    in out port bidir : DataPort;   // bidirectional
}
```

### Connections

```sysml
// Typed connection — explicit connection def
connection def DataLink {
    end source : DataPort;
    end target : DataPort;
}

// Usage: typed
connection myLink : DataLink connect partA.output to partB.input;

// Usage: untyped shorthand
connect partA.output to partB.input;

// Flow connection (item flows)
connection flow : DataPort connect partA.out to partB.in;
```

### Nested Parts and Internal Connections

```sysml
part def System {
    part subsystemA : SubsystemA;
    part subsystemB : SubsystemB;

    // Internal connection — declared inside the parent
    connection linkAB : DataLink connect subsystemA.dataOut to subsystemB.dataIn;
}
```

---

## Behaviour Package

### Use Case

```sysml
use case def UC1_ProcessData {
    doc /* System receives data and produces output. */
    subject system : MySystem;
    actor   operator : Human;
    actor   sensor   : ExternalSensor;
}

// Allocation in SystemConfiguration > Behaviour
use case systemUseCase : UC1_ProcessData {
    subject system   = Structure::mySystem;
    actor   operator = myOperator;
    actor   sensor   = mySensor;
    connect operator to processInput;
    connect sensor   to processInput;
}
```

### Action Flow (Activity)

Action flows are the SysML v2 equivalent of Activity Diagrams.
**Sequential** (one after another):

```sysml
action def ProcessingFlow {
    action step1;
    action step2;
    action step3;
    first start then step1;
    first step1  then step2;
    first step2  then step3;
    first step3  then done;
}
```

**Parallel** (fork/join):

```sysml
action def ParallelFlow {
    action taskA;
    action taskB;
    action taskC;
    fork  myFork;
    join  myJoin;
    first start   then myFork;
    first myFork  then taskA;
    first myFork  then taskB;
    first myFork  then taskC;
    first taskA   then myJoin;
    first taskB   then myJoin;
    first taskC   then myJoin;
    first myJoin  then done;
}
```

**Decision / merge (conditional)**:

```sysml
action def ConditionalFlow {
    attribute condition : Boolean;
    action branchA;
    action branchB;
    decide choiceNode;   // decision — one outgoing branch fires
    merge  mergeNode;    // merge — first incoming branch continues
    first start      then choiceNode;
    first choiceNode then branchA;   // when condition = true
    first choiceNode then branchB;   // when condition = false
    first branchA    then mergeNode;
    first branchB    then mergeNode;
    first mergeNode  then done;
}
```

**Loop (merge as loop-back)**:

```sysml
action def LoopFlow {
    merge loopStart;
    action process;
    action check;
    first start     then loopStart;
    first loopStart then process;
    first process   then check;
    first check     then loopStart;   // loop-back
    first check     then done;        // exit
}
```

### State Machine

```sysml
state def MyFSM {
    // Attributes used in guards
    attribute signalOK : Boolean;
    attribute faultDetected : Boolean;

    // Ports (use ref — state machines reference, not own, ports)
    ref port output : StatusPort;

    // Initial pseudo-state
    entry;
        then idle;

    // States
    state idle {
        entry action {
            send new StatusMessage(text = "idle") via output;
        }

        transition idle2running
            first idle
            accept when (signalOK)
            do action { send new StatusMessage(text = "starting") via output; }
            then running;
    }

    state running {
        entry action startProcessing;

        transition running2fault
            first running
            accept when (faultDetected)
            then fault;

        transition running2idle
            first running
            accept when (not signalOK)
            then idle;
    }

    state fault {
        entry action {
            send new StatusMessage(text = "fault") via output;
        }

        transition fault2idle
            first fault
            accept when (not faultDetected)
            then idle;
    }

    // Global (top-level) transitions — fire from any sub-state
    transition anyToFault
        first running
        accept when (faultDetected)
        then fault;
}
```

**State machine rules:**
- `entry; then <stateName>;` sets the initial state
- `entry action { ... }` runs on entering a state
- `transition <name> first <source> accept when (<guard>) do action { ... } then <target>;`
- The `do action { ... }` block is optional
- `send new MyItem(field = value) via portName;` sends a message on a port
- Use `ref port` inside state machines (state machines reference ports, they don't own them)
- Wrap boolean sub-expressions in parentheses: `(condA) and (condB)` not `condA and condB`

---

## Requirements Package

### Requirement Definition

```sysml
// DEFINITION — in ComponentDefinitions.sysml or StandardLibrary.sysml
requirement def LatencyRequirement {
    doc /* System latency shall not exceed the specified maximum. */
    attribute maxLatency : TimeValue;
    attribute :>> text = "End-to-end latency shall be ≤ maxLatency.";
    assert constraint { subject.measuredLatency <= maxLatency }
}

// USAGE — in SystemConfiguration > package Requirements
requirement myLatencyReq : LatencyRequirement {
    @RequirementStatus {
        status   = "Draft";
        approver = "";
        date     = "";
        group    = "Performance Requirements";
    }
    attribute :>> maxLatency = 100.0 [milli*s];
}
// Allocate to a system element
satisfy myLatencyReq by Structure::MySystem::myComponent;
```

### Nested Requirements

```sysml
requirement parentReq {
    requirement childReq1 : SomeRequirementDef { ... }
    requirement childReq2 : OtherRequirementDef { ... }
}
satisfy parentReq by Structure::MySystem::mySystem;
```

### Inline Requirement (no def)

```sysml
requirement simpleReq {
    @RequirementStatus { status = "Draft"; group = "Safety"; ... }
    doc /* The system shall recover within 30 ms after a fault. */
}
satisfy simpleReq by Structure::MySystem::mySystem;
```

---

## Analysis Package

Il package `Analysis` ospita casi di analisi: trade study, analisi di performance, analisi di sicurezza (FMEA/FTA), ecc. In SysML v2 si usa `analysis case def` / `analysis case`.

### Analysis Case Definition

```sysml
// DEFINITION — in ComponentDefinitions.sysml
analysis case def LatencyAnalysis {
    doc /* Verifica che la latenza end-to-end rientri nel budget assegnato. */
    subject system : MySystem;
    return attribute result : Real;   // valore restituito dall'analisi
}

// USAGE — in SystemConfiguration > package Analysis
analysis case latencyAnalysis : LatencyAnalysis {
    subject system = Structure::MySystem::myPart;
    return attribute :>> result = 85.0 [milli*s];  // risultato misurato/simulato
}
```

### Trade Study

```sysml
analysis case def ArchitectureTradeStudy {
    doc /* Confronto tra due architetture secondo criteri pesati. */
    subject system : MySystem;
    attribute weightPerformance : Real = 0.5;
    attribute weightCost        : Real = 0.3;
    attribute weightReliability : Real = 0.2;
    return attribute winnerOption : String;
}
```

### Analisi senza Analysis Case (approccio semplificato)

Per analisi qualitative o ancora da formalizzare, si può usare una semplice `part` con attributi:

```sysml
package Analysis {
    part performanceAnalysis {
        doc /* Valori misurati post-sintesi. Da confrontare con i requisiti. */
        attribute measuredLatency       : Real = 8.5 [nano*s];
        attribute measuredThroughput    : Real = 6.1 [giga*bit/s];
        attribute measuredPowerUsage    : Real = 14.2 [W];
    }
}
```

---

## Verification Package

Il package `Verification` ospita i casi di verifica dei requisiti. In SysML v2 si usa `verification case def` / `verification case` + `verify requirement ... by ...`.

### Verification Case Definition

```sysml
// DEFINITION — in ComponentDefinitions.sysml
verification case def SimulationVerification {
    doc /* Verifica tramite simulazione numerica. */
    subject system : MySystem;
    objective : Requirements::myLatencyReq;   // requisito da verificare
    return attribute passed : Boolean;
}

// DEFINITION — metodo hardware-in-the-loop
verification case def HilVerification {
    doc /* Verifica tramite hardware-in-the-loop su prototipo fisico. */
    subject system : MySystem;
    return attribute passed : Boolean;
}
```

### Verification Case Usage

```sysml
package Verification {
    // Istanzia il caso di verifica
    verification case simVerify : SimulationVerification {
        subject system = Structure::MySystem::myPart;
        return attribute :>> passed = true;
    }

    // Collega esplicitamente la verifica al requisito
    verify requirement Requirements::System_Requirements::myLatencyReq
        by simVerify;

    // Verifica con risultato non ancora disponibile
    verification case hilVerify : HilVerification {
        subject system = Structure::MySystem::myPart;
        // passed TBD — da eseguire in fase di integrazione
    }
    verify requirement Requirements::System_Requirements::myLatencyReq
        by hilVerify;
}
```

### Relazione `verify` standalone

Il `verify` può anche essere scritto fuori da un `verification case`, come relazione diretta tra requisito e elemento di sistema:

```sysml
// Dichiarazione semplice — "questo elemento verifica quel requisito"
verify requirement Requirements::System_Requirements::mySafetyReq
    by Structure::MySystem::myComponent;
```

**Regole:**
- `satisfy` risponde a "chi realizza il requisito?" → risposta strutturale
- `verify` risponde a "come si dimostra che il requisito è soddisfatto?" → risposta procedurale/sperimentale
- Un requisito può avere sia `satisfy` che `verify`
- Il metodo di verifica (simulation, test, analysis, inspection) si documenta nel `doc` del `verification case def`

---

## ProjectInfo Package

Il package `ProjectInfo` ospita informazioni qualitative del progetto, organizzate in quattro sotto-package.

### Struttura

```
ProjectInfo
├── ProjectLifecycle     // fasi del ciclo di vita, gate di qualità, eventi
├── ProjectTeamMembers   // membri del team
├── ProjectStakeHolders  // portatori di interesse
└── ProjectTools         // strumenti software usati nel progetto
```

### ProjectLifecycle

Usa `occurrence` per modellare il ciclo di vita e i suoi eventi. I tipi di base vanno definiti in `StandardLibrary`:

```sysml
// In StandardLibrary > Lifecycle_Definitions
item def Phase {
    attribute phaseName : String;
    attribute owner     : String;
    attribute startDate : String;
    attribute endDate   : String;
    attribute notes     : String;
}
item def Gate {
    attribute condition : String;
    attribute gateType  : String;   // "entry" | "exit"
}
item def Lifecycle { }   // contenitore top-level

occurrence def PassageEvent {
    doc /* Avanzamento da una fase alla successiva. */
    attribute fromPhase    : String;
    attribute toPhase      : String;
    attribute fromProgress : Integer;   // % completamento al passaggio
    attribute content      : String;
    attribute date         : String;
}
occurrence def IterationEvent {
    doc /* Rework verso una fase precedente. */
    attribute fromPhase : String;
    attribute toPhase   : String;
    attribute reason    : String;
    attribute content   : String;
    attribute date      : String;
}
occurrence def InternalOccurrence {
    doc /* Evento interno a una fase (attività, milestone, decisione). */
    attribute inPhase : String;   // nome della fase di appartenenza
    attribute content : String;
    attribute date    : String;
}
```

Istanziazione in `ProjectInfo > ProjectLifecycle`:

```sysml
package ProjectLifecycle {
    item projectLifecycle : Lifecycle {

        // ── FASI ─────────────────────────────────────────────────
        item phaseA : Phase {
            attribute phaseName = "Concept";
            attribute owner     = "Ing. Rossi";
            attribute notes     = "Feasibility study.";
            item gate_exit : Gate {
                attribute condition = "Feasibility Review Approved";
                attribute gateType  = "exit";
            }
        }
        item phaseB : Phase {
            attribute phaseName = "Requirements";
            attribute owner     = "Ing. Rossi";
            item gate_entry : Gate { attribute condition = "Concept Approved"; attribute gateType = "entry"; }
            item gate_exit  : Gate { attribute condition = "Requirements Baseline Fixed"; attribute gateType = "exit"; }
        }

        // ── EVENTI INTERNI (a livello lifecycle, non dentro la fase) ──
        occurrence occ_A1 : InternalOccurrence {
            attribute inPhase = "Concept";
            attribute content = "Define system objectives";
            attribute date    = "2026-03-15";
        }

        // ── TRANSIZIONI ──────────────────────────────────────────
        occurrence pass_A_B : PassageEvent {
            attribute fromPhase    = "Concept";
            attribute toPhase      = "Requirements";
            attribute fromProgress = 100;
            attribute content      = "Concept Review Approved";
            attribute date         = "2026-04-25";
        }

        // ── REWORK ───────────────────────────────────────────────
        occurrence iter_B_A : IterationEvent {
            attribute fromPhase = "Requirements";
            attribute toPhase   = "Concept";
            attribute reason    = "Scope change from stakeholder";
            attribute content   = "Revisit feasibility";
            attribute date      = "2026-05-01";
        }
    }
}
```

> **Regola critica:** gli `InternalOccurrence` vanno dichiarati **a livello del `Lifecycle`**, non dentro le `Phase`. La fase di appartenenza si indica con `attribute inPhase = "<phaseName>"`.

### ProjectTeamMembers e ProjectStakeHolders

```sysml
// In StandardLibrary > Stakeholders_Definitions
item def TeamMember {
    attribute fullName    : String;
    attribute role        : String;
    attribute email       : String;
    attribute team        : String;
    attribute phone       : String;
    attribute linkedinUrl : String;
    attribute teamsUrl    : String;
}
item def Stakeholder {
    attribute fullName     : String;
    attribute role         : String;
    attribute email        : String;
    attribute organization : String;
    attribute phone        : String;
}

// Istanziazione in ProjectInfo
package ProjectTeamMembers {
    item engineer_1 : TeamMember {
        attribute :>> fullName = "Mario Rossi";
        attribute :>> role     = "System Engineer";
        attribute :>> email    = "mario.rossi@example.com";
        attribute :>> team     = "MBSE Team";
    }
}
package ProjectStakeHolders {
    item sponsor_1 : Stakeholder {
        attribute :>> fullName     = "Anna Verdi";
        attribute :>> role         = "Project Sponsor";
        attribute :>> organization = "Acme Corp";
    }
}
```

### ProjectTools

```sysml
// In StandardLibrary > Tool_Definitions
item def SoftwareTool {
    attribute toolName    : String;
    attribute version     : String;
    attribute vendor      : String;
    attribute toolType    : String;
    attribute scope       : String;
    attribute license     : String;
    attribute description : String;
    attribute descPurpose : String;
    attribute descRole    : String;
    attribute descOutput  : String;
    attribute descModules : String;
    attribute descWiki    : String;
}

// Istanziazione in ProjectInfo > ProjectTools
package ProjectTools {
    item myIde : SoftwareTool {
        attribute toolName    = "Visual Studio Code (SysIde)";
        attribute version     = "1.90";
        attribute vendor      = "Sensmetry";
        attribute toolType    = "IDE / Textual Modeling Editor";
        attribute scope       = "Systems Engineering";
        attribute license     = "MIT / Academic";
        attribute description = "Editor SysML v2 con estensione SysIde.";
        attribute descPurpose = "Authoring testuale del modello SysML v2.";
        attribute descOutput  = "File .sysml, visualizzazioni interattive.";
        attribute descWiki    = "https://sensmetry.com/syside";
    }
}
```

---

## View / Viewpoint Package

### Viewpoint Definitions (in library)

```sysml
library package Viewpoint_Definitions {
    viewpoint def EngineerViewpoint {
        doc /* For engineers — behavioral, structural, and interface diagrams. */
    }
    viewpoint def StakeholderViewpoint {
        doc /* For stakeholders — high-level goals and requirements only. */
    }
    // Specialization
    viewpoint def SystemViewpoint :> EngineerViewpoint {
        doc /* Full system picture: structure, use cases, requirements allocation. */
    }
}
```

### View Definitions (in library)

```sysml
library package ViewDefinitions {
    view def UseCaseView    { doc /* Actor / use case diagram. */ }
    view def ActionFlowView { doc /* Action flow / activity diagram. */ }
    view def StateView      { doc /* State machine diagram. */ }
    view def RequirementView{ doc /* Requirement satisfaction matrix. */ }
    view def GeneralView    { doc /* Internal block diagram (ports and connections). */ }
}
```

### View Usages (in SystemConfiguration > View_Viewpoint)

```sysml
package View_Viewpoint {
    // Instantiate viewpoints
    viewpoint engineerVP : EngineerViewpoint { ... }
    viewpoint stakeholderVP : StakeholderViewpoint { ... }

    // Instantiate views — each view exposes model elements
    view useCaseView : UseCaseView {
        satisfy engineerVP;
        satisfy stakeholderVP;
        @ViewRendering { fileName = "UseCase-View"; }
        @AnalysisInfo {
            label       = "Use Case View";
            groupName   = "L1 — System Black-Box";
            domain      = "Functional";
            icon        = "👤";
            level       = "L1";
            kind        = "BlackBox";
            component   = "";
            parentGroup = "B_W";
        }
        expose Behaviour::systemUseCase;
    }

    view actionView : ActionFlowView {
        satisfy engineerVP;
        @AnalysisInfo { label = "Action Flow L1"; level = "L1"; ... }
        expose Behaviour::systemUseCase::MyActionDef::**;  // ::** = recursively all
    }

    view structureView : GeneralView {
        satisfy engineerVP;
        filter @SysML::PortUsage;   // show only ports
        expose Structure::MySystem::myPart;
    }
}
```

**View rules:**
- `satisfy <viewpoint>;` — declares which stakeholder concern this view addresses
- `expose <path>;` — selects which model element(s) the view renders
- `expose <path>::**;` — recursively expose all contents
- `filter @SysML::PortUsage;` — restrict display to a specific metatype
- `@ViewRendering { fileName = "..."; }` — sets the export filename
- `@AnalysisInfo { ... }` — metadata for dashboard grouping (project-specific convention)

---

## Metadata Definitions and Annotations

```sysml
// Define a metadata schema
metadata def MyAnnotation {
    attribute status : String;
    attribute owner  : String;
    attribute date   : String;
}

// Apply metadata to any model element
part myPart : SomeDef {
    @MyAnnotation { status = "Draft"; owner = "Alice"; date = "2026-05-12"; }
}

// Apply inline in a requirement usage
requirement myReq : SomeDef {
    @MyAnnotation { status = "Approved"; owner = "Bob"; date = "2026-05-01"; }
}
```

---

## Enumerations

```sysml
enum def StatusKind {
    OK;
    Degraded;
    Lost;
    Unknown;
}

// Usage in an attribute
attribute communicationStatus : StatusKind = StatusKind::OK;

// Usage in a guard
accept when (communicationStatus == StatusKind::Lost)
```

---

## Item Definitions (Messages / Data Structures)

```sysml
item def SensorReading {
    attribute timestamp  : Real;         // ms
    attribute value      : Real;         // unit depends on sensor
    attribute confidence : Real;         // 0.0 – 1.0
    attribute sensorID   : Integer;
}

// Nested items
item def NavigationMessage {
    item ephemeris {
        attribute orbX : Real;
        attribute orbY : Real;
    }
    item almanac {
        item satellitePosition : Real[*];  // array
    }
}

// Multiplicity — array of items
attribute readings : SensorReading[*];    // zero or more
attribute readings : SensorReading[1..*]; // one or more
attribute readings : SensorReading[3];    // exactly three
```

---

## Constraints

```sysml
attribute def TemperatureRange :> QuantityValue {
    attribute tempMin : TemperatureValue;
    attribute tempMax : TemperatureValue;

    assert constraint temperatureValid {
        tempMin <= tempMax
    }
}

// Inline constraint in a part
part def SafeSystem {
    attribute maxSpeed   : Real;
    attribute emergencyV : Real;
    assert constraint { emergencyV <= maxSpeed * 0.8 }
}
```

---

## Common Pitfalls (SysML v2 vs v1)

| SysML v1 concept | SysML v2 equivalent |
|---|---|
| `Block` (BDD) | `part def` |
| `ValueProperty` | `attribute` |
| Internal Block Diagram (IBD) | `part` with nested `part` usages and `connection` |
| `FlowPort` | `port def` with `in`/`out` items |
| Activity Diagram | `action def` with `first … then` sequencing |
| State Machine Diagram | `state def` with `transition` |
| `satisfy` relation (SysML v1) | `satisfy <req> by <element>;` (same idea, new syntax) |
| `«allocate»` | `allocate <feature> to <feature>;` |
| Profile / Stereotype | `metadata def` + `@` annotation |

**SysML v2-specific rules to remember:**
- Every definition keyword has a matching usage keyword (`part def` → `part`, `state def` → `state`, etc.)
- `:>` specializes; `:>>` redefines (overrides a named feature inherited from the supertype)
- Qualified names use `::`, not `.` (e.g., `MyPkg::MySubPkg::MyElement`)
- Boolean guards must have explicit parentheses around each sub-expression: `(a) and (b)`, NOT `a and b`
- Inside state machines, ports must be `ref port` (referenced, not owned)
- `send new MyItem(field = value) via portName;` is the SysML v2 message syntax
- Sequence diagrams have limited tooling support — prefer Action Views for behavioral diagrams
