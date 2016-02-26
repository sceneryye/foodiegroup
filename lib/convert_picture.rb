module ConvertPicture
  def resize picture_name, size_name, width, height, path
    size = "#{width}x#{height}"
    re_name = "#{path}/#{size_name}/#{picture_name}"
    resize = system "convert #{path}/#{picture_name} -resize #{size} #{re_name}"
    unless resize
      `mkdir "#{path}/#{size_name}"`
      system "convert #{path}/#{picture_name} -resize #{size} #{re_name}"
    end
  end

  def other_img photo, size_name
    if photo
      url = photo.image
      path = url.split('/')
      new_url = path.insert(2, size_name).join('/')
    end
  end


end