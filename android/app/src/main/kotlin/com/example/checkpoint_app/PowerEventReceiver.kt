package com.example.checkpoint_app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.util.Log
import android.widget.Toast
import android.preference.PreferenceManager

class PowerEventReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        val action = intent?.action
        Log.d("PowerEventReceiver", "Action reçue : $action")

        val prefs = PreferenceManager.getDefaultSharedPreferences(context)
        val editor = prefs.edit()

        val timestamp = System.currentTimeMillis()
        val batteryLevel = getBatteryLevel(context)

        when (action) {
            Intent.ACTION_SHUTDOWN -> {
                editor.putLong("shutdown_time", timestamp)
                editor.putInt("shutdown_battery", batteryLevel)
                Toast.makeText(context, "Extinction détectée !", Toast.LENGTH_LONG).show()
                Log.d("PowerEventReceiver", "Extinction détectée : $timestamp, $batteryLevel%")
            }

            Intent.ACTION_BOOT_COMPLETED -> {
                editor.putLong("boot_time", timestamp)
                editor.putInt("boot_battery", batteryLevel)
                Toast.makeText(context, "Allumage détecté !", Toast.LENGTH_LONG).show()
                Log.d("PowerEventReceiver", "Allumage détecté : $timestamp, $batteryLevel%")
            }
        }

        editor.apply()
    }

    private fun getBatteryLevel(context: Context): Int {
        val batteryIntent = context.registerReceiver(
            null,
            IntentFilter(Intent.ACTION_BATTERY_CHANGED)
        )
        return batteryIntent?.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) ?: -1
    }
}