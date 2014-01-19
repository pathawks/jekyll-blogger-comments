require 'rubygems'
require 'net/https'
require 'uri'
require 'json'
require 'domainatrix'
require 'date'
require 'yaml/store'
require 'yaml'

require 'jekyll'

desc "Sync Blogger comments"
task :bloggercomments do
	site              = Jekyll.configuration({})
	commentsdirectory = '_comments/'
	jekyll_site       = Jekyll::Site.new(site)

	jekyll_site.reset
	jekyll_site.read
	jekyll_site.generate

	jekyll_site.posts.each do |post|
		if post.data['published'] == 'false' or post.data['comments'] == 'false'
			next
		end
	
		post_id   = post.id()
		post_date = post.date()
		post_file = commentsdirectory + post_date.strftime('%Y-%m-%d-') + post.slug()
	
		link  = '##'
	
		unless post.data['blogger'] and ( post.data['blogger']['siteid'] or site['blogger']['siteid'] )
			next
		end
		blogger_siteid = post.data['blogger']['siteid'] || site['blogger']['siteid']
	
		unless post.data['blogger'] and post.data['blogger']['postid'] and blogger_siteid
			next
		end
	
		uri = "https://www.blogger.com/feeds/#{blogger_siteid}/#{post.data['blogger']['postid']}/comments/default/?alt=json"
		url = URI.parse(uri)
		http = Net::HTTP.new(url.host, url.port)
		http.use_ssl = true
		http.verify_mode = OpenSSL::SSL::VERIFY_NONE
		request = Net::HTTP::Get.new(url.request_uri)
		response = http.request(request)
	
		unless response.code == "200" then
			warn "Comments feed not found: #{post_id}"
		end
	
		if response.code == "200" then
			json_rep = JSON.parse(response.body)
	
			if json_rep['feed'] and json_rep['feed']['entry'] and json_rep['feed']['entry'].length > 0 then
	
				comments = json_rep['feed']['entry'].reverse

				comments.each do |comment|
					
					author  = comment['author'][0].clone
					comments_date = DateTime.parse(comment['published']['$t'])
					post_created  = comments_date.strftime('%Y-%m-%d %H:%M:%S %z')
					comments_date = comments_date.new_offset('+00:00')
					comments_file = comments_date.strftime('%Y-%m-%d-%H%M%S')
	
					entry = YAML::Store.new("#{post_file}_#{comments_file}.txt")
					entry.transaction do
						entry['id'] = "c"+comment['id']['$t'].gsub(/tag\:blogger\.com\,1999\:blog\-\d+\.post\-/,'')
						entry['source']            = 'Blogger'
						entry['date']              = post_created
						entry['updated']           = post_created
						entry['post_id']           = post_id
						entry['author']            = Hash.new
						if comment['author'][0]['name']['$t'] == 'Pat Hawks'
							entry['author']['url']   = 'http://pathawks.com/'
							entry['author']['email'] = 'pat@pathawks.com'
							entry['author']['image'] = 'http://0.gravatar.com/avatar/6838471f21e47341fbf89ed969d4529f?s=72'
							entry['author']['name']  = 'Pat Hawks'
						elsif comment['author'][0]['name']['$t'] == 'pathawks.com'
							entry['author']['url']   = 'http://pathawks.com/'
							entry['author']['email'] = 'pat@pathawks.com'
							entry['author']['image'] = 'http://0.gravatar.com/avatar/6838471f21e47341fbf89ed969d4529f?s=72'
							entry['author']['name']  = 'Pat Hawks'
						elsif comment['author'][0]['name']['$t'] == 'chad cook'
							entry['author']['url']   = 'https://www.facebook.com/chadgcook'
							entry['author']['email'] = 'chadgcook@facebook.com'
							entry['author']['image'] = 'https://graph.facebook.com/chadgcook/picture?width=72&height=72'
							entry['author']['name']  = 'Chad Cook'
						elsif comment['author'][0]['name']['$t'] == 'chad'
							entry['author']['url']   = 'https://www.facebook.com/chadgcook'
							entry['author']['email'] = 'chadgcook@facebook.com'
							entry['author']['image'] = 'https://graph.facebook.com/chadgcook/picture?width=72&height=72'
							entry['author']['name']  = 'Chad Cook'
						elsif comment['author'][0]['name']['$t'] == 'Christine'
							entry['author']['url']   = 'http://www.christinehawks.com/'
							entry['author']['email'] = 'christinejwarner@gmail.com'
							entry['author']['image'] = 'https://1.gravatar.com/avatar/096890a70b50ddd7ca11427042c5eb2c?s=72'
							entry['author']['name']  = 'Christine'
						elsif comment['author'][0]['name']['$t'] == 'Christine Warner'
							entry['author']['url']   = 'http://www.christinehawks.com/'
							entry['author']['email'] = 'christinejwarner@gmail.com'
							entry['author']['image'] = 'https://1.gravatar.com/avatar/096890a70b50ddd7ca11427042c5eb2c?s=72'
							entry['author']['name']  = 'Christine'
						elsif comment['author'][0]['name']['$t'] == 'Ben Hawks'
							entry['author']['url']   = 'https://www.facebook.com/ben.hawks.52'
							entry['author']['email'] = 'bjhnow@gmail.com'
							entry['author']['image'] = 'https://graph.facebook.com/ben.hawks.52/picture?width=72&height=72'
							entry['author']['name']  = 'Ben Hawks'
						elsif comment['author'][0]['name']['$t'] == 'Katie'
							entry['author']['url']   = 'https://www.facebook.com/katie.hawks.92'
							entry['author']['email'] = 'katie.hawks.92@facebook.com'
							entry['author']['image'] = 'https://graph.facebook.com/katie.hawks.92/picture?width=72&height=72'
							entry['author']['name']  = 'Katie'
						elsif comment['author'][0]['name']['$t'] == 'mroepke'
							entry['author']['url']   = 'http://thoughtsinthestillness.wordpress.com/'
							entry['author']['email'] = 'mac.roepke@facebook.com'
							entry['author']['image'] = 'http://1.gravatar.com/avatar/10f027627c39afe25a67dae37c8e509c?s=72'
							entry['author']['name']  = 'mcropekey'
						elsif comment['author'][0]['name']['$t'] == 'exploringtheinfiniteabyss'
							entry['author']['url']   = 'http://thoughtsinthestillness.wordpress.com/'
							entry['author']['email'] = 'mac.roepke@facebook.com'
							entry['author']['image'] = 'http://1.gravatar.com/avatar/10f027627c39afe25a67dae37c8e509c?s=72'
							entry['author']['name']  = 'mcropekey'
						elsif comment['author'][0]['name']['$t'] == 'louisgray'
							entry['author']['url']   = 'http://blog.louisgray.com/'
							entry['author']['email'] = 'louisgray@gmail.com'
							entry['author']['image'] = 'https://lh4.googleusercontent.com/-Zd0y5djZBSQ/AAAAAAAAAAI/AAAAAAAAwTQ/N7hoHuVtu3g/s72-c/photo.jpg'
							entry['author']['name']  = 'Louis Gray'
						elsif comment['author'][0]['name']['$t'] == 'louisgray'
							entry['author']['url']   = 'https://www.facebook.com/katie.hawks.92'
							entry['author']['email'] = 'katie.hawks.92@facebook.com'
							entry['author']['image'] = 'https://graph.facebook.com/katie.hawks.92/picture?width=72&height=72'
							entry['author']['name']  = 'Katie'
						elsif comment['author'][0]['name']['$t'] == 'MG Siegler'
							entry['author']['url']   = 'http://parislemon.com/'
							entry['author']['email'] = 'noreply@blogger.com'
							entry['author']['image'] = 'http://0.gravatar.com/avatar/710187cd963df0f92d11ddb31e6ae3db?size=72'
							entry['author']['name']  = 'MG Siegler'
						elsif comment['author'][0]['name']['$t'] == 'Med Student Wife'
							entry['author']['url']   = 'http://imawhitecoatwife.blogspot.com/'
							entry['author']['email'] = 'noreply@blogger.com'
							entry['author']['image'] = 'http://3.bp.blogspot.com/-xa4tSkiReOQ/UAM2lYcgngI/AAAAAAAAAAo/0cqSnSL58DA/s220/headshot.jpg'
							entry['author']['name']  = 'Med Student Wife'
						else
							if author['uri'] then
								entry['author']['url']   = comment['author'][0]['uri']['$t']
							end
							if comment['author'][0]['email'] then
								entry['author']['email'] = comment['author'][0]['email']['$t']
							else
								entry['author']['email'] = 'noreply@blogger.com'
							end
							if author['gd$image']['src'] then
								entry['author']['image'] = comment['author'][0]['gd$image']['src']
							end
							entry['author']['name']    = comment['author'][0]['name']['$t']
						end
						entry['content']           = '<p>' + comment['content']['$t'].to_str.gsub('<BR/>','<br />') + '</p>'
						entry['title']             = comment['title']['$t'].to_str.gsub('<BR/>','<br />')
					end
				end
			end
		end
	end
end
