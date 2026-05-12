/**
 * LIFECYCLE_ADVANCED.sysml
 * ──────────────────────────────────────────────────────────────────────────
 * File dimostrativo completo di tutte le funzionalità della LifecycleView
 * nel Visualizer v5. Mostra la sintassi aggiornata:
 *
 *  ① Fasi con attributi: phaseName, owner, startDate, endDate, notes
 *     status e progress NON più espliciti nelle fasi:
 *       – status  → inferito dal parser in base agli eventi (PassageEvent/IterationEvent)
 *       – progress → desunto da fromProgress del PassageEvent di uscita
 *                    oppure calcolato dalle date per la fase attiva
 *
 *  ② PassageEvent (transizioni) con fromProgress
 *     fromProgress = completamento % della fromPhase al momento del passaggio
 *
 *  ③ IterationEvent (rework) con fromProgress e reason
 *     → generano righe "Run N" separate nel diagramma
 *
 *  ④ InternalOccurrence al livello del Lifecycle (non più dentro la fase!)
 *     con attribute inPhase = "<phaseName>" per associarle alla fase corretta
 *
 *  ⑤ Quality Gates (entry / exit) ancora definiti dentro le fasi
 *
 * DIFFERENZE RISPETTO ALLA SINTASSI PRECEDENTE
 *  ✗ occurrence X : PhaseOccurrence { ... }  ← rimosso dall'interno delle fasi
 *  ✓ occurrence X : InternalOccurrence { attribute inPhase = "..."; ... }
 *                                             ← ora a livello lifecycle
 *  ✗ attribute progress = 100;  ← rimosso dalle fasi
 *  ✓ attribute fromProgress = 100;  ← aggiunto al PassageEvent di uscita
 */

package LifeCycle {
    doc /* Dimostrazione completa della LifecycleView — sintassi v5 aggiornata */

    private import ViewDefinitions::*;

    // ══════════════════════════════════════════════════════════════════
    //  CICLO DI VITA DEL PROGETTO V2X-CACC
    // ══════════════════════════════════════════════════════════════════

    item projectLifecycle : Lifecycle {
        doc /* Ciclo di vita completo del progetto V2X-CACC:
             * dalla concezione iniziale fino al ritiro del sistema.
             * Status e progress vengono inferiti automaticamente dal parser
             * a partire dagli eventi di passaggio e iterazione. */

        // ── ① FASI ───────────────────────────────────────────────────
        // Nessun attributo progress: viene desunto dal fromProgress del
        // PassageEvent che esce dalla fase (o calcolato dalle date se attiva).

        item phaseA : Phase {
            doc /* Definizione iniziale dei Bisogni degli stakeholder, idee per realizzarli e analisi di queste. */
            attribute phaseName = "Concept";
            attribute owner     = "Ing. Esposito";
            attribute notes     = "Feasibility study of needs and project ideas.";

            item gate_conceptExit : Gate {
                attribute condition = "Feasibility Review Approvata";
                attribute gateType  = "exit";
            }
        }

        item phaseB : Phase {
            doc /* Formalizza i Bisogni degli Stakeholder in Requisiti di sistema. */
            attribute phaseName = "Requirements";
            attribute owner     = "Ing. Esposito";
            attribute notes     = "Elicit, analyze and formalize stakeholder needs into system requirements.";

            item gate_reqEntry : Gate {
                attribute condition = "Concept Review Passed";
                attribute gateType  = "entry";
            }
            item gate_reqExit : Gate {
                attribute condition = "Requirements Baseline Fixed";
                attribute gateType  = "exit";
            }
        }

        item phaseC : Phase {
            doc /* Tradurre i Requisiti in funzioni (action), ignorando i componenti fisici. */
            attribute phaseName = "Functional";
            attribute owner     = "Ing. Esposito";
            attribute notes     = "Define system functions and their interactions, without committing to physical components.";

            item gate_designEntry : Gate {
                attribute condition = "Requirements Review Passed";
                attribute gateType  = "entry";
            }
            item gate_designExit : Gate {
                attribute condition = "Functional Design Review Passed";
                attribute gateType  = "exit";
            }
        }

        item phaseD : Phase {
            doc /* Associazione delle funzioni ai blocchi dell'architettura. */
            attribute phaseName = "Logical";
            attribute owner     = "Ing. Esposito";
            attribute notes     = "Associate function to architecture blocks and define ports and interfaces.";

            item gate_implEntry : Gate {
                attribute condition = "Functional Design Completed";
                attribute gateType  = "entry";
            }
            item gate_implExit : Gate {
                attribute condition = "System Architecture Review Passed.";
                attribute gateType  = "exit";
            }
        }

        item phaseE : Phase {
            doc /* Progettazione nel dettaglio dei blocchi funzionali dell'Architettura. */
            attribute phaseName = "Physical";
            attribute owner     = "Ing. Esposito";
            attribute notes     = "Detail design of functional blocks in the architecture.";

            item gate_implEntry : Gate {
                attribute condition = "Architecture Level Completed";
                attribute gateType  = "entry";
            }
            item gate_implExit : Gate {
                attribute condition = "Design Review Passed.";
                attribute gateType  = "exit";
            }
        }

        item phaseF : Phase {
            doc /* Test di integrazione, simulazione HIL e verifica dei requisiti. */
            attribute phaseName = "Verification";
            attribute owner     = "Ing. Esposito";
            attribute notes     = "Integration, simulation and verification of Requirements.";

            item gate_vvEntry : Gate {
                attribute condition = "Architecture Design Passed";
                attribute gateType  = "entry";
            }
            item gate_vvExit : Gate {
                attribute condition = "Verification Review Approved";
                attribute gateType  = "exit";
            }
        }

        item phaseG : Phase {
            doc /* Verifica che il sistema soddisfi i bisogni degli stakeholder. */
            attribute phaseName = "Validation";
            attribute owner     = "Ing. Esposito";
            attribute notes     = "Validation with stakeholders to ensure needs are met.";

            item gate_vvEntry : Gate {
                attribute condition = "Verification Review Approved";
                attribute gateType  = "entry";
            }
            item gate_vvExit : Gate {
                attribute condition = "Validation Review Approved";
                attribute gateType  = "exit";
            }
        }


        item phaseH : Phase {
            doc /* Rilascio e messa in produzione del sistema. */
            attribute phaseName = "Deployment";
            attribute owner     = "Unknown";
            attribute notes     = "Release and deployment of the system.";

            item gate_deployEntry : Gate {
                attribute condition = "Validation Review Approved";
                attribute gateType  = "entry";
            }

            item gate_depExit : Gate {
                attribute condition = "System deployed and operational.";
                attribute gateType  = "exit";
            }
        }

        item phaseH : Phase {
            doc /* Fase operativa con monitoraggio continuo e ritiro. */
            attribute phaseName = "M&R";
            attribute owner     = "Team Field";
            attribute notes     = "Operational phase with continuous monitoring and maintenance until retirement.";

            item gate_deployEntry : Gate {
                attribute condition = "System Deployed and Operational";
                attribute gateType  = "entry";
            }

        }

        // ── ② INTERNAL OCCURRENCES (NUOVA SINTASSI) ──────────────────
        // Definite al livello del Lifecycle, non più dentro le fasi.
        // Il renderer le raggruppa per fase usando attribute inPhase.

        occurrence occ_A1 : InternalOccurrence {
            attribute inPhase = "Concept";
            attribute content = "Analisi dei requisiti degli stakeholder";
            attribute date    = "2025-01-20";
        }
        occurrence occ_A2 : InternalOccurrence {
            attribute inPhase = "Concept";
            attribute content = "Studio di fattibilità tecnica e economica";
            attribute date    = "2025-02-10";
        }
        occurrence occ_A3 : InternalOccurrence {
            attribute inPhase = "Concept";
            attribute content = "Identificazione del System-of-Systems";
            attribute date    = "2025-03-05";
        }

        occurrence occ_B1 : InternalOccurrence {
            attribute inPhase = "Requirements";
            attribute content = "Requisiti funzionali del sistema (SYS-F-*)";
        }
        occurrence occ_B2 : InternalOccurrence {
            attribute inPhase = "Requirements";
            attribute content = "Requisiti non-funzionali (safety, security, perf.)";
        }
        occurrence occ_B3 : InternalOccurrence {
            attribute inPhase = "Requirements";
            attribute content = "Traceability matrix vers. 1.0";
        }
        occurrence occ_B4 : InternalOccurrence {
            attribute inPhase = "Requirements";
            attribute content = "Validazione con gli stakeholder";
        }

        occurrence occ_C1 : InternalOccurrence {
            attribute inPhase = "System Design";
            attribute content = "Architettura SysML v2 del top-level system";
        }
        occurrence occ_C2 : InternalOccurrence {
            attribute inPhase = "System Design";
            attribute content = "Definizione delle interfacce V2V / V2I / HMI";
        }
        occurrence occ_C3 : InternalOccurrence {
            attribute inPhase = "System Design";
            attribute content = "Analisi SOTIF e FMEA preliminare";
        }

        occurrence occ_D1 : InternalOccurrence {
            attribute inPhase = "Implementation";
            attribute content = "Modulo InputGateway V2V/V2I";
        }
        occurrence occ_D2 : InternalOccurrence {
            attribute inPhase = "Implementation";
            attribute content = "Elaboration: IDM 2D Car-Following";
        }
        occurrence occ_D3 : InternalOccurrence {
            attribute inPhase = "Implementation";
            attribute content = "OutputGateway: HMI + CAM composer";
        }
        occurrence occ_D4 : InternalOccurrence {
            attribute inPhase = "Implementation";
            attribute content = "State Machine: fallback e degraded mode";
        }
        occurrence occ_D5 : InternalOccurrence {
            attribute inPhase = "Implementation";
            attribute content = "Unit Test e Code Review";
        }

        occurrence occ_E1 : InternalOccurrence {
            attribute inPhase = "V&V";
            attribute content = "Test di integrazione sottosistemi";
        }
        occurrence occ_E2 : InternalOccurrence {
            attribute inPhase = "V&V";
            attribute content = "Simulazione Hardware-in-the-Loop (HIL)";
        }
        occurrence occ_E3 : InternalOccurrence {
            attribute inPhase = "V&V";
            attribute content = "Campagna di test su strada (closed track)";
        }
        occurrence occ_E4 : InternalOccurrence {
            attribute inPhase = "V&V";
            attribute content = "Validazione dei requisiti di safety (ISO 26262)";
        }

        occurrence occ_F1 : InternalOccurrence {
            attribute inPhase = "Deployment";
            attribute content = "Rilascio binario certificato";
        }
        occurrence occ_F2 : InternalOccurrence {
            attribute inPhase = "Deployment";
            attribute content = "Documentazione operativa e training";
        }

        occurrence occ_G1 : InternalOccurrence {
            attribute inPhase = "O&M";
            attribute content = "Monitoraggio telemetria in campo";
        }
        occurrence occ_G2 : InternalOccurrence {
            attribute inPhase = "O&M";
            attribute content = "Patch di sicurezza e aggiornamenti OTA";
        }

        // ── ③ PASSAGE EVENTS ─────────────────────────────────────────
        // fromProgress = completamento % della fromPhase al momento del passaggio.
        // Il parser usa questo valore per impostare phase.progress quando inferisce
        // lo status "completed" (senza attributo status esplicito nella fase).

        occurrence pass_A_B : PassageEvent {
            attribute fromPhase    = "Concept";
            attribute toPhase      = "Requirements";
            attribute fromProgress = 100;
            attribute date         = "2025-03-31";
            attribute content      = "Feasibility Review Approvata";
        }

        occurrence pass_B_C : PassageEvent {
            attribute fromPhase    = "Requirements";
            attribute toPhase      = "System Design";
            attribute fromProgress = 100;
            attribute date         = "2025-05-31";
            attribute content      = "Baseline Requirements v1.0 congelata";
        }

        occurrence pass_C_D : PassageEvent {
            attribute fromPhase    = "System Design";
            attribute toPhase      = "Implementation";
            attribute fromProgress = 100;
            attribute date         = "2025-08-31";
            attribute content      = "PDR Superata — architettura approvata";
        }

        // pass_D_E non ancora emesso: la fase Implementation è attiva.
        // Il parser calcola il suo progress automaticamente dalle date.

        // ── ④ ITERATION EVENTS ────────────────────────────────────────
        // fromProgress = % di avanzamento della fromPhase al momento del rework.

        /**
         * ITERAZIONE 1: A metà della fase System Design (≈60%), i requisiti
         * risultavano incompleti. Il team è tornato in Requirements per
         * aggiungere i casi d'uso SOTIF.
         */
        occurrence iter_back_to_req : IterationEvent {
            attribute fromPhase    = "System Design";
            attribute toPhase      = "Requirements";
            attribute fromProgress = 60;
            attribute date         = "2025-07-15";
            attribute reason       = "Requisiti SOTIF mancanti — aggiunta UC Safety";
            attribute content      = "Rework Requirements: SOTIF use cases";
        }

        /**
         * ITERAZIONE 2: Durante l'implementazione (≈30%), un test HIL
         * preliminare ha rivelato che l'architettura IDM 2D non era
         * real-time safe su FPGA. Il team è tornato in System Design.
         */
        occurrence iter_back_to_design : IterationEvent {
            attribute fromPhase    = "Implementation";
            attribute toPhase      = "System Design";
            attribute fromProgress = 30;
            attribute date         = "2025-12-10";
            attribute reason       = "Architettura IDM 2D non real-time safe — redesign";
            attribute content      = "Redesign: Car-Following su FPGA a logica pipeline";
        }
    }

    view lifecycleView : LifecycleView {
        doc /* Vista del ciclo di vita del progetto V2X-CACC.
             * Status e progress completamente inferiti dagli eventi. */
        expose projectLifecycle;
    }
}


// ══════════════════════════════════════════════════════════════════════════
//  ESEMPIO: SoftwareTool con descrizione strutturata (desc* attributes)
// ══════════════════════════════════════════════════════════════════════════
//
//  Il ToolRenderer v5 riconosce i prefissi desc* e li visualizza come
//  pannello strutturato nella card, con label colorati per Purpose, Role,
//  Output, Modules (badge list separata da ";") e Wiki (link cliccabile).

package Tools {
    doc /* Esempio di SoftwareTool con tutti i sotto-attributi desc* supportati. */

    private import ViewDefinitions::*;

    item Vivado : SoftwareTool {
        attribute toolName    = "Xilinx Vivado";
        attribute vendor      = "AMD (ex Xilinx)";
        attribute version     = "2023.x";
        attribute toolType    = "EDA / FPGA Design Suite";
        attribute scope       = "Hardware Engineering";
        attribute license     = "Proprietary (Standard/Enterprise)";
        attribute description = "Suite di sviluppo integrata per la sintesi, analisi e implementazione di progetti HDL su FPGA/SoC.";

        attribute descPurpose = "Tradurre codice RTL (VHDL/Verilog) o blocchi IP in bitstream configurabili per l'hardware target, ottimizzando timing e risorse logiche.";
        attribute descRole    = "Ambiente per la progettazione fisica (P) dell'hardware digitale, dalla sintesi logica fino al place & route e alla simulazione RTL.";
        attribute descOutput  = "Bitstream (.bit), report di timing/utilizzazione, netlist sintetizzate, file di configurazione hardware (.xsa).";
        attribute descModules = "Vivado Simulator (XSim); IP Integrator; Logic Analyzer; High-Level Synthesis (HLS).";
        attribute descWiki    = "https://docs.xilinx.com";
    }

    item MatlabToolchain : SoftwareTool {
        attribute toolName    = "MATLAB & Simulink";
        attribute vendor      = "MathWorks";
        attribute version     = "R2023b / R2024a"; 
        attribute toolType    = "Technical Computing & MBSE";
        attribute scope       = "Systems / Control Engineering";
        attribute license     = "Proprietary";
        attribute description = "Ambiente di calcolo numerico e modellazione basata su blocchi per la simulazione di sistemi dinamici.";

        attribute descPurpose = "Sviluppare, simulare e validare algoritmi di controllo e modelli fisici (Plant) prima dell'implementazione reale.";
        attribute descRole    = "Copre i livelli Funzionale (F) e Logico (L) dell'RFLP per il controllo dinamico, fornendo anche generazione automatica di codice (C/C++/HDL) per il livello Fisico (P).";
        attribute descOutput  = "Script (.m), modelli Simulink (.slx), codice autogenerato, dati di simulazione, report di test (MIL/SIL/HIL).";
        attribute descModules = "Simulink; Stateflow; Control System Toolbox; MATLAB Coder; Simulink Coder.";
        attribute descWiki    = "https://it.mathworks.com/help/";
    }

    item Python : SoftwareTool {
        attribute toolName    = "Python";
        attribute vendor      = "Python Software Foundation";
        attribute version     = "3.11+";
        attribute toolType    = "Programming Language";
        attribute scope       = "Cross-domain / Automation";
        attribute license     = "PSF License (Open Source)";
        attribute description = "Linguaggio di programmazione interpretato ad alto livello, standard de-facto per scripting e data science.";

        attribute descPurpose = "Fornire un ecosistema flessibile per l'automazione dei test, l'elaborazione dei dati di simulazione e la creazione di script di utilità per la toolchain.";
        attribute descRole    = "Collaudante per i vari tool del progetto: automazione di task ripetitivi, parsing di log, post-processing di dati provenienti da Matlab o test fisici.";
        attribute descOutput  = "Script sorgente (.py), dataset processati (CSV/JSON/Parquet), figure e plot, report analitici.";
        attribute descModules = "NumPy; Pandas; PyTest; Matplotlib; librerie standard (os, sys, json, subprocess).";
        attribute descWiki    = "https://docs.python.org/3/";
    }

    item VSCode_SysML : SoftwareTool {
        attribute toolName    = "Visual Studio Code (SysML v2 Ext)";
        attribute vendor      = "Microsoft / Systems Modeling";
        attribute version     = "1.8x (IDE) / Release attuale per LSP";
        attribute toolType    = "IDE / Text Editor";
        attribute scope       = "Systems / Software Engineering";
        attribute license     = "MIT (Sorgenti) / Freeware (Binari)";
        attribute description = "Editor di codice sorgente leggero equipaggiato con il Language Server SysML v2.";

        attribute descPurpose = "Consentire l'authoring testuale e la validazione sintattica dei modelli architetturali di sistema tramite un'interfaccia IDE moderna.";
        attribute descRole    = "Interfaccia operativa principale per definire l'architettura di sistema (livelli R, F, L) as-code, sfruttando i vantaggi del versioning testuale.";
        attribute descOutput  = "File sorgente SysML v2 (.sysml), workspace configurati, diagnostica degli errori in tempo reale.";
        attribute descModules = "SysML v2 Release Extension; Language Server Protocol (LSP) Client; Git Integration.";
        attribute descWiki    = "https://github.com/SystemsModeling/SysML-v2-Release";
    }

    item EclipseSysON : SoftwareTool {
        attribute toolName    = "Eclipse SysON";
        attribute vendor      = "Eclipse Foundation";
        attribute version     = "1.x.x";
        attribute toolType    = "MBSE Modeling Platform";
        attribute scope       = "Systems Engineering";
        attribute license     = "Eclipse Public License (EPL) 2.0";
        attribute description = "Piattaforma di modellazione open-source progettata nativamente per supportare la specifica SysML v2.";

        attribute descPurpose = "Fornire un ambiente integrato per la modellazione grafica e testuale di sistemi complessi basati sul nuovo standard.";
        attribute descRole    = "Strumento di authoring visivo e gestione del repository dei modelli SysML v2, utile per le design review interattive e l'analisi della tracciabilità.";
        attribute descOutput  = "Viste grafiche dei modelli (BBD, IBD, Use Cases), archivi di progetto, diagrammi esportati in vari formati visivi.";
        attribute descModules = "SysML v2 Text Editor; Graphical Diagram Editors; Model Explorer.";
        attribute descWiki    = "https://syson.org/";
    }

    item CustomSysmlVisualizer : SoftwareTool {
        attribute toolName    = "SysML v2 Visualizer";
        attribute vendor      = "In-house Tool";
        attribute version     = "1.0.0";
        attribute toolType    = "Visualization Utility";
        attribute scope       = "Systems Engineering / Review";
        attribute license     = "Proprietary (In-house)";
        attribute description = "Utility proprietaria per il rendering e l'esplorazione visiva dinamica di file .sysml.";

        attribute descPurpose = "Generare automaticamente diagrammi e alberi di tracciabilità a partire dal codice SysML v2 per facilitare la comprensione del modello.";
        attribute descRole    = "Ponte comunicativo: traduce l'architettura \"text-based\" creata dagli ingegneri in viste consumabili da stakeholder e project manager.";
        attribute descOutput  = "Dashboard interattive web, grafi di dipendenza (nodes/edges), esportazioni SVG/PDF ad alta risoluzione.";
        attribute descModules = "SysML v2 Parser Core; Rendering Engine (es. D3.js/Graphviz); Web UI Frontend.";
        attribute descWiki    = "Link alla Wiki di progetto interna";
    }

    item GitVersionControl : SoftwareTool {
        attribute toolName    = "Git";
        attribute vendor      = "Software Freedom Conservancy";
        attribute version     = "2.4x";
        attribute toolType    = "Version Control System (VCS)";
        attribute scope       = "Cross-domain Configuration Management";
        attribute license     = "GPL-2.0";
        attribute description = "Sistema di controllo di versione distribuito standard de-facto per tracciare le modifiche ai file.";

        attribute descPurpose = "Garantire la tracciabilità granulare, la storia delle modifiche e la collaborazione parallela su tutto il codice sorgente e i modelli as-code.";
        attribute descRole    = "Motore infrastrutturale di Configuration Management; abbinato a GitLab, gestisce il Single Source of Truth dell'intero progetto (codice, SysML, script).";
        attribute descOutput  = "Commit history, branch di sviluppo logici, tag di release, patch e diff.";
        attribute descModules = "Git CLI; Git Daemon; Hooks.";
        attribute descWiki    = "https://git-scm.com/doc";
    }

    view toolView : ToolView {
        doc /* Vista degli strumenti software del progetto. */
        expose GitLab;
    }
}
