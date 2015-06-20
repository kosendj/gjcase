jQuery ($) ->
  $('.image-tags').each ->
    self = $(this)

    image_id = $(this).data('image-id')

    view = self.find('.image-tags-labels')
    editor = self.find('.image-tags-editor')

    self.find('.image-tags-editor_start_btn').click ->
      view.hide()
      editor.show()
    self.find('.image-tags-editor_finish_btn').click ->
      view.show()
      editor.hide()

    editor.find('form button').click ->
      val = editor.find('.image-tags-editor_tag_field')[0].value

      $.ajax(
        method: 'POST'
        data:
          id: val
        url: "/images/#{encodeURIComponent(image_id)}/tags"
        dataType: 'json'
        error: (jqxhr,status,error) ->
          console.log(jqxhr)
          console.log(status)
          console.log(error)
          alert("Got error: #{status}")
        success: (data, status, jqxhr) ->
          console.log(data)
          label = $('<a>').attr('href', "/tags/#{encodeURIComponent(data.tag.id)}").addClass('label label-primary').text(data.tag.name).data('tag-id', data.tag.id)
          listitem = $('<li>').addClass('image-tags-editor_tag_listitem').text(data.tag.name).data('tag-id', data.tag.id)

          view.append(label)
          editor.find('ul').append(listitem)
      )

    editor.on "click", ".image-tags-editor_tag_listitem", (ev) ->
      tag_id = $(this).data('tag-id').toString()

      $.ajax(
        method: 'POST'
        data: '_method=DELETE'
        url: "/images/#{encodeURIComponent(image_id)}/tags/#{encodeURIComponent(tag_id)}"
        dataType: 'json'
        error: (jqxhr,status,error) ->
          console.log(jqxhr)
          console.log(status)
          console.log(error)
          alert("Got erro when deleting tag: #{status}")
        success: (data, status, jqxhr) ->
          view.find(".label[data-tag-id=#{tag_id.replace(/[^0-9]/,'')}]").remove()
          editor.find(".image-tags-editor_tag_listitem[data-tag-id=#{tag_id.replace(/[^0-9]/,'')}]").remove()
      )
