package com.example.checkpoint_app;

import android.app.ActivityManager;
import android.app.admin.DevicePolicyManager;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
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
 * Configuration : Barre de navigation masquée (swipe pour afficher), Barre de statut visible.
 */
public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.example.checkpoint_app/mdm";
    private DevicePolicyManager dpm;
    private ComponentName adminComponent;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        // Empêcher l'écran de s'éteindre
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        
        dpm = (DevicePolicyManager) getSystemService(Context.DEVICE_POLICY_SERVICE);
        adminComponent = new ComponentName(this, MyDeviceAdminReceiver.class);
        
        // Appliquer le masquage de la barre de navigation dès le départ
        applyImmersiveNavigation();

        // Si l'application est Device Owner, activer le mode kiosque
        if (dpm != null && dpm.isDeviceOwnerApp(getPackageName())) {
            setKioskMode(true);
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        // Ré-appliquer la visibilité système au retour sur l'app
        applyImmersiveNavigation();
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
     */
    private boolean setKioskMode(boolean active) {
        try {
            if (active) {
                if (dpm != null && dpm.isDeviceOwnerApp(getPackageName())) {
                    dpm.setLockTaskPackages(adminComponent, new String[]{getPackageName()});
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        dpm.setKeyguardDisabled(adminComponent, true);
                        // La barre de statut reste visible (false = non désactivée)
                        dpm.setStatusBarDisabled(adminComponent, false);
                    }
                    startLockTask();
                    applyImmersiveNavigation();
                    return true;
                }
            } else {
                stopLockTask();
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && dpm != null && dpm.isDeviceOwnerApp(getPackageName())) {
                    dpm.setKeyguardDisabled(adminComponent, false);
                }
                applyImmersiveNavigation();
                return true;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    private boolean isKioskModeActive() {
        ActivityManager am = (ActivityManager) getSystemService(Context.ACTIVITY_SERVICE);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            return am.getLockTaskModeState() != ActivityManager.LOCK_TASK_MODE_NONE;
        }
        return false;
    }

    /**
     * Applique les flags pour masquer la barre de navigation (bas) uniquement.
     * Le flag IMMERSIVE_STICKY permet de la faire apparaître temporairement via un swipe.
     */
    private void applyImmersiveNavigation() {
        View decorView = getWindow().getDecorView();
        int uiOptions = View.SYSTEM_UI_FLAG_HIDE_NAVIGATION 
                | View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
                | View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION;
        decorView.setSystemUiVisibility(uiOptions);
    }

    @Override
    public void onWindowFocusChanged(boolean hasFocus) {
        super.onWindowFocusChanged(hasFocus);
        if (hasFocus) {
            applyImmersiveNavigation();
        }
    }
}
