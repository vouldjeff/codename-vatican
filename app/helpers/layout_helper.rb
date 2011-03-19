module LayoutHelper
  def title(page_title)
    content_for(:title, page_title)
  end
  
  def h1(page_h1)
    content_for(:h1, page_h1)
    @show_h1 = true
  end
  
  def show_h1?
    @show_h1 == true
  end
  
  def h1?
    @h1.nil? ? true : false
  end
  
  def h1(value)
    @h1 = value
  end
end
