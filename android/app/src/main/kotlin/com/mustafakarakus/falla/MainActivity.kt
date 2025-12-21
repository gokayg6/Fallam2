package com.mustafakarakus.falla

import android.os.Build
import android.content.Context
import android.view.WindowManager
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.mustafakarakus.falla/display"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "setHighRefreshRate") {
                setHighRefreshRate()
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun setHighRefreshRate() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val window = window
            val windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
            val display = windowManager.defaultDisplay
            val modes = display.supportedModes

            var maxRate = 0f
            var maxModeId = 0

            for (mode in modes) {
                if (mode.refreshRate > maxRate) {
                    maxRate = mode.refreshRate
                    maxModeId = mode.modeId
                }
            }

            if (maxModeId != 0) {
                val params = window.attributes
                params.preferredDisplayModeId = maxModeId
                window.attributes = params
            }
        }
    }
}
