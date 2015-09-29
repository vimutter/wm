require 'nokogiri'
require 'open-uri'
API = "https://www.walmart.com/reviews/product/%{id}"

class Wallmart
  class << self
    def reviews(product_id, keywords)
      doc = Nokogiri::HTML(open(API % {id: product_id}))

      regexp = /#{keywords.split(' ').map {|token| Regexp.escape(token) }.join('|')}/i

      total = doc.css('.customer-review').count

      reviews = doc.css('.customer-review').select do |review|
        review.css(".js-customer-review-text").first.content =~ regexp
      end

      reviews = reviews.map do |review|
        {
          title: review.css(".customer-review-title").first.content,
          reviewer: review.css(".customer-name").first.content,
          reviewText: highlight(review.css(".js-customer-review-text").first.content, keywords, regexp)
        }
      end

      {
        reviews: reviews,
        total: total,
        count: reviews.count
      }
    end

    def empty
      {
        reviews: [],
        total: 0,
        count: 0
      }
    end

    def highlight(text, keywords, regexp)
      if keywords.present?
        text.gsub(regexp) {|a|  "<span class='found'>#{CGI.escapeHTML a}</span>".html_safe }
      else
        text
      end
    end
  end
end
