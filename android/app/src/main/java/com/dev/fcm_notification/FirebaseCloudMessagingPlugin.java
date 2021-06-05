package com.dev.fcm_notification;

import com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin;

import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin;

public class FirebaseCloudMessagingPlugin {
    public static void registerWith(PluginRegistry pluginRegistry) {
        if (alreadyRegisterWith(pluginRegistry))
            return;
        FirebaseMessagingPlugin.registerWith(pluginRegistry.registrarFor("io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin"));
        FlutterLocalNotificationsPlugin.registerWith(pluginRegistry.registrarFor("com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin"));
    }

    private static boolean alreadyRegisterWith(PluginRegistry pluginRegistry) {
        String key = FirebaseCloudMessagingPlugin.class.getCanonicalName();
        if (pluginRegistry.hasPlugin(key))
            return true;
        pluginRegistry.registrarFor(key);
        return false;
    }
}
