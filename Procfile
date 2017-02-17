web: bundle exec unicorn -p $PORT -c ./config/unicorn.rb
redis: redis-server
worker: bundle exec sidekiq -q default -q mailers
