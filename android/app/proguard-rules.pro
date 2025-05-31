# Empêche R8 de supprimer les classes TensorFlow Lite GPU
-keep class org.tensorflow.lite.** { *; }
-dontwarn org.tensorflow.lite.**
-keep class com.dexterous.** { *; }
-keep class me.carda.awesome_notifications.** { *; }
