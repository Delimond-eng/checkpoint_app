@echo off
title Desactivation MDM - Salama Mamba

echo Connexion a l'appareil...
adb wait-for-device

echo.
echo Retrait des privileges Device Admin...
adb shell dpm remove-active-admin com.example.checkpoint_app/.MyDeviceAdminReceiver

echo.
echo Tentative de desinstallation de l'application...
adb uninstall com.example.checkpoint_app

if %errorlevel% equ 0 (
    echo.
    echo [SUCCES] Le MDM a ete desactive et l'application a ete supprimee.
) else (
    echo.
    echo [INFO] Le retrait a peut-etre echoue.
    echo Vous devrez peut-etre reinitialiser l'appareil d'usine
    echo ou desactiver manuellement dans Parametres > Securite > Administrateurs.
)

pause