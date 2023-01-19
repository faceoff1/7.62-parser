require_relative 'product_parser'
require_relative 'product'
require 'nokogiri'
require 'date'
require 'open-uri'

class ProductCollection
  attr_reader :products

  def self.from_web(categories_array)
    product_ids = categories_array.map { |category| ProductParser.ids_from_category(category) }.flatten
    products = product_ids.map { |id| ProductParser.product_by_id(id) }.reject(&:nil?)
    new(products)
  end

  def initialize(products)
    @products = products
  end

  def to_xml(path, file_name)
    builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
      xml.document {
        xml.DocType_ 'PRODAT'
        xml.Currency_ 'RUB'
        xml.DocumentDate_ Date.today
        @products.each do |product|
          xml.Product {
            xml.id_   product.id
            xml.title_  product.title
            xml.categories_ {
              product.categories_list.each do |category|
                xml.category_ category
              end
            }
            xml.images_ {
              product.images_urls.each do |image|
                xml.image_ image
              end
            }
            xml.available_ product.available ? 'Да' : 'Нет'
            xml.price_ product.price
            xml.description_ product.description[:description]
            xml.specs_ {
              product.description[:specs].each do |feature|
                xml.feature_ {
                  xml.name_ feature[0]
                  xml.value_ feature[1]
                }
              end
            }
          }
        end
      }
    end

    doc = builder.to_xml
    file = File.new("#{path}/#{file_name}.xml", 'a:UTF-8')
    file.print(doc)
    file.close

    file
  end

  def upload_images(path)
    Dir.mkdir(path) unless Dir.exist?(path)
    @products.each do |product|
      image_path = File.join(path, product.id.to_s)
      Dir.mkdir(image_path) unless Dir.exist?(image_path)
      product.images_urls.each do |url|
        begin
          image = URI.open(url)
        rescue OpenURI::HTTPError => e
          if e.message == '404 Not Found'
            next
          elsif e.message == '500 Internal Server Error'
            retry
          else
            p e.message, e.backtrace.inspect
            next
          end
        end
        IO.copy_stream(image, "#{image_path}/#{image.base_uri.to_s.split('/')[-1]}")
      end
    end
  end
end
