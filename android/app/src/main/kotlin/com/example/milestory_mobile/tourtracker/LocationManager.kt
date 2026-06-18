package com.example.milestory_mobile.tourtracker

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager as AndroidLocationManager
import android.os.Looper
import android.util.Log
import androidx.core.content.ContextCompat

class LocationManager(private val context: Context) {

    var onLocationUpdate: ((Location) -> Unit)? = null
    var onError: ((String) -> Unit)? = null

    private val systemManager =
        context.getSystemService(Context.LOCATION_SERVICE) as AndroidLocationManager

    private val listener = LocationListener { location -> onLocationUpdate?.invoke(location) }

    fun start() {
        if (ContextCompat.checkSelfPermission(context, Manifest.permission.ACCESS_FINE_LOCATION)
            != PackageManager.PERMISSION_GRANTED
        ) {
            Log.e(TAG, "start: permission not granted")
            onError?.invoke("Location permission not granted")
            return
        }
        val provider = when {
            systemManager.isProviderEnabled(AndroidLocationManager.GPS_PROVIDER) ->
                AndroidLocationManager.GPS_PROVIDER
            systemManager.isProviderEnabled(AndroidLocationManager.NETWORK_PROVIDER) ->
                AndroidLocationManager.NETWORK_PROVIDER
            else -> {
                Log.e(TAG, "start: no location provider available")
                onError?.invoke("No location provider available")
                return
            }
        }
        Log.d(TAG, "start: using provider=$provider")
        systemManager.requestLocationUpdates(provider, 0L, 5f, listener, Looper.getMainLooper())
    }

    fun stop() {
        Log.d(TAG, "stop")
        systemManager.removeUpdates(listener)
    }

    companion object {
        private const val TAG = "[TourTracker]"
    }
}
