package com.example.checkpoint_app

import android.os.Bundle
import android.widget.Toast
import io.flutter.embedding.android.FlutterActivity

class ExitActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Toast.makeText(this, "Sortie du mode kiosque", Toast.LENGTH_LONG).show()
        finishAffinity()
        android.os.Process.killProcess(android.os.Process.myPid())
    }
}
