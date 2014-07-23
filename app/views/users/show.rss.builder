xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "Microposts"

    for micropost in @microposts
      xml.item do
        xml.title micropost.user.name
        xml.description micropost.content
        xml.pubDate micropost.created_at.to_s(:rfc822)
        xml.link user_url(micropost.user, :rss)
        xml.guid user_url(micropost.user, :rss)
      end
    end
  end
end
