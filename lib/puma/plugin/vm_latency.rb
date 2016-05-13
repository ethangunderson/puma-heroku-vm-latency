Puma::Plugin.create do
  def config(c)
    if workers_supported?
      c.on_worker_boot do

        Librato::Metrics.authenticate(ENV['LIBRATO_EMAIL'], ENV['LIBRATO_API_KEY'])

        vm_measurement_duration = (ENV["VM_MEASUREMENT_DURATION"] || 10).to_i

        Thread.start do
          while(true) do
            start_time = DateTime.now.strftime('%Q').to_i
            sleep(vm_measurement_duration)
            end_time = DateTime.now.strftime('%Q').to_i
            latency = (end_time - start_time) - (vm_measurement_duration * 1000)
            source = "#{ENV["HEROKU_APP_NAME"]}.#{ENV["DYNO"]}"

            Librato::Metrics.submit("heroku.dynos.vm_latency" => { value: latency, source: source })
          end
        end
      end
    end
  end
end
