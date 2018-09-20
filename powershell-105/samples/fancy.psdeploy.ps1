Deploy FancyDeployment {
  By FileSystem AllTheThings {
      FromSource modules,
                 scripts
      To C:\_temp\deployto
      DependingOn FancyDeployment-Modules  #DeploymentName-ByName
      Tagged Dev
  }

  By FileSystem Modules {
      FromSource modules
      To \\ServerY\c$\SomePSModulePath,
         \\ServerX\SomeShare$\Modules
      Tagged Prod,
             Module
  }
}