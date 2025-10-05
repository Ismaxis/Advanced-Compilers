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

#let ids = (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27);

#figure(
  table(
    columns: 2,
    stroke: none,
    align: (right + horizon, left + horizon),

    [Корни],
    table(
      columns: 4,
      [#val(3)], [#ptr(10)], [#val(2)], [#val(9)],
    ),

    [Куча],
    table(
      stroke: none,
      row-gutter: (-0.5em, auto),
      columns: ids.len(),
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
  ),
  caption: [Пример состояния памяти какой-то программы.],
  supplement: "Рис",
)<r1>

#task("1")[
  Примените алгоритм обхода в глубину с разворотом указателей [1, Algorithm 13.6] к состоянию памяти представленному на #ref(<r1>) и ответьте на вопросы:
  1. Какие блоки памяти (достаточно указать адреса начала блоков) будут _помечены_ по итогу работы алгоритма?
  2. Каково будет состояние кучи и локальных переменных алгоритма в момент, когда будет помечен блок со значением #val(7) в первом поле?
    1. Необходимо указать значения во всех ячейках памяти в куче или указать ячейки, которые имеют значение, отличное от исходного.
    2. Необходимо указать значения в массиве `done`.
    3. Необходимо указать значения переменных `t`, `x`, `y`.
  3. Сколько операций записи (изменения) памяти в _куче_ и массиве `done` требуется для алгоритма на данном примере?
  4. Какова амортизированная стоимость сборки мусора (в терминах операции записи/изменения памяти в куче и массиве `done`) на данном примере?
]
#solution()[
  #let marked_object(content) = object(content, color: yellow);

  #let replaced(it) = table.cell(fill: blue)[#it]

  Обозначения:
  - ...обозначения из задания
  - #box(object((val(8), ptr(16), nullptr), color: yellow)) -- помеченный блок.
  - #box(object((val(8), replaced(nullptr), nullptr))) -- второе поле временно перезаписано.

  Состояния памяти:

  #table(
    stroke: none,
    row-gutter: (-0.5em, auto),
    columns: ids.len(),
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
    columns: ids.len(),
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
    columns: ids.len(),
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
    columns: ids.len(),
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
    columns: ids.len(),
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
    columns: ids.len(),
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
    columns: ids.len(),
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
    columns: ids.len(),
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
    columns: ids.len(),
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
    columns: ids.len(),
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
    columns: ids.len(),
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
    columns: ids.len(),
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
  1. Адреса помеченных блоков: 1, 7, 10, 13, 16, 25
  2. Состояние памяти в момент пометки блока со значением #val(7) в первом поле:
    1. #table(
        stroke: none,
        row-gutter: (-0.5em, auto),
        columns: ids.len(),
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
  3. 6 (массив `done`) + 10 (изменения в куче) = 16 операций записи
  4. $ (c_1 R + c_2 H) / (H - R) = (10 dot (6 dot 3) + 3 dot 27) / (27 - 6 dot 3) = 29 $
]

#pagebreak()

#task("2")[
  Примените алгоритм сборки мусора копированием [1, Algorithm 13.9] с гибридным перенаправлением указателей [1, Algorithm 13.11], к состоянию памяти представленному на #ref(<r1>) и ответьте на вопросы ниже. В контексте сборки копированием, раздел _from-space_ включает адреса с 1 до 30 (включительно), а раздел _to-space_ — адреса с 31 до 60 (включительно).

  1. Каково состояние кучи после работы алгоритма?
  2. Какой адрес $p_1$ (в _to-space_) соответсвует адресу 1 из _from-space_? То есть, по какому адресу будет находится объект по адресу #ptr(1) после копирования?
  3. Каково состояние кучи в момент вызова процедуры *`Forward`*($p_1$), где $p_1$ — адрес _копии_ данных, которые находились по адресу #ptr(4) до сборки?
  4. Сколько операций записи (изменения) памяти в _куче_ требуется для алгоритма на данном примере? Считайте, что копирование одного машинного слова (из _from-space_ в _to-space_) — это одна операция.
  5. Какова амортизированная стоимость сборки мусора (то есть количество операций записи/изменения памяти в куче на количество собранного мусора) на данном примере?
]
#solution()[
  #let changed(it) = table.cell(fill: blue)[#it]


  #let from_space = ()
  #for i in range(30) { from_space.push(i + 1) }
  #let to_space = from_space.map(x => x + 30);

  #let object(content, color: white) = table.cell(colspan: content.len(), inset: (x: 1.1pt))[ #table(
    columns: content.len(),
    fill: color,
    ..content.map(c => [#c])
  )];

  #let arrow(text) = table(
    stroke: none,
    columns: 1,
    sym.arrow.t,
    raw(text),
  )

  #table(
    stroke: none,
    row-gutter: (-0.5em, auto),
    align: center,
    //
    columns: from_space.len(),
    ..from_space.map(id => table.cell(stroke: none)[#id]),
    object((val(5), nullptr, ptr(7))),
    object((val(1), ptr(19), nullptr)),
    object((val(7), nullptr, ptr(13))),
    object((val(8), ptr(16), nullptr)),
    object((val(9), val(10), ptr(16))),
    object((val(2), ptr(7), ptr(25))),
    object((val(4), ptr(4), ptr(22))),
    object((val(6), ptr(19), ptr(4))),
    object((val(3), nullptr, ptr(1))),
    object(("  ", "  ", "  ")),
    //
    ..range(9).map(_ => table.cell[ ]),
    arrow("p"),
  )

  #table(
    stroke: none,
    row-gutter: (-0.5em, auto),
    align: center,
    //
    columns: to_space.len(),
    ..to_space.map(id => table.cell(stroke: none)[#id]),
    object(("  ", "  ", "  ")),
    object(("  ", "  ", "  ")),
    object(("  ", "  ", "  ")),
    object(("  ", "  ", "  ")),
    object(("  ", "  ", "  ")),
    object(("  ", "  ", "  ")),
    object(("  ", "  ", "  ")),
    object(("  ", "  ", "  ")),
    object(("  ", "  ", "  ")),
    object(("  ", "  ", "  ")),
    //
    ..range(0).map(_ => table.cell[ ]),
    arrow("next scan"),
  )

  #align(center, sym.arrow.b + " Forward(" + ptr(10) + ") + первая итерация Chase(" + ptr(10) + ")")

  #table(
    stroke: none,
    row-gutter: (-0.5em, auto),
    align: center,
    //
    columns: from_space.len(),
    ..from_space.map(id => table.cell(stroke: none)[#id]),
    object((val(5), nullptr, ptr(7))),
    object((val(1), ptr(19), nullptr)),
    object((val(7), nullptr, ptr(13))),
    object((changed(ptr(31)), ptr(16), nullptr)),
    object((val(9), val(10), ptr(16))),
    object((val(2), ptr(7), ptr(25))),
    object((val(4), ptr(4), ptr(22))),
    object((val(6), ptr(19), ptr(4))),
    object((val(3), nullptr, ptr(1))),
    object(("  ", "  ", "  ")),
    //
    ..range(15).map(_ => table.cell[ ]),
    arrow("p"),
  )

  #table(
    stroke: none,
    row-gutter: (-0.5em, auto),
    align: center,
    //
    columns: to_space.len(),
    ..to_space.map(id => table.cell(stroke: none)[#id]),
    object((val(8), ptr(16), nullptr)),
    object(("  ", "  ", "  ")),
    object(("  ", "  ", "  ")),
    object(("  ", "  ", "  ")),
    object(("  ", "  ", "  ")),
    object(("  ", "  ", "  ")),
    object(("  ", "  ", "  ")),
    object(("  ", "  ", "  ")),
    object(("  ", "  ", "  ")),
    object(("  ", "  ", "  ")),
    //
    ..range(0).map(_ => table.cell[ ]),
    arrow("scan"),
    ..range(2).map(_ => table.cell[ ]),
    arrow("next"),
  )

  #align(center, sym.arrow.b + " вторая итерация Chase(" + ptr(10) + ")")

  #table(
    stroke: none,
    row-gutter: (-0.5em, auto),
    align: center,
    //
    columns: from_space.len(),
    ..from_space.map(id => table.cell(stroke: none)[#id]),
    object((val(5), nullptr, ptr(7))),
    object((val(1), ptr(19), nullptr)),
    object((val(7), nullptr, ptr(13))),
    object((changed(ptr(31)), ptr(16), nullptr)),
    object((val(9), val(10), ptr(16))),
    object((changed(ptr(34)), ptr(7), ptr(25))),
    object((val(4), ptr(4), ptr(22))),
    object((val(6), ptr(19), ptr(4))),
    object((val(3), nullptr, ptr(1))),
    object(("  ", "  ", "  ")),
    //
    ..range(24).map(_ => table.cell[ ]),
    arrow("p"),
  )

  #table(
    stroke: none,
    row-gutter: (-0.5em, auto),
    align: center,
    //
    columns: to_space.len(),
    ..to_space.map(id => table.cell(stroke: none)[#id]),
    object((val(8), ptr(16), nullptr)),
    object((val(2), ptr(7), ptr(25))),
    object(("  ", "  ", "  ")),
    object(("  ", "  ", "  ")),
    object(("  ", "  ", "  ")),
    object(("  ", "  ", "  ")),
    object(("  ", "  ", "  ")),
    object(("  ", "  ", "  ")),
    object(("  ", "  ", "  ")),
    object(("  ", "  ", "  ")),
    //
    ..range(0).map(_ => table.cell[ ]),
    arrow("scan"),
    ..range(5).map(_ => table.cell[ ]),
    arrow("next"),
  )

  #align(center, sym.arrow.b + " 3-я итерация Chase(" + ptr(10) + ")")

  #table(
    stroke: none,
    row-gutter: (-0.5em, auto),
    align: center,
    //
    columns: from_space.len(),
    ..from_space.map(id => table.cell(stroke: none)[#id]),
    object((val(5), nullptr, ptr(7))),
    object((val(1), ptr(19), nullptr)),
    object((val(7), nullptr, ptr(13))),
    object((changed(ptr(31)), ptr(16), nullptr)),
    object((val(9), val(10), ptr(16))),
    object((changed(ptr(34)), ptr(7), ptr(25))),
    object((val(4), ptr(4), ptr(22))),
    object((val(6), ptr(19), ptr(4))),
    object((changed(ptr(37)), nullptr, ptr(1))),
    object(("  ", "  ", "  ")),
    //
    ..range(0).map(_ => table.cell[ ]),
    arrow("p"),
  )

  #table(
    stroke: none,
    row-gutter: (-0.5em, auto),
    align: center,
    //
    columns: to_space.len(),
    ..to_space.map(id => table.cell(stroke: none)[#id]),
    object((val(8), ptr(16), nullptr)),
    object((val(2), ptr(7), ptr(25))),
    object((val(3), nullptr, ptr(1))),
    object(("  ", "  ", "  ")),
    object(("  ", "  ", "  ")),
    object(("  ", "  ", "  ")),
    object(("  ", "  ", "  ")),
    object(("  ", "  ", "  ")),
    object(("  ", "  ", "  ")),
    object(("  ", "  ", "  ")),
    //
    ..range(0).map(_ => table.cell[ ]),
    arrow("scan"),
    ..range(8).map(_ => table.cell[ ]),
    arrow("next"),
  )

  #align(center, sym.arrow.b + " 4-я итерация Chase(" + ptr(10) + ")")

  #table(
    stroke: none,
    row-gutter: (-0.5em, auto),
    align: center,
    //
    columns: from_space.len(),
    ..from_space.map(id => table.cell(stroke: none)[#id]),
    object((changed(ptr(40)), nullptr, ptr(7))),
    object((val(1), ptr(19), nullptr)),
    object((val(7), nullptr, ptr(13))),
    object((changed(ptr(31)), ptr(16), nullptr)),
    object((val(9), val(10), ptr(16))),
    object((changed(ptr(34)), ptr(7), ptr(25))),
    object((val(4), ptr(4), ptr(22))),
    object((val(6), ptr(19), ptr(4))),
    object((changed(ptr(37)), nullptr, ptr(1))),
    object(("  ", "  ", "  ")),
    //
    ..range(6).map(_ => table.cell[ ]),
    arrow("p"),
  )

  #table(
    stroke: none,
    row-gutter: (-0.5em, auto),
    align: center,
    //
    columns: to_space.len(),
    ..to_space.map(id => table.cell(stroke: none)[#id]),
    object((val(8), ptr(16), nullptr)),
    object((val(2), ptr(7), ptr(25))),
    object((val(3), nullptr, ptr(1))),
    object((val(5), nullptr, ptr(7))),
    object(("  ", "  ", "  ")),
    object(("  ", "  ", "  ")),
    object(("  ", "  ", "  ")),
    object(("  ", "  ", "  ")),
    object(("  ", "  ", "  ")),
    object(("  ", "  ", "  ")),
    //
    ..range(0).map(_ => table.cell[ ]),
    arrow("scan"),
    ..range(11).map(_ => table.cell[ ]),
    arrow("next"),
  )

  #align(center, sym.arrow.b + " 5-я итерация Chase(" + ptr(10) + ")")

  #table(
    stroke: none,
    row-gutter: (-0.5em, auto),
    align: center,
    //
    columns: from_space.len(),
    ..from_space.map(id => table.cell(stroke: none)[#id]),
    object((changed(ptr(40)), nullptr, ptr(7))),
    object((val(1), ptr(19), nullptr)),
    object((changed(ptr(43)), nullptr, ptr(13))),
    object((changed(ptr(31)), ptr(16), nullptr)),
    object((val(9), val(10), ptr(16))),
    object((changed(ptr(34)), ptr(7), ptr(25))),
    object((val(4), ptr(4), ptr(22))),
    object((val(6), ptr(19), ptr(4))),
    object((changed(ptr(37)), nullptr, ptr(1))),
    object(("  ", "  ", "  ")),
    //
    ..range(12).map(_ => table.cell[ ]),
    arrow("p"),
  )

  #table(
    stroke: none,
    row-gutter: (-0.5em, auto),
    align: center,
    //
    columns: to_space.len(),
    ..to_space.map(id => table.cell(stroke: none)[#id]),
    object((val(8), ptr(16), nullptr)),
    object((val(2), ptr(7), ptr(25))),
    object((val(3), nullptr, ptr(1))),
    object((val(5), nullptr, ptr(7))),
    object((val(7), nullptr, ptr(13))),
    object(("  ", "  ", "  ")),
    object(("  ", "  ", "  ")),
    object(("  ", "  ", "  ")),
    object(("  ", "  ", "  ")),
    object(("  ", "  ", "  ")),
    //
    ..range(0).map(_ => table.cell[ ]),
    arrow("scan"),
    ..range(14).map(_ => table.cell[ ]),
    arrow("next"),
  )

  #align(center, sym.arrow.b + " 6-я итерация Chase(" + ptr(10) + ")")

  #table(
    stroke: none,
    row-gutter: (-0.5em, auto),
    align: center,
    //
    columns: from_space.len(),
    ..from_space.map(id => table.cell(stroke: none)[#id]),
    object((changed(ptr(40)), nullptr, ptr(7))),
    object((val(1), ptr(19), nullptr)),
    object((changed(ptr(43)), nullptr, ptr(13))),
    object((changed(ptr(31)), ptr(16), nullptr)),
    object((changed(ptr(46)), val(10), ptr(16))),
    object((changed(ptr(34)), ptr(7), ptr(25))),
    object((val(4), ptr(4), ptr(22))),
    object((val(6), ptr(19), ptr(4))),
    object((changed(ptr(37)), nullptr, ptr(1))),
    object(("  ", "  ", "  ")),
    //
    raw("p"),
    sym.arrow.r,
    nullptr
  )

  #table(
    stroke: none,
    row-gutter: (-0.5em, auto),
    align: center,
    //
    columns: to_space.len(),
    ..to_space.map(id => table.cell(stroke: none)[#id]),
    object((val(8), ptr(16), nullptr)),
    object((val(2), ptr(7), ptr(25))),
    object((val(3), nullptr, ptr(1))),
    object((val(5), nullptr, ptr(7))),
    object((val(7), nullptr, ptr(13))),
    object((val(9), val(10), ptr(16))),
    object(("  ", "  ", "  ")),
    object(("  ", "  ", "  ")),
    object(("  ", "  ", "  ")),
    object(("  ", "  ", "  ")),
    //
    ..range(0).map(_ => table.cell[ ]),
    arrow("scan"),
    ..range(17).map(_ => table.cell[ ]),
    arrow("next"),
  )

  #align(center, sym.arrow.b + " 1-я итерация " + `while scan < next`)

  #table(
    stroke: none,
    row-gutter: (-0.5em, auto),
    align: center,
    //
    columns: to_space.len(),
    ..to_space.map(id => table.cell(stroke: none)[#id]),
    object((val(8), changed(ptr(34)), nullptr)),
    object((val(2), ptr(7), ptr(25))),
    object((val(3), nullptr, ptr(1))),
    object((val(5), nullptr, ptr(7))),
    object((val(7), nullptr, ptr(13))),
    object((val(9), val(10), ptr(16))),
    object(("  ", "  ", "  ")),
    object(("  ", "  ", "  ")),
    object(("  ", "  ", "  ")),
    object(("  ", "  ", "  ")),
    //
    ..range(3).map(_ => table.cell[ ]),
    arrow("scan"),
    ..range(14).map(_ => table.cell[ ]),
    arrow("next"),
  )

  #align(center, sym.arrow.b + " 2-я итерация " + `while scan < next`)

  #table(
    stroke: none,
    row-gutter: (-0.5em, auto),
    align: center,
    //
    columns: to_space.len(),
    ..to_space.map(id => table.cell(stroke: none)[#id]),
    object((val(8), changed(ptr(34)), nullptr)),
    object((val(2), changed(ptr(43)), changed(ptr(37)))),
    object((val(3), nullptr, ptr(1))),
    object((val(5), nullptr, ptr(7))),
    object((val(7), nullptr, ptr(13))),
    object((val(9), val(10), ptr(16))),
    object(("  ", "  ", "  ")),
    object(("  ", "  ", "  ")),
    object(("  ", "  ", "  ")),
    object(("  ", "  ", "  ")),
    //
    ..range(6).map(_ => table.cell[ ]),
    arrow("scan"),
    ..range(11).map(_ => table.cell[ ]),
    arrow("next"),
  )

  #align(center, sym.arrow.b + " 3-я итерация " + `while scan < next`)

  #table(
    stroke: none,
    row-gutter: (-0.5em, auto),
    align: center,
    //
    columns: to_space.len(),
    ..to_space.map(id => table.cell(stroke: none)[#id]),
    object((val(8), changed(ptr(34)), nullptr)),
    object((val(2), changed(ptr(43)), changed(ptr(37)))),
    object((val(3), nullptr, changed(ptr(31)))),
    object((val(5), nullptr, ptr(7))),
    object((val(7), nullptr, ptr(13))),
    object((val(9), val(10), ptr(16))),
    object(("  ", "  ", "  ")),
    object(("  ", "  ", "  ")),
    object(("  ", "  ", "  ")),
    object(("  ", "  ", "  ")),
    //
    ..range(9).map(_ => table.cell[ ]),
    arrow("scan"),
    ..range(8).map(_ => table.cell[ ]),
    arrow("next"),
  )

  #align(center, sym.arrow.b + " 4-я итерация " + `while scan < next`)

  #table(
    stroke: none,
    row-gutter: (-0.5em, auto),
    align: center,
    //
    columns: to_space.len(),
    ..to_space.map(id => table.cell(stroke: none)[#id]),
    object((val(8), changed(ptr(34)), nullptr)),
    object((val(2), changed(ptr(43)), changed(ptr(37)))),
    object((val(3), nullptr, changed(ptr(31)))),
    object((val(5), nullptr, changed(ptr(43)))),
    object((val(7), nullptr, ptr(13))),
    object((val(9), val(10), ptr(16))),
    object(("  ", "  ", "  ")),
    object(("  ", "  ", "  ")),
    object(("  ", "  ", "  ")),
    object(("  ", "  ", "  ")),
    //
    ..range(12).map(_ => table.cell[ ]),
    arrow("scan"),
    ..range(5).map(_ => table.cell[ ]),
    arrow("next"),
  )

  #align(center, sym.arrow.b + " 5-я итерация " + `while scan < next`)

  #table(
    stroke: none,
    row-gutter: (-0.5em, auto),
    align: center,
    //
    columns: to_space.len(),
    ..to_space.map(id => table.cell(stroke: none)[#id]),
    object((val(8), changed(ptr(34)), nullptr)),
    object((val(2), changed(ptr(43)), changed(ptr(37)))),
    object((val(3), nullptr, changed(ptr(31)))),
    object((val(5), nullptr, changed(ptr(43)))),
    object((val(7), nullptr, changed(ptr(46)))),
    object((val(9), val(10), ptr(16))),
    object(("  ", "  ", "  ")),
    object(("  ", "  ", "  ")),
    object(("  ", "  ", "  ")),
    object(("  ", "  ", "  ")),
    //
    ..range(15).map(_ => table.cell[ ]),
    arrow("scan"),
    ..range(2).map(_ => table.cell[ ]),
    arrow("next"),
  )

  #align(center, sym.arrow.b + " 6-я итерация " + `while scan < next`)

  #table(
    stroke: none,
    row-gutter: (-0.5em, auto),
    align: center,
    //
    columns: to_space.len(),
    ..to_space.map(id => table.cell(stroke: none)[#id]),
    object((val(8), changed(ptr(34)), nullptr)),
    object((val(2), changed(ptr(43)), changed(ptr(37)))),
    object((val(3), nullptr, changed(ptr(31)))),
    object((val(5), nullptr, changed(ptr(43)))),
    object((val(7), nullptr, changed(ptr(46)))),
    object((val(9), val(10), changed(ptr(34)))),
    object(("  ", "  ", "  ")),
    object(("  ", "  ", "  ")),
    object(("  ", "  ", "  ")),
    object(("  ", "  ", "  ")),
    //
    ..range(18).map(_ => table.cell[ ]),
    arrow("scan next"),
  )

  Ответы:
  1. #table(
      stroke: none,
      row-gutter: (-0.5em, auto),
      align: center,
      //
      columns: to_space.len(),
      ..to_space.map(id => table.cell(stroke: none)[#id]),
      object((val(8), ptr(34), nullptr)),
      object((val(2), ptr(43), ptr(37))),
      object((val(3), nullptr, ptr(31))),
      object((val(5), nullptr, ptr(43))),
      object((val(7), nullptr, ptr(46))),
      object((val(9), val(10), ptr(34))),
      object(("  ", "  ", "  ")),
      object(("  ", "  ", "  ")),
      object(("  ", "  ", "  ")),
      object(("  ", "  ", "  ")),
    )
  2. #ptr(40)
  3. Объект по адресу #ptr(4) недостежим и поэтому у него не будет адреса в _to-space_ и *`Forward`* вызван не будет.
  4. $R dot ("<кол-во полей> + 1 (перезапись" p.f_1 ")") + "<кол-во указателей в достижимых объектах>" = 6 dot (3 + 1) + 7 = 31$
  5. $ (c_3 R) / (H/2 - R) = (10 dot (6 dot 3)) / (60 / 2 - 6 dot 3) = 15 $
]
