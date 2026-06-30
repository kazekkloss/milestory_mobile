package com.example.milestory_mobile.tourtracker

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class TourTrackerChannel(private val activity: Activity) {

    private val checkpoint = CheckPoint()
    private var locationSink: EventChannel.EventSink? = null
    private var checkpointSink: EventChannel.EventSink? = null
    private var pendingStart = false

    fun register(messenger: BinaryMessenger) {
        MethodChannel(messenger, "milestory/tour_tracker")
            .setMethodCallHandler(::handleMethodCall)

        EventChannel(messenger, "milestory/tour_tracker/location").setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                    Log.d(TAG, "locationStream: onListen")
                    locationSink = events
                }
                override fun onCancel(arguments: Any?) {
                    Log.d(TAG, "locationStream: onCancel")
                    locationSink = null
                }
            }
        )

        EventChannel(messenger, "milestory/tour_tracker/checkpoint").setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                    Log.d(TAG, "checkpointStream: onListen")
                    checkpointSink = events
                }
                override fun onCancel(arguments: Any?) {
                    Log.d(TAG, "checkpointStream: onCancel")
                    checkpointSink = null
                }
            }
        )
    }

    fun handlePermissionResult(requestCode: Int, grantResults: IntArray) {
        val granted = grantResults.isNotEmpty() &&
            grantResults[0] == PackageManager.PERMISSION_GRANTED
        when (requestCode) {
            PERMISSION_REQUEST_CODE -> {
                Log.d(TAG, "handlePermissionResult: foreground granted=$granted, pendingStart=$pendingStart")
                if (granted && pendingStart) {
                    proceedAfterForegroundPermission()
                }
            }
            BACKGROUND_PERMISSION_REQUEST_CODE -> {
                Log.d(TAG, "handlePermissionResult: background granted=$granted, pendingStart=$pendingStart")
                if (pendingStart) {
                    doStartForegroundService()
                }
            }
        }
    }

    private fun handleMethodCall(call: MethodCall, result: MethodChannel.Result) {
        Log.d(TAG, "method: ${call.method}")
        when (call.method) {
            "requestPermission" -> {
                requestPermission()
                result.success(null)
            }
            "startTracking" -> {
                startForegroundService()
                result.success(null)
            }
            "stopTracking" -> {
                pendingStart = false
                stopForegroundService()
                result.success(null)
            }
            "setTourPoints" -> {
                val points = call.arguments as? List<*>
                if (points == null) {
                    result.error("INVALID_ARGS", "Expected List", null)
                    return
                }
                Log.d(TAG, "setTourPoints: ${points.size} tour points")
                checkpoint.setTourPoints(points)
                result.success(null)
            }
            "isIgnoringBatteryOptimizations" -> result.success(isIgnoringBatteryOptimizations())
            "requestIgnoreBatteryOptimizations" -> {
                requestIgnoreBatteryOptimizations()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    private fun startForegroundService() {
        if (!isLocationPermissionGranted()) {
            Log.d(TAG, "startTracking: foreground permission not granted — waiting for user")
            pendingStart = true
            requestPermission()
            return
        }
        proceedAfterForegroundPermission()
    }

    private fun proceedAfterForegroundPermission() {
        if (!isBackgroundLocationGranted()) {
            Log.d(TAG, "startTracking: requesting background location permission")
            pendingStart = true
            ActivityCompat.requestPermissions(
                activity,
                arrayOf(Manifest.permission.ACCESS_BACKGROUND_LOCATION),
                BACKGROUND_PERMISSION_REQUEST_CODE,
            )
            return
        }
        doStartForegroundService()
    }

    private fun doStartForegroundService() {
        Log.d(TAG, "doStartForegroundService")
        pendingStart = false
        LocationForegroundService.locationUpdateCallback = { location, bearing ->
            val lat = location.latitude
            val lng = location.longitude
            Log.d(TAG, "location update: $lat, $lng, bearing: $bearing")
            locationSink?.success(mapOf("latitude" to lat, "longitude" to lng))
            checkpoint.check(lat, lng, bearing)?.let { (tourPointId, areaId) ->
                Log.d(TAG, "CHECKPOINT HIT — tourPoint: $tourPointId, area: $areaId")
                checkpointSink?.success(mapOf("tourPointId" to tourPointId, "areaId" to areaId))
            }
        }
        LocationForegroundService.errorCallback = { message ->
            Log.e(TAG, "location error: $message")
            locationSink?.error("LOCATION_ERROR", message, null)
        }
        val intent = Intent(activity, LocationForegroundService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            activity.startForegroundService(intent)
        } else {
            activity.startService(intent)
        }
    }

    private fun stopForegroundService() {
        Log.d(TAG, "stopForegroundService")
        LocationForegroundService.locationUpdateCallback = null
        LocationForegroundService.errorCallback = null
        activity.stopService(Intent(activity, LocationForegroundService::class.java))
    }

    private fun requestPermission() {
        if (isLocationPermissionGranted()) return
        Log.d(TAG, "requestPermission: showing system dialog")
        ActivityCompat.requestPermissions(
            activity,
            arrayOf(
                Manifest.permission.ACCESS_FINE_LOCATION,
                Manifest.permission.ACCESS_COARSE_LOCATION,
            ),
            PERMISSION_REQUEST_CODE,
        )
    }

    private fun isLocationPermissionGranted(): Boolean =
        ContextCompat.checkSelfPermission(activity, Manifest.permission.ACCESS_FINE_LOCATION) ==
            PackageManager.PERMISSION_GRANTED

    private fun isBackgroundLocationGranted(): Boolean =
        Build.VERSION.SDK_INT < Build.VERSION_CODES.Q ||
            ContextCompat.checkSelfPermission(activity, Manifest.permission.ACCESS_BACKGROUND_LOCATION) ==
                PackageManager.PERMISSION_GRANTED

    private fun isIgnoringBatteryOptimizations(): Boolean {
        val powerManager = activity.getSystemService(Context.POWER_SERVICE) as PowerManager
        return powerManager.isIgnoringBatteryOptimizations(activity.packageName)
    }

    private fun requestIgnoreBatteryOptimizations() {
        if (isIgnoringBatteryOptimizations()) {
            Log.d(TAG, "battery optimizations already ignored")
            return
        }
        Log.d(TAG, "requesting to ignore battery optimizations")
        val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
            data = Uri.parse("package:${activity.packageName}")
        }
        activity.startActivity(intent)
    }

    companion object {
        private const val TAG = "[TourTracker]"
        const val PERMISSION_REQUEST_CODE = 1001
        const val BACKGROUND_PERMISSION_REQUEST_CODE = 1002
    }
}
