#set page(
  paper: "us-letter",
  margin: (top: 0.9in, bottom: 0.9in, left: 0.95in, right: 0.95in),
  header: context {
    if counter(page).get().first() > 1 [
      #set text(size: 8.5pt, fill: rgb("#525866"))
      The Chicago Software Craftsmanship Movement (2006–2015)
      #h(1fr)
      Mike Hall · just3ws.com
      #v(-4pt)
      #line(length: 100%, stroke: 0.5pt + rgb("#e3dfd7"))
    ]
  },
  footer: context [
    #line(length: 100%, stroke: 0.5pt + rgb("#e3dfd7"))
    #v(-4pt)
    #set text(size: 8.5pt, fill: rgb("#525866"))
    Oral History Monograph · Canonical Route: https://www.just3ws.com/chicago-craftsmanship/
    #h(1fr)
    Page #counter(page).display("1 of 1", both: true)
  ]
)

#set text(
  font: ("Charter", "Georgia", "Liberation Serif"),
  size: 10.5pt,
  fill: rgb("#1e232a"),
)

#set par(leading: 0.72em, justify: false)

#show heading.where(level: 1): it => [
  #set text(size: 20pt, weight: "bold", fill: rgb("#0f172a"))
  #block(below: 0.6em, it)
]

#show heading.where(level: 2): it => [
  #v(1.1em)
  #set text(size: 13.5pt, weight: "bold", fill: rgb("#0f766e"))
  #block(below: 0.35em)[
    #it
    #v(-6pt)
    #line(length: 100%, stroke: 0.75pt + rgb("#e3dfd7"))
  ]
]

#show heading.where(level: 3): it => [
  #v(0.7em)
  #set text(size: 11pt, weight: "bold", fill: rgb("#b45309"))
  #block(below: 0.25em, it)
]

#show quote: it => [
  #block(
    fill: rgb("#f4f0e8"),
    stroke: (left: 3pt + rgb("#0f766e")),
    inset: (x: 12pt, y: 8pt),
    radius: (right: 4pt),
    width: 100%,
    it
  )
]

#show link: set text(fill: rgb("#0f766e"))

$body$
