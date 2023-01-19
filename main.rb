require_relative 'lib/product'
require_relative 'lib/product_collection'
require_relative 'lib/product_parser'

#puts ProductParser.ids_from_category('airsoft')
#puts ProductParser.product_by_id(3009)
#puts ProductParser.product_by_id(8493)
#puts ProductParser.product_by_id(15573)

products =  ProductCollection.from_web(['airsoft'])
products.to_xml(File.dirname(__FILE__), "products_#{Date.today}")
products.upload_images("#{File.dirname(__FILE__)}/images")
