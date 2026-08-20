plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.lctcbd.amarpratisthan"
    compileSdk = 33 // replace with your desired SDK version
    ndkVersion = "27.0.12077973" // or any version you are using

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.lctcbd.amarpratisthan"
        minSdk = 21 // replace with your desired minimum SDK version
        targetSdk = 33 // replace with your desired target SDK version
        versionCode = 1 // replace with your desired version code
        versionName = "1.0" // replace with your desired version name
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release") // use appropriate signingConfigs
        }
    }
}

flutter {
    source = "../.."
}