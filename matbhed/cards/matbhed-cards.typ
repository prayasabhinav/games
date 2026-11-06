// Builds the Matbhed cards, one card to a page, from a text file of card texts.
//   typst compile --input lang=english matbhed-cards.typ matbhed-cards-english.pdf
//   typst compile --input lang=gujarati matbhed-cards.typ matbhed-cards-gujarati.pdf
// The 2023 cards were set in Ideal Sans Book, Kohinoor Gujarati and Minion Pro; the Noto faces are free stand-ins.

#let lang = sys.inputs.at("lang", default: "english")
#let colours = (red: rgb("#F89F8A"), yellow: rgb("#F2F69D"), green: rgb("#A8DE8F"))

// "# red" starts a colour; every other paragraph is one card.
#let cards = {
  let colour = none
  let out = ()
  for block in read("matbhed-cards-" + lang + ".txt").split("\n\n") {
    let text = block.trim()
    if text.starts-with("# ") { colour = text.slice(2) } else if text != "" { out.push((colour, text)) }
  }
  out
}

#set page(width: 2.5in, height: 3.5in, margin: (x: 0.25in, top: 0.2in, bottom: 0.2in))
#set text(..if lang == "gujarati" { (font: ("Kohinoor Gujarati", "Noto Sans Gujarati"), weight: 400, lang: "gu") } else { (font: ("Ideal Sans", "Noto Sans"), weight: 325, lang: "en") })
#set par(justify: true, leading: 0.5em)

// The largest size from 11pt down at which the card's text fits the space between heading and scale.
#let fitted(body) = context {
  let size = 11pt
  while size > 6pt and measure(block(width: 2in, text(size: size, body))).height > 2.3in { size -= 0.25pt }
  text(size: size, body)
}

#for (i, (colour, body)) in cards.enumerate() {
  let n = cards.slice(0, i).filter(c => c.at(0) == colour).len() + 1
  set page(fill: colours.at(colour))
  align(center, text(font: ("Minion Pro", "Crimson Pro", "Noto Serif"), size: 11pt)[card no. #n])
  block(height: 2.45in, align(horizon, fitted(body)))
  align(center, text(font: ("Ideal Sans", "Noto Sans"), size: 11pt, weight: 325, fill: rgb("#D22027"), tracking: 0.5pt)[1 | 2 | 3 | 4 | 5 | 6 | 7])
  if i < cards.len() - 1 { pagebreak() }
}
