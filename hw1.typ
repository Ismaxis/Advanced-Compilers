#import "@preview/ctheorems:1.1.3": *
#show: thmrules.with(qed-symbol: $square$)
#set page(height: auto, margin: 1.5cm)

#let task = thmbox("theorem", "Задание", fill: rgb("#eeffee")).with(numbering: none)
#let solution = thmproof("proof", "Решение")

#align(center, text[= Исаев Максим])
#align(center, text[== Темы 1–4. Теоретическое задание])

#let val(x) = text(fill: blue, str(x))
#let ptr(x) = underline(str(x))
#let nullptr = ptr("●");

#let object(content, color: white) = table.cell(colspan: content.len(), inset: (x: 1.1pt))[ #table(
  columns: content.len(),
  fill: color,
  ..content.map(c => [#c])
)];

#let marked_object(content) = object(content, color: yellow);


#let ids = (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27);

#table(
  columns: 2,
  stroke: none,
  align: horizon,

  [Корни],
  table(
    columns: 4,
    [#val(3)], [#ptr(10)], [#val(2)], [#val(9)],
  ),

  [Куча],
  table(
    stroke: none,
    row-gutter: (-0.5em, auto),
    columns: calc.floor(ids.len()),
    align: center,
    ..ids.map(id => table.cell(stroke: none)[#id]),
    object((val(5), nullptr, ptr(7))),
    object((val(1), ptr(19), nullptr)),
    object((val(7), nullptr, ptr(13))),
    object((val(8), ptr(16), nullptr)),
    object((val(9), val(10), ptr(16))),
    object((val(2), ptr(7), ptr(25))),
    object((val(4), ptr(4), ptr(22))),
    object((val(6), ptr(19), ptr(4))),
    object((val(3), nullptr, ptr(1)))
  ),
)



#task("1")[
  Примените алгоритм обхода в глубину с разворотом указателей [1, Algorithm 13.6] к состоянию памяти представленному на рис. 1 и ответьте на вопросы:
  1. Какие блоки памяти (достаточно указать адреса начала блоков) будут _помечены_ по итогу работы алгоритма?
  2. Каково будет состояние кучи и локальных переменных алгоритма в момент, когда будет помечен блок со значением #val(7) в первом поле?
    1. Необходимо указать значения во всех ячейках памяти в куче или указать ячейки, которые имеют значение, отличное от исходного.
    2. Необходимо указать значения в массиве `done`.
    3. Необходимо указать значения переменных `t`, `x`, `y`.
  3. Сколько операций записи (изменения) памяти в _куче_ и массиве `done` требуется для алгоритма на данном примере?
  4. Какова амортизированная стоимость сборки мусора (в терминах операции записи/изменения памяти в куче и массиве `done`) на данном примере?
]
#solution()[
  #let replaced(it) = table.cell(fill: blue)[#it]

  Обозначения:
  - #box(object((val(8), ptr(16), nullptr), color: yellow)) -- помеченный блок.
  - #box(object((val(8), replaced(nullptr), nullptr))) -- второе поле временно перезаписано.

  Состояния памяти:

  #table(
    stroke: none,
    row-gutter: (-0.5em, auto),
    columns: calc.floor(ids.len()),
    align: center,
    ..ids.map(id => table.cell(stroke: none)[#id]),
    object((val(5), nullptr, ptr(7))),
    object((val(1), ptr(19), nullptr)),
    object((val(7), nullptr, ptr(13))),
    object((val(8), ptr(16), nullptr)),
    object((val(9), val(10), ptr(16))),
    object((val(2), ptr(7), ptr(25))),
    object((val(4), ptr(4), ptr(22))),
    object((val(6), ptr(19), ptr(4))),
    object((val(3), nullptr, ptr(1)))
  )

  #align(center, sym.arrow.b + " нашли непомеченный " + ptr(10) + " в корнях")

  #table(
    stroke: none,
    row-gutter: (-0.5em, auto),
    columns: calc.floor(ids.len()),
    align: center,
    ..ids.map(id => table.cell(stroke: none)[#id]),
    object((val(5), nullptr, ptr(7))),
    object((val(1), ptr(19), nullptr)),
    object((val(7), nullptr, ptr(13))),
    marked_object((val(8), ptr(16), nullptr)),
    object((val(9), val(10), ptr(16))),
    object((val(2), ptr(7), ptr(25))),
    object((val(4), ptr(4), ptr(22))),
    object((val(6), ptr(19), ptr(4))),
    object((val(3), nullptr, ptr(1)))
  )

  #align(center, sym.arrow.b + " первое поле не указатель, второе " + ptr(16) + " не помечено")

  #table(
    stroke: none,
    row-gutter: (-0.5em, auto),
    columns: calc.floor(ids.len()),
    align: center,
    ..ids.map(id => table.cell(stroke: none)[#id]),
    object((val(5), nullptr, ptr(7))),
    object((val(1), ptr(19), nullptr)),
    object((val(7), nullptr, ptr(13))),
    marked_object((val(8), replaced(nullptr), nullptr)),
    object((val(9), val(10), ptr(16))),
    marked_object((val(2), ptr(7), ptr(25))),
    object((val(4), ptr(4), ptr(22))),
    object((val(6), ptr(19), ptr(4))),
    object((val(3), nullptr, ptr(1)))
  )

  #align(center, sym.arrow.b)

  #table(
    stroke: none,
    row-gutter: (-0.5em, auto),
    columns: calc.floor(ids.len()),
    align: center,
    ..ids.map(id => table.cell(stroke: none)[#id]),
    object((val(5), nullptr, ptr(7))),
    object((val(1), ptr(19), nullptr)),
    marked_object((val(7), nullptr, ptr(13))),
    marked_object((val(8), replaced(nullptr), nullptr)),
    object((val(9), val(10), ptr(16))),
    marked_object((val(2), replaced(ptr(10)), ptr(25))),
    object((val(4), ptr(4), ptr(22))),
    object((val(6), ptr(19), ptr(4))),
    object((val(3), nullptr, ptr(1)))
  )

  #align(center, sym.arrow.b)

  #table(
    stroke: none,
    row-gutter: (-0.5em, auto),
    columns: calc.floor(ids.len()),
    align: center,
    ..ids.map(id => table.cell(stroke: none)[#id]),
    object((val(5), nullptr, ptr(7))),
    object((val(1), ptr(19), nullptr)),
    marked_object((val(7), nullptr, replaced(ptr(16)))),
    marked_object((val(8), replaced(nullptr), nullptr)),
    marked_object((val(9), val(10), ptr(16))),
    marked_object((val(2), replaced(ptr(10)), ptr(25))),
    object((val(4), ptr(4), ptr(22))),
    object((val(6), ptr(19), ptr(4))),
    object((val(3), nullptr, ptr(1)))
  )

  #align(
    center,
    sym.arrow.b + " у " + ptr(13) + " нет непомеченных полей-указателей, выходим вверх по " + text[_стеку_],
  )

  #table(
    stroke: none,
    row-gutter: (-0.5em, auto),
    columns: calc.floor(ids.len()),
    align: center,
    ..ids.map(id => table.cell(stroke: none)[#id]),
    object((val(5), nullptr, ptr(7))),
    object((val(1), ptr(19), nullptr)),
    marked_object((val(7), nullptr, ptr(13))),
    marked_object((val(8), replaced(nullptr), nullptr)),
    marked_object((val(9), val(10), ptr(16))),
    marked_object((val(2), replaced(ptr(10)), ptr(25))),
    object((val(4), ptr(4), ptr(22))),
    object((val(6), ptr(19), ptr(4))),
    object((val(3), nullptr, ptr(1)))
  )

  #align(center, sym.arrow.b + " переходим к следующему полю-указателю у " + ptr(16))

  #table(
    stroke: none,
    row-gutter: (-0.5em, auto),
    columns: calc.floor(ids.len()),
    align: center,
    ..ids.map(id => table.cell(stroke: none)[#id]),
    object((val(5), nullptr, ptr(7))),
    object((val(1), ptr(19), nullptr)),
    marked_object((val(7), nullptr, ptr(13))),
    marked_object((val(8), replaced(nullptr), nullptr)),
    marked_object((val(9), val(10), ptr(16))),
    marked_object((val(2), ptr(7), ptr(25))),
    object((val(4), ptr(4), ptr(22))),
    object((val(6), ptr(19), ptr(4))),
    object((val(3), nullptr, ptr(1)))
  )

  #align(center, sym.arrow.b)

  #table(
    stroke: none,
    row-gutter: (-0.5em, auto),
    columns: calc.floor(ids.len()),
    align: center,
    ..ids.map(id => table.cell(stroke: none)[#id]),
    object((val(5), nullptr, ptr(7))),
    object((val(1), ptr(19), nullptr)),
    marked_object((val(7), nullptr, ptr(13))),
    marked_object((val(8), replaced(nullptr), nullptr)),
    marked_object((val(9), val(10), ptr(16))),
    marked_object((val(2), ptr(7), replaced(ptr(10)))),
    object((val(4), ptr(4), ptr(22))),
    object((val(6), ptr(19), ptr(4))),
    marked_object((val(3), nullptr, ptr(1)))
  )

  #align(center, sym.arrow.b)

  #table(
    stroke: none,
    row-gutter: (-0.5em, auto),
    columns: calc.floor(ids.len()),
    align: center,
    ..ids.map(id => table.cell(stroke: none)[#id]),
    marked_object((val(5), nullptr, ptr(7))),
    object((val(1), ptr(19), nullptr)),
    marked_object((val(7), nullptr, ptr(13))),
    marked_object((val(8), replaced(nullptr), nullptr)),
    marked_object((val(9), val(10), ptr(16))),
    marked_object((val(2), ptr(7), replaced(ptr(10)))),
    object((val(4), ptr(4), ptr(22))),
    object((val(6), ptr(19), ptr(4))),
    marked_object((val(3), nullptr, replaced(ptr(16))))
  )

  #align(center, sym.arrow.b + " у " + ptr(1) + " нет непомеченных полей-указателей")

  #table(
    stroke: none,
    row-gutter: (-0.5em, auto),
    columns: calc.floor(ids.len()),
    align: center,
    ..ids.map(id => table.cell(stroke: none)[#id]),
    marked_object((val(5), nullptr, ptr(7))),
    object((val(1), ptr(19), nullptr)),
    marked_object((val(7), nullptr, ptr(13))),
    marked_object((val(8), replaced(nullptr), nullptr)),
    marked_object((val(9), val(10), ptr(16))),
    marked_object((val(2), ptr(7), replaced(ptr(10)))),
    object((val(4), ptr(4), ptr(22))),
    object((val(6), ptr(19), ptr(4))),
    marked_object((val(3), nullptr, ptr(1)))
  )

  #align(center, sym.arrow.b)

  #table(
    stroke: none,
    row-gutter: (-0.5em, auto),
    columns: calc.floor(ids.len()),
    align: center,
    ..ids.map(id => table.cell(stroke: none)[#id]),
    marked_object((val(5), nullptr, ptr(7))),
    object((val(1), ptr(19), nullptr)),
    marked_object((val(7), nullptr, ptr(13))),
    marked_object((val(8), replaced(nullptr), nullptr)),
    marked_object((val(9), val(10), ptr(16))),
    marked_object((val(2), ptr(7), ptr(25))),
    object((val(4), ptr(4), ptr(22))),
    object((val(6), ptr(19), ptr(4))),
    marked_object((val(3), nullptr, ptr(1)))
  )

  #align(center, sym.arrow.b)

  #table(
    stroke: none,
    row-gutter: (-0.5em, auto),
    columns: calc.floor(ids.len()),
    align: center,
    ..ids.map(id => table.cell(stroke: none)[#id]),
    marked_object((val(5), nullptr, ptr(7))),
    object((val(1), ptr(19), nullptr)),
    marked_object((val(7), nullptr, ptr(13))),
    marked_object((val(8), ptr(16), nullptr)),
    marked_object((val(9), val(10), ptr(16))),
    marked_object((val(2), ptr(7), ptr(25))),
    object((val(4), ptr(4), ptr(22))),
    object((val(6), ptr(19), ptr(4))),
    marked_object((val(3), nullptr, ptr(1)))
  )

  Ответы:
  1. Адреса помеченных блоков: 1, 7, 10, 16, 25
  2. Состояние памяти в момент пометки блока со значением #val(7) в первом поле:
    1. #table(
        stroke: none,
        row-gutter: (-0.5em, auto),
        columns: calc.floor(ids.len()),
        align: center,
        ..ids.map(id => table.cell(stroke: none)[#id]),
        object((val(5), nullptr, ptr(7))),
        object((val(1), ptr(19), nullptr)),
        marked_object((val(7), nullptr, ptr(13))),
        marked_object((val(8), replaced(nullptr), nullptr)),
        object((val(9), val(10), ptr(16))),
        marked_object((val(2), replaced(ptr(10)), ptr(25))),
        object((val(4), ptr(4), ptr(22))),
        object((val(6), ptr(19), ptr(4))),
        object((val(3), nullptr, ptr(1)))
      )
    2. Массив done: [0,0,0,1,0,1,0,0,0]
    3. Переменные: t = #ptr(16), x = #ptr(7), y = #ptr(7)
  3. 5 (массив `done`) + 10 (изменения в куче) = 15 операций записи
  4. $ (c_1 R + c_2 H) / (H - R) = (10 dot (5 dot 3) + 3 dot (8 dot 3)) / (8 dot 3 - 5 dot 3) = 74/3 = 24 2/3 $
]
