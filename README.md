# ziyotek-pipeline

This respository will start a pipeline to deploy a simple web server on an ec2 instance.
To accomodate this repository for your code, you need to:
1) clone and push this repo to your own repository.
2) adjust the piplene source variables with you your repository parameters.
3) create your own github token and store it in SSM, then use the ssm data source name.
4) set your own backend s3 and edit the provider.tf file.
5) if you are using other region other than us-east-1, you wll need to inspect all the code for any hard-coded region references.
6) S3 for artifacts need to have a different name.
7) all SBX buckets will need different names defined
8) to apply (create) the infrastructure by codebuild, the buildspec.yml line 19 will need to change "destroy" to "apply"
9) to destroy your infrastructure and stop the application, change line 19 to "destroy" and push
