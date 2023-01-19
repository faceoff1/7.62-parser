class Product
  attr_reader :id, :title, :categories_list, :images_urls, :available, :price, :description

  def initialize(id, title, categories_list, images_urls, available, price, description)
    @id = id
    @title = title
    @categories_list = categories_list
    @images_urls = images_urls
    @available = available
    @price = price
    @description = description
  end

  def to_s
    <<-PRODUCT

      ID: #{@id}
      Название: #{@title}
      Категории: #{@categories_list}
      URL картинок: #{@images_urls}
      Наличие на складе: #{@available ? 'Да' : 'Нет'}
      Цена: #{@price}
      Описание: #{@description[:description]}
      Характеристики: #{@description[:specs]}

    PRODUCT
  end
end
