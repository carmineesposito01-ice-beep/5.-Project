@echo off
echo Avvio di Jupyter Lab in corso...

:: Imposta come cartella di lavoro la stessa cartella in cui si trova questo script .bat
cd /d "%~dp0"

:: Attiva l'ambiente Miniconda per i permessi
call C:\Miniconda\Scripts\activate.bat

echo Apertura diretta del localhost nel browser...

:: Avvia Jupyter Lab forzando l'apertura dell'URL diretto invece del file HTML temporaneo
jupyter lab --ServerApp.use_redirect_file=False

:: Mantiene la finestra aperta in caso di errori
pause