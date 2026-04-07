@echo off
title Enrolement MDM - Salama Mamba

echo Connexion a l'appareil...
adb wait-for-device

echo.
echo Tentative d'activation du Device Admin...

:: Remplacez com.example.checkpoint_app par votre package ID reel si different
adb shell dpm set-device-owner com.example.checkpoint_app/.MyDeviceAdminReceiver

if %errorlevel% equ 0 (
    echo.
    echo [SUCCES] L'appareil est desormais sous gestion MDM (Device Owner).
) else (
    echo.
    echo [ERREUR] L'enrolement a echoue.
    echo Assurez-vous qu'aucun compte (Google, etc.) n'est configure sur le telephone.
)

pause