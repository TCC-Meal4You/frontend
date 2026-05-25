package com.example.meal4you

import android.content.Intent
import android.content.ActivityNotFoundException
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "meal4you_app/google_maps_launcher"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                if (call.method == "open") {
                    val query = call.argument<String>("query")
                    if (query.isNullOrBlank()) {
                        result.error("INVALID_QUERY", "Consulta vazia", null)
                        return@setMethodCallHandler
                    }

                    try {
                        val geoUri = Uri.parse("geo:0,0?q=${Uri.encode(query)}")
                        val geoIntent = Intent(Intent.ACTION_VIEW, geoUri)
                        geoIntent.setPackage("com.google.android.apps.maps")
                        geoIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        try {
                            startActivity(geoIntent)
                            result.success(true)
                            return@setMethodCallHandler
                        } catch (_: ActivityNotFoundException) {
                            // Fall through to browser web URL.
                        }

                        val encoded = Uri.encode(query)
                        val webUri = Uri.parse("https://www.google.com/maps/search/?api=1&query=$encoded")
                        val webIntent = Intent(Intent.ACTION_VIEW, webUri)
                        webIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        startActivity(webIntent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("OPEN_FAILED", e.message, null)
                    }
                } else {
                    result.notImplemented()
                }
            }
    }
}
