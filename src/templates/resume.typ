#set page(
  paper: "us-letter",
  margin: (top: 0.55in, bottom: 0.55in, left: 0.6in, right: 0.6in),
  footer: context [
    #set text(size: 8pt, fill: rgb("#525866"))
    Mike Hall · Staff Software Engineer · https://www.just3ws.com/
    #h(1fr)
    Page #counter(page).display("1 / 1", both: true)
  ]
)

#set text(
  font: ("Inter", "Helvetica Neue", "Arial"),
  size: 9.2pt,
  fill: rgb("#1e232a"),
)

#set par(leading: 0.55em, spacing: 0.55em)

#show heading.where(level: 1): it => [
  #set text(size: 16pt, weight: "bold", fill: rgb("#0f172a"))
  #block(below: 0.25em, it)
]

#show heading.where(level: 2): it => [
  #v(0.7em)
  #set text(size: 10.5pt, weight: "bold", fill: rgb("#0f766e"))
  #block(below: 0.25em)[
    #upper(it.body)
    #v(-5pt)
    #line(length: 100%, stroke: 0.75pt + rgb("#0f766e"))
  ]
]

#show heading.where(level: 3): it => [
  #v(0.45em)
  #set text(size: 9.8pt, weight: "bold", fill: rgb("#0f172a"))
  #block(below: 0.15em, it)
]

#show link: set text(fill: rgb("#0f766e"))

$body$
