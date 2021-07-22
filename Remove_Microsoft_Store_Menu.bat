::&cls&:: Эта строчка должна быть первой. Скрывает ошибку из-за метки BOM, если батник "UTF-8 c BOM"
@echo off
chcp 65001 >nul
cd /d "%~dp0"

:: Если этот батник запущен без прав администратора, то перезапуск этого батника с запросом прав администратора.
reg query "HKU\S-1-5-19\Environment" >nul 2>&1 & cls
if "%Errorlevel%" NEQ "0" PowerShell.exe -WindowStyle Hidden -NoProfile -NoLogo -Command "Start-Process -Verb RunAS -FilePath '%0'"&cls&exit

:: Используется PowerShell.

:MenuIn
echo.
echo.  Получение данных по приложениям ...
echo.
chcp 866 >nul
set Store=
for /f "delims=" %%I in (' PowerShell.exe "Get-AppXPackage | Where-Object Name -Like *WindowsStore*" ') do set Store=1
for /f "delims=" %%I in (' PowerShell.exe "Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like *WindowsStore*" ') do set Store=1
set PurchaseApp=
for /f "delims=" %%I in (' PowerShell.exe "Get-AppXPackage | Where-Object Name -Like *StorePurchaseApp*" ') do set PurchaseApp=1
for /f "delims=" %%I in (' PowerShell.exe "Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like *StorePurchaseApp*" ') do set PurchaseApp=1
set DesktopApp=
for /f "delims=" %%I in (' PowerShell.exe "Get-AppXPackage | Where-Object Name -Match 'DesktopAppInstaller|UWPDesktop'" ') do set DesktopApp=1
for /f "delims=" %%I in (' PowerShell.exe "Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like *DesktopAppInstaller*" ') do set DesktopApp=1
set XboxIdentity=
for /f "delims=" %%I in (' PowerShell.exe "Get-AppXPackage | Where-Object Name -Like *XboxIdentityProvider*" ') do set XboxIdentity=1
for /f "delims=" %%I in (' PowerShell.exe "Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like *XboxIdentityProvider*" ') do set XboxIdentity=1
chcp 65001 >nul

if not defined Store ( set Store=Не найден ) else ( set Store=Установлен )
if not defined PurchaseApp ( set PurchaseApp=Не найден ) else ( set PurchaseApp=Установлен )
if not defined DesktopApp ( set DesktopApp=Не найден ) else ( set DesktopApp=Установлен )
if not defined XboxIdentity ( set XboxIdentity=Не найден ) else ( set XboxIdentity=Установлен )

:Menu
cls
echo.
echo.    ================================
echo.        Удаление Microsoft Store
echo.    ================================
echo.
echo.        Варианты для выбора:
echo.
echo.    [1] = Удалить Windows Store           ^| %Store%
echo.    [2] = Удалить Store Purchase App      ^| %PurchaseApp%
echo.    [3] = Удалить Desktop App Installer   ^| %DesktopApp%
echo.    [4] = Удалить Xbox Identity Provider  ^| %XboxIdentity%
echo.    [5] = Удалить Всё сразу
echo.
echo.    [Без ввода] = Выход
echo.
set "input="
set /p input=*  Ваш выбор: 
if not defined input ( echo.&echo.     - Выход -  & echo.
		       TIMEOUT /T 2 >nul & exit )
if "%input%"=="1" ( Call :Remove "WindowsStore" & goto :MenuIn )
if "%input%"=="2" ( Call :Remove "StorePurchaseApp" & goto :MenuIn )
if "%input%"=="3" ( Call :Remove "DesktopAppInstaller,UWPDesktop" & goto :MenuIn )
if "%input%"=="4" ( Call :Remove "XboxIdentityProvider" & goto :MenuIn )
if "%input%"=="5" ( Call :Remove "WindowsStore,StorePurchaseApp,DesktopAppInstaller,UWPDesktop,XboxIdentityProvider" & goto :MenuIn
) else (
 echo.&echo.     Неправильный выбор & echo.
 TIMEOUT /T 2 >nul & goto :Menu )


:Remove
for %%I in (%~1) do (
  echo.
  echo     Удаление: %%I
  chcp 866 >nul
  PowerShell.exe Get-AppXPackage ^| Where-Object Name -Like '*%%I*' ^| ForEach-Object { Remove-AppxPackage $_.PackageFullName -ErrorAction Continue }
  PowerShell.exe Get-AppxProvisionedPackage -Online ^| Where-Object DisplayName -like '*%%I*' ^| Remove-AppxProvisionedPackage -Online -ErrorAction Continue
  chcp 65001 >nul
)
echo.
echo.    Завершено
echo.
echo.Для продолжения нажмите любую клавишу ...
TIMEOUT /T -1 >nul
exit /b

