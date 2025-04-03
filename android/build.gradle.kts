buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.0")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Use File instead of Directory for build directory
val newBuildDir = File(rootProject.projectDir, "../build")

rootProject.buildDir = newBuildDir

subprojects {
    val subprojectBuildDir = File(newBuildDir, project.name)
    project.buildDir = subprojectBuildDir
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}