# rm-android-jni

This is a sample app that calls C code from RubyMotion on Android. It is
configured to be built for the x86 ABI, but it should be easily adaptable to
other architectures.

## Build Instructions

A recent version of the Android NDK (It uses `cmake` instead of
`ndk-build`). Simply download and the MacOS .zip and unzip it wherever you'd
like. For the sake of example, assume that the `$NDK` environment variable
points to the unzipped NDK.

From the `rm-android-jni` project folder, generate the `Makefile` for the JNI:

    $ cmake -DCMAKE_TOOLCHAIN_FILE=$NDK/build/cmake/android.toolchain.cmake \
    -DANDROID_ABI=x86 app/cpp

Generate the native library:

    $ cd app/cpp
    $ make
    $ cd ../..

This will produce `libhello-jni.so` in `app/cpp`. Then:

    $ mkdir -p vendor/x86
    $ mv app/cpp/libhello-jni.so vendor/x86

Rake per usual. You should see something like the following emitted to the console:

    02-22 13:04:02.072  6747  6747 I com/yourcompany/rm_android_jni: Hello from JNI !  Compiled with ABI x86.

## Building for Other Archs

I haven't personally tried this, but it should just be a matter of changing the
`-DANDROID_ABI` option to cmake, placing the generated `.so` file in
`vendor/<other-arch>`, and changing the `:native` key argument to
`app.vendor_project` in the `Rakefile`. See below for the gory details.

## Some Explanatory Magic

Essentially what we're doing here is building a native library with the NDK and
then telling RubyMotion that this native library is required by some 3rd-party
Java library (`dummy.jar`). This makes it place `libhello-jni.so` in the
`lib/x86` directory of the `.apk` payload, which is on the path searched at
runtime by `System.loadLibrary()`.

We then use a little java bridge file to glue to the JNI interface to Ruby. A
`static` block in `main_activity.java` calls the `loadLibrary()` method so that
the JNI library is loaded whenever the `MainActivity` class comes into
scope. The other key piece in `main_activity.java` is to declare the
`stringFromJNI()` method with the `native` keyword.

## Crucial Things

The `:jar` key is required for the `app.vendor_project` method in the
`Rakefile`. The contents of this file are irrelevant for our purposes; _however_
it must be a valid zip archive.  The included `dummy.jar` is just a zip of
directory containing a zero-length file.

You can specifiy multiple native libraries in the `:native` key. These libraries
are only loaded if they end with a valid ABI subpath, matching your target
architecture. These are: `armeabi`, `armeabi-v7a`, `arm64-v8a` and `x86`. So for
instance, `vendor/x86/foo.so` or `vendor/bar/x86/foo.so` are both fine for
`x86`, but `vendor/armeabi/something/libsomething.so` will not be included in
the `.apk`, even when targetting ARM.

The name of the methods in `app/cpp/hello-jni.c` must precisely match your Java
package name, class names, etc. for the dynamic linking to work. The pattern is
mostly just replacing `.` with `_`, but hyphens also become `1` such that:

    com.yourcompany.rm-android-jni.MainActivity.stringFromJNI

becomes:

    Java_com_yourcompany_rm_1android_1jni_MainActivity_stringFromJNI

When in doubt, consult the Android documentation for JNI. As well, if you
guessed wrongly, the `java.lang.UnsatisfiedLinkError` error at runtime will
inform you of what the right function name should have been.

## License

The files in `app/cpp` are derived from the Android NDK's [hello-jni
sample](https://github.com/googlesamples/android-ndk), which is licensed under
the Apache License, Version 2.0

```
Copyright 2018 The Android Open Source Project, Inc.

Licensed to the Apache Software Foundation (ASF) under one or more contributor
license agreements.  See the NOTICE file distributed with this work for
additional information regarding copyright ownership.  The ASF licenses this
file to you under the Apache License, Version 2.0 (the "License"); you may not
use this file except in compliance with the License.  You may obtain a copy of
the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
License for the specific language governing permissions and limitations under
the License.

```

All other source is released to the public domain.
