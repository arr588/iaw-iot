# IoT Dashboard - Sensores, MQTT, Telegraf, InfluxDB y Grafana

En esta práctica instalaremos y configuraremos Mosquitto, Telgraf, InfluxDB y Grafana. Mosquitto se encarga de publicar las actualizaciones de los sensores que creamos. Telgraf coge las publicaciones de MQTT y las guarda en una base de datos de InfluxDB (gestor de bases de datos de series temporales). Grafana es la interfaz web donde veremos las actualizaciones con gráficas.

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

