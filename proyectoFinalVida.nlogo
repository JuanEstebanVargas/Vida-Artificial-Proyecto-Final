globals [
  tamano-barrio  ; Tamaño de cada barrio en parches
  colores-barrios ; Lista de colores de los barrios
]

patches-own [
  nivel-ingreso
  inteligencia
  acceso-servicios
  edad
  barrio
  vivo
  tiene-centro-comercial  ; Indica si el parche tiene un centro comercial
  tiene-zona-conflicto  ; Indica si el parche tiene una zona de conflicto
  tiene-parque ; Indica si el parche tiene un parque
  tiene-escuela ; Indica si el parche tiene una escuela
  tiene-fabrica ; Indica si el parche tiene una fábrica
  tiene-vertedero ; Indica si el parche tiene un vertedero
]

to configurar
  clear-all

  ; Verificar que num-barrios sea al menos 1
  if num-barrios < 1 [
    user-message "El número de barrios debe ser al menos 1."
    stop
  ]

  ; Calcular el tamaño del barrio en función del número de barrios y el tamaño del mundo
  set tamano-barrio max (list 1 floor (sqrt (count patches / num-barrios)))

  ; Inicializar las listas
  set colores-barrios [brown red orange yellow green]

  ; Asignar parches a los barrios y establecer el color predominante del barrio
  let parches-restantes patches
  let id-barrio 0
  while [any? parches-restantes] [
    let parches-seleccionados n-of (floor (count parches-restantes / (num-barrios - id-barrio))) parches-restantes
    ask parches-seleccionados [
      set barrio id-barrio
      set nivel-ingreso random-float 1.0
      set inteligencia 0.1 + random-float 1.2
      set acceso-servicios random-float 1.0
      set edad random 100  ; Edad aleatoria entre 0 y 99 años
      set vivo true
      set tiene-centro-comercial false
      set tiene-zona-conflicto false
      set tiene-parque false
      set tiene-escuela false
      set tiene-fabrica false
      set tiene-vertedero false


      ; Asignar colores según el nivel de ingreso
      if nivel-ingreso < 0.2 [
        set pcolor brown
      ]
      if nivel-ingreso >= 0.2 and nivel-ingreso < 0.4 [
        set pcolor red
      ]
      if nivel-ingreso >= 0.4 and nivel-ingreso < 0.6 [
        set pcolor orange
      ]
      if nivel-ingreso >= 0.6 and nivel-ingreso < 0.8 [
        set pcolor yellow
      ]
      if nivel-ingreso >= 0.8 [
        set pcolor green
      ]
    ]
    set parches-restantes (patch-set parches-restantes with [not member? self parches-seleccionados])
    set id-barrio (id-barrio + 1)
  ]

  ; Asignar centros comerciales de manera aleatoria
  let parches-centros-comerciales n-of num-centros-comerciales patches
  ask parches-centros-comerciales [
    set tiene-centro-comercial true
    set pcolor blue
  ]

  ; Asignar ollas de manera aleatoria
  let parches-ollas n-of num-zonas-conflictos patches
  ask parches-ollas [
    set tiene-zona-conflicto true
    set pcolor black
  ]

  ; Asignar parques de manera aleatoria
  let parches-parques n-of num-parques patches
  ask parches-parques [
    set tiene-parque true
    set pcolor cyan
  ]

  ; Asignar escuelas de manera aleatoria
  let parches-escuelas n-of num-escuelas patches
  ask parches-escuelas [
    set tiene-escuela true
    set pcolor white  ; Blanco para las escuelas
  ]

  ; Asignar fábricas de manera aleatoria
  let parches-fabricas n-of num-fabricas patches
  ask parches-fabricas [
    set tiene-fabrica true
    set pcolor gray  ; Gris para las fábricas
  ]

  ; Asignar vertederos de manera aleatoria
  let parches-vertederos n-of num-vertederos patches
  ask parches-vertederos [
    set tiene-vertedero true
    set pcolor pink
  ]

  ; Dibujar los bordes de los barrios
  dibujar-bordes

  reset-ticks
end


to dibujar-bordes
  ask patches [
    if (pxcor mod tamano-barrio = 0 or pycor mod tamano-barrio = 0) [
      set pcolor black
    ]
  ]
end



;; REGLAS

;; Incremento o decremento de ingresos basado en la media de los vecinos.
to regla-transicion-1
  ask patches with [not tiene-centro-comercial and not tiene-zona-conflicto and not tiene-parque and not tiene-escuela and not tiene-fabrica and not tiene-vertedero and vivo] [
    let ingreso-promedio mean [nivel-ingreso] of neighbors
    if ingreso-promedio > nivel-ingreso [
      set nivel-ingreso min list (nivel-ingreso + 0.001) 1.0 ; Incrementar nivel de ingreso lentamente
    ]
    if ingreso-promedio < nivel-ingreso [
      set nivel-ingreso max list (nivel-ingreso - 0.001) 0.0 ; Decrementar nivel de ingreso lentamente
    ]
    ; Efecto adicional de los centros comerciales
    if any? neighbors with [tiene-centro-comercial] [
      set nivel-ingreso min list (nivel-ingreso + 0.01) 1.0 ; Incrementar nivel de ingreso más rápidamente si hay un centro comercial cercano
    ]
    if any? neighbors with [tiene-zona-conflicto] [
      set nivel-ingreso max list (nivel-ingreso - 0.01) 0.0 ; Decrementar nivel de ingreso más rápidamente si hay una olla cercana
    ]
    ; Efecto de los parques y escuelas
    if any? neighbors with [tiene-parque] [
      set nivel-ingreso min list (nivel-ingreso + 0.005) 1.0 ; Incrementar nivel de ingreso si hay un parque cercano
    ]
    if any? neighbors with [tiene-escuela] [
      set nivel-ingreso min list (nivel-ingreso + 0.008) 1.0 ; Incrementar nivel de ingreso si hay una escuela cercana
    ]
    ; Efecto de las fábricas y vertederos
    if any? neighbors with [tiene-fabrica] [
      set nivel-ingreso max list (nivel-ingreso - 0.008) 0.0 ; Decrementar nivel de ingreso si hay una fábrica cercana
    ]
    if any? neighbors with [tiene-vertedero] [
      set nivel-ingreso max list (nivel-ingreso - 0.015) 0.0 ; Decrementar nivel de ingreso si hay un vertedero cercano
    ]
    actualizar-color
  ]
end


;; Ajuste al ingreso máximo de los vecinos.
to bendicion

  ask patches [
    ; Verificar si el parche tiene características especiales y establecer el color correspondiente
    if tiene-centro-comercial [set pcolor blue]
    if tiene-zona-conflicto [set pcolor black]
    if tiene-parque [set pcolor green + 2]
    if tiene-escuela [set pcolor white]
    if tiene-fabrica [set pcolor gray]
    if tiene-vertedero [set pcolor brown]
  ]

; Obtener el 40% de todos los parches de la ciudad
  let num-parches-afectados round (0.4 * count patches)
  let parches-afectados n-of num-parches-afectados patches

  ; Aumentar los ingresos de los parches afectados en un 100%
  ask parches-afectados with [not tiene-centro-comercial and not tiene-zona-conflicto and not tiene-parque and not tiene-escuela and not tiene-fabrica and not tiene-vertedero and vivo] [
    set nivel-ingreso nivel-ingreso * 2
    actualizar-color
  ]

  ; Aplicar la regla de cambio estándar después de la bendición
  ask patches with [not tiene-centro-comercial and not tiene-zona-conflicto and not tiene-parque and not tiene-escuela and not tiene-fabrica and not tiene-vertedero] [
    let ingreso-minimo min [nivel-ingreso] of neighbors
    set nivel-ingreso nivel-ingreso - 0.001 * (nivel-ingreso - ingreso-minimo) ; Ajustar lentamente hacia el ingreso mínimo
    ; Efecto adicional de los centros comerciales y ollas
    if any? neighbors with [tiene-centro-comercial] [
      set nivel-ingreso min list (nivel-ingreso + 0.015) 1.0 ; Incrementar nivel de ingreso más rápidamente si hay un centro comercial cercano
    ]
    if any? neighbors with [tiene-zona-conflicto] [
      set nivel-ingreso max list (nivel-ingreso - 0.01) 0.0 ; Decrementar nivel de ingreso más rápidamente si hay una olla cercana
    ]
    ; Efecto de los parques y escuelas
    if any? neighbors with [tiene-parque] [
      set nivel-ingreso min list (nivel-ingreso + 0.01) 1.0 ; Incrementar nivel de ingreso si hay un parque cercano
    ]
    if any? neighbors with [tiene-escuela] [
      set nivel-ingreso min list (nivel-ingreso + 0.013) 1.0 ; Incrementar nivel de ingreso si hay una escuela cercana
    ]
    ; Efecto de las fábricas y vertederos
    if any? neighbors with [tiene-fabrica] [
      set nivel-ingreso max list (nivel-ingreso - 0.005) 0.0 ; Decrementar nivel de ingreso si hay una fábrica cercana
    ]
    if any? neighbors with [tiene-vertedero] [
      set nivel-ingreso max list (nivel-ingreso - 0.007) 0.0 ; Decrementar nivel de ingreso si hay un vertedero cercano
    ]

    ; Actualizar color según el nivel de ingreso
    actualizar-color
  ]

end

;; Ajuste al ingreso mínimo de los vecinos.
to tragedia

  ask patches [
    ; Verificar si el parche tiene características especiales y establecer el color correspondiente
    if tiene-centro-comercial [set pcolor blue]
    if tiene-zona-conflicto [set pcolor black]
    if tiene-parque [set pcolor green + 2]
    if tiene-escuela [set pcolor white]
    if tiene-fabrica [set pcolor gray]
    if tiene-vertedero [set pcolor brown]
  ]

; Obtener el 40% de todos los parches de la ciudad
  let num-parches-afectados round (0.4 * count patches)
  let parches-afectados n-of num-parches-afectados patches

  ; Reducir los ingresos de los parches afectados en un 50%
  ask parches-afectados with [not tiene-centro-comercial and not tiene-zona-conflicto and not tiene-parque and not tiene-escuela and not tiene-fabrica and not tiene-vertedero and vivo] [
    set nivel-ingreso nivel-ingreso * 0.5
    actualizar-color
  ]

  ; Aplicar la regla de cambio estándar después de la tragedia
  ask patches with [not tiene-centro-comercial and not tiene-zona-conflicto and not tiene-parque and not tiene-escuela and not tiene-fabrica and not tiene-vertedero] [
    let ingreso-minimo min [nivel-ingreso] of neighbors
    set nivel-ingreso nivel-ingreso - 0.001 * (nivel-ingreso - ingreso-minimo) ; Ajustar lentamente hacia el ingreso mínimo
    ; Efecto adicional de los centros comerciales y ollas
    if any? neighbors with [tiene-centro-comercial] [
      set nivel-ingreso min list (nivel-ingreso + 0.01) 1.0 ; Incrementar nivel de ingreso más rápidamente si hay un centro comercial cercano
    ]
    if any? neighbors with [tiene-zona-conflicto] [
      set nivel-ingreso max list (nivel-ingreso - 0.04) 0.0 ; Decrementar nivel de ingreso más rápidamente si hay una olla cercana
    ]
    ; Efecto de los parques y escuelas
    if any? neighbors with [tiene-parque] [
      set nivel-ingreso min list (nivel-ingreso + 0.005) 1.0 ; Incrementar nivel de ingreso si hay un parque cercano
    ]
    if any? neighbors with [tiene-escuela] [
      set nivel-ingreso min list (nivel-ingreso + 0.007) 1.0 ; Incrementar nivel de ingreso si hay una escuela cercana
    ]
    ; Efecto de las fábricas y vertederos
    if any? neighbors with [tiene-fabrica] [
      set nivel-ingreso max list (nivel-ingreso - 0.015) 0.0 ; Decrementar nivel de ingreso si hay una fábrica cercana
    ]
    if any? neighbors with [tiene-vertedero] [
      set nivel-ingreso max list (nivel-ingreso - 0.02) 0.0 ; Decrementar nivel de ingreso si hay un vertedero cercano
    ]

    ; Actualizar color según el nivel de ingreso
    actualizar-color
  ]

end

to inteligentes-al-mando

  ask patches with [not tiene-centro-comercial and not tiene-zona-conflicto and not tiene-parque and not tiene-escuela and not tiene-fabrica and not tiene-vertedero] [
    ; Multiplicar el nivel de ingreso por la inteligencia del parche
    set nivel-ingreso nivel-ingreso * inteligencia

    ; Actualizar color según el nuevo nivel de ingreso
    actualizar-color
  ]

end



to pandemia
  ; Obtener el 10% de todos los parches de la ciudad
  let num-parches-afectados round (0.025 * count patches)
  let parches-afectados n-of num-parches-afectados patches with [not tiene-centro-comercial and not tiene-zona-conflicto and not tiene-parque and not tiene-escuela and not tiene-fabrica and not tiene-vertedero and vivo]

  ; Aplicar los efectos de la pandemia a los parches afectados
  ask parches-afectados [
    ; Ajustar todos los atributos a 0 y marcar como muerto
    set nivel-ingreso 0
    set inteligencia 0
    set acceso-servicios 0
    set edad 0
    set vivo false

    ; Cambiar el color del parche para indicar que ha sido afectado
    set pcolor  magenta ; Un color distintivo para los parches "muertos"
  ]
end

to actualizar-color
  if nivel-ingreso < 0.2 [
    set pcolor brown
  ]
  if nivel-ingreso >= 0.2 and nivel-ingreso < 0.4 [
    set pcolor red
  ]
  if nivel-ingreso >= 0.4 and nivel-ingreso < 0.6 [
    set pcolor orange
  ]
  if nivel-ingreso >= 0.6 and nivel-ingreso < 0.8 [
    set pcolor yellow
  ]
  if nivel-ingreso >= 0.8 [
    set pcolor lime
  ]
end

to ir
  if regla-seleccionada = "CASO BASE" [
    regla-transicion-1
  ]
  if regla-seleccionada = "BENDICION" [
    bendicion
  ]
  if regla-seleccionada = "TRAGEDIA" [
    tragedia
  ]
  if regla-seleccionada = "INTELIGENTES AL MANDO" [
    inteligentes-al-mando
  ]
  if regla-seleccionada = "PANDEMIA" [
    pandemia
  ]
  tick
end
@#$#@#$#@
GRAPHICS-WINDOW
232
10
1145
524
-1
-1
5.0
1
4
1
1
1
0
1
1
1
-90
90
-50
50
0
0
1
ticks
30.0

BUTTON
33
10
121
43
NIL
configurar
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
36
83
208
116
num-barrios
num-barrios
2
10
8.0
2
1
NIL
HORIZONTAL

SLIDER
37
148
224
181
num-centros-comerciales
num-centros-comerciales
0
50
40.0
5
1
NIL
HORIZONTAL

SLIDER
39
390
210
423
num-zonas-conflictos
num-zonas-conflictos
0
50
15.0
5
1
NIL
HORIZONTAL

CHOOSER
36
441
228
486
regla-seleccionada
regla-seleccionada
"CASO BASE" "BENDICION" "TRAGEDIA" "INTELIGENTES AL MANDO" "PANDEMIA"
0

BUTTON
35
47
98
80
NIL
ir
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
121
49
184
82
NIL
ir
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
37
188
209
221
num-parques
num-parques
0
100
75.0
5
1
NIL
HORIZONTAL

SLIDER
39
231
211
264
num-escuelas
num-escuelas
10
100
50.0
10
1
NIL
HORIZONTAL

SLIDER
38
308
210
341
num-fabricas
num-fabricas
10
100
30.0
10
1
NIL
HORIZONTAL

SLIDER
38
347
210
380
num-vertederos
num-vertederos
5
25
5.0
5
1
NIL
HORIZONTAL

TEXTBOX
1157
22
1360
107
MARRON: POBREZA EXTREMA\nROJO: POBRE\nNARANJA: CLASE MEDIA BAJA\nAMARILLO: CLASE MEDIA ALTA\nVERDE: RICOS
13
0.0
1

TEXTBOX
1159
138
1371
250
AZUL: CENTRO COMERCIAL\nNEGRO: ZONAS DE CONFLICTO\nCYAN: PARQUES\nBLANCO: ESCUELAS\nGRIS: FABRICA\nROSA: VERTEDERO
13
0.0
1

TEXTBOX
38
125
188
143
POSITIVOS
11
0.0
1

TEXTBOX
36
281
186
299
NEGATIVOS
11
0.0
1

TEXTBOX
1162
266
1312
284
MUERTOS: MAGENTA
13
0.0
1

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
