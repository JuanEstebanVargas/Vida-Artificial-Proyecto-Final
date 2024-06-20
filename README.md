# Modelo de Simulación de Dinámicas Urbanas

Este proyecto utiliza un modelo basado en agentes implementado en NetLogo para simular y analizar dinámicas urbanas complejas. El objetivo es estudiar cómo diferentes infraestructuras y variables socioeconómicas afectan la distribución de ingresos y la calidad de vida en una ciudad.

## Características del Modelo

- **Infraestructuras Simuladas**: Centros comerciales, zonas de conflicto, parques, escuelas, fábricas y vertederos.
- **Variables Socioeconómicas**: Nivel de ingreso, inteligencia, acceso a servicios, edad.
- **Eventos Disruptivos**: Pandemias, bendiciones (mejoras significativas) y tragedias (decaimientos significativos).

## Configuración Inicial

El modelo permite configurar varios parámetros iniciales:

- **Número de barrios**: Divide la ciudad en diferentes barrios.
- **Cantidad de infraestructuras**: Centros comerciales, zonas de conflicto, parques, escuelas, fábricas y vertederos.
- **Parámetros socioeconómicos**: Niveles iniciales de ingreso, inteligencia y acceso a servicios.

## Reglas de Transición

El modelo incluye varias reglas de transición que determinan cómo los ingresos y otras variables cambian a lo largo del tiempo:

1. **Regla de Cambio Estándar**: Ajustes lentos en el nivel de ingreso basados en los vecinos y la proximidad a infraestructuras.
2. **Bendición**: Incremento significativo del ingreso en un porcentaje de los parches.
3. **Tragedia**: Reducción significativa del ingreso en un porcentaje de los parches.
4. **Inteligentes al Mando**: Ajustes en el nivel de ingreso basados en la inteligencia del parche.
5. **Pandemia**: Reducción de ingresos y otros efectos negativos en un porcentaje de los parches.

## Uso del Modelo

### Instalación

1. **Descargar NetLogo**: Asegúrate de tener instalada la última versión de [NetLogo](https://ccl.northwestern.edu/netlogo/).
2. **Clonar el repositorio**:
   ```bash
   git clone https://github.com/tu-usuario/nombre-del-repositorio.git

   ## Configuración y Ejecución

### Configurar parámetros
Ajusta los parámetros en la interfaz de NetLogo según tus necesidades (número de barrios, cantidad de infraestructuras, etc.).

### Iniciar la simulación

1. Haz clic en el botón `configurar` para configurar el entorno inicial.
2. Haz clic en el botón `ir` para iniciar la simulación.

### Seleccionar regla de transición
Elige una regla de transición del menú desplegable `regla-seleccionada` y observa cómo evolucionan los niveles de ingreso y otras variables.

## Visualización de Resultados

### Colores de los parches
Los parches cambian de color según el nivel de ingreso y la presencia de infraestructuras:

- **Marrón**: Ingreso muy bajo
- **Rojo**: Ingreso bajo
- **Naranja**: Ingreso medio-bajo
- **Amarillo**: Ingreso medio-alto
- **Verde**: Ingreso alto
- **Azul**: Centros comerciales
- **Negro**: Zonas de conflicto
- **Cian**: Parques
- **Blanco**: Escuelas
- **Gris**: Fábricas
- **Rosa**: Vertederos
- **Magenta**: Parches afectados por la pandemia

### Gráficos y Monitores
Utiliza los gráficos y monitores en la interfaz de NetLogo para analizar la evolución de las variables a lo largo del tiempo.

