#Use several variable groups with special condition

To use a variable from a **variable group**, you need to add a reference to the group in your `YAML` file:

```yaml
variables:
- group: my-variable-group
```

Also we can reference multiple **variable groups** in the same pipeline: 

```yaml
variables:
- group: my-first-variable-group
- group: my-second-variable-group
```

But on the real project, we would use conditions. Our pipeline can perform more than one scenario. 
For example, we can describe several cases in one file. Let's imagine that we have two brunches for deploying our application:

 - `Development` -> for **TEST** environment;
 - `Master` -> for **PROD** environment;
 
We should use different **variable groups** for those branches:

```yaml
variables:
  - ${{ if eq(variables['build.SourceBranchName'], 'master') }}:
      - group: master-variable
  - ${{ if eq(variables['build.SourceBranchName'], 'development') }}:
      - group: development-variable
```

If we have a case, when our application can deploy from another branch, we would use special conditions:

```yaml
variables:
  - ${{ if and(ne(variables['build.SourceBranchName'], 'master'), 
                ne(variables['build.SourceBranchName'], 'development')) }}:
      - group: basic-variables
```

Check out more about [variables groups here](https://docs.microsoft.com/en-us/azure/devops/pipelines/library/variable-groups?view=azure-devops&tabs=yaml).
