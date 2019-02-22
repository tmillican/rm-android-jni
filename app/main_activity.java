static {
    java.lang.System.loadLibrary("hello-jni");
}

public native java.lang.String stringFromJNI();
