## Answers

Questions

1. But what about my scripts???
2. Why are there two AllTheThings?
3. How would I only deploy Tagged items?
4. What happens if I try to deploy FancyDeployment-Modules, where those servers aren't real?
5. What is with the DependsOn? Why isn't that failing when I run AllTheThings?

Answers

1.

```
FromSource modules,
           scripts
```

2.

See #1  --  Get it? ( because we are deploying two sources )

3.

```
Get-PSDeployment -path .\fancy.psdeploy.ps1 -tag Dev
```

4.

Let's Try!!!

It times out - fails

5.

```
Deploy A {
    By FileSystem Two {
        FromSource MyModule
        To C:\PSDeployTo
        DependingOn One
    }

    By FileSystem Three {
        FromSource MyModule
        To C:\PSDeployTo
        DependingOn Two
    }
}

Deploy B {
    By FileSystem One {
        FromSource MyModule
        To C:\PSDeployTo
    }
}
```

```
Get-PSDeployment -Path C:\_temp\deployfrom\my.psdeploy.ps1 | Select DeploymentName

DeploymentName
--------------
One
A-Two
A-Three
```

It's ordering the deploy **blocks**