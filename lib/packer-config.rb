# Encoding: utf-8
# Copyright 2014 Ian Chesal
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
require 'json'
require 'yaml'
require 'packer/dataobject'
require 'packer/builder'
require 'packer/provisioner'
require 'packer/postprocessor'

module Packer
  class Config < Packer::DataObject

    attr_accessor :builders
    attr_accessor :postprocessors
    attr_accessor :provisioners
    attr_reader   :output_file

    def initialize(file)
      super()
      self.data['variables'] = {}
      self.output_file = file
      self.builders = []
      self.provisioners = []
      self.postprocessors = []
    end

    def validate
      super
      if self.builders.length == 0
        raise DataValidationError.new("At least one builder is required")
      end
      self.builders.each do |thing|
        thing.validate
      end
      self.provisioners.each do |thing|
        thing.validate
      end
      self.postprocessors.each do |thing|
        thing.validate
      end
    end

    class DumpError < StandardError
    end

    def dump(format='json')
      data_copy = self.deep_copy
      data_copy['builders'] = []
      self.builders.each do |thing|
        data_copy['builders'].push(thing.deep_copy)
      end
      if self.provisioners.length > 0
        data_copy['provisioners'] = []
        self.provisioners.each do |thing|
          data_copy['provisioners'].push(thing.deep_copy)
        end
      end
      if self.postprocessors.length > 0
        data_copy['postprocessors'] = []
        self.postprocessors.each do |thing|
          data_copy['postprocessors'].push(thing.deep_copy)
        end
      end
      case format
      when 'json'
        data_copy.to_json
      when 'yaml', 'yml'
        data_copy.to_yaml
      else
        raise DumpError.new("Unrecognized format #{format} use one of ['json', 'yaml']")
      end
    end

    def write(format='json')
      File.write(self.output_file, self.dump(format))
    end

    def description(description)
      self.__add_string('description', description)
    end

    def min_packer_version(version)
      self.__add_string('min_packer_version', version)
    end

    def variables
      self.data['variables']
    end

    def add_builder(type)
      builder = Packer::Builder.get_builder(type)
      self.builders.append(builder)
      builder
    end

    def add_provisioner(type)
      provisioner = Packer::Provisioner.get_provisioner(type)
      self.provisioners.append(provisioner)
      provisioner
    end

    def add_postprocessor(type)
      postprocessor = Packer::PostProcessor.get_postprocessor(type)
      self.postprocessors.append(postprocessor)
      postprocessor
    end

    def add_variable(name, value)
      variables_copy = Marshal.load(Marshal.dump(self.variables))
      variables_copy[name.to_s] = value.to_s
      self.__add_hash('variables', variables_copy)
    end

    class UndefinedVariableError < StandardError
    end

    def variable(name)
      unless self.variables.has_key? name
        raise UndefinedVariableError.new("No variable named #{name} has been defined -- did you forget to call add_variable?")
      end
      "{{user `#{name}`}}"
    end

    def envvar(name)
      "{{env `#{name}`}}"
    end

    def macro(name)
      "{{ .#{name} }}"
    end

    private
    attr_writer :output_file

  end
end
