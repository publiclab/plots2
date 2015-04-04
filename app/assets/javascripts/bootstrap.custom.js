/*
 * Needed to get the typeaheads working properly; 
 * not auto-selecting the first item and using the 
 * raw value of the input if no item is manually selected.
 */

jQuery(document).ready(function($) {
  $.fn.typeahead.Constructor.prototype.select = function () {
      var val = this.$menu.find('.active').attr('data-value')
      if (val === undefined) val = this.$element.val()
      this.$element
        .val(this.updater(val))
        .change()
      return this.hide()
    }

  $.fn.typeahead.Constructor.prototype.render = function (items) {
      var that = this

      items = $(items).map(function (i, item) {
        i = $(that.options.item).attr('data-value', item)
        i.find('a').html(that.highlighter(item))
        return i[0]
      })

      //items.first().addClass('active')
      this.$menu.html(items)
      return this
    }
})
