#let val(x) = text(fill: blue, str(x))
#let ptr(x) = underline(str(x))
#let nullptr = ptr("●");

#let object(content) = table.cell(colspan: content.len(), inset: (x: 1.1pt))[ #table(
  columns: content.len(),
  ..content.map(c => [#c])
)];


#let ids = (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27);
#let col-gut = ids.map(id => if (calc.rem(id, 3) == 0) { 2.2pt } else { auto });


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
    object((val(4), val(4), ptr(22))),
    object((val(6), ptr(19), ptr(4))),
    object((val(3), nullptr, ptr(1)))
  ),
)


