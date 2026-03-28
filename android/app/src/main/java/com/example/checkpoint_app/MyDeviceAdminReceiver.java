package com.example.checkpoint_app;

import android.app.admin.DeviceAdminReceiver;
import android.content.Context;
import android.content.Intent;
import android.widget.Toast;
import androidx.annotation.NonNull;

/**
 * Receiver responsable de la gestion des privilèges d'administration de l'appareil.
 * C'est cette classe qui est ciblée par la commande ADB dpm set-device-owner.
 */
public class MyDeviceAdminReceiver extends DeviceAdminReceiver {

    @Override
    public void onEnabled(@NonNull Context context, @NonNull Intent intent) {
        super.onEnabled(context, intent);
        Toast.makeText(context, "Administration de l'appareil activée", Toast.LENGTH_SHORT).show();
    }

    @Override
    public void onDisabled(@NonNull Context context, @NonNull Intent intent) {
        super.onDisabled(context, intent);
        Toast.makeText(context, "Administration de l'appareil désactivée", Toast.LENGTH_SHORT).show();
    }
}
