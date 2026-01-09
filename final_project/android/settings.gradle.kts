pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
        maven("https://storage.googleapis.com/flutter_infra_release/flutter/repo")
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
        maven {
            url = File(settings.rootDir, "../build/host/outputs/repo").toURI()
        }
    }
}

rootProject.name = "final_project_android"
include(":app")

val generatedPluginsFile = File(settings.rootDir, "../.flutter/generated_plugins.gradle")
if (generatedPluginsFile.exists()) {
    apply(from = generatedPluginsFile)
}
