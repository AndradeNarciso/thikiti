plugins {
    // Plugin do Google Services para Firebase (aplicado no módulo app)
    id("com.google.gms.google-services") version "4.4.3" apply false

    // Outros plugins que precises para o projeto raiz aqui
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Mudar diretório padrão de build para fora da pasta do projeto (opcional)
val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    // Diretório de build separado para cada subprojeto
    val newSubprojectBuildDir = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)

    // Avalia o módulo :app antes dos outros
    project.evaluationDependsOn(":app")
}

// Task para limpar build
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
