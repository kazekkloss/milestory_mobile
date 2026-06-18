package com.example.milestory_mobile.tourtracker

import android.Manifest
import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
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
        if (requestCode != PERMISSION_REQUEST_CODE) return
        val granted = grantResults.isNotEmpty() &&
            grantResults[0] == PackageManager.PERMISSION_GRANTED
        Log.d(TAG, "handlePermissionResult: granted=$granted, pendingStart=$pendingStart")
        if (granted && pendingStart) {
            doStartForegroundService()
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
            else -> result.notImplemented()
        }
    }

    private fun startForegroundService() {
        if (!isLocationPermissionGranted()) {
            Log.d(TAG, "startTracking: permission not granted — waiting for user")
            pendingStart = true
            requestPermission()
            return
        }
        doStartForegroundService()
    }

    private fun doStartForegroundService() {
        Log.d(TAG, "doStartForegroundService")
        pendingStart = false
        LocationForegroundService.locationUpdateCallback = { location ->
            val lat = location.latitude
            val lng = location.longitude
            Log.d(TAG, "location update: $lat, $lng")
            locationSink?.success(mapOf("latitude" to lat, "longitude" to lng))
            checkpoint.check(lat, lng)?.let { (tourPointId, areaId) ->
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

    companion object {
        private const val TAG = "[TourTracker]"
        const val PERMISSION_REQUEST_CODE = 1001
    }
}
