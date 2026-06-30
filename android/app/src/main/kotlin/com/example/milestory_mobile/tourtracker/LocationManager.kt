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
import kotlin.math.atan2
import kotlin.math.cos
import kotlin.math.sin

class LocationManager(private val context: Context) {

    var onLocationUpdate: ((Location, Double?) -> Unit)? = null
    var onError: ((String) -> Unit)? = null

    private val systemManager =
        context.getSystemService(Context.LOCATION_SERVICE) as AndroidLocationManager

    private var lastLocation: Location? = null

    private val listener = LocationListener { location ->
        val bearing = resolveBearing(location)
        onLocationUpdate?.invoke(location, bearing)
        lastLocation = location
    }

    // Prefers GPS-derived bearing (reliable above walking speed), falls back to
    // computing the bearing between the last two fixes once the user has moved
    // far enough for that calculation to be meaningful.
    private fun resolveBearing(location: Location): Double? {
        if (location.hasBearing() && location.hasSpeed() && location.speed >= MIN_SPEED_FOR_GPS_BEARING_MPS) {
            return location.bearing.toDouble()
        }
        val previous = lastLocation ?: return null
        if (previous.distanceTo(location) < MIN_DISTANCE_FOR_BEARING_METERS) return null
        return computeBearing(previous.latitude, previous.longitude, location.latitude, location.longitude)
    }

    // Initial bearing (great-circle) from point 1 to point 2, in degrees [0, 360).
    private fun computeBearing(lat1: Double, lon1: Double, lat2: Double, lon2: Double): Double {
        val phi1 = Math.toRadians(lat1)
        val phi2 = Math.toRadians(lat2)
        val deltaLambda = Math.toRadians(lon2 - lon1)
        val y = sin(deltaLambda) * cos(phi2)
        val x = cos(phi1) * sin(phi2) - sin(phi1) * cos(phi2) * cos(deltaLambda)
        return (Math.toDegrees(atan2(y, x)) + 360.0) % 360.0
    }

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
        lastLocation = null
    }

    companion object {
        private const val TAG = "[TourTracker]"
        private const val MIN_SPEED_FOR_GPS_BEARING_MPS = 0.5f
        private const val MIN_DISTANCE_FOR_BEARING_METERS = 3.0
    }
}
