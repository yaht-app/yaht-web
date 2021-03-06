module Warden
  class Proxy
    def user(argument = {})
      opts  = argument.is_a?(Hash) ? argument : { :scope => argument }
      scope = (opts[:scope] ||= @config.default_scope)

      if @users.has_key?(scope)
        @users[scope]
      else
        # the following line was monkey patched to disable session auth when the API is used
        # according to the following tutorial:
        # https://blog.siliconjungles.io/devise-jwt-with-sessions-hybrid
        unless (user = request.original_fullpath.starts_with?("/api") ? nil : session_serializer.fetch(scope))
          run_callbacks = opts.fetch(:run_callbacks, true)
          manager._run_callbacks(:after_failed_fetch, user, self, :scope => scope) if run_callbacks
        end

        @users[scope] = user ? set_user(user, opts.merge(:event => :fetch)) : nil
      end
    end
  end
end