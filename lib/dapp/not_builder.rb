module Dapp
  class NotBuilder
    attr_reader :cli_options, :patterns

    def initialize(cli_options:, patterns: nil)
      @cli_options = cli_options

      @patterns = patterns || []
      @patterns << '*' unless @patterns.any?
    end

    def build
      build_configs.each do |build_conf|
        puts build_conf[:name]
        options = { conf: build_conf, opts: cli_options }
        Application.new(**options).build_and_fixate!
      end
    end

    protected

    def build_configs
      Dapp::Config.default_opts.tap do |default_opts|
        [:log_quiet, :log_verbose, :type].each { |opt| default_opts[opt] = cli_options[opt] }
      end

      if File.exist? dappfile_path
        process_file
      else
        process_directory
      end
    end

    def dappfile_path
      @dappfile_path ||= File.join [cli_options[:dir], cli_options[:dappfile_name] || 'Dappfile'].compact
    end

    def process_file
      patterns.map do |pattern|
        unless (configs = Dapp::Config.process_file(dappfile_path, app_filter: pattern)).any?
          STDERR.puts "Error: No such app: '#{pattern}' in #{dappfile_path}"
          exit 1
        end
        configs
      end.flatten
    end

    def process_directory
      Dapp::Config.default_opts[:shared_build_dir] = true
      patterns.map do |pattern|
        unless (configs = Dapp::Config.process_directory(cli_options[:dir], pattern)).any?
          STDERR.puts "Error: No such app '#{pattern}'"
          exit 1
        end
        configs
      end.flatten
    end
  end # Builder
end # Dapp