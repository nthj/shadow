class Rack::Sendfile
  def call_with_silenced_missing_header env
    status, headers, body = @app.call(env)
    if body.respond_to?(:to_path)
      case type = variation(env)
      when 'X-Accel-Redirect'
        path = F.expand_path(body.to_path)
        if url = map_accel_path(env, path)
          headers[type] = url
          body = []
        else
          #env['rack.errors'] << "X-Accel-Mapping header missing"
        end
      when 'X-Sendfile', 'X-Lighttpd-Send-File'
        path = F.expand_path(body.to_path)
        headers[type] = path
        body = []
      when '', nil
      else
        env['rack.errors'] << "Unknown x-sendfile variation: '#{variation}'.\n"
      end
    end
    [status, headers, body]
  end
  alias_method_chain :call, :silenced_missing_header
end
