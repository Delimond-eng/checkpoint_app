# Empêche R8 de supprimer les classes TensorFlow Lite GPU
-keep class org.tensorflow.lite.** { *; }
-dontwarn org.tensorflow.lite.**
