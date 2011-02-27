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
end
