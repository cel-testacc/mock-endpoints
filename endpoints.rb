require 'sinatra'
require 'mysql2'
require 'json'

get '/endpoints' do 
    begin
        client = Mysql2::Client.new(:host => ENV['DBHOST'], :username => ENV['DBUSER'], :password => ENV['DBPASS'], :database => 'hold_endpoints', :as => :hash)
        results = client.query('SELECT * from endpoints')
        endpoint_values = results.map do |row|
            if row['headers'].nil? 
                headers = ''
            else
                headers = JSON.parse(row['headers'])
            end 
            if row['body'].nil? 
                body = ''
            else 
                body = JSON.parse(row['body'])
            end 
            {'id': row['id'], 'path': row['endpoint_path'], 'verb': row['verb'], 'code': row['code'], 'headers': headers, 'body': body}
        end
    end

    [200, JSON.generate(endpoint_values)]
end 

post '/endpoints' do 
    received_endpoint = JSON.parse request.body.read 
    if received_endpoint['data']['attributes']['verb'].nil? or received_endpoint['data']['attributes']['path'].nil? or received_endpoint['data']['attributes']['response']['code'].nil?
        halt 400, 'The data you have passed is incomplete'
    end

    insert_path = received_endpoint['data']['attributes']['path']
    insert_verb = received_endpoint['data']['attributes']['verb']
    created_paths = Array.new 
    begin 
        client = Mysql2::Client.new(:host => ENV['DBHOST'], :username => ENV['DBUSER'], :password => ENV['DBPASS'], :database => 'hold_endpoints', :as => :hash)
        results = client.prepare('SELECT * from endpoints WHERE endpoint_path=? and verb=?')
        result = results.execute(insert_path, insert_verb)
        created_paths = result.map do |row| 
            row['endpoint_path'] + ' ' + row['verb']
        end 
    end 

    if created_paths.include? received_endpoint['data']['attributes']['path'] + ' ' + received_endpoint['data']['attributes']['verb'] 
        halt 400, 'this path already exists'
    end 

    if received_endpoint['data']['attributes']['response']['headers'].nil? 
        headers = nil
    else
        headers = JSON.generate(received_endpoint['data']['attributes']['response']['headers'])
    end 
    if received_endpoint['data']['attributes']['response']['body'].nil? 
        body = nil
    else 
        body = JSON.generate(received_endpoint['data']['attributes']['response']['body'])
    end 

    insert_code = received_endpoint['data']['attributes']['response']['code']
    new_endpoint = ""
    begin 
        client = Mysql2::Client.new(:host => ENV['DBHOST'], :username => ENV['DBUSER'], :password => ENV['DBPASS'], :database => 'hold_endpoints', :as => :hash)
        results = client.prepare('INSERT INTO endpoints(endpoint_path, verb, code, headers, body) VALUES(?, ?, ?, ?, ?)')
        results.execute(insert_path, insert_verb, insert_code, headers, body)
        check_insert = client.prepare('SELECT * from endpoints where endpoint_path=? and verb=?')
        inserted = check_insert.execute(insert_path, insert_verb)
        new_endpoint = inserted.map do |row| 
            {'id': row['id'], 'path': row['endpoint_path'], 'verb': row['verb'], 'code': row['code'], 'headers': headers, 'body': body}
        end 
    end 

    [201, JSON.generate(new_endpoint)]
end 

patch '/endpoints/:id' do 
    created_paths = Array.new 
    begin 
        client = Mysql2::Client.new(:host => ENV['DBHOST'], :username => ENV['DBUSER'], :password => ENV['DBPASS'], :database => 'hold_endpoints', :as => :hash)
        results = client.prepare('SELECT * from endpoints WHERE id=?')
        result = results.execute(params['id'])
        created_paths = result.map do |row| 
            row['id']
        end 
    end 

    if created_paths.include? params['id'].to_i
        received_endpoint = JSON.parse request.body.read 
        if received_endpoint['data']['attributes']['response']['body'].nil? 
            halt 400, 'No response body sent in request'
        else 
            body = JSON.generate(received_endpoint['data']['attributes']['response']['body'])
        end 
        client = Mysql2::Client.new(:host => ENV['DBHOST'], :username => ENV['DBUSER'], :password => ENV['DBPASS'], :database => 'hold_endpoints', :as => :hash)
        results = client.prepare('UPDATE endpoints SET body=? WHERE id=?')
        results.execute(body, params['id'])
        check_insert = client.prepare('SELECT * from endpoints where id=?')
        inserted = check_insert.execute(params['id'])
        new_endpoint = inserted.map do |row| 
            {'id': row['id'], 'path': row['endpoint_path'], 'verb': row['verb'], 'code': row['code'], 'headers': headers, 'body': body}
        end 
    else 
        halt 404, 'Not found'
    end 

    [201, JSON.generate(new_endpoint)]
end

delete '/endpoints/:id' do 
    created_paths = Array.new 
    begin 
        client = Mysql2::Client.new(:host => ENV['DBHOST'], :username => ENV['DBUSER'], :password => ENV['DBPASS'], :database => 'hold_endpoints', :as => :hash)
        results = client.prepare('SELECT * from endpoints WHERE id=?')
        result = results.execute(params['id'])
        created_paths = result.map do |row| 
            row['id']
        end 
    end 

    if created_paths.include? params['id'].to_i
        client = Mysql2::Client.new(:host => ENV['DBHOST'], :username => ENV['DBUSER'], :password => ENV['DBPASS'], :database => 'hold_endpoints', :as => :hash)
        results = client.prepare('DELETE FROM endpoints WHERE id=?')
        results.execute(params['id'])
        check_insert = client.prepare('SELECT * from endpoints where id=?')
    else 
        halt 404, 'Not found'
    end 

    [200, 'The endpoint has been deleted.']
end

get '/*' do 
    path = params['splat'][0]
    created_paths = Array.new
    begin 
        client = Mysql2::Client.new(:host => ENV['DBHOST'], :username => ENV['DBUSER'], :password => ENV['DBPASS'], :database => 'hold_endpoints', :as => :hash)
        results = client.prepare('SELECT * from endpoints WHERE endpoint_path=? and verb="GET"')
        result = results.execute(path)
        created_paths = result.map do |row| 
            {'code': row['code'], 'headers': headers, 'body': body}
        end 
    end 

    if created_paths.length == 0 
        halt 404, 'Requested page doesnt exist'
    else
        [200, JSON.generate(created_paths)]
    end 
end 

post '/*' do 
    path = params['splat'][0]
    created_paths = Array.new
    begin 
        client = Mysql2::Client.new(:host => ENV['DBHOST'], :username => ENV['DBUSER'], :password => ENV['DBPASS'], :database => 'hold_endpoints', :as => :hash)
        results = client.prepare('SELECT * from endpoints WHERE endpoint_path=? and verb="POST"')
        result = results.execute(path)
        created_paths = result.map do |row| 
            {'code': row['code'], 'headers': headers, 'body': body}
        end 
    end 

    if created_paths.length == 0 
        halt 404, 'Requested page doesnt exist'
    else
        [200, JSON.generate(created_paths)]
    end 
end 