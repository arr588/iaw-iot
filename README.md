# IoT Dashboard - Sensores, MQTT, Telegraf, InfluxDB y Grafana

En esta práctica instalaremos y configuraremos Mosquitto, Telgraf, InfluxDB y Grafana. Mosquitto se encarga de publicar las actualizaciones de los sensores que creamos. Telgraf coge las publicaciones de MQTT y las guarda en una base de datos de InfluxDB (gestor de bases de datos de series temporales). Grafana es la interfaz web donde veremos las actualizaciones con gráficas.

![diagrama](https://raw.githubusercontent.com/arr588/iaw-iot/main/img/diagram.png)

Las instalaciones las haremos a través de Docker Compose:

- MQTT utiliza el siguiente volumen:

    ```
  mosquitto:
    image: eclipse-mosquitto:2
    ports:
      - 1883:1883
    volumes:
      - ./mosquitto/mosquitto.conf:/mosquitto/config/mosquitto.conf
      - mosquitto_data:/mosquitto/data
      - mosquitto_log:/mosquitto/log
    ```

    El archivo de configuración de MQTT será el que le diga el puerto que debe escuchar y las conexiones que permite:

    ```
    listener 1883
    allow_anonymous true
    ```

- Telgraf utiliza el siguiente volumen:

    ```
    telegraf:
      image: telegraf
      volumes:
        - ./telegraf/telegraf.conf:/etc/telegraf/telegraf.conf
      depends_on: 
        - influxdb
    ```

    Para configurarlo primero tendremos que descargar el archivo de configuración a través de docker:

    `docker run --rm telegraf telegraf config > telegraf.conf`

    Una vez descargado tendremos que modificar las siguiente líneas para que conecte con MQTT e InfluxDB:

    ```
    [[inputs.mqtt_consumer]]
    servers = ["tcp://mosquitto:1883"] 

    topics = [
     "iescelia/#" 
    ] 

    data_format = "value" 
    data_type = "float"
    ```

    ```
    [[outputs.influxdb]]
    urls = ["http://influxdb:8086"] 

    database = "iescelia_db" 

    skip_database_creation = true 

    username = "root" 
    password = "root"
    ```

- InfluxDB usa el siguiente volumen:

    ```
    influxdb:
      image: influxdb:1.8
      ports:
        - 8086:8086
      volumes:
        - influxdb_data:/var/lib/influxdb
      environment:
        - INFLUXDB_DB=iescelia_db
        - INFLUXDB_ADMIN_USER=root
        - INFLUXDB_ADMIN_PASSWORD=root
        - INFLUXDB_HTTP_AUTH_ENABLED=true
    ```

- Grafana usa el siguiente volumen:

    ```
    grafana:
      image: grafana/grafana:7.4.0
      ports:
        - 3000:3000
      volumes:
        - grafana_data:/var/lib/grafana
        - ./grafana-provisioning/:/etc/grafana/provisioning
      depends_on:
        - influxdb
    ```

    Grafana requiere de dos archivos de configuración .yml:

    - El primero conecta con la base de datos:
        ```
        apiVersion: 1
        datasources:
          - name: InfluxDB
            type: influxdb
            access: proxy
            database: iescelia_db 
            user: root 
            password: root 
            url: http://influxdb:8086 
            isDefault: true
            editable: true
        ```
    
    - El segundo se encarga de almacenar las dashboards para la página de grafana. Dentro de la carpeta se encuentra un .json donde se guarda la esctructura también:

        ```
        apiVersion: 1
        providers:
        - name: InfluxDB
        folder: ''
        type: file
        disableDeletion: false
        editable: true
        options:
        path: /etc/grafana/provisioning/dashboards
        ```

Una vez todo está instalado y configurado podremos entrar en la web de grafana a través del puerto 3000. Agregamos datos con el siguiente comando: `docker run -it --rm efrecon/mqtt-client pub -h IP -p 1883 -t "iescelia/aula22/co2" -m 30` y el resultado es el siguiente:

![grafana](https://raw.githubusercontent.com/arr588/iaw-iot/main/img/Captura%20de%20pantalla%202021-05-27%20110304.png)