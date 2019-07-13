@echo off
FOR /f "tokens=1-4 delims=:.," %%T IN ( "%TIME%" ) DO (
set /a StartTime=100%%T %% 100*360000+100%%U %% 100*6000+100%%V %% 100*100+100%%W %% 100
)

echo Start time: %TIME%

"C:\Users\Sergey\Documents\Github\MTG-SAMP\pawno\pawncc.exe" "%1" -; -(

FOR /f "tokens=1-4 delims=:.," %%T IN ( "%TIME%" ) DO (
SET /a FinishTime=100%%T %% 100*360000+100%%U %% 100*6000+100%%V %% 100*100+100%%W %% 100
)

SET /a FinishTime=%FinishTime%-%StartTime%
SET /a FinishTime=%FinishTime%*10
SET /a FinishTime2=%FinishTime%/10

echo Finish time: %TIME% -- (%FinishTime% ms)
start "" cmd /c "echo Compile finished!&echo(&pause"
