namespace :admin do
  desc "Tail production log files."
  task :tail_logs, :roles => :app do
    invoke_command "tail -f #{shared_path}/log/production.log" do |channel, stream, data|
      puts "\n#{channel[:host]}: #{data}" if stream == :out
      warn "[err :: #{channel[:server]}] #{data}" if stream == :err
    end
  end
end
