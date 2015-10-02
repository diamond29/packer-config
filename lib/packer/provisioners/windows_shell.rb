# Encoding: utf-8
require 'packer/provisioner'
require 'packer/dataobject'

module Packer
  class Provisioner < Packer::DataObject
    class WindowsShell < Provisioner
      def initialize
        super
        self.data['type'] = WINDOWS_SHELL
        self.add_required(['inline', 'script', 'scripts'])
      end

      def inline(commands)
        self.__add_array_of_strings('inline', commands, %w[script scripts])
      end

      def script(filename)
        self.__add_string('script', filename, %w[inline scripts])
      end

      def scripts(filenames)
        self.__add_array_of_strings('scripts', filenames, %w[inline script])
      end

      def binary(bool)
        self.__add_boolean('binary', bool, [])
      end

      def execute_command(command)
        self.__add_string('execute_command', command)
      end

      def remote_path(command)
        self.__add_string('remote_path', command)
      end

      def start_retry_timeout(time)
        self.__add_string('start_retry_timeout', string)
      end
    end
  end
end
