# Standard-Konfiguration des Blueprints

Die Standard-Konfiguration des Blueprints wird in der `values.yaml` festgelegt. Das Format in dieser
Datei entspricht in weiten Teilen dem Blueprint-Format. Da Helm es nicht erlaubt, einzelne Einträge einer
Liste zu verändern, wurden Listen durch Mappings ersetzt.

Die folgenden Beispiele zeigen, wo Listen durch Mappings ersetzt wurden.

**Globale Konfiguration**

```yaml
# Blueprint
apiVersion: k8s.cloudogu.com/v3
kind: Blueprint
metadata:
  name: blueprint-sample
spec:
  blueprint:
    config:
      global:
        - key: "my/global/key"
          value: "myValue"
        - absent: true
          key: "global/to/be/delete"
```

```yaml
# values.yaml
spec:
  blueprint:
    config:
      global:
        my/global/key:
          value: "myValue"
        local/to/be/delete:
          absent: true
```


**Konfiguration der Dogus**

```yaml
# Blueprint
apiVersion: k8s.cloudogu.com/v3
kind: Blueprint
metadata:
  name: blueprint-sample
spec:
  blueprint:
    config:
      dogus:
          mysql:
            - key: "logging/root"
              value: "WARN"
            - key: "sa-ldap/password"
              sensitive: true
              secretRef:
                name: "ldap-sa-secret"
                key: "password"
            - key: "to/be/deleted"
              absent: true
```

```yaml
# values.yaml
spec:
  blueprint:
    config:
      dogus:
        mysql:
          logging/root:
            value: "WARN"
          sa-ldap/password:
            sensitive: true
            secretRef:
              name: "ldap-sa-secret"
              key: "password"
          to/be/deleted:
            absent: true
        redmine:
          keyTest:
            absent: true
```


**Dogus mit ihrer Platform-Konfiguration** 

```yaml
# Blueprint
apiVersion: k8s.cloudogu.com/v3
kind: Blueprint
metadata:
  name: blueprint-sample
spec:
  blueprint:
    dogus:
      - name: "official/mysql"
        version: "1.26.3-2"
        platformConfig: 
            additionalMounts: 
              - sourceType: "ConfigMap"
                name: "key-1"
                volume: "volume1"
                subfolder: "about1"
              - sourceType: "ConfigMap"
                name: "key-2"
                volume: "volume2"
                subfolder: "about2"
              - sourceType: "Secret" 
                name: "key-1"
                volume: "sec-volume1"
```

```yaml
# values.yaml
spec:
  blueprint:
    dogus:
      official/mysql:
        version: "8.4.6-1"
        platformConfig:
          ResourceConfig:
            MinVolumeSize: "2Gi"
          additionalMounts:
            configMaps:
              key-1:
                volume: "volume1"
                subfolder: "about1"
              key-2:
                volume: "volume2"
                subfolder: "about2"
            secrets:
              key-1:
                volume: "sec-volume1"
```

**Konfiguration der Blueprint-Mask**

```yaml
# Blueprint
apiVersion: k8s.cloudogu.com/v3
kind: Blueprint
metadata:
  name: blueprint-sample
spec:
  blueprintMask:
    dogus:
      - name: "official/mysql"
        absent: true
      - name: "official/postgres"
        absent: true

```

```yaml
# values.yaml
spec:
  blueprintMask:
    manifest:
      dogus:
        official/mysql:
          absent: true
        official/postgres:
          absent: true
```