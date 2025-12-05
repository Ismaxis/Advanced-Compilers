#import "@preview/ctheorems:1.1.3": *
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node
#import fletcher.shapes: *
#import "@preview/codelst:2.0.2": sourcecode

#show: thmrules.with(qed-symbol: $square$)
#set page(height: auto, margin: 1.5cm)

#let task = thmbox("theorem", "Задание", fill: rgb("#eeffee")).with(numbering: none)
#let solution = thmproof("proof", "Решение")

#align(center)[= Максим Исаев]
#align(center)[== Темы 6–10. Теоретическое задание]

#task("1")[
  Предложите расширение алгоритма каскадного анализа общих подвыражний:
  #enum(
    numbering: "1.",
    enum.item[
      Расширьте алгоритм поддержкой инструкций копирования и коммутативных операций.
      Для коммутативных операций, записи в таблицы рекомендуется хранить в каноническом виде (например, аргументы должны быть упорядочены каким-то образом). Приведите псевдокод расширенной версии алгоритма.
    ],
    enum.item[
      Примените расширенный алгоритм к следующему блоку:
      #sourcecode[
        ```
        с = a - b
        d = a × b
        e = a
        h = a - b
        a = d
        f = b × e
        g = e - b
        d = a + d
        a = b
        u = e - a
        v = c × h
        c = e - a
        u = c × u
        h = e - a
        c = g × v
        v = d + f
        f = h × u
        a = v + c
        b = a × f
        ```
      ]
      #enum(
        numbering: "(a)",
        enum.item[Выпишите таблицу значений],
        enum.item[Нарисуйте граф, соответствующий таблице],
      )
    ],
  )

]
#solution()[
  #enum(
    numbering: "1.",
    enum.item[
      #sourcecode[
        ```py
        T = empty
        N = 0

        for 'a = rhs' in the block:
            if rhs is variable: # handle copy instruction
                if rhs in T:
                    T[a] = T[rhs]
                else:
                    N = N + 1
                    T[a] = N
                continue

            b, op, c = rhs.parse()
            if b in T:
                nb = T[b]
            else:
                N = N + 1
                nb = N
                T[b] = nb
            if c in T:
                nc = T[c]
            else:
                N = N + 1
                nc = N
                T[c] = nc

            if op is commutative: # handle commutative operation
                nb, nc = min(nb, nc), max(nb, nc) # canonical order

            if (nb, op, nc) in T:
                m = T[(nb, op, nc)]
                T[a] = m
                mark 'a = b <op> c' as a common subexpression
            else:
                N = N + 1
                T[(nb, op, nc)] = N
                T[a] = N
        ```
      ]
    ],
    enum.item[
      #let node = fletcher.node.with(shape: rect, stroke: luma(50%))
      #let var = fletcher.node.with()
      #let idx = fletcher.node.with(fill: white, radius: 7pt, stroke: luma(60%))
      #let strike = strike.with(stroke: red + 1pt, extent: 4pt)

      #grid(
        columns: (1fr, 2fr),
        align: (right, left),
        figure(
          caption: [Таблица значений],
          box(
            stroke: black,
            outset: 5pt,
            grid(
              columns: 3,
              align: (left, center, right),
              row-gutter: 0.5em,

              strike[a], $arrow.r.bar$, [1],
              strike[b], $arrow.r.bar$, [2],
              [(1, $minus$, 2)], $arrow.r.bar$, [3],
              strike[c], $arrow.r.bar$, [3],
              [(1, $times$, 2)], $arrow.r.bar$, [4],
              strike[d], $arrow.r.bar$, [4],
              [e], $arrow.r.bar$, [1],
              strike[h], $arrow.r.bar$, [3],
              strike[a], $arrow.r.bar$, [4],
              strike[f], $arrow.r.bar$, [4],
              [g], $arrow.r.bar$, [3],
              [(4, $plus$, 4)], $arrow.r.bar$, [5],
              [d], $arrow.r.bar$, [5],
              strike[a], $arrow.r.bar$, [2],
              strike[u], $arrow.r.bar$, [3],
              strike[c], $arrow.r.bar$, [6],
              [(3, $times$, 6)], $arrow.r.bar$, [7],
              strike[v], $arrow.r.bar$, [7],
              strike[c], $arrow.r.bar$, [3],
              [(3, $times$, 3)], $arrow.r.bar$, [8],
              [u], $arrow.r.bar$, [8],
              [h], $arrow.r.bar$, [3],
              [(3, $times$, 7)], $arrow.r.bar$, [9],
              [c], $arrow.r.bar$, [9],
              [(4, $plus$, 5)], $arrow.r.bar$, [10],
              [v], $arrow.r.bar$, [10],
              [(3, $times$, 8)], $arrow.r.bar$, [11],
              [f], $arrow.r.bar$, [11],
              [(9, $plus$, 10)], $arrow.r.bar$, [12],
              [a], $arrow.r.bar$, [12],
              [(11, $times$, 12)], $arrow.r.bar$, [13],
              [b], $arrow.r.bar$, [13],
            ),
          ),
        ),
        figure(
          caption: [Граф, соответствующий таблице],
          diagram(
            node((-1, 0), $times$, name: <13>),
            node((-2, 1), $plus$, name: <12>),
            node((0, 2), $times$, name: <11>),
            node((1, 3), $times$, name: <8>),
            node((-1, 2), $times$, name: <9>),
            node((-1, 3), $times$, name: <7>),
            node((-1, 6), $c_0$, name: <6>),
            node((-2, 2), $plus$, name: <10>),
            node((-3, 3), $plus$, name: <5>),
            node((-2, 4), $times$, name: <4>),
            node((0, 4), $minus$, name: <3>),
            node((-2, 6), $a_0$, name: <1>),
            node((0, 6), $b_0$, name: <2>),

            var((-2.5, 5.5), "e", name: <e>),
            var((1, 3.75), "g", name: <g>),
            var((-3, 2), "d", name: <d>),
            var((1, 2), "u", name: <u>),
            var((1, 4.25), "h", name: <h>),
            var((-1, 1), "c", name: <c>),
            var((-2.5, 1.5), "v", name: <v>),
            var((0.5, 1.5), "f", name: <f>),
            var((-2.5, 0.5), "a", name: <a>),
            var((-2, 0), "b", name: <b>),

            edge(<e>, <1>, "-|>", stroke: red),
            edge(<g>, <3>, "-|>", stroke: red),
            edge(<d>, <5>, "-|>", stroke: red),
            edge(<u>, <8>, "-|>", stroke: red),
            edge(<h>, <3>, "-|>", stroke: red),
            edge(<c>, <9>, "-|>", stroke: red),
            edge(<v>, <10>, "-|>", stroke: red),
            edge(<f>, <11>, "-|>", stroke: red),
            edge(<a>, <12>, "-|>", stroke: red),
            edge(<b>, <13>, "-|>", stroke: red),

            idx(<13.north-east>, [13]),
            idx(<12.north-east>, [12]),
            idx(<11.south-west>, [11]),
            idx(<8.north-east>, [8]),
            idx(<9.north-east>, [9]),
            idx(<7.north-east>, [7]),
            idx(<6.north-east>, [6]),
            idx(<10.north-east>, [10]),
            idx(<5.south-west>, [5]),
            idx(<4.south-west>, [4]),
            idx(<3.south-east>, [3]),
            idx(<1.north-east>, [1]),
            idx(<2.north-east>, [2]),

            edge(<13>, <11>, "-|>"),
            edge(<13>, <12>, "-|>"),
            edge(<12>, <9>, "-|>"),
            edge(<12>, <10>, "-|>"),
            edge(<10>, <4>, "-|>"),
            edge(<10>, <5>, "-|>"),
            edge(<5>, <4>, "-|>", bend: -30deg),
            edge(<5>, <4>, "-|>", bend: 30deg),
            edge(<4>, <1>, "-|>"),
            edge(<4>, <2>, "-|>"),
            edge(<9>, <7>, "-|>"),
            edge(<7>, <6>, "-|>"),
            edge(<7>, <3>, "-|>"),
            edge(<9>, <3>, "-|>"),
            edge(<3>, <2>, "-|>"),
            edge(<3>, <1>, "-|>"),
            edge(<11>, <3>, "-|>"),
            edge(<11>, <8>, "-|>"),
            edge(<8>, <3>, "-|>", bend: -30deg),
            edge(<8>, <3>, "-|>", bend: 30deg),
          ),
        ),
      )
    ],
  )
]

#task("2")[
  Оптимизируйте следующую программу, используя SSA-представление

  #sourcecode[
    ```py
    m = 30
    i = 0
    j = 1
    n = m
    while n > i:
      k = j
      if n > m:
        p = n
        while q > p:
          p = p * 2
          q = q - 1
      else:
        while i > 0:
          if m < 20:
            j = j + p
            i = i - q
            m = n
          else:
            j = j + 1
            i = i - 1
      i = k
      n = n - 1
    print(j)
    ```
  ]

  #enum(
    numbering: "1.",
    enum.item[
      Переведите программу в SSA-представление
      #enum(
        numbering: "(a)",
        enum.item[Постройте граф потока управления (control-flow graph, CFG). Убедитесь, что граф обладает свойством уникального последователя или предшественника.],
        enum.item[Постройте дерево доминаторов.],
        enum.item[Распишите значения границ доминирования для каждого узла в графе потока управления.],
        enum.item[Напишите в какие блоки и для каких переменных необходимо вставить 𝜙-функции. Аргументируйте решение.],
        enum.item[Вставьте 𝜙-функции и переименуйте переменные должным образом. Покажите финальный граф потока управления для SSA-представления.],
      )
    ],
    enum.item[
      Примените агрессивное устранение мёртвого кода:
      #enum(
        numbering: "(a)",
        enum.item[Постройте таблицу для выполняемых присваиваний ℰ и возможных значений 𝒱.],
        enum.item[Постройте граф управления для SSA-представления, полученный после устранения мёртвого кода.],
        enum.item[Постройте граф управления для SSA-представления, полученный после устранения лишних пустых блоков и лишних 𝜙-функций.],
      )
    ],
    enum.item[
      Постройте граф зависимости управления:
      #enum(
        numbering: "(a)",
        enum.item[Постройте дерево пост-доминаторов.],
        enum.item[Постройте границы пост-доминирования.],
        enum.item[Постройте граф зависимости управления.],
      )
    ],
    enum.item[
      Постройте граф управления для SSA-представления, полученный после агрессивного устранения мёртвого кода.
    ],
    enum.item[
      Переведите программу из SSA-представления:
      #enum(
        numbering: "(a)",
        enum.item[Постройте граф конфликтов (интерференции) для переменных в SSA-представлении.],
        enum.item[Постройте полученный граф потока управления оптимизированной программы: замените 𝜙-функции на копирующие инструкции (в предшествующих блоках), переименуйте переменные (согласно графу конфликтов), и уберите лишние копирующие инструкции.],
      )
    ],
  )
]
#solution()[
  #let node = fletcher.node.with(shape: rect, stroke: luma(90%))
  #let idx = fletcher.node.with(fill: white, radius: 7pt, stroke: luma(60%))

  #enum(
    numbering: "1.",
    enum.item[
      #enum(
        numbering: "(a)",
        enum.item[
          #figure(
            diagram(
              node(
                (0, 0),
                [```
                m = 30
                i = 0
                j = 1
                n = m
                ```],
                name: <1>,
              ),
              idx(<1.north-east>, [1]),
              node(
                (0, 1),
                [```
                if n > i
                ```],
                name: <2>,
              ),
              idx(<2.north-east>, [2]),
              node(
                (0, 2),
                [```
                k = j
                if n > m
                ```],
                name: <3>,
              ),
              idx(<3.north-east>, [3]),
              node(
                (0, 3),
                [```
                p = n
                ```],
                name: <4>,
              ),
              idx(<4.north-east>, [4]),
              node(
                (0, 4),
                [```
                if q > p
                ```],
                name: <5>,
              ),
              idx(<5.north-east>, [5]),
              node(
                (0, 5),
                [```
                p = p * 2
                q = q - 1
                ```],
                name: <6>,
              ),
              idx(<6.north-east>, [6]),
              node(
                (0, 6),
                [```
                i = k
                n = n - 1
                ```],
                name: <7>,
              ),
              idx(<7.north-east>, [7]),
              node(
                (1, 3),
                [```
                if i > 0
                ```],
                name: <8>,
              ),
              idx(<8.north-east>, [8]),
              node(
                (1, 4),
                [```
                if m < 20
                ```],
                name: <9>,
              ),
              idx(<9.north-east>, [9]),
              node(
                (1, 5),
                [```
                j = j + p
                i = i - q
                m = n
                ```],
                name: <10>,
              ),
              idx(<10.north-east>, [10]),
              node(
                (2, 5),
                [```
                j = j + 1
                i = i - 1
                ```],
                name: <11>,
              ),
              idx(<11.north-east>, [11]),
              node(
                (1.5, 6),
                [` `],
                name: <12>,
              ),
              idx(<12.south-west>, [12]),
              node(
                (2, 1),
                [```
                print(j)
                ```],
                name: <13>,
              ),
              idx(<13.north-east>, [13]),

              edge(<1>, <2>, "-|>"),
              edge(<2>, <3>, "-|>", stroke: green),
              edge(<3>, <4>, "-|>", stroke: green),
              edge(<4>, <5>, "-|>"),
              edge(<5>, <6>, "-|>", stroke: green),
              edge(<6>, <5>, "-|>", shift: -15pt),
              edge(<5>, (-3 / 4, 4), (-3 / 4, 6), <7>, "-|>", shift: -5pt, stroke: red),
              edge(<7>, (-1, 6), (-1, 1), <2>, "-|>"),
              edge(<3>, <8>, "-|>", stroke: red),
              edge(<8>, <9>, "-|>", stroke: green),
              edge(<8>, (1 / 2, 3), (1 / 2, 6), <7>, "-|>", stroke: red),
              edge(<9>, <10>, "-|>", stroke: green),
              edge(<9>, <11>, "-|>", stroke: red),
              edge(<10>, <12>, "-|>"),
              edge(<11>, <12>, "-|>"),
              edge(<12>, (3, 6), (3, 3), <8>, "-|>"),
              edge(<2>, <13>, "-|>", stroke: red),
            ),
            caption: [Control-flow graph (CFG)],
          )

          Данных граф обладает свойством уникального предшественника и уникального последователя, однако мы временно нарушим это свойство для уменьшения количества узлов и вернёт нужные веришны на этапе перевода из SSA-представления обратно.

          #figure(
            diagram(
              node(
                (0, 0),
                [```
                m = 30
                i = 0
                j = 1
                n = m
                ```],
                name: <1>,
              ),
              idx(<1.north-east>, [1]),
              node(
                (0, 1),
                [```
                if n > i
                ```],
                name: <2>,
              ),
              idx(<2.north-east>, [2]),
              node(
                (0, 2),
                [```
                k = j
                if n > m
                ```],
                name: <3>,
              ),
              idx(<3.north-east>, [3]),
              node(
                (0, 3),
                [```
                p = n
                ```],
                name: <4>,
              ),
              idx(<4.north-east>, [4]),
              node(
                (0, 4),
                [```
                if q > p
                ```],
                name: <5>,
              ),
              idx(<5.north-east>, [5]),
              node(
                (0, 5),
                [```
                p = p * 2
                q = q - 1
                ```],
                name: <6>,
              ),
              idx(<6.north-east>, [6]),
              node(
                (0, 6),
                [```
                i = k
                n = n - 1
                ```],
                name: <7>,
              ),
              idx(<7.north-east>, [7]),
              node(
                (1, 3),
                [```
                if i > 0
                ```],
                name: <8>,
              ),
              idx(<8.north-east>, [8]),
              node(
                (1, 4),
                [```
                if m < 20
                ```],
                name: <9>,
              ),
              idx(<9.north-east>, [9]),
              node(
                (2, 3),
                [```
                j = j + p
                i = i - q
                m = n
                ```],
                name: <10>,
              ),
              idx(<10.north-east>, [10]),
              node(
                (2, 4),
                [```
                j = j + 1
                i = i - 1
                ```],
                name: <11>,
              ),
              idx(<11.north-east>, [11]),
              node(
                (2, 1),
                [```
                print(j)
                ```],
                name: <12>,
              ),
              idx(<12.north-east>, [12]),

              edge(<1>, <2>, "-|>"),
              edge(<2>, <3>, "-|>", stroke: green),
              edge(<3>, <4>, "-|>", stroke: green),
              edge(<4>, <5>, "-|>"),
              edge(<5>, <6>, "-|>", stroke: green),
              edge(<6>, <5>, "-|>", shift: -15pt),
              edge(<5>, (-3 / 4, 4), (-3 / 4, 6), <7>, "-|>", shift: -5pt, stroke: red),
              edge(<7>, (-1, 6), (-1, 1), <2>, "-|>"),
              edge(<3>, <8>, "-|>", stroke: red),
              edge(<8>, <9>, "-|>", stroke: green),
              edge(<8>, (1 / 2, 3), (1 / 2, 6), <7>, "-|>", stroke: red),
              edge(<9>, <10>, "-|>", stroke: green),
              edge(<9>, <11>, "-|>", stroke: red),
              edge(<10>, <8>, "-|>"),
              edge(<11>, <8>, "-|>"),
              edge(<2>, <12>, "-|>", stroke: red),
            ),
            caption: [CFG с нарушенным свойством уникального предшественника и уникального последователя],
          )
        ],
        enum.item[
          #figure(
            diagram(
              node((0, 0), [1], name: <1>),
              node((0, 1), [2], name: <2>),
              node((0, 2), [3], name: <3>),
              node((-1, 3), [4], name: <4>),
              node((-1, 4), [5], name: <5>),
              node((-1, 5), [6], name: <6>),
              node((0, 3), [7], name: <7>),
              node((1, 3), [8], name: <8>),
              node((1, 4), [9], name: <9>),
              node((0, 5), [10], name: <10>),
              node((1, 5), [11], name: <11>),
              node((1, 2), [12], name: <12>),

              edge(<1>, <2>, "-|>"),
              edge(<2>, <3>, "-|>"),
              edge(<3>, <4>, "-|>"),
              edge(<4>, <5>, "-|>"),
              edge(<5>, <6>, "-|>"),
              edge(<3>, <7>, "-|>"),
              edge(<3>, <8>, "-|>"),
              edge(<8>, <9>, "-|>"),
              edge(<9>, <10>, "-|>"),
              edge(<9>, <11>, "-|>"),
              edge(<2>, <12>, "-|>"),
            ),
            caption: [Дерево доминаторов],
          )
        ],
        enum.item[
          #table(
            columns: 2,
            align: (center, left),
            [*Block*], [*Dominance Frontier*],
            [1], [{}],
            [2], [{2}],
            [3], [{2}],
            [4], [{7}],
            [5], [{5, 7}],
            [6], [{5}],
            [7], [{2}],
            [8], [{7, 8}],
            [9], [{8}],
            [10], [{8}],
            [11], [{8}],
            [12], [{}],
          )
        ],
        enum.item[
          Для каждой переменной посмотрим блоки, где она присваивается и найдём границы доминирования этих блоков.
          #table(
            columns: 2,
            align: (left, left),
            [*Var*], [*Blocks with definition*],
            [n], [{1, 7, 2}],
            [m], [{1, 10, 8, 7, 2}],
            [i], [{1, 7, 10, 11, 2, 8}],
            [j], [{1, 10, 11, 8, 7, 2}],
            [p], [{4, 6, 7, 5, 2}],
            [q], [{6, 5, 7, 2}],
          )
          Расставим 𝜙-функции в блоки, которые входят в границы доминирования *Blocks with definition*.
          #figure(
            diagram(
              node(
                (0, 0),
                [```
                m = 30
                i = 0
                j = 1
                n = m
                ```],
                name: <1>,
              ),
              idx(<1.north-east>, [1]),
              node(
                (0, 1),
                [```
                q = φ(q,q)
                p = φ(p,p)
                j = φ(j,j)
                i = φ(i,i)
                m = φ(m,m)
                n = φ(n,n)
                if n > i
                ```],
                name: <2>,
              ),
              idx(<2.north-east>, [2]),
              node(
                (0, 2),
                [```
                k = j
                if n > m
                ```],
                name: <3>,
              ),
              idx(<3.north-east>, [3]),
              node(
                (0, 3),
                [```
                p = n
                ```],
                name: <4>,
              ),
              idx(<4.north-east>, [4]),
              node(
                (0, 4),
                [```
                q = φ(q,q)
                p = φ(p,p)
                if q > p
                ```],
                name: <5>,
              ),
              idx(<5.north-east>, [5]),
              node(
                (0, 5),
                [```
                p = p * 2
                q = q - 1
                ```],
                name: <6>,
              ),
              idx(<6.north-east>, [6]),
              node(
                (0, 6),
                [```
                q = φ(q,q)
                p = φ(p,p)
                j = φ(j,j)
                i = φ(i,i)
                m = φ(m,m)
                i = k
                n = n - 1
                ```],
                name: <7>,
              ),
              idx(<7.north-east>, [7]),
              node(
                (1, 3),
                [```
                j = φ(j,j,j)
                i = φ(i,i,i)
                m = φ(m,m,m)
                if i > 0
                ```],
                name: <8>,
              ),
              idx(<8.north-east>, [8]),
              node(
                (1, 4),
                [```
                if m < 20
                ```],
                name: <9>,
              ),
              idx(<9.north-east>, [9]),
              node(
                (2, 3),
                [```
                j = j + p
                i = i - q
                m = n
                ```],
                name: <10>,
              ),
              idx(<10.north-east>, [10]),
              node(
                (2, 4),
                [```
                j = j + 1
                i = i - 1
                ```],
                name: <11>,
              ),
              idx(<11.north-east>, [11]),
              node(
                (2, 1),
                [```
                print(j)
                ```],
                name: <12>,
              ),
              idx(<12.north-east>, [12]),

              edge(<1>, <2>, "-|>"),
              edge(<2>, <3>, "-|>", stroke: green),
              edge(<3>, <4>, "-|>", stroke: green),
              edge(<4>, <5>, "-|>"),
              edge(<5>, <6>, "-|>", stroke: green),
              edge(<6>, <5>, "-|>", shift: -15pt),
              edge(<5>, (-3 / 4, 4), (-3 / 4, 6), <7>, "-|>", shift: -5pt, stroke: red),
              edge(<7>, (-1, 6), (-1, 1), <2>, "-|>"),
              edge(<3>, <8>, "-|>", stroke: red),
              edge(<8>, <9>, "-|>", stroke: green),
              edge(<8>, (1 / 2, 3), (1 / 2, 6), <7>, "-|>", stroke: red),
              edge(<9>, <10>, "-|>", stroke: green),
              edge(<9>, <11>, "-|>", stroke: red),
              edge(<10>, <8>, "-|>"),
              edge(<11>, <8>, "-|>"),
              edge(<2>, <12>, "-|>", stroke: red),
            ),
            caption: [CFG с вставленными 𝜙-функциями],
          )
        ],
        enum.item[
          #figure(
            diagram(
              node(
                (0, 0),
                [```
                m1 = 30
                i1 = 0
                j1 = 1
                n1 = m1
                ```],
                name: <1>,
              ),
              idx(<1.north-east>, [1]),
              node(
                (0, 1),
                [```
                q1 = φ(q0,q4)
                p1 = φ(p0,p5)
                j2 = φ(j1,j3)
                i2 = φ(i1,i4)
                m2 = φ(m1,m3)
                n2 = φ(n1,n3)
                if n2 > i2
                ```],
                name: <2>,
              ),
              idx(<2.north-east>, [2]),
              node(
                (0, 2),
                [```
                k = j2
                if n2 > m2
                ```],
                name: <3>,
              ),
              idx(<3.north-east>, [3]),
              node(
                (0, 3),
                [```
                p2 = n2
                ```],
                name: <4>,
              ),
              idx(<4.north-east>, [4]),
              node(
                (0, 4),
                [```
                q2 = φ(q1,q3)
                p3 = φ(p2,p4)
                if q2 > p3
                ```],
                name: <5>,
              ),
              idx(<5.north-east>, [5]),
              node(
                (0, 5),
                [```
                p4 = p3 * 2
                q3 = q2 - 1
                ```],
                name: <6>,
              ),
              idx(<6.north-east>, [6]),
              node(
                (0, 6),
                [```
                q4 = φ(q2,q1)
                p5 = φ(p3,p1)
                j3 = φ(j2,j4)
                i3 = φ(i2,i5)
                m3 = φ(m2,m4)
                i4 = k
                n3 = n2 - 1
                ```],
                name: <7>,
              ),
              idx(<7.north-east>, [7]),
              node(
                (1, 3),
                [```
                j4 = φ(j2,j5,j6)
                i5 = φ(i2,i5,i7)
                m4 = φ(m2,m4,m5)
                if i5 > 0
                ```],
                name: <8>,
              ),
              idx(<8.north-east>, [8]),
              node(
                (1, 4),
                [```
                if m4 < 20
                ```],
                name: <9>,
              ),
              idx(<9.north-east>, [9]),
              node(
                (2, 3),
                [```
                j5 = j4 + p1
                i6 = i5 - q1
                m5 = n4
                ```],
                name: <10>,
              ),
              idx(<10.north-east>, [10]),
              node(
                (2, 4),
                [```
                j6 = j4 + 1
                i7 = i5 - 1
                ```],
                name: <11>,
              ),
              idx(<11.north-east>, [11]),
              node(
                (2, 1),
                [```
                print(j2)
                ```],
                name: <12>,
              ),
              idx(<12.north-east>, [12]),

              edge(<1>, <2>, "-|>"),
              edge(<2>, <3>, "-|>", stroke: green),
              edge(<3>, <4>, "-|>", stroke: green),
              edge(<4>, <5>, "-|>"),
              edge(<5>, <6>, "-|>", stroke: green),
              edge(<6>, <5>, "-|>", shift: -15pt),
              edge(<5>, (-3 / 4, 4), (-3 / 4, 6), <7>, "-|>", shift: -5pt, stroke: red),
              edge(<7>, (-1, 6), (-1, 1), <2>, "-|>"),
              edge(<3>, <8>, "-|>", stroke: red),
              edge(<8>, <9>, "-|>", stroke: green),
              edge(<8>, (1 / 2, 3), (1 / 2, 6), <7>, "-|>", stroke: red),
              edge(<9>, <10>, "-|>", stroke: green),
              edge(<9>, <11>, "-|>", stroke: red),
              edge(<10>, <8>, "-|>"),
              edge(<11>, <8>, "-|>"),
              edge(<2>, <12>, "-|>", stroke: red),
            ),
            caption: [CFG с 𝜙-функциями и переименованиями],
          )
        ],
      )
    ],
    enum.item[
      #enum(
        numbering: "(a)",
        enum.item[
          #grid(
            columns: 1,
            align: (center, left),
            row-gutter: 1.5em,
            figure(
              caption: [Выполняемые присваивания],
              table(
                columns: 13,
                align: center,
                [Block], [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12],
                [*$cal(E)$*],
                [true],
                [true],
                [true],
                [true],
                [true],
                [true],
                [true],
                [true],
                [true],
                text("false", fill: red),
                [true],
                [true],
              ),
            ),
            figure(
              caption: [Возможные значения],
              table(
                columns: 22,
                align: center,
                [Var],
                [m1],
                [m2],
                [m3],
                [m4],
                [m5],
                [n1],
                [n2],
                [n3],
                [i1],
                [i2],
                [i3],
                [i4],
                [i5],
                [i6],
                [i7],
                [j1],
                [j2],
                [j3],
                [j4],
                [j5],
                [j6],

                [*$cal(V)$*],
                [30],
                [30],
                [30],
                [30],
                [⊥],
                [30],
                [⊤],
                [⊤],
                [0],
                [⊤],
                [⊤],
                [⊤],
                [⊤],
                [⊥],
                [⊤],
                [1],
                [⊤],
                [⊤],
                [⊤],
                [⊥],
                [⊤],
              ),
            ),
            figure(
              caption: [Возможные значения],
              table(
                columns: 13,
                align: (center, left),
                [Var], [p0], [p1], [p2], [p3], [p4], [p5], [q0], [q1], [q2], [q3], [q4], [k],
                [*$cal(V)$*], [⊤], [⊤], [⊤], [⊤], [⊤], [⊤], [⊤], [⊤], [⊤], [⊤], [⊤], [⊤],
              ),
            ),
          )
        ],
        enum.item[
          #figure(
            diagram(
              node(
                (0, 0),
                [` `],
                name: <1>,
              ),
              idx(<1.north-east>, [1]),
              node(
                (0, 1),
                [```
                q1 = φ(q0,q4)
                p1 = φ(p0,p5)
                j2 = φ(1,j3)
                i2 = φ(0,i4)
                n2 = φ(30,n3)
                if n2 > i2
                ```],
                name: <2>,
              ),
              idx(<2.north-east>, [2]),
              node(
                (0, 2),
                [```
                k = j2
                if n2 > 30
                ```],
                name: <3>,
              ),
              idx(<3.north-east>, [3]),
              node(
                (0, 3),
                [```
                p2 = n2
                ```],
                name: <4>,
              ),
              idx(<4.north-east>, [4]),
              node(
                (0, 4),
                [```
                q2 = φ(q1,q3)
                p3 = φ(p2,p4)
                if q2 > p3
                ```],
                name: <5>,
              ),
              idx(<5.north-east>, [5]),
              node(
                (0, 5),
                [```
                p4 = p3 * 2
                q3 = q2 - 1
                ```],
                name: <6>,
              ),
              idx(<6.north-east>, [6]),
              node(
                (0, 6),
                [```
                q4 = φ(q2,q1)
                p5 = φ(p3,p1)
                j3 = φ(j2,j4)
                i3 = φ(i2,i5)
                m3 = φ(m2,m4)
                i4 = k
                n3 = n2 - 1
                ```],
                name: <7>,
              ),
              idx(<7.north-east>, [7]),
              node(
                (1, 3),
                [```
                j4 = φ(j2,j5,j6)
                i5 = φ(i2,i5,i7)
                m4 = φ(m2,m4,m5)
                if i5 > 0
                ```],
                name: <8>,
              ),
              idx(<8.north-east>, [8]),
              node(
                (1, 4),
                [```
                if 30 < 20
                ```],
                name: <9>,
              ),
              idx(<9.north-east>, [9]),
              node(
                (2, 3),
                [```
                j5 = j4 + p1
                i6 = i5 - q1
                m5 = n4
                ```],
                name: <10>,
              ),
              idx(<10.north-east>, [10]),
              node(
                (2, 4),
                [```
                j6 = j4 + 1
                i7 = i5 - 1
                ```],
                name: <11>,
              ),
              idx(<11.north-east>, [11]),
              node(
                (2, 1),
                [```
                print(j2)
                ```],
                name: <12>,
              ),
              idx(<12.north-east>, [12]),

              edge(<1>, <2>, "-|>"),
              edge(<2>, <3>, "-|>", stroke: green),
              edge(<3>, <4>, "-|>", stroke: green),
              edge(<4>, <5>, "-|>"),
              edge(<5>, <6>, "-|>", stroke: green),
              edge(<6>, <5>, "-|>", shift: -15pt),
              edge(<5>, (-3 / 4, 4), (-3 / 4, 6), <7>, "-|>", shift: -5pt, stroke: red),
              edge(<7>, (-1, 6), (-1, 1), <2>, "-|>"),
              edge(<3>, <8>, "-|>", stroke: red),
              edge(<8>, <9>, "-|>", stroke: green),
              edge(<8>, (1 / 2, 3), (1 / 2, 6), <7>, "-|>", stroke: red),
              edge(<9>, <10>, "-|>", stroke: green),
              edge(<9>, <11>, "-|>", stroke: red),
              edge(<10>, <8>, "-|>"),
              edge(<11>, <8>, "-|>"),
              edge(<2>, <12>, "-|>", stroke: red),
            ),
            caption: [CFG после продвижения констант],
          )
        ],
        enum.item[
          #figure(
            diagram(
              node(
                (0, 1),
                [```
                q1 = φ(q0,q4)
                p1 = φ(p0,p5)
                j2 = φ(1,j3)
                i2 = φ(0,i4)
                n2 = φ(30,n3)
                if n2 > i2
                ```],
                name: <2>,
              ),
              idx(<2.north-east>, [2]),
              node(
                (0, 2),
                [```
                k = j2
                if n2 > 30
                ```],
                name: <3>,
              ),
              idx(<3.north-east>, [3]),
              node(
                (0, 3),
                [```
                p2 = n2
                ```],
                name: <4>,
              ),
              idx(<4.north-east>, [4]),
              node(
                (0, 4),
                [```
                q2 = φ(q1,q3)
                p3 = φ(p2,p4)
                if q2 > p3
                ```],
                name: <5>,
              ),
              idx(<5.north-east>, [5]),
              node(
                (0, 5),
                [```
                p4 = p3 * 2
                q3 = q2 - 1
                ```],
                name: <6>,
              ),
              idx(<6.north-east>, [6]),
              node(
                (0, 6),
                [```
                q4 = φ(q2,q1)
                p5 = φ(p3,p1)
                j3 = φ(j2,j4)
                i3 = φ(i2,i5)
                i4 = k
                n3 = n2 - 1
                ```],
                name: <7>,
              ),
              idx(<7.north-east>, [7]),
              node(
                (1, 3),
                [```
                j4 = φ(j2,j6)
                i5 = φ(i2,i7)
                if i5 > 0
                ```],
                name: <8>,
              ),
              idx(<8.north-east>, [8]),
              node(
                (1, 4),
                [```
                j6 = j4 + 1
                i7 = i5 - 1
                ```],
                name: <11>,
              ),
              idx(<11.north-east>, [11]),
              node(
                (2, 1),
                [```
                print(j2)
                ```],
                name: <12>,
              ),
              idx(<12.north-east>, [12]),

              edge((0, 0), <2>, "-|>"),
              edge(<2>, <3>, "-|>", stroke: green),
              edge(<3>, <4>, "-|>", stroke: green),
              edge(<4>, <5>, "-|>"),
              edge(<5>, <6>, "-|>", stroke: green),
              edge(<6>, <5>, "-|>", shift: -15pt),
              edge(<5>, (-3 / 4, 4), (-3 / 4, 6), <7>, "-|>", shift: -5pt, stroke: red),
              edge(<7>, (-1, 6), (-1, 1), <2>, "-|>"),
              edge(<3>, <8>, "-|>", stroke: red),
              edge(<8>, <11>, "-|>", stroke: green),
              edge(<8>, (1 / 2, 3), (1 / 2, 6), <7>, "-|>", stroke: red),
              edge(<11>, <8>, "-|>", shift: -15pt),
              edge(<2>, <12>, "-|>", stroke: red),
            ),
            caption: [CFG после удаления лишних пустых блоков и лишних 𝜙-функций],
          )
        ],
      )
    ],
    enum.item[
      #enum(
        numbering: "(a)",
        enum.item[
          #figure(
            diagram(
              node((0, 0), [exit], name: <13>),
              node((0, 1), [12], name: <12>),
              node((1, 1), [r], name: <r>),
              node((0, 2), [2], name: <2>),
              node((0, 3), [7], name: <7>),
              node((-1, 4), [8], name: <8>),
              node((0, 4), [5], name: <5>),
              node((1, 4), [3], name: <3>),
              node((-1, 5), [11], name: <11>),
              node((0, 5), [6], name: <6>),
              node((1, 5), [4], name: <4>),

              // Edges
              edge(<13>, <12>, "-|>"),
              edge(<13>, <r>, "-|>"),
              edge(<12>, <2>, "-|>"),
              edge(<2>, <7>, "-|>"),
              edge(<7>, <8>, "-|>"),
              edge(<7>, <5>, "-|>"),
              edge(<7>, <3>, "-|>"),
              edge(<8>, <11>, "-|>"),
              edge(<5>, <6>, "-|>"),
              edge(<5>, <4>, "-|>"),
            ),
            caption: [Дерево пост-доминаторов],
          )
        ],
        enum.item[
          #table(
            columns: 2,
            align: (center, left),
            [*Block*], [*Post-Dominance Frontier*],
            [1], [{}],
            [2], [{1, 2}],
            [3], [{2}],
            [4], [{3}],
            [5], [{3, 5}],
            [6], [{5}],
            [7], [{2}],
            [8], [{3, 8}],
            [11], [{8}],
            [12], [{1}],
            [13], [{}],
          )
        ],
        enum.item[
          #figure(
            diagram(
              node((0, 0), [r], name: <r>),
              node((-1, 1), [12], name: <12>),
              node((0, 1), [2], name: <2>),
              node((1, 2), [7], name: <7>),
              node((0, 2), [3], name: <3>),
              node((-1, 3), [8], name: <8>),
              node((0, 3), [4], name: <4>),
              node((1, 3), [5], name: <5>),
              node((-1, 4), [11], name: <11>),
              node((1, 4), [6], name: <6>),
              node((1, 0), [exit], name: <exit>),

              edge(<r>, <2>, "-|>"),
              edge(<r>, <12>, "-|>"),
              edge(<2>, <3>, "-|>"),
              edge(<2>, <7>, "-|>"),
              edge(<3>, <4>, "-|>"),
              edge(<3>, <5>, "-|>"),
              edge(<3>, <8>, "-|>"),
              edge(<5>, <6>, "-|>"),
              edge(<8>, <11>, "-|>"),
            ),
            caption: [Control Dependence Graph (CDG)],
          )
        ],
      )
    ],
    enum.item[
      #let sel(v) = highlight(fill: rgb("#fff9b0"))[#v]
      #figure(
        diagram(
          node(
            (0, 1),
            [
              ```
              q1 = φ(q0,q4)
              p1 = φ(p0,p5)
              ```
              #sel(```
              j2 = φ(1,j3)
              i2 = φ(0,i4)
              n2 = φ(30,n3)
              if n2 > i2
              ```)
            ],
            name: <2>,
          ),
          idx(<2.north-east>, [2]),
          node(
            (0, 2),
            ```
            k = j2
            if n2 > 30
            ```,
            name: <3>,
          ),
          idx(<3.north-east>, [3]),
          node(
            (0, 3),
            ```
            p2 = n2
            ```,
            name: <4>,
          ),
          idx(<4.north-east>, [4]),
          node(
            (0, 4),
            ```
            q2 = φ(q1,q3)
            p3 = φ(p2,p4)
            if q2 > p3
            ```,
            name: <5>,
          ),
          idx(<5.north-east>, [5]),
          node(
            (0, 5),
            ```
            p4 = p3 * 2
            q3 = q2 - 1
            ```,
            name: <6>,
          ),
          idx(<6.north-east>, [6]),
          node(
            (0, 6),
            [```
              q4 = φ(q2,q1)
              p5 = φ(p3,p1)
              ```
              #sel(`j3 = φ(j2,j4)`)
              ```
              i3 = φ(i2,i5)
              ```
              #sel(```
              i4 = k
              n3 = n2 - 1
              ```)
            ],
            name: <7>,
          ),
          idx(<7.north-east>, [7]),
          node(
            (1, 3),
            sel(```
            j4 = φ(j2,j5,j6)
            i5 = φ(i2,i5,i7)
            if i5 > 0
            ```),
            name: <8>,
          ),
          idx(<8.north-east>, [8]),
          node(
            (1, 4),
            sel(```
            j6 = j4 + 1
            i7 = i5 - 1
            ```),
            name: <11>,
          ),
          idx(<11.north-east>, [11]),
          node(
            (2, 1),
            sel(```
            print(j2)
            ```),
            name: <12>,
          ),
          idx(<12.north-east>, [12]),

          edge((0, 0), <2>, "-|>"),
          edge(<2>, <3>, "-|>", stroke: green),
          edge(<3>, <4>, "-|>", stroke: green),
          edge(<4>, <5>, "-|>"),
          edge(<5>, <6>, "-|>", stroke: green),
          edge(<6>, <5>, "-|>", shift: -15pt),
          edge(<5>, (-3 / 4, 4), (-3 / 4, 6), <7>, "-|>", shift: -5pt, stroke: red),
          edge(<7>, (-1, 6), (-1, 1), <2>, "-|>"),
          edge(<3>, <8>, "-|>", stroke: red),
          edge(<8>, <11>, "-|>", stroke: green),
          edge(<8>, (1 / 2, 3), (1 / 2, 6), <7>, "-|>", stroke: red),
          edge(<11>, <8>, "-|>", shift: -15pt),
          edge(<2>, <12>, "-|>", stroke: red),
        ),
        caption: [CFG до агрессивного устранения мёртвого кода],
      )
      #figure(
        diagram(
          node(
            (0, 1),
            [
              ```
              j2 = φ(1,j3)
              i2 = φ(0,i4)
              n2 = φ(30,n3)
              if n2 > i2
              ```
            ],
            name: <2>,
          ),
          idx(<2.north-east>, [2]),
          node(
            (0, 2),
            ```
            k = j2
            if n2 > 30
            ```,
            name: <3>,
          ),
          idx(<3.north-east>, [3]),
          node(
            (0, 3),
            ```
            j3 = φ(j2,j4)
            i4 = k
            n3 = n2 - 1
            ```,
            name: <7>,
          ),
          idx(<7.north-east>, [7]),
          node(
            (1, 2),
            ```
            j4 = φ(j2,j5,j6)
            i5 = φ(i2,i5,i7)
            if i5 > 0
            ```,
            name: <8>,
          ),
          idx(<8.north-east>, [8]),
          node(
            (1, 3),
            ```
            j6 = j4 + 1
            i7 = i5 - 1
            ```,
            name: <11>,
          ),
          idx(<11.north-east>, [11]),
          node(
            (1, 1),
            ```
            print(j2)
            ```,
            name: <12>,
          ),
          idx(<12.north-east>, [12]),

          edge((0, 0), <2>, "-|>"),
          edge(<2>, <3>, "-|>", stroke: green),
          edge(<3>, <7>, "-|>", stroke: green),
          edge(<7>, (-1, 3), (-1, 1), <2>, "-|>"),
          edge(<3>, <8>, "-|>", stroke: red),
          edge(<8>, <11>, "-|>", shift: -5pt, stroke: green),
          edge(<8>, <7>, "-|>", stroke: red),
          edge(<11>, <8>, "-|>", shift: -5pt),
          edge(<2>, <12>, "-|>", stroke: red),
        ),
        caption: [CFG после агрессивного устранения мёртвого кода],
      )
    ],
    enum.item[
      #enum(
        numbering: "(a)",
        enum.item[
          #let node = node.with(shape: circle, stroke: luma(90%))
          #let idx = fletcher.node.with(size: 16pt)

          #let ed = "-"
          #let color_i2 = rgb("#b7e07c")
          #let color_i4 = rgb("#4fa3c7")
          #let color_i5 = rgb("#ffe44c")
          #let color_j2 = rgb("#4fd1b7")
          #let color_j4 = rgb("#5a2a7c")
          #let color_n3 = rgb("#5a6ac7")

          #let pi = 3.14159
          #let n = 11
          #let radius = 5
          #let circle_pos(i) = (
            radius * calc.cos(2 * pi * i / n),
            radius * calc.sin(2 * pi * i / n),
          )
          #figure(
            diagram(
              node(circle_pos(0), [i2], name: <0>, fill: color_i2),
              node(circle_pos(1), [i4], name: <1>, fill: color_i4),
              node(circle_pos(2), [i5], name: <2>, fill: color_i5),
              node(circle_pos(3), [i7], name: <3>, fill: color_j2),
              node(circle_pos(4), [j2], name: <4>, fill: color_j2),
              node(circle_pos(5), [j3], name: <5>, fill: color_j2),
              node(circle_pos(6), [j4], name: <6>, fill: color_j4),
              node(circle_pos(7), [j6], name: <7>, fill: color_i2),
              node(circle_pos(8), [n2], name: <8>, fill: color_n3),
              node(circle_pos(9), [n3], name: <9>, fill: color_n3),
              node(circle_pos(10), [k], name: <10>, fill: color_i4),
              edge(<4>, <0>, ed),
              edge(<4>, <9>, ed),
              edge(<4>, <6>, ed),
              edge(<4>, <8>, ed),
              edge(<4>, <10>, ed),

              edge(<0>, <8>, ed),
              edge(<0>, <4>, ed),
              edge(<0>, <10>, ed),
              edge(<0>, <9>, ed),
              edge(<0>, <6>, ed),

              edge(<9>, <5>, ed),
              edge(<9>, <1>, ed),
              edge(<9>, <4>, ed),
              edge(<9>, <0>, ed),
              edge(<9>, <6>, ed),

              edge(<3>, <7>, ed),
              edge(<3>, <10>, ed),
              edge(<3>, <6>, ed),
              edge(<3>, <2>, ed),
              edge(<3>, <8>, ed),

              edge(<7>, <10>, ed),
              edge(<7>, <3>, ed),
              edge(<7>, <6>, ed),
              edge(<7>, <2>, ed),
              edge(<7>, <8>, ed),

              edge(<6>, <2>, ed),
              edge(<6>, <5>, ed),
              edge(<6>, <8>, ed),
              edge(<6>, <1>, ed),
              edge(<6>, <4>, ed),
              edge(<6>, <7>, ed),
              edge(<6>, <10>, ed),
              edge(<6>, <0>, ed),
              edge(<6>, <3>, ed),
              edge(<6>, <9>, ed),

              edge(<5>, <1>, ed),
              edge(<5>, <10>, ed),
              edge(<5>, <6>, ed),
              edge(<5>, <9>, ed),
              edge(<5>, <8>, ed),

              edge(<1>, <6>, ed),
              edge(<1>, <9>, ed),
              edge(<1>, <5>, ed),
              edge(<1>, <8>, ed),

              edge(<8>, <0>, ed),
              edge(<8>, <3>, ed),
              edge(<8>, <6>, ed),
              edge(<8>, <2>, ed),
              edge(<8>, <5>, ed),
              edge(<8>, <4>, ed),
              edge(<8>, <1>, ed),
              edge(<8>, <7>, ed),
              edge(<8>, <10>, ed),

              edge(<10>, <0>, ed),
              edge(<10>, <6>, ed),
              edge(<10>, <3>, ed),
              edge(<10>, <2>, ed),
              edge(<10>, <5>, ed),
              edge(<10>, <8>, ed),
              edge(<10>, <4>, ed),
              edge(<10>, <7>, ed),

              edge(<2>, <8>, ed),
              edge(<2>, <7>, ed),
              edge(<2>, <10>, ed),
              edge(<2>, <3>, ed),
              edge(<2>, <6>, ed),
            ),
            caption: [Граф конфликтов переменных],
          )
        ],
        enum.item[
          Вернём графу свойство уникального предшественника и уникального последователя, добавив блоки `13` и `14`.

          #figure(
            diagram(
              node(
                (0, 0),
                ```
                j2 = 1
                i2 = 0
                n2 = 30
                ```,
                name: <1>,
              ),
              idx(<1.north-east>, [1]),
              node(
                (0, 1),
                ```
                if n2 > i2
                ```,
                name: <2>,
              ),
              idx(<2.north-east>, [2]),
              node(
                (0, 2),
                ```
                k = j2
                if n2 > 30
                ```,
                name: <3>,
              ),
              idx(<3.north-east>, [3]),
              node(
                (0, 3),
                ```
                j3 = j2
                ```,
                name: <13>,
              ),
              idx(<13.north-east>, [13]),
              node(
                (1, 2),
                ```
                j4 = j2
                i5 = i2
                ```,
                name: <14>,
              ),
              idx(<14.north-east>, [14]),
              node(
                (0, 4),
                ```
                i4 = k
                n3 = n2 - 1
                j2 = j3
                i2 = i4
                n2 = n3
                ```,
                name: <7>,
              ),
              idx(<7.north-east>, [7]),
              node(
                (1, 3),
                ```
                if i5 > 0
                ```,
                name: <8>,
              ),
              idx(<8.north-east>, [8]),
              node(
                (1, 4),
                ```
                j6 = j4 + 1
                i7 = i5 - 1
                j4 = j6
                i5 = i7
                ```,
                name: <11>,
              ),
              idx(<11.north-east>, [11]),
              node(
                (1, 1),
                ```
                print(j2)
                ```,
                name: <12>,
              ),
              idx(<12.north-east>, [12]),

              edge(<1>, <2>, "-|>"),
              edge(<2>, <3>, "-|>", stroke: green),
              edge(<3>, <13>, "-|>", stroke: green),
              edge(<7>, (-1, 4), (-1, 1), <2>, "-|>"),
              edge(<3>, <14>, "-|>", stroke: red),
              edge(<8>, <11>, "-|>", shift: -5pt, stroke: green),
              edge(<8>, <7>, "-|>", stroke: red),
              edge(<11>, <8>, "-|>", shift: -5pt),
              edge(<2>, <12>, "-|>", stroke: red),
              edge(<13>, <7>, "-|>"),
              edge(<14>, <8>, "-|>"),
            ),
            caption: [CFG после удаления 𝜙-функций],
          )

          Переименуем переменные: переменным одинакового цвета из графа конфликтов дадим одинаковые имена.

          #figure(
            diagram(
              node(
                (0, 0),
                ```
                x = 1
                y = 0
                n = 30
                ```,
                name: <1>,
              ),
              idx(<1.north-east>, [1]),
              node(
                (0, 1),
                ```
                if n > y
                ```,
                name: <2>,
              ),
              idx(<2.north-east>, [2]),
              node(
                (0, 2),
                ```
                k = x
                if n > 30
                ```,
                name: <3>,
              ),
              idx(<3.north-east>, [3]),
              node(
                (0, 3),
                ```
                x = x
                ```,
                name: <13>,
              ),
              idx(<13.north-east>, [13]),
              node(
                (1, 2),
                ```
                j = x
                i = y
                ```,
                name: <14>,
              ),
              idx(<14.north-east>, [14]),
              node(
                (0, 4),
                ```
                k = k
                n = n - 1
                x = x
                y = k
                n = n
                ```,
                name: <7>,
              ),
              idx(<7.north-east>, [7]),
              node(
                (1, 3),
                ```
                if i > 0
                ```,
                name: <8>,
              ),
              idx(<8.north-east>, [8]),
              node(
                (1, 4),
                ```
                y = j + 1
                x = i - 1
                j = y
                i = x
                ```,
                name: <11>,
              ),
              idx(<11.north-east>, [11]),
              node(
                (1, 1),
                ```
                print(x)
                ```,
                name: <12>,
              ),
              idx(<12.north-east>, [12]),

              edge(<1>, <2>, "-|>"),
              edge(<2>, <3>, "-|>", stroke: green),
              edge(<3>, <13>, "-|>", stroke: green),
              edge(<7>, (-1, 4), (-1, 1), <2>, "-|>"),
              edge(<3>, <14>, "-|>", stroke: red),
              edge(<8>, <11>, "-|>", shift: -5pt, stroke: green),
              edge(<8>, <7>, "-|>", stroke: red),
              edge(<11>, <8>, "-|>", shift: -5pt),
              edge(<2>, <12>, "-|>", stroke: red),
              edge(<13>, <7>, "-|>"),
              edge(<14>, <8>, "-|>"),
            ),
            caption: [CFG после переименования переменных],
          )
          #figure(
            diagram(
              node(
                (0, 0),
                ```
                x = 1
                y = 0
                n = 30
                ```,
                name: <1>,
              ),
              idx(<1.north-east>, [1]),
              node(
                (0, 1),
                ```
                if n > y
                ```,
                name: <2>,
              ),
              idx(<2.north-east>, [2]),
              node(
                (0, 2),
                ```
                k = x
                if n > 30
                ```,
                name: <3>,
              ),
              idx(<3.north-east>, [3]),
              node(
                (1, 2),
                ```
                j = x
                i = y
                ```,
                name: <14>,
              ),
              idx(<14.north-east>, [14]),
              node(
                (0, 3),
                ```
                n = n - 1
                y = k
                ```,
                name: <7>,
              ),
              idx(<7.north-east>, [7]),
              node(
                (1, 3),
                ```
                if i > 0
                ```,
                name: <8>,
              ),
              idx(<8.north-east>, [8]),
              node(
                (1, 4),
                ```
                y = j + 1
                x = i - 1
                j = y
                i = x
                ```,
                name: <11>,
              ),
              idx(<11.north-east>, [11]),
              node(
                (1, 1),
                ```
                print(x)
                ```,
                name: <12>,
              ),
              idx(<12.north-east>, [12]),

              edge(<1>, <2>, "-|>"),
              edge(<2>, <3>, "-|>", stroke: green),
              edge(<3>, <7>, "-|>", stroke: green),
              edge(<7>, (-1, 3), (-1, 1), <2>, "-|>"),
              edge(<3>, <14>, "-|>", stroke: red),
              edge(<8>, <11>, "-|>", shift: -5pt, stroke: green),
              edge(<8>, <7>, "-|>", stroke: red),
              edge(<11>, <8>, "-|>", shift: -5pt),
              edge(<2>, <12>, "-|>", stroke: red),
              edge(<14>, <8>, "-|>"),
            ),
            caption: [CFG после удаление лишних копирований],
          )
        ],
      )
    ],
  )
]
