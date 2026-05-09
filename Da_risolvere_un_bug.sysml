/**
 * LIFECYCLE_ADVANCED.sysml
 * ──────────────────────────────────────────────────────────────────────────
 * File dimostrativo completo di tutte le funzionalità della LifecycleView
 * nel Visualizer v5. Mostra:
 *
 *  ① Fasi con tutti gli attributi supportati
 *     (phaseName, status, owner, startDate, endDate, progress, notes)
 *
 *  ② Passaggi tra fasi (PassageEvent) con content e date
 *
 *  ③ Iterazioni/rework (IterationEvent) con reason e date
 *     → generano righe "Run N" separate nel diagramma
 *
 *  ④ Quality Gates (Entry / Exit) con condition
 *
 *  ⑤ Internal Occurrences (PhaseOccurrence) → lista punti dentro ogni fase
 *
 *  ⑥ Status inferito automaticamente dagli eventi (senza attributo esplicito)
 *
 *  ⑦ Progresso calcolato dalle date (senza attributo progress esplicito)
 *
 * Convenzione parser (sysmlParser.js / collectLifecycleData):
 *  – item X : Lifecycle          → radice del lifecycle
 *  – item X : Phase              → fase (match case-insensitive)
 *  – item X : Gate               → quality gate dentro una fase
 *  – occurrence X : PhaseOccurrence → milestone/attività interna
 *  – occurrence X : PassageEvent → transizione tra due fasi
 *  – occurrence X : IterationEvent → loop/rework a una fase precedente
 */

package LifeCycle { //TODO: Applicare modifiche alla funzione delle lifecycle, perchè ad ora costringe a mettere le iterazioni interne nella fase, finendo per mostrarle in ogni momento (si potrebbe realizzare una visualizzazione dove solo quelli aggiunti in quella iterazione sono mostrati in grassetto)
    doc /* Dimostrazione completa della LifecycleView per il SysML v2 Visualizer v5 */

    private import ViewDefinitions::*;

    // ══════════════════════════════════════════════════════════════════
    //  DEFINIZIONI DEL CICLO DI VITA DEL PROGETTO
    // ══════════════════════════════════════════════════════════════════

    /**
     * Radice del Lifecycle — il parser cerca un item : Lifecycle
     * e usa i suoi figli come fasi ed eventi.
     */
    item projectLifecycle : Lifecycle {
        doc /* Ciclo di vita completo del progetto V2X-CACC:
             * dalla concezione iniziale fino al ritiro del sistema. */

        // ── ① FASE: Concept ──────────────────────────────────────────────
        item phaseA : Phase {
            doc /* Definizione iniziale dei requisiti e fattibilità del sistema. */
            attribute phaseName = "Concept";
            attribute status    = "completed";   // esplicito: completed
            attribute owner     = "Prof. Bianchi";
            attribute startDate = "2025-01-10";
            attribute endDate   = "2025-03-31";
            attribute progress  = 100;           // 100% — fase chiusa
            attribute notes     = "Feasibility study approvato. SoS identificato.";

            // Quality Gate EXIT: condizione per passare alla fase successiva
            item gate_conceptExit : Gate {
                attribute condition = "Feasibility Review Approvata";
                attribute gateType  = "exit";
            }

            // Internal Occurrences — milestone interne visibili nel box
            occurrence occ_A1 : PhaseOccurrence {
                attribute content = "Analisi dei requisiti degli stakeholder";
            }
            occurrence occ_A2 : PhaseOccurrence {
                attribute content = "Studio di fattibilità tecnica e economica";
            }
            occurrence occ_A3 : PhaseOccurrence {
                attribute content = "Identificazione del System-of-Systems";
            }
        }

        // ── ② FASE: Requirements ─────────────────────────────────────────
        item phaseB : Phase {
            doc /* Cattura e formalizzazione dei requisiti di sistema. */
            attribute phaseName = "Requirements";
            attribute status    = "completed";
            attribute owner     = "Ing. Rossi";
            attribute startDate = "2025-04-01";
            attribute endDate   = "2025-05-31";
            attribute progress  = 100;

            // Quality Gate ENTRY: condizione per entrare in questa fase
            item gate_reqEntry : Gate {
                attribute condition = "Concept Review Superata";
                attribute gateType  = "entry";
            }
            // Quality Gate EXIT
            item gate_reqExit : Gate {
                attribute condition = "Requirements Baseline Congelata";
                attribute gateType  = "exit";
            }

            occurrence occ_B1 : PhaseOccurrence {
                attribute content = "Requisiti funzionali del sistema (SYS-F-*)";
            }
            occurrence occ_B2 : PhaseOccurrence {
                attribute content = "Requisiti non-funzionali (safety, security, perf.)";
            }
            occurrence occ_B3 : PhaseOccurrence {
                attribute content = "Traceability matrix vers. 1.0";
            }
            occurrence occ_B4 : PhaseOccurrence {
                attribute content = "Validazione con gli stakeholder";
            }
        }

        // ── ③ FASE: System Design ────────────────────────────────────────
        item phaseC : Phase {
            doc /* Architettura e progettazione del sistema V2X-CACC. */
            attribute phaseName = "System Design";
            attribute status    = "completed";
            attribute owner     = "Team Architettura";
            attribute startDate = "2025-06-01";
            attribute endDate   = "2025-08-31";
            attribute progress  = 100;

            item gate_designEntry : Gate {
                attribute condition = "Requirements Sign-Off ricevuto";
                attribute gateType  = "entry";
            }
            item gate_designExit : Gate {
                attribute condition = "Preliminary Design Review (PDR) Superata";
                attribute gateType  = "exit";
            }

            occurrence occ_C1 : PhaseOccurrence {
                attribute content = "Architettura SysML v2 del top-level system";
            }
            occurrence occ_C2 : PhaseOccurrence {
                attribute content = "Definizione delle interfacce V2V / V2I / HMI";
            }
            occurrence occ_C3 : PhaseOccurrence {
                attribute content = "Analisi SOTIF e FMEA preliminare";
            }
        }

        // ── ④ FASE: Implementation ───────────────────────────────────────
        item phaseD : Phase {
            doc /* Sviluppo software e firmware del sistema CACC su FPGA. */
            attribute phaseName = "Implementation";
            attribute status    = "active";      // fase corrente
            attribute owner     = "Team Sviluppo";
            attribute startDate = "2025-09-01";
            attribute endDate   = "2026-04-30";
            // Nessun attributo progress: verrà calcolato dalle date
            attribute notes     = "Sprint attuale: modulo Car-Following IDM 2D.";

            item gate_implEntry : Gate {
                attribute condition = "Critical Design Review (CDR) Completata";
                attribute gateType  = "entry";
            }
            item gate_implExit : Gate {
                attribute condition = "Code Freeze + Unit Test Coverage >= 90%";
                attribute gateType  = "exit";
            }

            occurrence occ_D1 : PhaseOccurrence {
                attribute content = "Modulo InputGateway V2V/V2I";
            }
            occurrence occ_D2 : PhaseOccurrence {
                attribute content = "Elaboration: IDM 2D Car-Following";
            }
            occurrence occ_D3 : PhaseOccurrence {
                attribute content = "OutputGateway: HMI + CAM composer";
            }
            occurrence occ_D4 : PhaseOccurrence {
                attribute content = "State Machine: fallback e degraded mode";
            }
            occurrence occ_D5 : PhaseOccurrence {
                attribute content = "Unit Test e Code Review";
            }
        }

        // ── ⑤ FASE: Verification & Validation ───────────────────────────
        item phaseE : Phase {
            doc /* Test di integrazione, simulazione HIL e validazione su strada. */
            attribute phaseName = "V&V";
            attribute status    = "planned";
            attribute owner     = "Team QA";
            attribute startDate = "2026-05-01";
            attribute endDate   = "2026-08-31";
            attribute progress  = 0;

            item gate_vvEntry : Gate {
                attribute condition = "Implementation Exit Gate Superata";
                attribute gateType  = "entry";
            }
            item gate_vvExit : Gate {
                attribute condition = "Qualification Test Report Approvato";
                attribute gateType  = "exit";
            }

            occurrence occ_E1 : PhaseOccurrence {
                attribute content = "Test di integrazione sottosistemi";
            }
            occurrence occ_E2 : PhaseOccurrence {
                attribute content = "Simulazione Hardware-in-the-Loop (HIL)";
            }
            occurrence occ_E3 : PhaseOccurrence {
                attribute content = "Campagna di test su strada (closed track)";
            }
            occurrence occ_E4 : PhaseOccurrence {
                attribute content = "Validazione dei requisiti di safety (ISO 26262)";
            }
        }

        // ── ⑥ FASE: Deployment ──────────────────────────────────────────
        item phaseF : Phase {
            doc /* Rilascio e messa in produzione del sistema. */
            attribute phaseName = "Deployment";
            attribute status    = "planned";
            attribute owner     = "Team Operations";
            attribute startDate = "2026-09-01";
            attribute endDate   = "2026-11-30";
            attribute progress  = 0;

            item gate_depExit : Gate {
                attribute condition = "Operational Readiness Review (ORR) Superata";
                attribute gateType  = "exit";
            }

            occurrence occ_F1 : PhaseOccurrence {
                attribute content = "Rilascio binario certificato";
            }
            occurrence occ_F2 : PhaseOccurrence {
                attribute content = "Documentazione operativa e training";
            }
        }

        // ── ⑦ FASE: Operations & Maintenance ────────────────────────────
        item phaseG : Phase {
            doc /* Fase operativa con monitoraggio continuo e aggiornamenti OTA. */
            attribute phaseName = "O&M";
            attribute status    = "planned";
            attribute owner     = "Team Field";
            attribute startDate = "2026-12-01";
            attribute endDate   = "2028-12-31";
            attribute progress  = 0;
            attribute notes     = "Supporto continuo con update OTA semestrali.";

            occurrence occ_G1 : PhaseOccurrence {
                attribute content = "Monitoraggio telemetria in campo";
            }
            occurrence occ_G2 : PhaseOccurrence {
                attribute content = "Patch di sicurezza e aggiornamenti OTA";
            }
        }

        // ══════════════════════════════════════════════════════════════
        //  PASSAGE EVENTS — transizioni sequenziali tra fasi
        //  Parser: occurrence X : PassageEvent { fromPhase, toPhase, date, content }
        // ══════════════════════════════════════════════════════════════

        occurrence pass_A_B : PassageEvent {
            attribute fromPhase = "Concept";
            attribute toPhase   = "Requirements";
            attribute date      = "2025-03-31";
            attribute content   = "Feasibility Review Approvata";
        }

        occurrence pass_B_C : PassageEvent {
            attribute fromPhase = "Requirements";
            attribute toPhase   = "System Design";
            attribute date      = "2025-05-31";
            attribute content   = "Baseline Requirements v1.0 congelata";
        }

        occurrence pass_C_D : PassageEvent {
            attribute fromPhase = "System Design";
            attribute toPhase   = "Implementation";
            attribute date      = "2025-08-31";
            attribute content   = "PDR Superata — architettura approvata";
        }

        // NOTA: il passaggio D→E non è ancora avvenuto (phaseD è active)
        // Il parser inferirà automaticamente che phaseD è "active"
        // e phaseE, phaseF, phaseG sono "planned".

        // ══════════════════════════════════════════════════════════════
        //  ITERATION EVENTS — rework/loop a una fase precedente
        //  Parser: occurrence X : IterationEvent { fromPhase, toPhase, date, reason }
        //  → Ogni IterationEvent crea una NUOVA RIGA "Run N" nel diagramma
        // ══════════════════════════════════════════════════════════════

        /**
         * ITERAZIONE 1: Durante System Design, i requisiti erano incompleti.
         * Il team è tornato in Requirements per aggiungere i casi d'uso SOTIF.
         */
        occurrence iter_back_to_req : IterationEvent {
            attribute fromPhase = "System Design";
            attribute toPhase   = "Requirements";
            attribute date      = "2025-07-15";
            attribute reason    = "Requisiti SOTIF mancanti — aggiunta UC Safety";
            attribute content   = "Rework Requirements: SOTIF use cases";
        }

        /**
         * ITERAZIONE 2: Durante Implementation, un test HIL preliminare ha
         * rivelato un'architettura inadatta per il Car-Following real-time.
         * Il team è tornato in System Design per ridisegnare il modulo IDM.
         */
        occurrence iter_back_to_design : IterationEvent {
            attribute fromPhase = "Implementation";
            attribute toPhase   = "System Design";
            attribute date      = "2025-12-10";
            attribute reason    = "Architettura IDM 2D non real-time safe — redesign";
            attribute content   = "Redesign: Car-Following su FPGA a logica pipeline";
        }
    }

    // ══════════════════════════════════════════════════════════════════
    //  LIFECYCLE VIEW — entry point per il Visualizer
    // ══════════════════════════════════════════════════════════════════

    view lifecycleView : LifecycleView {
        doc /* Vista del ciclo di vita del progetto V2X-CACC.
             * Mostra tutte le fasi con status, owner, date, progress,
             * quality gates, occurrences interne, passaggi e iterazioni. */
        expose projectLifecycle;
    }
}
