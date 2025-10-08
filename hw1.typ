#import "@preview/ctheorems:1.1.3": *
#show: thmrules.with(qed-symbol: $square$)
#set page(height: auto, margin: 1.5cm)

#let task = thmbox("theorem", "Задание", fill: rgb("#eeffee")).with(numbering: none)
#let solution = thmproof("proof", "Решение")

#align(center, text[= Максим Исаев])
#align(center, text[== Темы 1–4. Теоретическое задание])

#let val(x) = text(fill: blue, str(x))
#let ptr(x) = underline(str(x))
#let nil = ptr("●");

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
      object((val(5), nil, ptr(7))),
      object((val(1), ptr(19), nil)),
      object((val(7), nil, ptr(13))),
      object((val(8), ptr(16), nil)),
      object((val(9), val(10), ptr(16))),
      object((val(2), ptr(7), ptr(25))),
      object((val(4), ptr(4), ptr(22))),
      object((val(6), ptr(19), ptr(4))),
      object((val(3), nil, ptr(1)))
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
  - #box(object((val(8), ptr(16), nil), color: yellow)) -- помеченный блок.
  - #box(object((val(8), replaced(nil), nil))) -- второе поле временно перезаписано.

  Состояния памяти:
  #block[
    #set par(spacing: 0.5em)

    #table(
      stroke: none,
      row-gutter: (-0.5em, auto),
      columns: ids.len(),
      align: center,
      ..ids.map(id => table.cell(stroke: none)[#id]),
      object((val(5), nil, ptr(7))),
      object((val(1), ptr(19), nil)),
      object((val(7), nil, ptr(13))),
      object((val(8), ptr(16), nil)),
      object((val(9), val(10), ptr(16))),
      object((val(2), ptr(7), ptr(25))),
      object((val(4), ptr(4), ptr(22))),
      object((val(6), ptr(19), ptr(4))),
      object((val(3), nil, ptr(1)))
    )

    #align(center, sym.arrow.b + " нашли непомеченный " + ptr(10) + " в корнях")

    #table(
      stroke: none,
      row-gutter: (-0.5em, auto),
      columns: ids.len(),
      align: center,
      ..ids.map(id => table.cell(stroke: none)[#id]),
      object((val(5), nil, ptr(7))),
      object((val(1), ptr(19), nil)),
      object((val(7), nil, ptr(13))),
      marked_object((val(8), ptr(16), nil)),
      object((val(9), val(10), ptr(16))),
      object((val(2), ptr(7), ptr(25))),
      object((val(4), ptr(4), ptr(22))),
      object((val(6), ptr(19), ptr(4))),
      object((val(3), nil, ptr(1)))
    )

    #align(center, sym.arrow.b + " первое поле не указатель, второе " + ptr(16) + " не помечено")

    #table(
      stroke: none,
      row-gutter: (-0.5em, auto),
      columns: ids.len(),
      align: center,
      ..ids.map(id => table.cell(stroke: none)[#id]),
      object((val(5), nil, ptr(7))),
      object((val(1), ptr(19), nil)),
      object((val(7), nil, ptr(13))),
      marked_object((val(8), replaced(nil), nil)),
      object((val(9), val(10), ptr(16))),
      marked_object((val(2), ptr(7), ptr(25))),
      object((val(4), ptr(4), ptr(22))),
      object((val(6), ptr(19), ptr(4))),
      object((val(3), nil, ptr(1)))
    )

    #align(center, sym.arrow.b)

    #table(
      stroke: none,
      row-gutter: (-0.5em, auto),
      columns: ids.len(),
      align: center,
      ..ids.map(id => table.cell(stroke: none)[#id]),
      object((val(5), nil, ptr(7))),
      object((val(1), ptr(19), nil)),
      marked_object((val(7), nil, ptr(13))),
      marked_object((val(8), replaced(nil), nil)),
      object((val(9), val(10), ptr(16))),
      marked_object((val(2), replaced(ptr(10)), ptr(25))),
      object((val(4), ptr(4), ptr(22))),
      object((val(6), ptr(19), ptr(4))),
      object((val(3), nil, ptr(1)))
    )

    #align(center, sym.arrow.b)

    #table(
      stroke: none,
      row-gutter: (-0.5em, auto),
      columns: ids.len(),
      align: center,
      ..ids.map(id => table.cell(stroke: none)[#id]),
      object((val(5), nil, ptr(7))),
      object((val(1), ptr(19), nil)),
      marked_object((val(7), nil, replaced(ptr(16)))),
      marked_object((val(8), replaced(nil), nil)),
      marked_object((val(9), val(10), ptr(16))),
      marked_object((val(2), replaced(ptr(10)), ptr(25))),
      object((val(4), ptr(4), ptr(22))),
      object((val(6), ptr(19), ptr(4))),
      object((val(3), nil, ptr(1)))
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
      object((val(5), nil, ptr(7))),
      object((val(1), ptr(19), nil)),
      marked_object((val(7), nil, ptr(13))),
      marked_object((val(8), replaced(nil), nil)),
      marked_object((val(9), val(10), ptr(16))),
      marked_object((val(2), replaced(ptr(10)), ptr(25))),
      object((val(4), ptr(4), ptr(22))),
      object((val(6), ptr(19), ptr(4))),
      object((val(3), nil, ptr(1)))
    )

    #align(center, sym.arrow.b + " переходим к следующему полю-указателю у " + ptr(16))

    #table(
      stroke: none,
      row-gutter: (-0.5em, auto),
      columns: ids.len(),
      align: center,
      ..ids.map(id => table.cell(stroke: none)[#id]),
      object((val(5), nil, ptr(7))),
      object((val(1), ptr(19), nil)),
      marked_object((val(7), nil, ptr(13))),
      marked_object((val(8), replaced(nil), nil)),
      marked_object((val(9), val(10), ptr(16))),
      marked_object((val(2), ptr(7), ptr(25))),
      object((val(4), ptr(4), ptr(22))),
      object((val(6), ptr(19), ptr(4))),
      object((val(3), nil, ptr(1)))
    )

    #align(center, sym.arrow.b)

    #table(
      stroke: none,
      row-gutter: (-0.5em, auto),
      columns: ids.len(),
      align: center,
      ..ids.map(id => table.cell(stroke: none)[#id]),
      object((val(5), nil, ptr(7))),
      object((val(1), ptr(19), nil)),
      marked_object((val(7), nil, ptr(13))),
      marked_object((val(8), replaced(nil), nil)),
      marked_object((val(9), val(10), ptr(16))),
      marked_object((val(2), ptr(7), replaced(ptr(10)))),
      object((val(4), ptr(4), ptr(22))),
      object((val(6), ptr(19), ptr(4))),
      marked_object((val(3), nil, ptr(1)))
    )

    #align(center, sym.arrow.b)

    #table(
      stroke: none,
      row-gutter: (-0.5em, auto),
      columns: ids.len(),
      align: center,
      ..ids.map(id => table.cell(stroke: none)[#id]),
      marked_object((val(5), nil, ptr(7))),
      object((val(1), ptr(19), nil)),
      marked_object((val(7), nil, ptr(13))),
      marked_object((val(8), replaced(nil), nil)),
      marked_object((val(9), val(10), ptr(16))),
      marked_object((val(2), ptr(7), replaced(ptr(10)))),
      object((val(4), ptr(4), ptr(22))),
      object((val(6), ptr(19), ptr(4))),
      marked_object((val(3), nil, replaced(ptr(16))))
    )

    #align(center, sym.arrow.b + " у " + ptr(1) + " нет непомеченных полей-указателей")

    #table(
      stroke: none,
      row-gutter: (-0.5em, auto),
      columns: ids.len(),
      align: center,
      ..ids.map(id => table.cell(stroke: none)[#id]),
      marked_object((val(5), nil, ptr(7))),
      object((val(1), ptr(19), nil)),
      marked_object((val(7), nil, ptr(13))),
      marked_object((val(8), replaced(nil), nil)),
      marked_object((val(9), val(10), ptr(16))),
      marked_object((val(2), ptr(7), replaced(ptr(10)))),
      object((val(4), ptr(4), ptr(22))),
      object((val(6), ptr(19), ptr(4))),
      marked_object((val(3), nil, ptr(1)))
    )

    #align(center, sym.arrow.b)

    #table(
      stroke: none,
      row-gutter: (-0.5em, auto),
      columns: ids.len(),
      align: center,
      ..ids.map(id => table.cell(stroke: none)[#id]),
      marked_object((val(5), nil, ptr(7))),
      object((val(1), ptr(19), nil)),
      marked_object((val(7), nil, ptr(13))),
      marked_object((val(8), replaced(nil), nil)),
      marked_object((val(9), val(10), ptr(16))),
      marked_object((val(2), ptr(7), ptr(25))),
      object((val(4), ptr(4), ptr(22))),
      object((val(6), ptr(19), ptr(4))),
      marked_object((val(3), nil, ptr(1)))
    )

    #align(center, sym.arrow.b)

    #table(
      stroke: none,
      row-gutter: (-0.5em, auto),
      columns: ids.len(),
      align: center,
      ..ids.map(id => table.cell(stroke: none)[#id]),
      marked_object((val(5), nil, ptr(7))),
      object((val(1), ptr(19), nil)),
      marked_object((val(7), nil, ptr(13))),
      marked_object((val(8), ptr(16), nil)),
      marked_object((val(9), val(10), ptr(16))),
      marked_object((val(2), ptr(7), ptr(25))),
      object((val(4), ptr(4), ptr(22))),
      object((val(6), ptr(19), ptr(4))),
      marked_object((val(3), nil, ptr(1)))
    )
  ]
  *Ответы*:
  1. Адреса помеченных блоков: 1, 7, 10, 13, 16, 25
  2. Состояние памяти в момент пометки блока со значением #val(7) в первом поле:
    1. #table(
        stroke: none,
        row-gutter: (-0.5em, auto),
        columns: ids.len(),
        align: center,
        ..ids.map(id => table.cell(stroke: none)[#id]),
        object((val(5), nil, ptr(7))),
        object((val(1), ptr(19), nil)),
        marked_object((val(7), nil, ptr(13))),
        marked_object((val(8), replaced(nil), nil)),
        object((val(9), val(10), ptr(16))),
        marked_object((val(2), replaced(ptr(10)), ptr(25))),
        object((val(4), ptr(4), ptr(22))),
        object((val(6), ptr(19), ptr(4))),
        object((val(3), nil, ptr(1)))
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

  #let total_memory = 60
  #let from_space = range(1, calc.floor(total_memory / 2) + 1)
  #let to_space = range(calc.floor(total_memory / 2) + 1, total_memory + 1)

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

  Изменение памяти во время исполнения программы:
  #block[
    #set par(spacing: 0.5em)
    #set table(row-gutter: (-0.5em, auto))
    #table(
      stroke: none,
      row-gutter: (-0.5em, auto),
      align: center,
      //
      columns: from_space.len(),
      ..from_space.map(id => table.cell(stroke: none)[#id]),
      object((val(5), nil, ptr(7))),
      object((val(1), ptr(19), nil)),
      object((val(7), nil, ptr(13))),
      object((val(8), ptr(16), nil)),
      object((val(9), val(10), ptr(16))),
      object((val(2), ptr(7), ptr(25))),
      object((val(4), ptr(4), ptr(22))),
      object((val(6), ptr(19), ptr(4))),
      object((val(3), nil, ptr(1))),
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
      object((val(5), nil, ptr(7))),
      object((val(1), ptr(19), nil)),
      object((val(7), nil, ptr(13))),
      object((changed(ptr(31)), ptr(16), nil)),
      object((val(9), val(10), ptr(16))),
      object((val(2), ptr(7), ptr(25))),
      object((val(4), ptr(4), ptr(22))),
      object((val(6), ptr(19), ptr(4))),
      object((val(3), nil, ptr(1))),
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
      object((val(8), ptr(16), nil)),
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
      object((val(5), nil, ptr(7))),
      object((val(1), ptr(19), nil)),
      object((val(7), nil, ptr(13))),
      object((changed(ptr(31)), ptr(16), nil)),
      object((val(9), val(10), ptr(16))),
      object((changed(ptr(34)), ptr(7), ptr(25))),
      object((val(4), ptr(4), ptr(22))),
      object((val(6), ptr(19), ptr(4))),
      object((val(3), nil, ptr(1))),
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
      object((val(8), ptr(16), nil)),
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
      object((val(5), nil, ptr(7))),
      object((val(1), ptr(19), nil)),
      object((val(7), nil, ptr(13))),
      object((changed(ptr(31)), ptr(16), nil)),
      object((val(9), val(10), ptr(16))),
      object((changed(ptr(34)), ptr(7), ptr(25))),
      object((val(4), ptr(4), ptr(22))),
      object((val(6), ptr(19), ptr(4))),
      object((changed(ptr(37)), nil, ptr(1))),
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
      object((val(8), ptr(16), nil)),
      object((val(2), ptr(7), ptr(25))),
      object((val(3), nil, ptr(1))),
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
      object((changed(ptr(40)), nil, ptr(7))),
      object((val(1), ptr(19), nil)),
      object((val(7), nil, ptr(13))),
      object((changed(ptr(31)), ptr(16), nil)),
      object((val(9), val(10), ptr(16))),
      object((changed(ptr(34)), ptr(7), ptr(25))),
      object((val(4), ptr(4), ptr(22))),
      object((val(6), ptr(19), ptr(4))),
      object((changed(ptr(37)), nil, ptr(1))),
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
      object((val(8), ptr(16), nil)),
      object((val(2), ptr(7), ptr(25))),
      object((val(3), nil, ptr(1))),
      object((val(5), nil, ptr(7))),
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
      object((changed(ptr(40)), nil, ptr(7))),
      object((val(1), ptr(19), nil)),
      object((changed(ptr(43)), nil, ptr(13))),
      object((changed(ptr(31)), ptr(16), nil)),
      object((val(9), val(10), ptr(16))),
      object((changed(ptr(34)), ptr(7), ptr(25))),
      object((val(4), ptr(4), ptr(22))),
      object((val(6), ptr(19), ptr(4))),
      object((changed(ptr(37)), nil, ptr(1))),
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
      object((val(8), ptr(16), nil)),
      object((val(2), ptr(7), ptr(25))),
      object((val(3), nil, ptr(1))),
      object((val(5), nil, ptr(7))),
      object((val(7), nil, ptr(13))),
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
      object((changed(ptr(40)), nil, ptr(7))),
      object((val(1), ptr(19), nil)),
      object((changed(ptr(43)), nil, ptr(13))),
      object((changed(ptr(31)), ptr(16), nil)),
      object((changed(ptr(46)), val(10), ptr(16))),
      object((changed(ptr(34)), ptr(7), ptr(25))),
      object((val(4), ptr(4), ptr(22))),
      object((val(6), ptr(19), ptr(4))),
      object((changed(ptr(37)), nil, ptr(1))),
      object(("  ", "  ", "  ")),
      //
      raw("p"),
      sym.arrow.r,
      nil
    )

    #table(
      stroke: none,
      row-gutter: (-0.5em, auto),
      align: center,
      //
      columns: to_space.len(),
      ..to_space.map(id => table.cell(stroke: none)[#id]),
      object((val(8), ptr(16), nil)),
      object((val(2), ptr(7), ptr(25))),
      object((val(3), nil, ptr(1))),
      object((val(5), nil, ptr(7))),
      object((val(7), nil, ptr(13))),
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
      object((val(8), changed(ptr(34)), nil)),
      object((val(2), ptr(7), ptr(25))),
      object((val(3), nil, ptr(1))),
      object((val(5), nil, ptr(7))),
      object((val(7), nil, ptr(13))),
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
      object((val(8), changed(ptr(34)), nil)),
      object((val(2), changed(ptr(43)), changed(ptr(37)))),
      object((val(3), nil, ptr(1))),
      object((val(5), nil, ptr(7))),
      object((val(7), nil, ptr(13))),
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
      object((val(8), changed(ptr(34)), nil)),
      object((val(2), changed(ptr(43)), changed(ptr(37)))),
      object((val(3), nil, changed(ptr(31)))),
      object((val(5), nil, ptr(7))),
      object((val(7), nil, ptr(13))),
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
      object((val(8), changed(ptr(34)), nil)),
      object((val(2), changed(ptr(43)), changed(ptr(37)))),
      object((val(3), nil, changed(ptr(31)))),
      object((val(5), nil, changed(ptr(43)))),
      object((val(7), nil, ptr(13))),
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
      object((val(8), changed(ptr(34)), nil)),
      object((val(2), changed(ptr(43)), changed(ptr(37)))),
      object((val(3), nil, changed(ptr(31)))),
      object((val(5), nil, changed(ptr(43)))),
      object((val(7), nil, changed(ptr(46)))),
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
      object((val(8), changed(ptr(34)), nil)),
      object((val(2), changed(ptr(43)), changed(ptr(37)))),
      object((val(3), nil, changed(ptr(31)))),
      object((val(5), nil, changed(ptr(43)))),
      object((val(7), nil, changed(ptr(46)))),
      object((val(9), val(10), changed(ptr(34)))),
      object(("  ", "  ", "  ")),
      object(("  ", "  ", "  ")),
      object(("  ", "  ", "  ")),
      object(("  ", "  ", "  ")),
      //
      ..range(18).map(_ => table.cell[ ]),
      arrow("scan next"),
    )
  ]
  *Ответы*:
  1. #table(
      stroke: none,
      row-gutter: (-0.5em, auto),
      align: center,
      //
      columns: to_space.len(),
      ..to_space.map(id => table.cell(stroke: none)[#id]),
      object((val(8), ptr(34), nil)),
      object((val(2), ptr(43), ptr(37))),
      object((val(3), nil, ptr(31))),
      object((val(5), nil, ptr(43))),
      object((val(7), nil, ptr(46))),
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
#pagebreak()

#task("3")[
  #import "@preview/codelst:2.0.2": sourcecode

  Продемонстрируйте работу алгоритма Бейкера [1, §13.6] (инкрементальная сборка мусора), полагаясь на гибридный (semi-depth-first) алгоритм обхода и перенаправления указателей [1, Algorithm 13.11], на следующей программе. Учтите, что общая доступная память (_from-space_ + _to-space_) — 60 машинных слов.

  #sourcecode[
    ```py
    def insert(t, x):
      if t is None:
        return [x, None, None]
      elif x < t[0]:
        r = [t[0], None, t[2]]
        lt = insert(t[1], x)
        r[1] = lt
        return r
      else:
        r = [t[0], t[1], None]
        rt = insert(t[2], x)
        r[2] = rt
        return r

    n = 12
    t = None
    while n > 1:
      t = insert(t, n)
      if n % 2 == 0:
        n = n / 2
      else:
        n = 3 * n + 1
    print(t)
    ```
  ]

  #enum(
    numbering: "1.",
    enum.item[В какой момент работы программы происходит инициализация сборки мусора? Происходит ли инициализация второй раз? Если да, то в какой момент?],
    enum.item[Сколько мусора (кол-во машинных слов) находится на куче в момент вызова сборщика мусора (первый раз)?],
    enum.item[Сколько мусора (кол-во машинных слов) находится на куче в момент завершения сборки мусора (первый раз)?],
    enum.item[
      Каково состояние кучи после вызова insert(t, 5) в основной программе?
      #enum(
        numbering: "(a)",
        enum.item[Покажите состояние ячеек памяти в from-space и to-space.],
        enum.item[Покажите значения корней основной программы.],
        enum.item[Покажите значения (куда указывают) переменные scan, next, limit.],
      )
    ],
  )
]
#solution()[
  #let changed(it) = table.cell(fill: blue)[#it]

  #let total_memory = 60

  #let n = calc.floor(total_memory / 2)
  #let from_space = range(1, n + 1)
  #let to_space = range(n + 1, total_memory + 1)

  #let from_space_ids = from_space.map(id => table.cell(stroke: none)[#id])
  #let to_space_ids = to_space.map(id => table.cell(stroke: none)[#id])

  #let object(content, color: white) = table.cell(colspan: content.len(), inset: (x: 1.1pt))[ #table(
    columns: content.len(),
    fill: color,
    ..content.map(c => [#c])
  )];

  #let arrow(text) = table(
    stroke: none,
    row-gutter: (-0.5em),
    columns: 1,
    sym.arrow.t,
    raw(text),
  )

  #let ptrs(ptrs) = {
    let res = ()
    let ptr = 0
    for (i, name) in ptrs {
      res += range(i - ptr - 1).map(_ => table.cell[ ])
      res.push(arrow(name))
      ptr = i
    }
    res += range(n - ptr).map(_ => table.cell[ ])
    assert(res.len() == n, message: repr(ptr) + " " + repr(res.len()) + " not full row")
    return res
  }

  #let limit(limit) = {
    let res = ()
    res += range(limit - 1).map(_ => table.cell[ ])
    res.push(arrow("limit"))
    res += range(n - limit).map(_ => table.cell[ ])
    assert(res.len() == n, message: "not full row")
    return res
  }

  Изменение памяти во время исполнения программы:

  #block[

    #set par(spacing: 0.5em)
    #table(
      stroke: none,
      row-gutter: (-0.7em),
      align: center,
      ///////////////////////////////
      columns: n,
      ..from_space_ids,
      ..(object(("  ", "  ", "  ")),) * 10,
      ////
      ..to_space_ids,
      ..(object(("  ", "  ", "  ")),) * 10,
      ..limit(30),
    )


    #line(length: 100%)
    n = 12,
    t = #nil

    #align(center, sym.arrow.b + " insert(" + nil + ", " + val(12) + ")")
    #table(
      stroke: none,
      row-gutter: (-0.7em),
      align: center,
      ///////////////////////////////
      columns: n,
      ..from_space_ids,
      object((val(12), nil, nil)),
      object(("  ", "  ", "  ")),
      object(("  ", "  ", "  ")),
      object(("  ", "  ", "  ")),
      object(("  ", "  ", "  ")),
      object(("  ", "  ", "  ")),
      object(("  ", "  ", "  ")),
      object(("  ", "  ", "  ")),
      object(("  ", "  ", "  ")),
      object(("  ", "  ", "  ")),
    )

    #line(length: 100%)
    n = 6,
    t = [12, #nil, #nil]

    #align(center, sym.arrow.b + " insert(" + ptr(1) + ", " + val(6) + ")")
    #table(
      stroke: none,
      row-gutter: (-0.7em),
      align: center,
      ///////////////////////////////
      columns: n,
      ..from_space_ids,
      object((val(12), nil, nil)),
      object((val(12), nil, nil)),
      object(("  ", "  ", "  ")),
      object(("  ", "  ", "  ")),
      object(("  ", "  ", "  ")),
      object(("  ", "  ", "  ")),
      object(("  ", "  ", "  ")),
      object(("  ", "  ", "  ")),
      object(("  ", "  ", "  ")),
      object(("  ", "  ", "  ")),
    )

    #align(center, sym.arrow.b + " insert(" + nil + ", " + val(6) + ")")
    #table(
      stroke: none,
      row-gutter: (-0.7em),
      align: center,
      ///////////////////////////////
      columns: n,
      ..from_space_ids,
      object((val(12), nil, nil)),
      object((val(12), changed(ptr(7)), nil)),
      object((val(6), nil, nil)),
      object(("  ", "  ", "  ")),
      object(("  ", "  ", "  ")),
      object(("  ", "  ", "  ")),
      object(("  ", "  ", "  ")),
      object(("  ", "  ", "  ")),
      object(("  ", "  ", "  ")),
      object(("  ", "  ", "  ")),
    )

    #line(length: 100%)
    n = 6,
    t = [12, [6, #nil, #nil], #nil]

    #align(center, sym.arrow.b + " insert(" + ptr(4) + ", " + val(3) + ")")
    #table(
      stroke: none,
      row-gutter: (-0.7em),
      align: center,
      ///////////////////////////////
      columns: n,
      ..from_space_ids,
      object((val(12), nil, nil)),
      object((val(12), ptr(7), nil)),
      object((val(6), nil, nil)),
      object((val(12), nil, nil)),
      object(("  ", "  ", "  ")),
      object(("  ", "  ", "  ")),
      object(("  ", "  ", "  ")),
      object(("  ", "  ", "  ")),
      object(("  ", "  ", "  ")),
      object(("  ", "  ", "  ")),
    )

    #align(center, sym.arrow.b + " insert(" + ptr(7) + ", " + val(3) + ")")
    #table(
      stroke: none,
      row-gutter: (-0.7em),
      align: center,
      ///////////////////////////////
      columns: n,
      ..from_space_ids,
      object((val(12), nil, nil)),
      object((val(12), ptr(7), nil)),
      object((val(6), nil, nil)),
      object((val(12), nil, nil)),
      object((val(6), nil, nil)),
      object(("  ", "  ", "  ")),
      object(("  ", "  ", "  ")),
      object(("  ", "  ", "  ")),
      object(("  ", "  ", "  ")),
      object(("  ", "  ", "  ")),
    )

    #align(center, sym.arrow.b + " insert(" + nil + ", " + val(3) + ")")
    #table(
      stroke: none,
      row-gutter: (-0.7em),
      align: center,
      ///////////////////////////////
      columns: n,
      ..from_space_ids,
      object((val(12), nil, nil)),
      object((val(12), ptr(7), nil)),
      object((val(6), nil, nil)),
      object((val(12), changed(ptr(13)), nil)),
      object((val(6), changed(ptr(16)), nil)),
      object((val(3), nil, nil)),
      object(("  ", "  ", "  ")),
      object(("  ", "  ", "  ")),
      object(("  ", "  ", "  ")),
      object(("  ", "  ", "  ")),
    )

    #line(length: 100%)
    n = 10,
    t = [12, [6, [3, #nil, #nil], #nil], #nil]

    #align(center, sym.arrow.b + " insert(" + ptr(10) + ", " + val(10) + ")")
    #table(
      stroke: none,
      row-gutter: (-0.7em),
      align: center,
      ///////////////////////////////
      columns: n,
      ..from_space_ids,
      object((val(12), nil, nil)),
      object((val(12), ptr(7), nil)),
      object((val(6), nil, nil)),
      object((val(12), ptr(13), nil)),
      object((val(6), ptr(16), nil)),
      object((val(3), nil, nil)),
      object((val(12), nil, nil)),
      object(("  ", "  ", "  ")),
      object(("  ", "  ", "  ")),
      object(("  ", "  ", "  ")),
    )

    #align(center, sym.arrow.b + " insert(" + ptr(13) + ", " + val(10) + ")")
    #table(
      stroke: none,
      row-gutter: (-0.7em),
      align: center,
      ///////////////////////////////
      columns: n,
      ..from_space_ids,
      object((val(12), nil, nil)),
      object((val(12), ptr(7), nil)),
      object((val(6), nil, nil)),
      object((val(12), ptr(13), nil)),
      object((val(6), ptr(16), nil)),
      object((val(3), nil, nil)),
      object((val(12), nil, nil)),
      object((val(6), ptr(16), nil)),
      object(("  ", "  ", "  ")),
      object(("  ", "  ", "  ")),
    )

    #align(center, sym.arrow.b + " insert(" + nil + ", " + val(10) + ")")
    #table(
      stroke: none,
      row-gutter: (-0.7em),
      align: center,
      ///////////////////////////////
      columns: n,
      ..from_space_ids,
      object((val(12), nil, nil)),
      object((val(12), ptr(7), nil)),
      object((val(6), nil, nil)),
      object((val(12), ptr(13), nil)),
      object((val(6), ptr(16), nil)),
      object((val(3), nil, nil)),
      object((val(12), changed(ptr(22)), nil)),
      object((val(6), ptr(16), changed(ptr(25)))),
      object((val(10), nil, nil)),
      object(("  ", "  ", "  ")),
    )

    #line(length: 100%)
    n = 5,
    t = [12, [6.0, [3.0, #nil, #nil], [10.0, #nil, #nil]], #nil]

    #align(center, sym.arrow.b + " insert(" + ptr(19) + ", " + val(5) + ")")
    #table(
      stroke: none,
      row-gutter: (-0.7em),
      align: center,
      ///////////////////////////////
      columns: n,
      ..from_space_ids,
      object((val(12), nil, nil)),
      object((val(12), ptr(7), nil)),
      object((val(6), nil, nil)),
      object((val(12), ptr(13), nil)),
      object((val(6), ptr(16), nil)),
      object((val(3), nil, nil)),
      object((val(12), ptr(22), nil)),
      object((val(6), ptr(16), ptr(25))),
      object((val(10), nil, nil)),
      object((val(12), nil, nil)),
      ////

      ..to_space_ids,
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
      ..ptrs(((1, "scan next"), (30, "limit")))
    )

    Попытка аллоцировать память для нового объекта #text(fill: red)[[6, None, ptr(25)]] вызывает сборку мусора.

    #align(center, sym.arrow.b + " insert(" + ptr(22) + ", " + val(5) + ")")
    #table(
      stroke: none,
      row-gutter: (-0.5em),
      align: center,
      ///////////////////////////////
      columns: n,
      ..from_space_ids,
      object((val(12), nil, nil)),
      object((val(12), ptr(7), nil)),
      object((val(6), nil, nil)),
      object((val(12), ptr(13), nil)),
      object((val(6), ptr(16), nil)),
      object((val(3), nil, nil)),
      object((changed(ptr(31)), ptr(22), nil)),
      object((changed(ptr(34)), ptr(16), ptr(25))),
      object((changed(ptr(37)), nil, nil)),
      object((changed(ptr(40)), nil, nil)),

      ////
      ..to_space_ids,
      object((val(12), changed(ptr(34)), nil)),
      object((val(6), ptr(16), ptr(25))),
      object((val(10), nil, nil)),
      object((val(12), nil, nil)),
      object(("  ", "  ", "  ")),
      object(("  ", "  ", "  ")),
      object(("  ", "  ", "  ")),
      object(("  ", "  ", "  ")),
      object(("  ", "  ", "  ")),
      object((val(6), nil, ptr(37))),
      ..ptrs(((4, "scan"), (13, "next"), (27, "limit")))
    )

    #align(center, sym.arrow.b + " insert(" + ptr(16) + ", " + val(5) + ")" + " read barier 16 -> 43")
    #table(
      stroke: none,
      row-gutter: (-0.5em),
      align: center,
      ///////////////////////////////
      columns: n,
      ..from_space_ids,
      object((val(12), nil, nil)),
      object((val(12), ptr(7), nil)),
      object((val(6), nil, nil)),
      object((val(12), ptr(13), nil)),
      object((val(6), ptr(16), nil)),
      object((changed(ptr(43)), nil, nil)),
      object((ptr(31), ptr(22), nil)),
      object((ptr(34), ptr(16), ptr(25))),
      object((ptr(37), nil, nil)),
      object((ptr(40), nil, nil)),


      ////
      ..to_space_ids,
      object((val(12), ptr(34), nil)),
      object((val(6), changed(ptr(43)), changed(ptr(37)))),
      object((val(10), nil, nil)),
      object((val(12), nil, nil)),
      object((val(3), nil, nil)),
      object(("  ", "  ", "  ")),
      object(("  ", "  ", "  ")),
      object(("  ", "  ", "  ")),
      object((val(3), nil, nil)),
      object((val(6), nil, ptr(37))),
      ..ptrs(((7, "scan"), (16, "next"), (24, "limit")))
    )

    #align(center, sym.arrow.b + " insert(" + nil + ", " + val(5) + ")")
    #table(
      stroke: none,
      row-gutter: (-0.5em),
      align: center,
      ///////////////////////////////
      columns: n,
      ..from_space_ids,
      object((val(12), nil, nil)),
      object((val(12), ptr(7), nil)),
      object((val(6), nil, nil)),
      object((val(12), ptr(13), nil)),
      object((val(6), ptr(16), nil)),
      object((changed(ptr(43)), nil, nil)),
      object((ptr(31), ptr(22), nil)),
      object((ptr(34), ptr(16), ptr(25))),
      object((ptr(37), nil, nil)),
      object((ptr(40), nil, nil)),

      ////
      ..to_space_ids,
      object((val(12), ptr(34), nil)),
      object((val(6), ptr(43), ptr(37))),
      object((val(10), nil, nil)),
      object((val(12), changed(ptr(58)), nil)),
      object((val(3), nil, nil)),
      object(("  ", "  ", "  ")),
      object(("  ", "  ", "  ")),
      object((val(5), nil, nil)),
      object((val(3), changed(ptr(52)), nil)),
      object((val(6), changed(ptr(55)), ptr(37))),
      ..ptrs(((10, "scan"), (16, "next"), (21, "limit")))
    )

    #align(center, sym.arrow.b + " Конец сборки мусора insert(" + ptr(49) + ", " + val(8) + ")")
    #table(
      stroke: none,
      row-gutter: (-0.5em),
      align: center,
      ///////////////////////////////
      columns: n,
      ..from_space_ids,
      object((val(12), nil, nil)),
      object((val(12), ptr(7), nil)),
      object((val(6), nil, nil)),
      object((val(12), ptr(13), nil)),
      object((val(6), ptr(16), nil)),
      object((ptr(43), nil, nil)),
      object((ptr(31), ptr(22), nil)),
      object((ptr(34), ptr(16), ptr(25))),
      object((ptr(37), nil, nil)),
      object((ptr(40), nil, nil)),

      ////
      ..to_space_ids,
      object((val(12), ptr(34), nil)),
      object((val(6), ptr(43), ptr(37))),
      object((val(10), nil, nil)),
      object((val(12), ptr(58), nil)),
      object((val(3), nil, nil)),
      object((val(16), nil, nil)),
      object((val(12), nil, ptr(46))),
      object((val(5), nil, nil)),
      object((val(3), ptr(52), nil)),
      object((val(6), ptr(55), ptr(37))),
      ..ptrs(((15, "scan next limit"),))
    )
  ]

  *Ответы*:
  #enum(
    numbering: "1.",
    enum.item[
      Инициализация сборки мусора (помечено красным) произойдёт на 5 итерации при попытке аллоцировать память для нового объекта [6, None, ptr(25)].

      #import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node
      #figure(
        diagram(
          node-stroke: luma(80%),
          node((0, -1), [#"__main__"], name: <main>),
          node((0, 0), [insert(#ptr(19), #val(5))], name: <i19-5>),
          node((0, 1), [alloc([#val(12), #nil, #nil])], name: <a1>),
          node((1, 1), [insert(#ptr(22), #val(5))], name: <i22-5>),
          node((1, 2), [alloc([#val(6), #nil, #ptr(25)])], name: <a2>, stroke: red, fill: rgb(255, 200, 200, 80%)),

          edge(<main>, <i19-5>, "-|>"),
          edge(<i19-5>, <a1>, "-|>"),
          edge(<i19-5>, <i22-5>, "-|>", label: `x < t[0] (10 < 12)`),
          edge(<i22-5>, <a2>, "-|>"),
        ),
        caption: [Дерево вызовов на 5-й итерации],
      )

      Инициализация сборки мусора произойдёт второй раз, т.к. всего будет 28 аллокаций (легко проверить запустив программу и посчитав создания списков), что равно $28 * 3 = 84$ машинным словам, а за одну итерацию можно собрать не более половины памяти, т.е. $30$ машинных слов: $84 - 30 = 54 > 30$.

    ],
    enum.item[
      Рассмотрим состояние памяти в момент начала сборки мусора:
      #table(
        columns: 2,
        table.cell(colspan: 2, align: center)[Корни],
        "t", "r",
        ptr(19), ptr(28),
      )

      Достижимые объекты:

      #block[
        #set par(spacing: 0.5em)

        #table(
          stroke: none,
          row-gutter: (-0.7em),
          align: center,
          ///////////////////////////////
          columns: n,
          ..from_space_ids,
          object((val(12), nil, nil), color: white),
          object((val(12), ptr(7), nil), color: white),
          object((val(6), nil, nil), color: white),
          object((val(12), ptr(13), nil), color: white),
          object((val(6), ptr(16), nil), color: white),
          object((val(3), nil, nil), color: white),
          object((val(12), ptr(22), nil), color: yellow),
          object((val(6), ptr(16), ptr(25)), color: white),
          object((val(10), nil, nil), color: white),
          object((val(12), nil, nil), color: yellow),
          ////
        )
        #table(
          stroke: none,
          row-gutter: (-0.7em),
          align: center,
          ///////////////////////////////
          columns: n,
          ..from_space_ids,
          object((val(12), nil, nil), color: white),
          object((val(12), ptr(7), nil), color: white),
          object((val(6), nil, nil), color: white),
          object((val(12), ptr(13), nil), color: white),
          object((val(6), ptr(16), nil), color: white),
          object((val(3), nil, nil), color: white),
          object((val(12), ptr(22), nil), color: yellow),
          object((val(6), ptr(16), ptr(25)), color: yellow),
          object((val(10), nil, nil), color: white),
          object((val(12), nil, nil), color: yellow),
          ////
        )
        #table(
          stroke: none,
          row-gutter: (-0.7em),
          align: center,
          ///////////////////////////////
          columns: n,
          ..from_space_ids,
          object((val(12), nil, nil), color: white),
          object((val(12), ptr(7), nil), color: white),
          object((val(6), nil, nil), color: white),
          object((val(12), ptr(13), nil), color: white),
          object((val(6), ptr(16), nil), color: white),
          object((val(3), nil, nil), color: yellow),
          object((val(12), ptr(22), nil), color: yellow),
          object((val(6), ptr(16), ptr(25)), color: yellow),
          object((val(10), nil, nil), color: yellow),
          object((val(12), nil, nil), color: yellow),
          ////
        )

      ]

      Итого на куче 5 недостижимых объектов: *15 мусорных машинных слов*.
    ],
    enum.item[
      Рассмотрим состояние памяти в момент начала сборки мусора:
      #table(
        columns: 2,
        table.cell(colspan: 2, align: center)[Корни],
        "t", "r",
        ptr(40), ptr(49),
      )

      Достижимые объекты:

      #table(
        stroke: none,
        row-gutter: (-0.5em),
        align: center,
        ///////////////////////////////
        columns: n,
        ////
        ..to_space_ids,
        object((val(12), ptr(34), nil)),
        object((val(6), ptr(43), ptr(37))),
        object((val(10), nil, nil)),
        object((val(12), ptr(58), nil), color: yellow),
        object((val(3), nil, nil)),
        object((val(16), nil, nil)),
        object((val(12), nil, ptr(46)), color: yellow),
        object((val(5), nil, nil)),
        object((val(3), ptr(52), nil)),
        object((val(6), ptr(55), ptr(37))),
      )
      #table(
        stroke: none,
        row-gutter: (-0.5em),
        align: center,
        ///////////////////////////////
        columns: n,
        ////
        ..to_space_ids,
        object((val(12), ptr(34), nil)),
        object((val(6), ptr(43), ptr(37))),
        object((val(10), nil, nil)),
        object((val(12), ptr(58), nil), color: yellow),
        object((val(3), nil, nil)),
        object((val(16), nil, nil), color: yellow),
        object((val(12), nil, ptr(46)), color: yellow),
        object((val(5), nil, nil)),
        object((val(3), ptr(52), nil)),
        object((val(6), ptr(55), ptr(37)), color: yellow),
      )
      #table(
        stroke: none,
        row-gutter: (-0.5em),
        align: center,
        ///////////////////////////////
        columns: n,
        ////
        ..to_space_ids,
        object((val(12), ptr(34), nil)),
        object((val(6), ptr(43), ptr(37))),
        object((val(10), nil, nil), color: yellow),
        object((val(12), ptr(58), nil), color: yellow),
        object((val(3), nil, nil)),
        object((val(16), nil, nil), color: yellow),
        object((val(12), nil, ptr(46)), color: yellow),
        object((val(5), nil, nil)),
        object((val(3), ptr(52), nil), color: yellow),
        object((val(6), ptr(55), ptr(37)), color: yellow),
      )
      #table(
        stroke: none,
        row-gutter: (-0.5em),
        align: center,
        ///////////////////////////////
        columns: n,
        ////
        ..to_space_ids,
        object((val(12), ptr(34), nil)),
        object((val(6), ptr(43), ptr(37))),
        object((val(10), nil, nil), color: yellow),
        object((val(12), ptr(58), nil), color: yellow),
        object((val(3), nil, nil)),
        object((val(16), nil, nil), color: yellow),
        object((val(12), nil, ptr(46)), color: yellow),
        object((val(5), nil, nil), color: yellow),
        object((val(3), ptr(52), nil), color: yellow),
        object((val(6), ptr(55), ptr(37)), color: yellow),
      )

      Итого на куче 3 недостижимых объектов: *9 мусорных машинных слов*.
    ],
    enum.item[
      #enum(
        numbering: "(a)",
        enum.item[
          Память на момент *после* вызова `insert(t, 5)`:

          #table(
            stroke: none,
            row-gutter: (-0.5em),
            align: center,
            ///////////////////////////////
            columns: n,
            ..from_space_ids,
            object((val(12), nil, nil)),
            object((val(12), ptr(7), nil)),
            object((val(6), nil, nil)),
            object((val(12), ptr(13), nil)),
            object((val(6), ptr(16), nil)),
            object((ptr(43), nil, nil)),
            object((ptr(31), ptr(22), nil)),
            object((ptr(34), ptr(16), ptr(25))),
            object((ptr(37), nil, nil)),
            object((ptr(40), nil, nil)),

            ////
            ..to_space_ids,
            object((val(12), ptr(34), nil)),
            object((val(6), ptr(43), ptr(37))),
            object((val(10), nil, nil)),
            object((val(12), ptr(58), nil)),
            object((val(3), nil, nil)),
            object(("  ", "  ", "  ")),
            object(("  ", "  ", "  ")),
            object((val(5), nil, nil)),
            object((val(3), ptr(52), nil)),
            object((val(6), ptr(55), ptr(37))),
            ..ptrs(((10, "scan"), (16, "next"), (21, "limit")))
          )
        ],
        enum.item[
          #table(
            columns: 2,
            align: center,
            table.cell(colspan: 2, align: center)[Корни],
            "t", "n",
            ptr(40), val(5),
          )

        ],
        enum.item[
          #context [
            #let header = "Переменные сборщика мусора"
            #let size = measure(header).width + 0.7em * 2
            #table(
              columns: (size / 3, size / 3, size / 3),
              align: center,
              table.cell(colspan: 3, align: center)[#header],
              "scan", "next", "limit",
              ptr(40), ptr(46), ptr(51),
            )
          ]
        ],
      )
    ],
  )
]
#pagebreak()

#import "@preview/codelst:2.0.2": sourcecode

#task("4")[
  #sourcecode[
    ```py
    def f(x):
      n = x[0]
      while x[1] is not None:
        x = x[1]
      while n > 1:
        x[1] = [n - 1, None]
        x = x[1]
        n = n - 1

    s = 0
    def g(x):
      global s
      if x[1] is not None:
        n = x[0]
        x = x[1]
        s = s + n
        return x
      else:
        return None

    x = [7, None]
    while x is not None:
      f(x)
      x = g(x)
      print(x)
    ```
  ]

  #enum(
    numbering: "1.",
    enum.item[
      Каково общее количество памяти (кол-во машинных слов), которое выделяет эта программа на куче на протяжении своей работы?
    ],
    enum.item[
      Какое максимальное количество _живой_ памяти (достижимых машинных слов) находится на куче в течение работы этой программы?
    ],
    enum.item[При использовании копирующего сборщика мусора без поколений [1, §13.3], достаточно ли будет 30 машинных слов на _from-space_ (и столько же на _to-space_)? Достаточно ли 20 машинных слов? 25 машинных слов?
    ],
    enum.item[
      При использовании сборки по поколениям [1, §13.4] (на основе копирующего сборщика мусора) с двумя поколениями ($G_0$ и $G_1$) общим размером в 30 машинных слов, как бы вы разделили память по поколениям (сколько машинных слов будет относиться к $G_0$, а сколько -- к $G_1$)? Обоснуйте свой ответ.
    ],
  )
]
#solution()[
  Проанализируем поведение функций:
  - `f` добавляет в конце списка `x` (`x` -- список в смысле (`голова` : `хвост`)) числа от `x[0]-1` до `1`. #sourcecode[
      ```py
      x = [3, None]
      f(x)
      # x == [3, [2, [1, None]]]
      ```
    ]
  - `g` удаляет первый элемент списка и добавляет его значение к глобальной переменной `s`. #sourcecode[
      ```py
      x = [3, [2, [1, None]]]
      x = g(x)
      # x == [2, [1, None]]
      ```
    ]

  Рассмотрим композицию:
  #sourcecode[
    ```py
    def h(x):
      f(x)
      return g(x)
    ```
  ]

  `h` добавляет в конец списка числа от `x[0]-1` до `1`, а затем удаляет первый элемент списка и возвращает хвост.
  #sourcecode[
    ```py
    x = [3, None]
    x = h(x)
    # x == [2, [1, None]]
    ```
  ]

  Основная программа вызывает `h` пока `x` не станет `None`, т.е. пока не удалит все элементы списка. Начальное значение `x` -- список из одного элемента `7`, значит `h` будет вызвана 7 раз.

  *Ответы*:
  #enum(
    numbering: "1.",
    enum.item[
      Один вызов `h` создаёт `x[0]` объектов на куче. Эти числа в будущем тоже станет `x[0]` и породят другие объекты. Получаем рекуренту:
      #import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node
      #figure(
        diagram(
          node-stroke: luma(80%),
          node((0, 0), [F(4)], name: <4>),
          node((-1, 1), [F(3)], name: <3>),
          node((0, 1), [F(2)], name: <2>),
          node((1, 1), [F(1)], name: <1>),

          edge(<4>, <3>, "-|>"),
          edge(<4>, <2>, "-|>"),
          edge(<4>, <1>, "-|>"),
        ),
        caption: [Пример для `F(4)`],
      )

      $ F(n) = sum_(i=1)^(n - 1) F(i) $
      Угадывается паттрен $2^(n - 1) - 1$ при $n >= 1$.

      Итого получаем, что при вызове `h([7, None])` будет создано $F(7)$ объектов на куче, т.е $63$.

      Всего программа выделяет $63$ объекта по $2$ машинных слова = *$126$ машинных слов*.
    ],
    enum.item[
      В каждый момент исполнения программы есть только один корень указывающий на кучу -- `x`, поэтому вся достижимая память может быть только в списке `x`. Запустив программу получим, что максимальная длина списка `x` за всё время исполнения: $23$. Т.к вывод случается после вызова `g`, то нужно добавить ещё $1$.

      Итого $24$ объекта по $2$ машинных слова = *$48$ машинных слов*.
    ],
    enum.item[
      Т.к есть момент когда живо $48$ машшиных слов, то ни одного из этих размеров не хватит, но видимо тут имелось ввиду по $60$, $50$ и $40$ машинных слов на _from-space_ и _to-space_.

      - $40$ машинных слов *не хватит*, т.к это не вместит $48$ доступных.
      - $50$ машинных слов *хватит*, т.к объекты представляют односвязный список и ссылки не меняются и все объекты одинакового размера, так что не будет дефрагментации памяти и $48$ слов, смогут поместиться в _from-space_ размера $50$.
      - $60$ машинных слов *хватит*, т.к хватит и $50$ и поведение от этого не меняется.
    ],
    enum.item[
      Аналогично предыдущему заданию буду считать, что общий размер $G_0 + G_1 = 60$ машшиных слов.

      Сборка по поколениям спроектирована с гипотизой о том, что объекты умирают молодыми.
      Однако в этой программе новые объекты всегда добавляются в конец списка и каждый раз умирает самый старый (FIFO).
      При сборке по поколениям, объекты в $G_1$ собираются в $n$ раза реже чем в $G_0$, где n отношение их размеров.
      Когда в $G_0$ аллоцируется новый объект он гарантировано переживёт все объекты в $G_1$. От сюда слудует, что чем меньше $n$ тем эффективнее, т.к мы меньше раз будет просматривать гарантировано живой объект.

      Если взять $n=0$ (т.е $G_0$ = 60, $G_1$ = 0), тогда мы сделаем минимум бесполезной работы. В этой задаче сборка по поколениям никогда не будет эффективной т.к не выполняется гипотиза на который она основана.
    ],
  )
]
