require 'open3'
require 'shellwords'

module Packer
  class Runner
    class CommandExecutionError < StandardError
      def initialize(stdout, stderr)
        if(stderr.empty?)
          message = stdout
        else
          message = stderr
        end

        super(message)
      end
    end

    def self.run!(*args, quiet: false)
      cmd = Shellwords.shelljoin(args.flatten)

      debug = cmd.include? '-debug'
      quiet = quiet && !debug

      status = 0
      stdout = ''
      stderr = ''
      if quiet
        # Run without streaming std* to any screen
        stdout, stderr, status = Open3.capture3(cmd)
      else
        # Run but stream as well as capture stdout to the screen
        # see: http://stackoverflow.com/a/1162850/83386
        Open3.popen3(cmd) do |std_in, std_out, std_err, thread|
          # read each stream from a new thread
          Thread.new do
            until (raw = std_out.getc).nil? do
              stdout << raw
              $stdout.write "#{raw}"
            end
          end
          Thread.new do
            until (raw_line = std_err.gets).nil? do
              stderr << raw_line
            end
          end

          if debug
            Thread.new do
              std_in.puts $stdin.gets while thread.alive?
            end
          end

          thread.join # don't exit until the external process is done
          status = thread.value
        end
      end
      raise CommandExecutionError.new(stdout, stderr) unless status == 0
      stdout
    end

    def self.exec!(*args)
      cmd = Shellwords.shelljoin(args.flatten)
      logger.debug "Exec'ing: #{cmd}, in: #{Dir.pwd}"
      Kernel.exec cmd
    end
  end
end
