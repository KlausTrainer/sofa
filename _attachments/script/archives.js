function Archives(yearClassName, MonthClassName) {
  var clicker = 'clicker'
  var arrow = 'arrow'
  var closed = 'closed'
  var open = 'open'
  var open_arrow = '<span class="' + arrow + ' ' + open +
                   '">▾&nbsp;&nbsp;&nbsp;</span>'
  var closed_arrow = '<span class="'  + arrow + ' ' + closed +
                     '">▸&nbsp;&nbsp;&nbsp;</span>'

  function toggleByClassName(cname) {
    clickers = $('.' + cname)
    if (clickers.length < 1)
      return
    clickers[0].className += ' ' + clicker
    clickers[0].className += ' ' + open
    $(clickers[0]).prepend(open_arrow)
    clickers[0].onclick = function() {
      toggleNextOpenClose(this)
    }
    for (i = 1; i < clickers.length; i++) {
      clickers[i].className += ' ' + clicker
      clickers[i].className += ' ' + closed
      $(clickers[i]).prepend(open_arrow)
      clickers[i].onclick = function() {
        toggleNextOpenClose(this)
      }
      toggleNextOpenClose(clickers[i])
    }
  }

  function toggleNextOpenClose(el) {
    el.className = el.className.replace(new RegExp(open + '\\b'), '')
    el.className = el.className.replace(new RegExp(closed + '\\b'), '')
    var fc = el.firstChild
    if (fc.classList.contains('arrow') && fc.classList.contains('open')) {
      $(fc).replaceWith(closed_arrow)
    } else if (fc.classList.contains('arrow')) {
      $(fc).replaceWith(open_arrow)
    }
    var next = el.nextSibling
    while(next.nodeType != 1)
      next = next.nextSibling
    next.style.display = (next.style.display == 'none' ? 'block' : 'none')
    el.className += (next.style.display == 'block' ? ' ' + open : ' ' + closed)
  }

  toggleByClassName(yearClassName)
  toggleByClassName(MonthClassName)
}
