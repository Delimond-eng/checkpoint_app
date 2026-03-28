package com.example.checkpoint_app;

import android.app.ActivityManager;
import android.app.admin.DevicePolicyManager;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Build;
import android.os.Bundle;
import android.view.View;
import android.view.WindowManager;
import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

/**
 * Activité principale gérant le mode MDM (Kiosque / LockTask) via MethodChannel.
 * Ce code permet de verrouiller l'appareil pour qu'il ne puisse exécuter que cette application.
 */
public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.example.checkpoint_app/mdm";
    private DevicePolicyManager dpm;
    private ComponentName adminComponent;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        // Maintenir l'écran allumé pendant l'utilisation de l'application
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        
        dpm = (DevicePolicyManager) getSystemService(Context.DEVICE_POLICY_SERVICE);
        adminComponent = new ComponentName(this, MyDeviceAdminReceiver.class);
        
        // Si l'application est configurée comme Device Owner, activer le mode kiosque au démarrage
        if (dpm != null && dpm.isDeviceOwnerApp(getPackageName())) {
            setKioskMode(true);
        }
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
            .setMethodCallHandler((call, result) -> {
                switch (call.method) {
                    case "lockDevice":
                        result.success(setKioskMode(true));
                        break;
                    case "unlockDevice":
                        result.success(setKioskMode(false));
                        break;
                    case "isDeviceLocked":
                        result.success(isKioskModeActive());
                        break;
                    default:
                        result.notImplemented();
                        break;
                }
            });
    }

    /**
     * Active ou désactive le mode Kiosque.
     * @param active true pour verrouiller, false pour déverrouiller.
     * @return true si l'opération a réussi.
     */
    private boolean setKioskMode(boolean active) {
        try {
            if (active) {
                if (dpm != null && dpm.isDeviceOwnerApp(getPackageName())) {
                    // Autoriser l'application à s'épingler (LockTask)
                    dpm.setLockTaskPackages(adminComponent, new String[]{getPackageName()});
                    startLockTask();
                    hideSystemUI();
                    
                    // Bloquer la barre de statut et les notifications si possible (Android 6.0+)
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        dpm.setKeyguardDisabled(adminComponent, true);
                        dpm.setStatusBarDisabled(adminComponent, true);
                    }
                    return true;
                }
            } else {
                // Arrêter le mode LockTask et réactiver l'UI système
                stopLockTask();
                showSystemUI();
                
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && dpm != null && dpm.isDeviceOwnerApp(getPackageName())) {
                    dpm.setKeyguardDisabled(adminComponent, false);
                    dpm.setStatusBarDisabled(adminComponent, false);
                }
                return true;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Vérifie si l'application est actuellement épinglée à l'écran.
     */
    private boolean isKioskModeActive() {
        ActivityManager am = (ActivityManager) getSystemService(Context.ACTIVITY_SERVICE);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            return am.getLockTaskModeState() != ActivityManager.LOCK_TASK_MODE_NONE;
        }
        return false;
    }

    /**
     * Cache la barre de navigation et la barre de statut pour une immersion totale.
     */
    private void hideSystemUI() {
        View decorView = getWindow().getDecorView();
        int uiOptions = View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
                | View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                | View.SYSTEM_UI_FLAG_FULLSCREEN;
        decorView.setSystemUiVisibility(uiOptions);
    }

    /**
     * Réaffiche les éléments système standards.
     */
    private void showSystemUI() {
        View decorView = getWindow().getDecorView();
        int uiOptions = View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN;
        decorView.setSystemUiVisibility(uiOptions);
    }

    @Override
    public void onWindowFocusChanged(boolean hasFocus) {
        super.onWindowFocusChanged(hasFocus);
        // S'assurer que l'UI reste cachée si le mode kiosque est actif et qu'on perd le focus (ex: popups)
        if (hasFocus && isKioskModeActive()) {
            hideSystemUI();
        }
    }
}
