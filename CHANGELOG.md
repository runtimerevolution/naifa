## 0.2.0
* Adds support for postgres command options in the naifa file
    * NOTE: If you use the postgres plugin, please update you .naifa file to add the default backup_options and restore_options. Ex of adding those to the a development environment setting:
```
...
db:
  plugin: postgres
  settings:
    ...
    environments:
      ...
      development:
        backup_options:
        - "-Fc"
        restore_options:
        - "--verbose"
        - "--clean"
        - "--no-acl"
        - "--no-owner"
...
```

## 0.1.1
* Adds S3 bucket sync support
* Restructure configuration and the CLI
* Removes defaults. Settings must come from the configuration file
* Fixes some postgres plugin bugs
* Adds some validations and error messages

## 0.1.0
* First version!
* Adds postgresql sync between environment database, backup and restore
