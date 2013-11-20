require 'typhoeus'
class Flower::Rest

  def post_message(msg, tags = [], message)
    params = {
      content: msg,
      tags: tags || [],
      event: 'message'
    }

    Typhoeus::Request.post(post_url(message), {params: params})
  end

  def get_users
    users = []
    flows.each do |flow|
      response = Typhoeus::Request.get(flow_url(flow))
      users += JSON.parse(response.body)["users"]
    end
    users
  end

  private

  def flows
    @flows ||= JSON.parse(Typhoeus::Request.get(flow_url).body).select{|f| f["joined"]}
  end

  def flow_url(flow = nil)
    url = "https://#{Flower::Config.api_token}@"
    if flow
      url + flow["url"].gsub("https://", "")
    else
      url + "api.flowdock.com/flows/"
    end
  end

  def post_url(message)
    flow = flows.detect{|f| f['id'] == message.flow }
    url = "#{flow_url(flow)}/messages"
    url << "/#{message.reply_to}/comments" if message.reply_to
    url
  end
end
