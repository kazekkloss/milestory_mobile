package com.example.milestory_mobile

import com.example.milestory_mobile.tourtracker.TourTrackerChannel
import com.example.milestory_mobile.tourtracker.TourTrackerChannel.Companion.PERMISSION_REQUEST_CODE
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {

    private lateinit var tourTrackerChannel: TourTrackerChannel

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        tourTrackerChannel = TourTrackerChannel(this)
        tourTrackerChannel.register(flutterEngine.dartExecutor.binaryMessenger)
    }

    @Deprecated("Use ActivityResultLauncher for new code")
    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        tourTrackerChannel.handlePermissionResult(requestCode, grantResults)
    }
}
