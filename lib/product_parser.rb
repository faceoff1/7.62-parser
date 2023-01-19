require 'nokogiri'
require 'open-uri'
require 'addressable/uri'
require_relative 'product'

module ProductParser
  extend self

  SITE_URL = 'https://7-62.ru'.freeze

  def ids_from_category(category)
    page = 1
    products_ids = []
    loop do
      url = "#{SITE_URL}/category/#{category}/?page=#{page}"
      url_string = Addressable::URI.parse(url).normalize
      doc = Nokogiri::HTML(URI.open(url_string))
      products_on_page = doc.css('div#product-list > div.product-list > div.product')

      break if products_on_page.length == 0

      products_ids += products_on_page.map { |node| node.css('input[name=product_id]')[0]['value'].to_i }
      page += 1
    end
    products_ids
  end

  def product_by_id(id)
    url = "#{SITE_URL}/#{id}/"
    puts url
    begin
      url_string = Addressable::URI.parse(url).normalize
      doc = Nokogiri::HTML(URI.open(url_string))

      title = doc.css('h1.product-name > span[itemprop="name"]').text

      categories = doc.css('ul.breadcrumbs  > li').map { |node| node.css('a > span[itemprop="name"]').text }.reject(&:empty?)

      more_images = doc.css('div.more-images  div.image').map { |node| "#{SITE_URL}#{node.css('a')[0]['href']}" }
      if more_images.empty? then
        core_image = doc.css('div.product-core-image > a')
        images_urls = core_image.length == 0 ? [] : ["#{SITE_URL}#{core_image[0]['href']}"]
      else
        images_urls = more_images
      end

      available = doc.css('div.stocks > div > span')[0]['class'] == 'stock-unavailable' ? false : true

      price = doc.css('div.prices > span')[0]['data-price'].to_i

      product_description = doc.css('div.tab-content  div#product-description p').inner_html
      product_specs = doc.css('div.tab-content  table#product-features tr').map {
        |node|  [node.css('td.name').text.strip, node.css('td.value').text.strip]
      }
      description = {
        description: product_description,
        specs: product_specs
      }

      Product.new(id, title, categories, images_urls, available, price, description)

    rescue OpenURI::HTTPError => e
      if e.message == '404 Not Found'
        nil
      elsif e.message == '500 Internal Server Error'
        retry
      else
        p e.message, e.backtrace.inspect
        nil
      end
    end
  end

end
