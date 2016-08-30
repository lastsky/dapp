module Dapp
  # Project
  class Project
    # Lock
    module Lock
      def lock_path
        build_path.join('locks')
      end

      def lock(name, *args, default_timeout: 300, **kwargs, &blk)
        if dry_run?
          yield if block_given?
        else
          timeout = cli_options[:lock_timeout] || default_timeout

          ::Dapp::Lock::File.new(
            lock_path, name,
            timeout: timeout,
            on_wait: lambda do |&blk|
              log_secondary_process(
                t(code: 'process.waiting_resouce_lock', data: { name: name }),
                short: true,
                &blk
              )
            end
          ).synchronize(*args, **kwargs, &blk)
        end
      end
    end # Lock
  end # Project
end # Dapp